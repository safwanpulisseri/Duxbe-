-- FUNCTION: public.create_sale(jsonb)

-- DROP FUNCTION IF EXISTS public.create_sale(jsonb);

-- Add tax_amount column to sale_items table
ALTER TABLE public.sale_items ADD COLUMN IF NOT EXISTS tax_amount NUMERIC DEFAULT 0;

CREATE OR REPLACE FUNCTION public.create_sale(
	p_sale_json jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_sale_json->>'business_id')::uuid;
    v_org_id              UUID := (p_sale_json->>'org_id')::uuid; 
    v_customer_id         UUID := (p_sale_json->>'customer_id')::uuid;
    v_sale_date           TIMESTAMPTZ := COALESCE((p_sale_json->>'sale_date')::timestamptz, now());
    v_notes               TEXT := p_sale_json->>'notes';
    v_attachment_url      TEXT := p_sale_json->>'attachment';
    v_platform                TEXT := COALESCE(p_sale_json->>'platform', 'Duxbe');
    v_discount_amount     NUMERIC := COALESCE((p_sale_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_sale_json->>'shipping')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_sale_json->>'paid_amount')::numeric, 0);
    v_sale_items_json     JSONB := p_sale_json->'sale_items'; 
    v_payment_details     JSONB := p_sale_json->'payment_details';
    v_order_mode          BOOLEAN := COALESCE((p_sale_json->>'order_mode')::boolean, false);
    v_acting_user_id      UUID := COALESCE((p_sale_json->>'employee_id')::uuid, auth.uid());
    v_table_id UUID := (p_sale_json->>'table_id')::uuid;
    v_billing_address     json := (p_sale_json->>'billing_address')::json; -- Nullable
    v_shipping_address    json := (p_sale_json->>'shipping_address')::json; -- Nullable

    -- Internal Calculated Totals
    v_calc_subtotal_goods   NUMERIC := 0; 
    v_calc_subtotal_services NUMERIC := 0; 
    v_calc_tax_total      NUMERIC := 0;
    v_calc_grand_total    NUMERIC := 0;
    v_calculated_due_amount NUMERIC;

    -- Internal Vars
    v_transaction_id      UUID;
    v_sale_id             UUID;
    v_status_id           UUID;
    v_gen_reference_no    TEXT;
    v_status              public.transaction_status;
    v_sale_item_loop_data RECORD; 
    v_subservice_loop_data RECORD;
    v_payment_method      TEXT;
    v_payment_amount      NUMERIC;
    
    -- Account IDs & Codes (COA v6.4)
    v_ar_acc_id                 UUID; 
    v_sales_products_acc_id     UUID; 
    v_sales_services_acc_id     UUID; 
    v_sales_tax_payable_acc_id  UUID; 
    v_shipping_revenue_acc_id   UUID; 
    v_inventory_acc_id          UUID; 
    v_cogs_products_acc_id      UUID; 
    v_cash_in_bank_acc_id       UUID; 
    v_petty_cash_acc_id         UUID; 
    v_sales_discount_acc_id     UUID; 

    -- COA v6.4 Codes as per your request
    v_ar_code                   TEXT := '1120';
    v_sales_products_code       TEXT := '4110';
    v_sales_services_code       TEXT := '4120';
    v_sales_tax_payable_code    TEXT := '2120';
    v_shipping_revenue_code     TEXT := '4210';
    v_inventory_code            TEXT := '1130';
    v_cogs_products_code        TEXT := '5110';
    v_cash_in_bank_code         TEXT := '1111';
    v_petty_cash_code           TEXT := '1113';
    v_sales_discount_code       TEXT := '4800';

BEGIN
    RAISE LOG 'create_sale: Start. Biz:%, Org:%, Cust:%', v_business_id, v_org_id, v_customer_id;

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_sale_items_json IS NULL OR jsonb_array_length(v_sale_items_json) = 0 THEN
        RAISE EXCEPTION 'business_id, org_id, and at least one sale_item are required.';
    END IF;
    IF v_sale_date IS NULL THEN v_sale_date := now(); END IF;

    SELECT s.status_id INTO v_status_id FROM public.statuses s
    WHERE s.business_id = v_business_id AND s.is_default = true AND s.type = 'sale'::public.status_type LIMIT 1;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Default sale status not found for Business:%, Org:%', v_business_id, v_org_id;
    END IF;

    -- Fetch Account IDs (using COA v6.4 codes)
    SELECT account_id INTO v_ar_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_ar_code AND is_group=FALSE;
    IF v_ar_acc_id IS NULL THEN RAISE EXCEPTION 'Accounts Receivable account (%s) not found. Biz:%, Org:%', v_ar_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_products_code AND is_group=FALSE;
    IF v_sales_products_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Products account (%s) not found. Biz:%, Org:%', v_sales_products_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_services_code AND is_group=FALSE;
    IF v_sales_services_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Services account (%s) not found. Biz:%, Org:%', v_sales_services_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_tax_payable_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_tax_payable_code AND is_group=FALSE;
    IF v_sales_tax_payable_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Tax Payable account (%s) not found. Biz:%, Org:%', v_sales_tax_payable_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_inventory_code AND is_group=FALSE;
    IF v_inventory_acc_id IS NULL THEN RAISE EXCEPTION 'Inventory account (%s) not found. Biz:%, Org:%', v_inventory_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    IF v_cogs_products_acc_id IS NULL THEN RAISE EXCEPTION 'COGS Products account (%s) not found. Biz:%, Org:%', v_cogs_products_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_cash_in_bank_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cash_in_bank_code AND is_group=FALSE;
    IF v_cash_in_bank_acc_id IS NULL THEN RAISE EXCEPTION 'Cash in Bank account (%s) not found. Biz:%, Org:%', v_cash_in_bank_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_petty_cash_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_petty_cash_code AND is_group=FALSE;
    IF v_petty_cash_acc_id IS NULL THEN RAISE EXCEPTION 'Petty Cash account (%s) not found. Biz:%, Org:%', v_petty_cash_code, v_business_id, v_org_id; END IF;

    -- Optional accounts (only required if their respective amounts are > 0)
    IF v_shipping_charge > 0 THEN
        SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
        IF v_shipping_revenue_acc_id IS NULL THEN RAISE EXCEPTION 'Shipping Revenue account (%s) not found. Biz:%, Org:%', v_shipping_revenue_code, v_business_id, v_org_id; END IF;
    END IF;

    IF v_discount_amount > 0 THEN
        SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_discount_code AND is_group=FALSE;
        IF v_sales_discount_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Discount account (%s) not found. Biz:%, Org:%', v_sales_discount_code, v_business_id, v_org_id; END IF;
    END IF;

    -- Verify all required accounts are found
    IF v_ar_acc_id IS NULL OR v_sales_products_acc_id IS NULL OR v_sales_services_acc_id IS NULL OR 
       v_sales_tax_payable_acc_id IS NULL OR v_inventory_acc_id IS NULL OR v_cogs_products_acc_id IS NULL OR 
       v_cash_in_bank_acc_id IS NULL OR v_petty_cash_acc_id IS NULL THEN
        RAISE EXCEPTION 'One or more required accounts not found for Business:%, Org:%. Please check COA setup.', v_business_id, v_org_id;
    END IF;

    SELECT public.get_next_sale_code(v_business_id) INTO v_gen_reference_no;

    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status, total_amount, paid_amount, due_amount,
        notes, business_id, org_id, created_by, updated_by, customer_id
    ) VALUES (
        v_gen_reference_no, 'SALE'::public.transaction_type, v_sale_date, 'PENDING'::public.transaction_status, 0, 0, 0,
        v_notes, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_customer_id
    ) RETURNING transaction_id INTO v_transaction_id;
    RAISE LOG 'create_sale: Initial Transaction ID created: %', v_transaction_id;

    INSERT INTO public.sales (
        sale_id, customer_id, sale_date, transaction_id, subtotal, discount_amount, tax_amount, shipping_charge, total_amount,
        paid_amount, due_amount, business_id, created_by, updated_by, notes, platform, attachment_url, sale_invoice, status_id, order_mode, metadata, table_id,billing_address, shipping_address
    ) VALUES (
        gen_random_uuid(), v_customer_id, v_sale_date, v_transaction_id, 0,v_discount_amount,0,v_shipping_charge,0,0,0, 
        v_business_id, v_acting_user_id, v_acting_user_id, v_notes, v_platform, v_attachment_url, v_gen_reference_no, v_status_id, v_order_mode, p_sale_json->'metadata',v_table_id,v_billing_address, v_shipping_address
    ) RETURNING sales.sale_id INTO v_sale_id;
    RAISE LOG 'create_sale: Initial Sale ID created: %', v_sale_id;

    -- Loop: Calculate totals, Insert Sale Items, Subservices, Update Inventory, and Create Item-Specific GL Entries
    FOR v_sale_item_loop_data IN
        SELECT
            x.item_id, x.quantity, x.unit_price, x.subservices,
            i.item_type, i.inventory_enabled, COALESCE(i.purchase_price, 0) as item_cost,
            i.name as item_name, i.tax_id,
            COALESCE(i.is_tax_inclusive, FALSE) as is_tax_inclusive 
        FROM jsonb_to_recordset(v_sale_items_json)
            AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id
    LOOP
        DECLARE
            v_item_id               UUID := v_sale_item_loop_data.item_id;
            v_quantity              NUMERIC := v_sale_item_loop_data.quantity;
            v_unit_price_input      NUMERIC := v_sale_item_loop_data.unit_price; 
            v_item_type             public.item_type := v_sale_item_loop_data.item_type;
            v_inventory_enabled     BOOLEAN := v_sale_item_loop_data.inventory_enabled;
            v_item_cost             NUMERIC := v_sale_item_loop_data.item_cost;
            v_item_name             TEXT := v_sale_item_loop_data.item_name;
            v_item_tax_id           UUID := v_sale_item_loop_data.tax_id;
            v_is_tax_inclusive_item BOOLEAN := v_sale_item_loop_data.is_tax_inclusive;

            v_line_net_subtotal_item NUMERIC; 
            v_line_tax_item          NUMERIC := 0;
            v_tax_rate               DOUBLE PRECISION := 0;
            v_current_sale_item_id   UUID;
        BEGIN
            RAISE LOG 'create_sale: Item ID:%, Name:%, Qty:%, InputPrice:%, Inclusive?:%', 
                v_item_id, v_item_name, v_quantity, v_unit_price_input, v_is_tax_inclusive_item;

            INSERT INTO public.sale_items (sale_item_id, sale_id, item_id, quantity, unit_price, created_by, updated_by, created_at, updated_at)
            VALUES (gen_random_uuid(), v_sale_id, v_item_id, v_quantity, v_unit_price_input, v_acting_user_id, v_acting_user_id, now(), now())
            RETURNING sale_items.sale_item_id INTO v_current_sale_item_id;

            IF v_item_tax_id IS NOT NULL THEN
                SELECT COALESCE(t.rate, 0) INTO v_tax_rate FROM public.taxes t
                WHERE t.tax_id = v_item_tax_id AND t.business_id = v_business_id;
            END IF;

            -- Calculate tax based on whether it's inclusive or exclusive
            IF v_is_tax_inclusive_item AND v_tax_rate > 0 THEN
                -- For tax inclusive: tax = total * (rate / (100 + rate))
                v_line_tax_item := ROUND((v_unit_price_input * v_quantity)::numeric * (v_tax_rate::numeric / (100 + v_tax_rate)::numeric), 2);
                v_line_net_subtotal_item := (v_unit_price_input * v_quantity) - v_line_tax_item;
            ELSE
                -- For tax exclusive: tax = total * (rate / 100)
                v_line_net_subtotal_item := v_unit_price_input * v_quantity;
                v_line_tax_item := ROUND(v_line_net_subtotal_item::numeric * (v_tax_rate::numeric / 100), 2);
            END IF;
            
            v_calc_tax_total := v_calc_tax_total + v_line_tax_item;

            -- Update sale_items with tax amount
            UPDATE public.sale_items 
            SET tax_amount = v_line_tax_item,
                updated_at = now(),
                updated_by = v_acting_user_id
            WHERE sale_item_id = v_current_sale_item_id;

            IF v_item_type = 'goods'::public.item_type THEN
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_net_subtotal_item;
                IF v_inventory_enabled THEN
                    DECLARE v_cogs_for_item NUMERIC := v_quantity * v_item_cost;
                    BEGIN
                        IF v_cogs_for_item > 0 THEN
                            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES 
                                (v_transaction_id, v_cogs_products_acc_id, 'DEBIT'::public.entry_type, v_cogs_for_item, 'COGS: ' || v_item_name, v_acting_user_id, v_acting_user_id),
                                (v_transaction_id, v_inventory_acc_id, 'CREDIT'::public.entry_type, v_cogs_for_item, 'Inventory Sold: ' || v_item_name, v_acting_user_id, v_acting_user_id);
                        END IF;
                        UPDATE public.items SET stock_quantity = items.stock_quantity - v_quantity, updated_at = now(), updated_by = v_acting_user_id
                        WHERE items.item_id = v_item_id;
                    END;
                END IF;
            ELSIF v_item_type = 'services'::public.item_type THEN 
                v_calc_subtotal_services := v_calc_subtotal_services + v_line_net_subtotal_item;
            ELSE 
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_net_subtotal_item; 
            END IF;

            IF v_item_type = 'services'::public.item_type AND v_sale_item_loop_data.subservices IS NOT NULL AND jsonb_array_length(v_sale_item_loop_data.subservices) > 0 THEN
                FOR v_subservice_loop_data IN
                    SELECT (x->>'sub_service_id')::uuid as sub_service_id, COALESCE((x->>'quantity')::numeric, 1) as quantity,
                           COALESCE((x->>'additional_price')::numeric, 0) as additional_price, ss.name as sub_service_name
                    FROM jsonb_array_elements(v_sale_item_loop_data.subservices) x
                    LEFT JOIN public.subservices ss ON ss.sub_service_id = (x->>'sub_service_id')::uuid AND ss.service_id = v_item_id
                LOOP
                    DECLARE 
                        v_sub_line_net_total NUMERIC := v_subservice_loop_data.quantity * v_subservice_loop_data.additional_price;
                        v_sub_line_tax   NUMERIC;
                    BEGIN
                        -- Calculate tax for subservices using the same logic as main items
                        IF v_is_tax_inclusive_item AND v_tax_rate > 0 THEN
                            v_sub_line_tax := ROUND(v_sub_line_net_total::numeric * (v_tax_rate::numeric / (100 + v_tax_rate)::numeric), 2);
                            v_sub_line_net_total := v_sub_line_net_total - v_sub_line_tax;
                        ELSE
                            v_sub_line_tax := ROUND(v_sub_line_net_total::numeric * (v_tax_rate::numeric / 100), 2);
                        END IF;

                        v_calc_subtotal_services := v_calc_subtotal_services + v_sub_line_net_total;
                        v_calc_tax_total := v_calc_tax_total + v_sub_line_tax;
                        IF v_subservice_loop_data.sub_service_id IS NOT NULL THEN
                           INSERT INTO public.sale_item_subservices (sale_item_subservice_id, sale_item_id, sub_service_id, quantity, additional_price, created_by, updated_by, created_at, updated_at)
                           VALUES (gen_random_uuid(), v_current_sale_item_id, v_subservice_loop_data.sub_service_id, v_subservice_loop_data.quantity, v_subservice_loop_data.additional_price, v_acting_user_id, v_acting_user_id, now(), now());
                        END IF;
                    END;
                END LOOP;
            END IF;
        END;
    END LOOP;

    v_calc_grand_total := ROUND(v_calc_subtotal_goods + v_calc_subtotal_services - v_discount_amount + v_shipping_charge + v_calc_tax_total, 2);
    v_calculated_due_amount := v_calc_grand_total - v_paid_amount;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_calc_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
        IF v_customer_id IS NOT NULL THEN v_calculated_due_amount := 0; END IF;
    ELSIF v_paid_amount > 0 THEN v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE v_status := 'PENDING'::public.transaction_status; END IF;

    UPDATE public.transactions SET
        total_amount = v_calc_grand_total, paid_amount = v_paid_amount, due_amount = v_calculated_due_amount, status = v_status, updated_at = now(), updated_by = v_acting_user_id
    WHERE transaction_id = v_transaction_id;

    UPDATE public.sales SET
        subtotal = ROUND(v_calc_subtotal_goods + v_calc_subtotal_services, 2), 
        tax_amount = ROUND(v_calc_tax_total, 2), 
        total_amount = v_calc_grand_total,
        paid_amount = v_paid_amount, 
        due_amount = v_calculated_due_amount, 
        -- status_id = v_status_id, -- Status in transactions table drives this for reporting
        updated_at = now(), 
        updated_by = v_acting_user_id
    WHERE sale_id = v_sale_id;

    -- Create Summary GL Entries
    IF v_calc_subtotal_goods > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_sales_products_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_subtotal_goods,2), 'Sales Revenue - Products',v_acting_user_id,v_acting_user_id); END IF;
    IF v_calc_subtotal_services > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_sales_services_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_subtotal_services,2), 'Sales Revenue - Services',v_acting_user_id,v_acting_user_id); END IF;
    IF v_shipping_charge > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_shipping_revenue_acc_id, 'CREDIT'::public.entry_type, v_shipping_charge, 'Shipping & Handling Revenue',v_acting_user_id,v_acting_user_id); END IF;
    IF v_calc_tax_total > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_sales_tax_payable_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_tax_total,2), 'Sales Tax Payable',v_acting_user_id,v_acting_user_id); END IF;
    IF v_discount_amount > 0 THEN
         INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_sales_discount_acc_id, 'DEBIT'::public.entry_type, v_discount_amount, 'Sales Discount',v_acting_user_id,v_acting_user_id); END IF;
    
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES (v_transaction_id, v_ar_acc_id, 'DEBIT'::public.entry_type, v_calc_grand_total, 'Accounts Receivable for Sale ' || v_gen_reference_no,v_acting_user_id,v_acting_user_id);

    -- Process Immediate Payment
    IF v_paid_amount > 0 AND v_payment_details IS NOT NULL THEN
        DECLARE 
            v_total_payment_processed NUMERIC := 0;
            v_payment_method TEXT;
            v_payment_amount NUMERIC;
        BEGIN
            FOR v_payment_method, v_payment_amount IN 
                SELECT key, value::text::numeric 
                FROM jsonb_each_text(v_payment_details) 
                WHERE value::text::numeric > 0
            LOOP
                DECLARE v_payment_asset_account_id UUID;
                BEGIN
                    v_total_payment_processed := v_total_payment_processed + v_payment_amount;
                    IF lower(v_payment_method) = 'cash' THEN 
                        v_payment_asset_account_id := v_petty_cash_acc_id;
                    ELSE 
                        v_payment_asset_account_id := v_cash_in_bank_acc_id;
                    END IF;

                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES 
                        (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_gen_reference_no, v_acting_user_id, v_acting_user_id),
                        (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_gen_reference_no, v_acting_user_id, v_acting_user_id);

                    INSERT INTO public.payments (payment_id, transaction_id, payment_date, amount, payment_method, reference_no, created_by, updated_by)
                    VALUES (gen_random_uuid(), v_transaction_id, v_sale_date, v_payment_amount, v_payment_method, v_gen_reference_no, v_acting_user_id, v_acting_user_id);
                END;
            END LOOP;
            
            IF abs(v_total_payment_processed - v_paid_amount) > 0.01 THEN
                RAISE WARNING 'create_sale: Sum of payment_details (%) != input paid_amount (%) for Sale %', v_total_payment_processed, v_paid_amount, v_gen_reference_no;
            END IF;
        END;
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_sale: Completed. TxnID:%, SaleID:%', v_transaction_id, v_sale_id;
        PERFORM nextval(v_business_id::text || '_sale_invoice');

    RETURN (SELECT row_to_json(sv) FROM public.sale_view sv WHERE sv.sale_id = v_sale_id);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create sale: Unique constraint violated. Ref No "%s". Detail: %s', v_gen_reference_no, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create sale. Biz:%, Org:%. Error: %s. SQLState: %s. Input: %s', v_business_id, v_org_id, SQLERRM, SQLSTATE, p_sale_json;
END;
$BODY$;

ALTER FUNCTION public.create_sale(jsonb)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.create_sale(jsonb) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.create_sale(jsonb) TO anon;

GRANT EXECUTE ON FUNCTION public.create_sale(jsonb) TO authenticated;

GRANT EXECUTE ON FUNCTION public.create_sale(jsonb) TO postgres;

GRANT EXECUTE ON FUNCTION public.create_sale(jsonb) TO service_role;




CREATE OR REPLACE FUNCTION public.update_sale(
	p_sale_json jsonb)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_sale_json->>'business_id')::uuid;
    v_org_id              UUID := (p_sale_json->>'org_id')::uuid; 
    v_customer_id         UUID := (p_sale_json->>'customer_id')::uuid;
    v_sale_id             UUID := (p_sale_json->>'sale_id')::uuid;
    v_sale_date           TIMESTAMPTZ := COALESCE((p_sale_json->>'sale_date')::timestamptz, now());
    v_notes               TEXT := p_sale_json->>'notes';
    v_attachment_url      TEXT := p_sale_json->>'attachment';
    v_platform            TEXT := COALESCE(p_sale_json->>'platform', 'Duxbe');
    v_discount_amount     NUMERIC := COALESCE((p_sale_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_sale_json->>'shipping')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_sale_json->>'paid_amount')::numeric, 0);
    v_sale_items_json     JSONB := p_sale_json->'sale_items'; 
    v_payment_details     JSONB := p_sale_json->'payment_details';
    v_order_mode          BOOLEAN := COALESCE((p_sale_json->>'order_mode')::boolean, false);
    v_acting_user_id      UUID := COALESCE((p_sale_json->>'employee_id')::uuid, auth.uid());
    v_table_id            UUID := (p_sale_json->>'table_id')::uuid;
    v_billing_address     json := (p_sale_json->>'billing_address')::json;
    v_shipping_address    json := (p_sale_json->>'shipping_address')::json;

    -- Internal Calculated Totals
    v_calc_subtotal_goods   NUMERIC := 0; 
    v_calc_subtotal_services NUMERIC := 0; 
    v_calc_tax_total      NUMERIC := 0;
    v_calc_grand_total    NUMERIC := 0;
    v_calculated_due_amount NUMERIC;

    -- Internal Vars
    v_transaction_id      UUID;
    v_status_id           UUID;
    v_status              public.transaction_status;
    v_sale_item_loop_data RECORD; 
    v_subservice_loop_data RECORD;
    v_existing_sale       RECORD;
    v_old_sale_item       RECORD;
    v_sale_item_id        UUID;
    v_tax_rate            DOUBLE PRECISION;
    v_is_tax_inclusive    BOOLEAN;
    
    -- Account IDs & Codes (COA v6.4)
    v_ar_acc_id                 UUID; 
    v_sales_products_acc_id     UUID; 
    v_sales_services_acc_id     UUID; 
    v_sales_tax_payable_acc_id  UUID; 
    v_shipping_revenue_acc_id   UUID; 
    v_inventory_acc_id          UUID; 
    v_cogs_products_acc_id      UUID; 
    v_cash_in_bank_acc_id       UUID; 
    v_petty_cash_acc_id         UUID; 
    v_sales_discount_acc_id     UUID; 

    -- COA v6.4 Codes
    v_ar_code                   TEXT := '1120';
    v_sales_products_code       TEXT := '4110';
    v_sales_services_code       TEXT := '4120';
    v_sales_tax_payable_code    TEXT := '2120';
    v_shipping_revenue_code     TEXT := '4210';
    v_inventory_code            TEXT := '1130';
    v_cogs_products_code        TEXT := '5110';
    v_cash_in_bank_code         TEXT := '1111';
    v_petty_cash_code           TEXT := '1113';
    v_sales_discount_code       TEXT := '4800';

BEGIN
    -- Get existing sale information
    SELECT s.*, t.transaction_id, t.paid_amount, t.reference_no
    INTO v_existing_sale
    FROM sales s
    JOIN transactions t ON t.transaction_id = s.transaction_id
    WHERE s.sale_id = v_sale_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found';
    END IF;
    
    v_transaction_id := v_existing_sale.transaction_id;

    -- Fetch Account IDs (using COA v6.4 codes)
    SELECT account_id INTO v_ar_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_ar_code AND is_group=FALSE;
    IF v_ar_acc_id IS NULL THEN RAISE EXCEPTION 'Accounts Receivable account (%s) not found. Biz:%, Org:%', v_ar_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_products_code AND is_group=FALSE;
    IF v_sales_products_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Products account (%s) not found. Biz:%, Org:%', v_sales_products_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_services_code AND is_group=FALSE;
    IF v_sales_services_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Services account (%s) not found. Biz:%, Org:%', v_sales_services_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_sales_tax_payable_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_tax_payable_code AND is_group=FALSE;
    IF v_sales_tax_payable_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Tax Payable account (%s) not found. Biz:%, Org:%', v_sales_tax_payable_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_inventory_code AND is_group=FALSE;
    IF v_inventory_acc_id IS NULL THEN RAISE EXCEPTION 'Inventory account (%s) not found. Biz:%, Org:%', v_inventory_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    IF v_cogs_products_acc_id IS NULL THEN RAISE EXCEPTION 'COGS Products account (%s) not found. Biz:%, Org:%', v_cogs_products_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_cash_in_bank_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cash_in_bank_code AND is_group=FALSE;
    IF v_cash_in_bank_acc_id IS NULL THEN RAISE EXCEPTION 'Cash in Bank account (%s) not found. Biz:%, Org:%', v_cash_in_bank_code, v_business_id, v_org_id; END IF;

    SELECT account_id INTO v_petty_cash_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_petty_cash_code AND is_group=FALSE;
    IF v_petty_cash_acc_id IS NULL THEN RAISE EXCEPTION 'Petty Cash account (%s) not found. Biz:%, Org:%', v_petty_cash_code, v_business_id, v_org_id; END IF;

    -- Optional accounts (only required if their respective amounts are > 0)
    IF v_shipping_charge > 0 THEN
        SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
        IF v_shipping_revenue_acc_id IS NULL THEN RAISE EXCEPTION 'Shipping Revenue account (%s) not found. Biz:%, Org:%', v_shipping_revenue_code, v_business_id, v_org_id; END IF;
    END IF;

    IF v_discount_amount > 0 THEN
        SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_discount_code AND is_group=FALSE;
        IF v_sales_discount_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Discount account (%s) not found. Biz:%, Org:%', v_sales_discount_code, v_business_id, v_org_id; END IF;
    END IF;

    -- Verify all required accounts are found
    IF v_ar_acc_id IS NULL OR v_sales_products_acc_id IS NULL OR v_sales_services_acc_id IS NULL OR 
       v_sales_tax_payable_acc_id IS NULL OR v_inventory_acc_id IS NULL OR v_cogs_products_acc_id IS NULL OR 
       v_cash_in_bank_acc_id IS NULL OR v_petty_cash_acc_id IS NULL THEN
        RAISE EXCEPTION 'One or more required accounts not found for Business:%, Org:%. Please check COA setup.', v_business_id, v_org_id;
    END IF;

    -- Revert inventory changes for existing sale items
    FOR v_old_sale_item IN 
        SELECT si.*, i.item_type, i.inventory_enabled, i.purchase_price
        FROM sale_items si
        JOIN items i ON i.item_id = si.item_id
        WHERE si.sale_id = v_sale_id
    LOOP
        IF v_old_sale_item.item_type = 'goods' AND v_old_sale_item.inventory_enabled THEN
            UPDATE items
            SET 
                stock_quantity = stock_quantity + v_old_sale_item.quantity,
                updated_at = now(),
                updated_by = v_acting_user_id
            WHERE item_id = v_old_sale_item.item_id;
        END IF;
    END LOOP;

    -- Delete existing sale items and subservices
    DELETE FROM sale_item_subservices 
    WHERE sale_item_id IN (SELECT sale_item_id FROM sale_items WHERE sale_id = v_sale_id);
    DELETE FROM sale_items WHERE sale_id = v_sale_id;

    -- Delete existing transaction entries
    DELETE FROM transaction_entries WHERE transaction_id = v_transaction_id;

    -- Loop: Calculate totals, Insert Sale Items, Subservices, Update Inventory, and Create Item-Specific GL Entries
    FOR v_sale_item_loop_data IN
        SELECT
            x.item_id, x.quantity, x.unit_price, x.subservices,
            i.item_type, i.inventory_enabled, COALESCE(i.purchase_price, 0) as item_cost,
            i.name as item_name, i.tax_id,
            COALESCE(i.is_tax_inclusive, FALSE) as is_tax_inclusive 
        FROM jsonb_to_recordset(v_sale_items_json)
            AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id
    LOOP
        DECLARE
            v_item_id               UUID := v_sale_item_loop_data.item_id;
            v_quantity              NUMERIC := v_sale_item_loop_data.quantity;
            v_unit_price_input      NUMERIC := v_sale_item_loop_data.unit_price; 
            v_item_type             public.item_type := v_sale_item_loop_data.item_type;
            v_inventory_enabled     BOOLEAN := v_sale_item_loop_data.inventory_enabled;
            v_item_cost             NUMERIC := v_sale_item_loop_data.item_cost;
            v_item_name             TEXT := v_sale_item_loop_data.item_name;
            v_item_tax_id           UUID := v_sale_item_loop_data.tax_id;
            v_is_tax_inclusive_item BOOLEAN := v_sale_item_loop_data.is_tax_inclusive;

            v_line_net_subtotal_item NUMERIC; 
            v_line_tax_item          NUMERIC := 0;
            v_tax_rate               DOUBLE PRECISION := 0;
            v_current_sale_item_id   UUID;
        BEGIN
            INSERT INTO public.sale_items (
                sale_item_id, sale_id, item_id, quantity, unit_price, created_by, updated_by, created_at, updated_at
            ) VALUES (
                gen_random_uuid(), v_sale_id, v_item_id, v_quantity, v_unit_price_input, v_acting_user_id, v_acting_user_id, now(), now()
            ) RETURNING sale_items.sale_item_id INTO v_current_sale_item_id;

            IF v_item_tax_id IS NOT NULL THEN
                SELECT COALESCE(t.rate, 0) INTO v_tax_rate FROM public.taxes t
                WHERE t.tax_id = v_item_tax_id AND t.business_id = v_business_id;
            END IF;

            -- Calculate tax based on whether it's inclusive or exclusive
            IF v_is_tax_inclusive_item AND v_tax_rate > 0 THEN
                -- For tax inclusive: tax = total * (rate / (100 + rate))
                v_line_tax_item := ROUND((v_unit_price_input * v_quantity)::numeric * (v_tax_rate::numeric / (100 + v_tax_rate)::numeric), 2);
                v_line_net_subtotal_item := (v_unit_price_input * v_quantity) - v_line_tax_item;
            ELSE
                -- For tax exclusive: tax = total * (rate / 100)
                v_line_net_subtotal_item := v_unit_price_input * v_quantity;
                v_line_tax_item := ROUND(v_line_net_subtotal_item::numeric * (v_tax_rate::numeric / 100), 2);
            END IF;
            
            v_calc_tax_total := v_calc_tax_total + v_line_tax_item;

            -- Update sale_items with tax amount
            UPDATE public.sale_items 
            SET tax_amount = v_line_tax_item,
                updated_at = now(),
                updated_by = v_acting_user_id
            WHERE sale_item_id = v_current_sale_item_id;

            IF v_item_type = 'goods'::public.item_type THEN
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_net_subtotal_item;
                IF v_inventory_enabled THEN
                    DECLARE v_cogs_for_item NUMERIC := v_quantity * v_item_cost;
                    BEGIN
                        IF v_cogs_for_item > 0 THEN
                            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES 
                                (v_transaction_id, v_cogs_products_acc_id, 'DEBIT'::public.entry_type, v_cogs_for_item, 'COGS: ' || v_item_name, v_acting_user_id, v_acting_user_id),
                                (v_transaction_id, v_inventory_acc_id, 'CREDIT'::public.entry_type, v_cogs_for_item, 'Inventory Sold: ' || v_item_name, v_acting_user_id, v_acting_user_id);
                        END IF;
                        UPDATE public.items SET 
                            stock_quantity = items.stock_quantity - v_quantity, 
                            updated_at = now(), 
                            updated_by = v_acting_user_id
                        WHERE items.item_id = v_item_id;
                    END;
                END IF;
            ELSIF v_item_type = 'services'::public.item_type THEN 
                v_calc_subtotal_services := v_calc_subtotal_services + v_line_net_subtotal_item;
            ELSE 
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_net_subtotal_item; 
            END IF;

            IF v_item_type = 'services'::public.item_type AND v_sale_item_loop_data.subservices IS NOT NULL AND jsonb_array_length(v_sale_item_loop_data.subservices) > 0 THEN
                FOR v_subservice_loop_data IN
                    SELECT (x->>'sub_service_id')::uuid as sub_service_id, COALESCE((x->>'quantity')::numeric, 1) as quantity,
                           COALESCE((x->>'additional_price')::numeric, 0) as additional_price, ss.name as sub_service_name
                    FROM jsonb_array_elements(v_sale_item_loop_data.subservices) x
                    LEFT JOIN public.subservices ss ON ss.sub_service_id = (x->>'sub_service_id')::uuid AND ss.service_id = v_item_id
                LOOP
                    DECLARE 
                        v_sub_line_net_total NUMERIC := v_subservice_loop_data.quantity * v_subservice_loop_data.additional_price;
                        v_sub_line_tax   NUMERIC;
                    BEGIN
                        -- Calculate tax for subservices using the same logic as main items
                        IF v_is_tax_inclusive_item AND v_tax_rate > 0 THEN
                            v_sub_line_tax := ROUND(v_sub_line_net_total::numeric * (v_tax_rate::numeric / (100 + v_tax_rate)::numeric), 2);
                            v_sub_line_net_total := v_sub_line_net_total - v_sub_line_tax;
                        ELSE
                            v_sub_line_tax := ROUND(v_sub_line_net_total::numeric * (v_tax_rate::numeric / 100), 2);
                        END IF;

                        v_calc_subtotal_services := v_calc_subtotal_services + v_sub_line_net_total;
                        v_calc_tax_total := v_calc_tax_total + v_sub_line_tax;

                        IF v_subservice_loop_data.sub_service_id IS NOT NULL THEN
                           INSERT INTO public.sale_item_subservices (
                               sale_item_subservice_id, sale_item_id, sub_service_id, quantity, additional_price, created_by, updated_by, created_at, updated_at
                           ) VALUES (
                               gen_random_uuid(), v_current_sale_item_id, v_subservice_loop_data.sub_service_id, v_subservice_loop_data.quantity, v_subservice_loop_data.additional_price, v_acting_user_id, v_acting_user_id, now(), now()
                           );
                        END IF;
                    END;
                END LOOP;
            END IF;
        END;
    END LOOP;

    v_calc_grand_total := ROUND(v_calc_subtotal_goods + v_calc_subtotal_services - v_discount_amount + v_shipping_charge + v_calc_tax_total, 2);
    v_calculated_due_amount := v_calc_grand_total - v_paid_amount;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_calc_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
        IF v_customer_id IS NOT NULL THEN v_calculated_due_amount := 0; END IF;
    ELSIF v_paid_amount > 0 THEN v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE v_status := 'PENDING'::public.transaction_status; END IF;

    -- Update transaction
    UPDATE public.transactions SET
        total_amount = v_calc_grand_total,
        paid_amount = v_paid_amount,
        due_amount = v_calculated_due_amount,
        status = v_status,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE transaction_id = v_transaction_id;

    -- Update sale record
    UPDATE public.sales SET
        subtotal = ROUND(v_calc_subtotal_goods + v_calc_subtotal_services, 2),
        tax_amount = ROUND(v_calc_tax_total, 2),
        total_amount = v_calc_grand_total,
        paid_amount = v_paid_amount,
        due_amount = v_calculated_due_amount,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE sale_id = v_sale_id;

    -- Create Summary GL Entries
    IF v_calc_subtotal_goods > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
        VALUES (v_transaction_id, v_sales_products_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_subtotal_goods,2), 'Sales Revenue - Products', v_acting_user_id, v_acting_user_id);
    END IF;
    
    IF v_calc_subtotal_services > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
        VALUES (v_transaction_id, v_sales_services_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_subtotal_services,2), 'Sales Revenue - Services', v_acting_user_id, v_acting_user_id);
    END IF;
    
    IF v_shipping_charge > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
        VALUES (v_transaction_id, v_shipping_revenue_acc_id, 'CREDIT'::public.entry_type, v_shipping_charge, 'Shipping & Handling Revenue', v_acting_user_id, v_acting_user_id);
    END IF;
    
    IF v_calc_tax_total > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
        VALUES (v_transaction_id, v_sales_tax_payable_acc_id, 'CREDIT'::public.entry_type, ROUND(v_calc_tax_total,2), 'Sales Tax Payable', v_acting_user_id, v_acting_user_id);
    END IF;
    
    IF v_discount_amount > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
        VALUES (v_transaction_id, v_sales_discount_acc_id, 'DEBIT'::public.entry_type, v_discount_amount, 'Sales Discount', v_acting_user_id, v_acting_user_id);
    END IF;
    
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) 
    VALUES (v_transaction_id, v_ar_acc_id, 'DEBIT'::public.entry_type, v_calc_grand_total, 'Accounts Receivable for Sale ' || v_existing_sale.reference_no, v_acting_user_id, v_acting_user_id);

    -- Process Immediate Payment
    IF v_paid_amount > 0 AND v_payment_details IS NOT NULL THEN
        DECLARE 
            v_total_payment_processed NUMERIC := 0;
            v_payment_method TEXT;
            v_payment_amount NUMERIC;
        BEGIN
            FOR v_payment_method, v_payment_amount IN 
                SELECT key, value::text::numeric 
                FROM jsonb_each_text(v_payment_details) 
                WHERE value::text::numeric > 0
            LOOP
                DECLARE v_payment_asset_account_id UUID;
                BEGIN
                    v_total_payment_processed := v_total_payment_processed + v_payment_amount;
                    IF lower(v_payment_method) = 'cash' THEN 
                        v_payment_asset_account_id := v_petty_cash_acc_id;
                    ELSE 
                        v_payment_asset_account_id := v_cash_in_bank_acc_id;
                    END IF;

                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES 
                        (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_existing_sale.reference_no, v_acting_user_id, v_acting_user_id),
                        (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_existing_sale.reference_no, v_acting_user_id, v_acting_user_id);

                    INSERT INTO public.payments (payment_id, transaction_id, payment_date, amount, payment_method, reference_no, created_by, updated_by)
                    VALUES (gen_random_uuid(), v_transaction_id, v_sale_date, v_payment_amount, v_payment_method, v_existing_sale.reference_no, v_acting_user_id, v_acting_user_id);
                END;
            END LOOP;
            
            IF abs(v_total_payment_processed - v_paid_amount) > 0.01 THEN
                RAISE WARNING 'update_sale: Sum of payment_details (%) != input paid_amount (%) for Sale %', v_total_payment_processed, v_paid_amount, v_existing_sale.reference_no;
            END IF;
        END;
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    
    RETURN (SELECT row_to_json(sv) FROM public.sale_view sv WHERE sv.sale_id = v_sale_id);

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error in update_sale: %', SQLERRM;
END;
$BODY$;

ALTER FUNCTION public.update_sale(jsonb)
    OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.update_sale(jsonb) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.update_sale(jsonb) TO anon;

GRANT EXECUTE ON FUNCTION public.update_sale(jsonb) TO authenticated;

GRANT EXECUTE ON FUNCTION public.update_sale(jsonb) TO postgres;

GRANT EXECUTE ON FUNCTION public.update_sale(jsonb) TO service_role;

