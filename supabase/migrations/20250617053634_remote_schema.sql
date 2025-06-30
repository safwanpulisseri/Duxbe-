

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."addon_type_enum" AS ENUM (
    'limit_increase',
    'feature_enable',
    'metered_quota'
);


ALTER TYPE "public"."addon_type_enum" OWNER TO "postgres";


CREATE TYPE "public"."billing_cycle_enum" AS ENUM (
    'monthly',
    'annually'
);


ALTER TYPE "public"."billing_cycle_enum" OWNER TO "postgres";


CREATE TYPE "public"."business_types" AS ENUM (
    'retail',
    'automotive',
    'foodAndBeverage',
    'others'
);


ALTER TYPE "public"."business_types" OWNER TO "postgres";


CREATE TYPE "public"."credit_note_status" AS ENUM (
    'open',
    'closed',
    'partially_used'
);


ALTER TYPE "public"."credit_note_status" OWNER TO "postgres";


CREATE TYPE "public"."custom_field_type" AS ENUM (
    'text'
);


ALTER TYPE "public"."custom_field_type" OWNER TO "postgres";


CREATE TYPE "public"."employee_type" AS ENUM (
    'admin',
    'staff',
    'customer'
);


ALTER TYPE "public"."employee_type" OWNER TO "postgres";


CREATE TYPE "public"."entry_type" AS ENUM (
    'CREDIT',
    'DEBIT'
);


ALTER TYPE "public"."entry_type" OWNER TO "postgres";


CREATE TYPE "public"."feature_type_enum" AS ENUM (
    'boolean',
    'limit',
    'metered'
);


ALTER TYPE "public"."feature_type_enum" OWNER TO "postgres";


CREATE TYPE "public"."invoice_status" AS ENUM (
    'DRAFT',
    'INVOICE'
);


ALTER TYPE "public"."invoice_status" OWNER TO "postgres";


CREATE TYPE "public"."invoice_status_enum" AS ENUM (
    'draft',
    'issued',
    'paid',
    'void',
    'partially_paid',
    'pending'
);


ALTER TYPE "public"."invoice_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."item_type" AS ENUM (
    'goods',
    'services'
);


ALTER TYPE "public"."item_type" OWNER TO "postgres";


CREATE TYPE "public"."payment_recieved" AS ENUM (
    'refund',
    'paid',
    'completed'
);


ALTER TYPE "public"."payment_recieved" OWNER TO "postgres";


CREATE TYPE "public"."payment_type" AS ENUM (
    'cash',
    'card',
    'bank'
);


ALTER TYPE "public"."payment_type" OWNER TO "postgres";


CREATE TYPE "public"."purchase_audit_action" AS ENUM (
    'CREATED',
    'UPDATED',
    'PAYMENT_ADDED',
    'STATUS_CHANGED',
    'CANCELED',
    'ITEM_ADDED',
    'ITEM_REMOVED',
    'ITEM_QUANTITY_CHANGED',
    'RETURN_CREATED'
);


ALTER TYPE "public"."purchase_audit_action" OWNER TO "postgres";


CREATE TYPE "public"."quote_status" AS ENUM (
    'DRAFT',
    'PAID',
    'DELETED'
);


ALTER TYPE "public"."quote_status" OWNER TO "postgres";


CREATE TYPE "public"."sale_audit_action" AS ENUM (
    'CREATED',
    'UPDATED',
    'PAYMENT_ADDED',
    'STATUS_CHANGED',
    'CANCELED',
    'ITEM_ADDED',
    'ITEM_REMOVED',
    'ITEM_QUANTITY_CHANGED',
    'RETURN_CREATED',
    'DISCOUNT_APPLIED',
    'DELIVERY_STATUS_CHANGED',
    'INVOICE_GENERATED'
);


ALTER TYPE "public"."sale_audit_action" OWNER TO "postgres";


CREATE TYPE "public"."status_type" AS ENUM (
    'sale'
);


ALTER TYPE "public"."status_type" OWNER TO "postgres";


CREATE TYPE "public"."subscription_status" AS ENUM (
    'active',
    'inactive',
    'expired',
    'cancelled'
);


ALTER TYPE "public"."subscription_status" OWNER TO "postgres";


CREATE TYPE "public"."subscription_status_enum" AS ENUM (
    'trialing',
    'active',
    'past_due',
    'canceled',
    'ended',
    'free_limited',
    'paused',
    'pending_activation'
);


ALTER TYPE "public"."subscription_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."transaction_status" AS ENUM (
    'PENDING',
    'PARTIALLY_PAID',
    'PAID',
    'VOID',
    'CANCELLED',
    'REVERSED'
);


ALTER TYPE "public"."transaction_status" OWNER TO "postgres";


CREATE TYPE "public"."transaction_type" AS ENUM (
    'SALE',
    'PURCHASE',
    'SALE_RETURN',
    'PURCHASE_RETURN',
    'INCOME',
    'EXPENSE',
    'ADJUSTMENT',
    'OPENING_STOCK',
    'SUPPLIER_OPENING_BALANCE',
    'STOCK_ADJUSTMENT',
    'CUSTOMER_OPENING_BALANCE'
);


ALTER TYPE "public"."transaction_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."adjust_stock"("p_adjustment_json" "jsonb", "p_business_id" "uuid", "p_org_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data
    v_reference               TEXT := p_adjustment_json->>'reference_number';
    v_reason                  TEXT := p_adjustment_json->>'reason';
    v_adjusted_date           TIMESTAMPTZ := COALESCE((p_adjustment_json->>'adjusted_date')::timestamptz, now());
    v_adjusted_items          JSONB := p_adjustment_json->'adjusted_items';

    -- Internal Vars
    v_transaction_id          UUID;
    v_adjustment_id           UUID := gen_random_uuid();
    v_item_adjustment_value   NUMERIC;
    v_total_adjustment_abs_value NUMERIC := 0;
    v_item_data               RECORD;
    v_item_cost               NUMERIC;
    v_acting_user_id          UUID := auth.uid(); -- User performing the action

    -- Account IDs & Codes (COA v6.4)
    v_inventory_account_id          UUID;
    v_stock_loss_exp_account_id   UUID; -- For decreases
    v_stock_gain_inc_account_id   UUID; -- For increases

    v_inventory_code          TEXT := '1130'; -- Inventory
    v_stock_loss_exp_code     TEXT := '6950'; -- Stock Adjustment Loss/Expense
    v_stock_gain_inc_code     TEXT := '4950'; -- Stock Overage/Adjustment Gain

BEGIN
    -- Validate Inputs
    IF p_business_id IS NULL OR p_org_id IS NULL THEN
        RAISE EXCEPTION 'Business ID and Org ID cannot be null.';
    END IF;
    IF v_adjusted_items IS NULL OR jsonb_array_length(v_adjusted_items) = 0 THEN
        RAISE EXCEPTION 'adjusted_items array cannot be null or empty.';
    END IF;
    IF v_adjusted_date IS NULL THEN
        v_adjusted_date := now();
    END IF;

    -- Fetch required account IDs
    SELECT account_id INTO v_inventory_account_id FROM public.accounts 
        WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_inventory_code AND is_group = FALSE;
    SELECT account_id INTO v_stock_loss_exp_account_id FROM public.accounts 
        WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_stock_loss_exp_code AND is_group = FALSE;
    SELECT account_id INTO v_stock_gain_inc_account_id FROM public.accounts 
        WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_stock_gain_inc_code AND is_group = FALSE;

    IF v_inventory_account_id IS NULL THEN
         RAISE EXCEPTION 'Inventory account (Code: %s) not found for business %s, org %s.', v_inventory_code, p_business_id, p_org_id;
    END IF;
    IF v_stock_loss_exp_account_id IS NULL THEN
         RAISE EXCEPTION 'Stock Adjustment Loss/Expense account (Code: %s) not found for business %s, org %s.', v_stock_loss_exp_code, p_business_id, p_org_id;
    END IF;
    IF v_stock_gain_inc_account_id IS NULL THEN
         RAISE EXCEPTION 'Stock Overage/Adjustment Gain account (Code: %s) not found for business %s, org %s.', v_stock_gain_inc_code, p_business_id, p_org_id;
    END IF;

    -- Ensure reference number is not empty, generate if needed
    IF v_reference IS NULL OR v_reference = '' THEN
        v_reference := 'ADJ-' || public.generate_short_id() || '-' || to_char(v_adjusted_date, 'YYYYMMDD');
    END IF;

    -- Calculate total absolute adjustment value for the transaction header
    FOR v_item_data IN SELECT * FROM jsonb_array_elements(v_adjusted_items)
    LOOP
        SELECT COALESCE((v_item_data.value->>'unit_price')::numeric, i.purchase_price, 0) INTO v_item_cost -- Prioritize last_cost if available over purchase_price
        FROM public.items i
        WHERE i.item_id = (v_item_data.value->>'item_id')::uuid
          AND i.business_id = p_business_id
          AND i.org_id = p_org_id;

        IF NOT FOUND THEN
             RAISE EXCEPTION 'Item ID %s not found for business %s, org %s.', (v_item_data.value->>'item_id')::uuid, p_business_id, p_org_id;
        END IF;

        v_item_adjustment_value := (v_item_data.value->>'adjusted_quantity')::numeric * v_item_cost;
        v_total_adjustment_abs_value := v_total_adjustment_abs_value + abs(v_item_adjustment_value);
    END LOOP;

    -- Create the Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status,
        total_amount, paid_amount, due_amount,
        notes, business_id, org_id, created_by, updated_by
    ) VALUES (
        v_reference, 'STOCK_ADJUSTMENT'::public.transaction_type, v_adjusted_date, 'PAID'::public.transaction_status,
        v_total_adjustment_abs_value, v_total_adjustment_abs_value, 0,
        'Stock Adjustment: ' || COALESCE(v_reason,'No reason provided.'), p_business_id, p_org_id, v_acting_user_id, v_acting_user_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- Create stock adjustment header record
    INSERT INTO public.stock_adjustments (
        adjustment_id, reason, reference, performed_at, performed_by,
        business_id, org_id, transaction_id, updated_by
    ) VALUES (
        v_adjustment_id, v_reason, v_reference, v_adjusted_date, v_acting_user_id,
        p_business_id, p_org_id, v_transaction_id, v_acting_user_id
    );

    -- Loop through items again to update stock and create GL entries
    FOR v_item_data IN SELECT * FROM jsonb_array_elements(v_adjusted_items)
    LOOP
        DECLARE
            v_item_id           UUID := (v_item_data.value->>'item_id')::uuid;
            v_adjusted_quantity NUMERIC := (v_item_data.value->>'adjusted_quantity')::numeric;
            v_current_quantity  NUMERIC := (v_item_data.value->>'current_quantity')::numeric;
            v_new_quantity      NUMERIC := (v_item_data.value->>'new_quantity')::numeric;
            v_item_name         TEXT;
        BEGIN
            SELECT COALESCE((v_item_data.value->>'unit_price')::numeric, i.purchase_price, 0), i.name INTO v_item_cost, v_item_name
            FROM public.items i
            WHERE i.item_id = v_item_id AND i.business_id = p_business_id AND i.org_id = p_org_id;

            v_item_adjustment_value := v_adjusted_quantity * v_item_cost;

            IF v_item_adjustment_value = 0 AND v_adjusted_quantity != 0 THEN
                RAISE WARNING 'Item % (%) has zero cost. Stock quantity adjusted but no financial impact recorded for this item.', v_item_name, v_item_id;
            END IF;
            
            IF v_adjusted_quantity > 0 AND v_item_adjustment_value != 0 THEN
                -- Increase Inventory: Debit Inventory (1130), Credit Stock Overage/Gain (4950)
                INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                VALUES
                    (v_transaction_id, v_inventory_account_id, 'DEBIT'::public.entry_type, abs(v_item_adjustment_value), 'Stock Increase Adj: ' || v_item_name),
                    (v_transaction_id, v_stock_gain_inc_account_id, 'CREDIT'::public.entry_type, abs(v_item_adjustment_value), 'Stock Overage/Gain: ' || v_item_name);
            ELSIF v_adjusted_quantity < 0 AND v_item_adjustment_value != 0 THEN
                -- Decrease Inventory: Debit Stock Adjustment Loss/Expense (6950), Credit Inventory (1130)
                INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                VALUES
                    (v_transaction_id, v_stock_loss_exp_account_id, 'DEBIT'::public.entry_type, abs(v_item_adjustment_value), 'Stock Loss/Expense: ' || v_item_name),
                    (v_transaction_id, v_inventory_account_id, 'CREDIT'::public.entry_type, abs(v_item_adjustment_value), 'Stock Decrease Adj: ' || v_item_name);
            END IF;
            -- If v_item_adjustment_value is 0 (either due to zero quantity or zero cost), no GL entries.

            INSERT INTO public.stock_adjustment_items (
                adjustment_item_id, -- Assuming this is PK, gen_random_uuid()
                adjustment_id, item_id, quantity_adjusted, previous_quantity, new_quantity,
                created_by, updated_by
            ) VALUES (
                gen_random_uuid(),
                v_adjustment_id, v_item_id, v_adjusted_quantity, v_current_quantity, v_new_quantity,
                v_acting_user_id, v_acting_user_id
            );

            UPDATE public.items
            SET stock_quantity = v_new_quantity,
                updated_at = now(),
                updated_by = v_acting_user_id
            WHERE items.item_id = v_item_id
              AND items.business_id = p_business_id
              AND items.org_id = p_org_id;
        END;
    END LOOP;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RETURN v_transaction_id; -- Return transaction_id as it might be more useful than adjustment_id

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to adjust stock: Unique constraint violated. Check reference number "%s". Detail: %s', v_reference, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to adjust stock for business %s, org %s. Error: %s', p_business_id, p_org_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."adjust_stock"("p_adjustment_json" "jsonb", "p_business_id" "uuid", "p_org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_customer"("p_customer_id" "uuid", "p_business_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_customer_balance NUMERIC;
    v_transaction_count INTEGER;
    v_acting_user_id UUID := auth.uid();
BEGIN
    RAISE LOG 'archive_customer: Attempting to archive Customer ID: % for Business ID: %', 
        p_customer_id, p_business_id;

    IF p_customer_id IS NULL OR p_business_id IS NULL THEN
        RAISE EXCEPTION 'customer_id, business_id are required.';
    END IF;

    -- 1. Check the denormalized balance for this customer specifically within the given business/org
    SELECT bc.customer_balance
    INTO v_customer_balance
    FROM public.business_customers bc
    WHERE bc.customer_id = p_customer_id
      AND bc.business_id = p_business_id;

    IF NOT FOUND THEN
        -- This means the customer is not specifically associated with this business_customer record.
        -- Depending on your system design (central customer table vs. business-specific customer table),
        -- this might be an error or indicate no business-specific relationship to archive.
        -- For this function, we assume `business_customers` is the target for marking inactive.
        RAISE WARNING 'archive_customer: Customer ID % not found in business_customers for Business ID %. No business-specific record to archive.', 
            p_customer_id, p_business_id;
        RETURN; -- Or RAISE EXCEPTION if a business_customer record is expected.
    END IF;

    IF v_customer_balance IS NOT NULL AND v_customer_balance != 0 THEN
        RAISE EXCEPTION 'Cannot archive Customer ID % for Business ID %: Outstanding balance of % exists. Please settle or write off the balance first.',
            p_customer_id, p_business_id, v_customer_balance;
    END IF;

    -- 2. Check if the customer has ANY transactions associated with them for this business/org
    -- This is a stricter check beyond just the denormalized balance.
    SELECT COUNT(*)
    INTO v_transaction_count
    FROM public.transactions t
    WHERE t.customer_id = p_customer_id
      AND t.business_id = p_business_id;

    IF v_transaction_count > 0 THEN
        RAISE EXCEPTION 'Cannot archive Customer ID % for Business ID %: Customer has existing transactions. Archiving is not permitted to maintain data integrity.',
            p_customer_id, p_business_id;
        -- Note: If you wanted to allow archiving despite transactions, you would remove this block
        -- or change the condition (e.g., check only for *open* or *unpaid* transactions).
        -- However, "restrict delete/archive if involved in a transaction already" is usually strict.
    END IF;

    -- 3. Mark the business-specific customer record as inactive
    -- Assuming 'is_active' is on the business_customers table.
    UPDATE public.business_customers
    SET is_active = FALSE,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE customer_id = p_customer_id
      AND business_id = p_business_id;

    IF NOT FOUND THEN
        -- This should ideally not happen if the first SELECT found a record,
        -- but as a safeguard or if the first select was removed.
        RAISE WARNING 'archive_customer: Customer ID % for Business ID % was not found for final update to inactive, though it might have passed initial checks.', 
            p_customer_id, p_business_id;
    ELSE
        RAISE LOG 'archive_customer: Successfully archived (marked as inactive) Customer ID % for Business ID %.',
            p_customer_id, p_business_id;
    END IF;

    -- Note: No direct GL entries are made here. Archiving is an administrative action.
    -- Financial settlement (clearing A/R or Customer Deposits) must happen via separate transactions.

END;
$$;


ALTER FUNCTION "public"."archive_customer"("p_customer_id" "uuid", "p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_item"("p_item_id" "uuid", "p_business_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_stock_quantity NUMERIC;
    v_item_code TEXT;
    v_transaction_exists BOOLEAN := FALSE;
BEGIN
    -- 1. Check if the item exists for the given business
    SELECT stock_quantity, item_code INTO v_stock_quantity, v_item_code
    FROM public.items i
    WHERE i.item_id = p_item_id
      AND i.business_id = p_business_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item ID % not found for business ID %.', v_item_code, p_business_id;
    END IF;

    -- 2. Check for existing transactions linked to this item
    -- We look beyond just the Opening Stock transaction. Any transaction linked
    -- via the optional transactions.item_id or potentially via transaction_entries
    -- if item details are stored there (less ideal) indicates usage.
    -- This example primarily checks transactions.item_id.
    SELECT EXISTS (
        SELECT 1
        FROM public.transactions t
        WHERE t.business_id = p_business_id
          AND t.item_id = p_item_id
          AND t.transaction_type != 'OPENING_STOCK' -- Exclude the OB transaction itself
    ) INTO v_transaction_exists;

    -- Alternatively, or additionally, you might need to check line item tables
    -- if items are linked there instead of directly on the transaction header.
    -- Example (assuming a 'sale_items' table):
    /*
    IF NOT v_transaction_exists THEN
        SELECT EXISTS (
            SELECT 1 FROM public.sale_items si -- Replace with your actual line item table(s)
            JOIN public.sales s ON si.sale_id = s.sale_id -- Join to get business_id if needed
            WHERE si.item_id = p_item_id
              AND s.business_id = p_business_id -- Ensure check is scoped to the business
        ) INTO v_transaction_exists;
    END IF;
    -- Add similar checks for purchase line items, adjustment line items etc.
    */

    IF v_transaction_exists THEN
        RAISE EXCEPTION 'Cannot archive item ID %: Item has associated transaction history (e.g., sales, purchases, adjustments).', v_item_code;
    END IF;

    -- 3. Check for current stock quantity (optional but recommended for inventory items)
    -- This prevents archiving items that physically exist in inventory.
    -- Adjust this check based on whether v_stock_quantity could be null for non-inventory items.
    IF v_stock_quantity IS NOT NULL AND v_stock_quantity != 0 THEN
        RAISE EXCEPTION 'Cannot archive item ID %: Item has a current stock quantity of %. Please perform a stock adjustment first.',
            v_item_code, v_stock_quantity;
    END IF;

    -- 4. Mark the item as inactive
    UPDATE public.items
    SET is_active = FALSE,
        updated_at = now()
    WHERE item_id = p_item_id
      AND business_id = p_business_id; -- Redundant check but safe

    RAISE NOTICE 'Item ID % successfully archived.', v_item_code;

    -- Note: Archiving does not typically create GL entries.
    -- If stock quantity was non-zero and needed adjustment before archiving,
    -- that adjustment transaction would create the necessary GL entries
    -- (e.g., Dr Stock Adjustment Expense, Cr Inventory).

END;
$$;


ALTER FUNCTION "public"."archive_item"("p_item_id" "uuid", "p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_supplier"("p_supplier_id" "uuid", "p_business_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_supplier_balance NUMERIC;
    v_transaction_count INTEGER;
    v_acting_user_id UUID := auth.uid();
BEGIN
    RAISE LOG 'archive_supplier: Attempting to archive Supplier ID: % for Business ID: %', 
        p_supplier_id, p_business_id;

    IF p_supplier_id IS NULL OR p_business_id IS NULL THEN
        RAISE EXCEPTION 'supplier_id, business_id are required.';
    END IF;

    -- 1. Check the supplier's balance for this specific business/org context
    SELECT s.supplier_balance
    INTO v_supplier_balance
    FROM public.suppliers s
    WHERE s.supplier_id = p_supplier_id
      AND s.business_id = p_business_id;       -- Assuming suppliers table is scoped by org_id

    IF NOT FOUND THEN
         RAISE EXCEPTION 'Supplier ID %s not found for Business ID %s.', 
            p_supplier_id, p_business_id;
    END IF;

    IF v_supplier_balance IS NOT NULL AND v_supplier_balance != 0 THEN
        RAISE EXCEPTION 'Cannot archive this supplier: Outstanding balance of %s exists. Please settle the balance first.', v_supplier_balance;
    END IF;

    -- 2. Check if the supplier has ANY transactions associated with them for this business/org
    SELECT COUNT(*)
    INTO v_transaction_count
    FROM public.transactions t
    WHERE t.supplier_id = p_supplier_id
      AND t.business_id = p_business_id;

    IF v_transaction_count > 0 THEN
        RAISE EXCEPTION 'This supplier cannot be deleted because they have existing transactions. Please resolve or archive the transactions before attempting to delete the supplier.';
        -- To allow archiving despite transactions (e.g., only if all are settled), modify this condition.
    END IF;

    -- 3. Mark the supplier record as inactive for this business/org
    UPDATE public.suppliers
    SET is_active = FALSE,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE supplier_id = p_supplier_id
      AND business_id = p_business_id;       -- Scope the update

    IF NOT FOUND THEN
        -- This would be unusual if the first check passed, but indicates a potential race condition or issue.
        RAISE WARNING 'archive_supplier: Supplier ID %s for Business ID %s was not found for final update to inactive, though it passed initial checks.', 
            p_supplier_id, p_business_id;
    ELSE
        RAISE LOG 'archive_supplier: Successfully archived (marked as inactive) Supplier ID %s for Business ID %s.',
            p_supplier_id, p_business_id;
    END IF;

    -- Note: No GL entries made here. Financial settlement happens via other transactions.

END;
$$;


ALTER FUNCTION "public"."archive_supplier"("p_supplier_id" "uuid", "p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."build_account_node"("_account_id" "uuid", "_business_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
DECLARE
    v_account record;
    v_children jsonb := '[]'::jsonb; -- Default to empty array for children
BEGIN
    -- Fetch the details of the current account
    SELECT
        account_id,
        name,
        code,
        description,
        balance,
        is_group,
        parent_account_id,
        category_id
    INTO v_account
    FROM public.accounts a
    WHERE a.account_id = _account_id
      AND a.business_id = _business_id; -- Ensure it belongs to the correct business

    -- If account not found for the business, return NULL
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    -- If the current account is a group, find its children recursively
    IF v_account.is_group THEN
        SELECT jsonb_agg(child_node ORDER BY child_code) -- Order children by code for consistency
        INTO v_children
        FROM (
            SELECT public.build_account_node(a.account_id, _business_id) as child_node, a.code as child_code
            FROM public.accounts a
            WHERE a.parent_account_id = _account_id
              AND a.business_id = _business_id -- Ensure children belong to the same business
        ) AS children_subquery
        WHERE child_node IS NOT NULL; -- Exclude potential NULLs if a child wasn't found (shouldn't happen with FKs)

        -- If no children found, jsonb_agg returns NULL, default back to empty array
        IF v_children IS NULL THEN
            v_children := '[]'::jsonb;
        END IF;
    END IF;

    -- Build the JSON object for the current account
    RETURN jsonb_build_object(
        'account_id', v_account.account_id,
        'name', v_account.name,
        'code', v_account.code,
        'description', v_account.description,
        'balance', v_account.balance,
        'is_group', v_account.is_group,
        'parent_account_id', v_account.parent_account_id, -- Included for reference, though structure shows hierarchy
        'category_id', v_account.category_id,             -- Included for reference
        'children', v_children                            -- Add the children array (empty if not a group or no children)
    );
END;
$$;


ALTER FUNCTION "public"."build_account_node"("_account_id" "uuid", "_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."bulk_import_items"("p_import_data" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Params
    v_items_array        JSONB := p_import_data->'p_items';
    v_business_id      UUID := (p_import_data->>'p_business_id')::uuid;
    v_skip_duplicates  BOOLEAN := COALESCE((p_import_data->>'p_skip_duplicates')::boolean, true);

    -- Loop Vars
    item_data          JSONB;
    v_item_name        TEXT;
    v_category_name    TEXT;
    v_brand_name       TEXT;
    v_unit_name        TEXT;
    v_item_code        TEXT;
    v_sale_price       NUMERIC;
    v_retail_price     NUMERIC;
    v_purchase_price   NUMERIC;
    v_opening_qty      NUMERIC;
    v_opening_value    NUMERIC;

    -- Resolved IDs
    v_item_category_id UUID;
    v_brand_id         UUID;
    v_unit_id          UUID;
    v_existing_item_id UUID;
    v_item_id_out      UUID;

    -- Accounting Vars (COA v6.4)
    v_transaction_id        UUID;
    v_ob_ref_no             TEXT;
    v_inventory_account_id  UUID;
    v_ob_equity_account_id  UUID;
    v_inventory_code        TEXT := '1130'; -- Inventory
    v_ob_equity_code        TEXT := '3310'; -- Opening Balance Equity

    -- Internal State
    v_org_id           UUID;
    v_acting_user_id   UUID := auth.uid(); -- User performing the import
    v_processed_count  INTEGER := 0;
    v_inserted_count   INTEGER := 0;
    v_updated_count    INTEGER := 0;
    v_skipped_count    INTEGER := 0;
    v_error_count      INTEGER := 0;
    v_errors           TEXT[] := '{}';

BEGIN
    -- Validate top-level inputs
    IF v_business_id IS NULL THEN
        RAISE EXCEPTION 'p_business_id is required.';
    END IF;
    IF v_items_array IS NULL OR jsonb_typeof(v_items_array) != 'array' OR jsonb_array_length(v_items_array) = 0 THEN
        RAISE EXCEPTION 'p_items array is required and cannot be empty.';
    END IF;

    -- Get Org ID once
    SELECT org.org_id INTO v_org_id FROM public.businesses org WHERE org.business_id = v_business_id;
    IF v_org_id IS NULL THEN
        RAISE EXCEPTION 'Cannot find org_id for business_id %s', v_business_id;
    END IF;

    -- Fetch account IDs once if opening stock might be processed
    SELECT account_id INTO v_inventory_account_id FROM public.accounts 
        WHERE accounts.business_id = v_business_id AND accounts.org_id = v_org_id AND accounts.code = v_inventory_code AND accounts.is_group = FALSE;
    SELECT account_id INTO v_ob_equity_account_id FROM public.accounts 
        WHERE accounts.business_id = v_business_id AND accounts.org_id = v_org_id AND accounts.code = v_ob_equity_code AND accounts.is_group = FALSE;

    -- Loop through each item in the input array
    FOR item_data IN SELECT * FROM jsonb_array_elements(v_items_array)
    LOOP
        BEGIN -- Start block for individual item processing
            v_processed_count := v_processed_count + 1;
            v_existing_item_id := NULL;
            v_item_id_out := NULL;

            v_item_name := trim(item_data->>'Item Name');
            v_category_name := item_data->>'Category';
            v_brand_name := item_data->>'Brand';
            v_unit_name := item_data->>'Item Unit';
            v_item_code := trim(item_data->>'Item Code/Barcode');
            v_sale_price := COALESCE((item_data->>'Sale Price')::numeric, 0);
            v_retail_price := COALESCE((item_data->>'Retail Price')::numeric, v_sale_price);
            v_purchase_price := COALESCE((item_data->>'Purchase Price')::numeric, 0);
            v_opening_qty := COALESCE((item_data->>'Opening Stock Qty')::numeric, 0);
            v_opening_value := COALESCE((item_data->>'Opening Stock Value')::numeric, 0);

            IF v_item_name IS NULL OR v_item_name = '' THEN
                RAISE EXCEPTION 'Item Name is required.';
            END IF;
            IF v_opening_value < 0 THEN
                RAISE EXCEPTION 'Opening Stock Value for item "%" cannot be negative.', v_item_name;
            END IF;

            -- Resolve foreign keys (ensure these helper functions exist and handle org_id)
            v_item_category_id := public.get_or_create_item_category(v_business_id, v_org_id, v_category_name);
            v_brand_id := public.get_or_create_brand(v_business_id, v_org_id, v_brand_name);
            v_unit_id := public.get_or_create_unit(v_business_id, v_org_id, v_unit_name);

            -- Check if item already exists by NAME or ITEM_CODE for this business
            IF v_item_code IS NOT NULL AND v_item_code != '' THEN
                 SELECT item_id INTO v_existing_item_id
                 FROM public.items
                 WHERE items.business_id = v_business_id AND items.org_id = v_org_id AND items.item_code = v_item_code;
            END IF;

            IF v_existing_item_id IS NULL THEN -- If not found by code, try by name
                 SELECT item_id INTO v_existing_item_id
                 FROM public.items
                 WHERE items.business_id = v_business_id AND items.org_id = v_org_id AND lower(items.name) = lower(v_item_name);
            END IF;

            IF v_existing_item_id IS NOT NULL THEN
                IF v_skip_duplicates THEN
                    RAISE WARNING 'Skipping duplicate item (name/code): "%" / "%"', v_item_name, v_item_code;
                    v_skipped_count := v_skipped_count + 1;
                    CONTINUE;
                ELSE
                    UPDATE public.items SET
                        item_category_id = COALESCE(v_item_category_id, items.item_category_id),
                        brand_id = COALESCE(v_brand_id, items.brand_id),
                        unit_id = COALESCE(v_unit_id, items.unit_id),
                        item_code = COALESCE(v_item_code, items.item_code),
                        sale_price = v_sale_price,
                        purchase_price = v_purchase_price,
                        retail_price = v_retail_price,
                        -- Do not update stock, opening_stock_qty, opening_stock_value on update
                        updated_at = now(),
                        updated_by = v_acting_user_id
                    WHERE items.item_id = v_existing_item_id;
                    v_updated_count := v_updated_count + 1;
                END IF;
            ELSE
                -- INSERT new item
                IF v_item_code IS NULL OR v_item_code = '' THEN
                    v_item_code := public.get_next_item_code(v_business_id); -- Ensure this handles org_id if needed
                END IF;

                INSERT INTO public.items (
                    item_id, -- generate new
                    name, item_type, item_code, item_category_id, brand_id, unit_id,
                    sales_enabled, purchase_enabled, inventory_enabled, is_returnable,
                    sale_price, purchase_price, retail_price, alert_quantity,
                    business_id, org_id,
                    stock_quantity, stock_value,
                    opening_stock_qty, opening_stock_value,
                    created_at, updated_at, created_by, updated_by
                ) VALUES (
                    gen_random_uuid(),
                    v_item_name, 'GOODS'::public.item_type, v_item_code, v_item_category_id, v_brand_id, v_unit_id,
                    true, true, true, false, -- Assuming these defaults for imported goods
                    v_sale_price, v_purchase_price, v_retail_price, 0, -- Default alert_quantity
                    v_business_id, v_org_id,
                    v_opening_qty, v_opening_value,
                    v_opening_qty, v_opening_value,
                    now(), now(), v_acting_user_id, v_acting_user_id
                )
                RETURNING items.item_id INTO v_item_id_out;
                v_inserted_count := v_inserted_count + 1;

                -- Handle Opening Stock Accounting (Only if INSERTED and value > 0)
                IF v_opening_value > 0 THEN -- Opening stock value must be positive
                    IF v_inventory_account_id IS NULL THEN
                        RAISE EXCEPTION 'Inventory account (Code: %s) not found for business %s, org %s. Cannot process opening stock for "%s".', v_inventory_code, v_business_id, v_org_id, v_item_name;
                    END IF;
                    IF v_ob_equity_account_id IS NULL THEN
                        RAISE EXCEPTION 'Opening Balance Equity account (Code: %s) not found for business %s, org %s. Cannot process opening stock for "%s".', v_ob_equity_code, v_business_id, v_org_id, v_item_name;
                    END IF;

                    v_ob_ref_no := 'OB-ITEM-IMP-' || public.generate_short_id() || '-' || v_item_id_out::text;

                    INSERT INTO public.transactions (
                        reference_no, transaction_type, transaction_date, status,
                        total_amount, paid_amount, due_amount,
                        notes, business_id, org_id, created_by, updated_by, item_id
                    ) VALUES (
                        v_ob_ref_no, 'OPENING_STOCK'::public.transaction_type, now(), 'PAID'::public.transaction_status,
                        v_opening_value, v_opening_value, 0,
                        'Opening stock value (Import) for item: ' || v_item_name || ' (' || COALESCE(v_item_code,'N/A') || ')', 
                        v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_item_id_out
                    ) RETURNING transaction_id INTO v_transaction_id;

                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES
                        (v_transaction_id, v_inventory_account_id, 'DEBIT'::public.entry_type, v_opening_value, 'Item opening stock value (Import)'),
                        (v_transaction_id, v_ob_equity_account_id, 'CREDIT'::public.entry_type, v_opening_value, 'Offset for item opening stock value (Import)');

                    PERFORM public.verify_transaction_balance(v_transaction_id);
                END IF;
            END IF;
        EXCEPTION
            WHEN unique_violation THEN
                 v_error_count := v_error_count + 1;
                 v_errors := array_append(v_errors, format('Item "%s" (Code: "%s"): Failed due to unique constraint. Detail: %s', COALESCE(v_item_name, 'N/A'), COALESCE(v_item_code, 'N/A'), SQLERRM));
                 RAISE WARNING 'Unique violation for Item "%" (Code: "%"): %s', COALESCE(v_item_name, 'N/A'), COALESCE(v_item_code, 'N/A'), SQLERRM;
            WHEN others THEN
                 v_error_count := v_error_count + 1;
                 v_errors := array_append(v_errors, format('Item "%s" (Code: "%s"): Failed with error: %s', COALESCE(v_item_name, 'N/A'), COALESCE(v_item_code, 'N/A'), SQLERRM));
                 RAISE WARNING 'Error processing Item "%" (Code: "%"): %s', COALESCE(v_item_name, 'N/A'), COALESCE(v_item_code, 'N/A'), SQLERRM;
        END;
    END LOOP;

    RETURN jsonb_build_object(
        'processed_count', v_processed_count,
        'inserted_count', v_inserted_count,
        'updated_count', v_updated_count,
        'skipped_count', v_skipped_count,
        'error_count', v_error_count,
        'errors', v_errors
    );

END;
$$;


ALTER FUNCTION "public"."bulk_import_items"("p_import_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cancel_expired_trials"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    rec RECORD;
BEGIN
  -- Find all expired trialing subscriptions
  FOR rec IN
    SELECT org_id
    FROM public.subscriptions
    WHERE status = 'trialing'::public.subscription_status_enum
      AND trial_end_date <= NOW()
      AND cancel_at_period_end = TRUE
      AND (canceled_at IS NULL OR canceled_at > NOW())
  LOOP
    -- Cancel the trialing subscriptions for this org
    UPDATE public.subscriptions
    SET status = 'canceled'::public.subscription_status_enum,
        canceled_at = NOW()
    WHERE org_id = rec.org_id
      AND status = 'trialing'::public.subscription_status_enum
      AND trial_end_date <= NOW()
      AND cancel_at_period_end = TRUE
      AND (canceled_at IS NULL OR canceled_at > NOW());

    -- Insert a free plan if not already active for this org
    IF NOT EXISTS (
      SELECT 1 FROM public.subscriptions
      WHERE org_id = rec.org_id
        AND plan_id = 1
        AND status = 'active'::public.subscription_status_enum
    ) THEN
      RAISE NOTICE '[cancel_expired_trials] OrgID: %. Inserting free plan subscription...', rec.org_id;
      INSERT INTO public.subscriptions (
        org_id, plan_id, status, start_date, end_date, trial_end_date, cancel_at_period_end, addon_id
      ) VALUES (
        rec.org_id, 1, 'active'::public.subscription_status_enum, current_date, NULL, NULL, FALSE, NULL
      );
    END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."cancel_expired_trials"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."change_phone_or_email"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- This function is triggered AFTER INSERT on auth.users.
    -- It updates the email and phone in the public.users table
    -- for the corresponding user ID.

    -- This assumes that a row with NEW.id already exists in public.users.
    -- If not, this UPDATE statement will affect 0 rows silently.
    -- Consider using an UPSERT (INSERT ... ON CONFLICT) if this function
    -- should also handle creating the public.users row if it doesn't exist.

    UPDATE public.users
    SET
        email = NEW.email,  -- Get email from the newly inserted auth.users row
        phone = NEW.phone   -- Get phone from the newly inserted auth.users row
                            -- If your column in public.users is named e.g. 'phone_number', adjust accordingly.
    WHERE
        user_id = NEW.id;        -- Match based on the user ID

    -- For AFTER triggers, the return value is ignored, but it's good practice to return NEW or NULL.
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."change_phone_or_email"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_user_exists"("p_email" "text" DEFAULT NULL::"text", "p_phone" "text" DEFAULT NULL::"text") RETURNS SETOF "auth"."users"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM auth.users
    WHERE email = p_email
       OR regexp_replace(phone, '\+', '', 'g') = regexp_replace(p_phone, '\+', '', 'g');
END;
$$;


ALTER FUNCTION "public"."check_user_exists"("p_email" "text", "p_phone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."clear_sequences"("business_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    v_base_name text;
BEGIN
    v_base_name := business_id::text;

    -- Drop sequences if they exist in the public schema
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_purchase_invoice');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_sale_invoice');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_purchase_return_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_sale_return_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_item_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_employee_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_invoice_code');
	EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_quote_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_payment_code');
    EXECUTE format('DROP SEQUENCE IF EXISTS public.%I', v_base_name || '_credit_note_code');
	

END;$$;


ALTER FUNCTION "public"."clear_sequences"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_addon_subscription_package"("p_org_id" "uuid", "p_addon_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_item_id" "text", "p_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_quantity" integer, "p_billing_cycle" "public"."billing_cycle_enum", "p_country_code" character varying, "p_currency_code" character varying, "p_trial_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_current_start" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_current_end" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_subscription_id UUID;
    invoice_item JSONB;
    v_addon_amount NUMERIC;
    v_fetched_currency_code CHARACTER VARYING(3);
BEGIN

    -- Fetch addon price based on billing cycle, country, and currency
    IF p_billing_cycle = 'monthly' THEN
        SELECT price_monthly, currency_code INTO v_addon_amount, v_fetched_currency_code
        FROM public.addon_prices
        WHERE addon_id = p_addon_id
          AND addon_prices.country_code = p_country_code
          AND addon_prices.currency_code = p_currency_code
          AND is_active = true;
    ELSIF p_billing_cycle = 'annually' THEN
        SELECT price_annual, currency_code INTO v_addon_amount, v_fetched_currency_code
        FROM public.addon_prices
        WHERE addon_id = p_addon_id
          AND addon_prices.country_code = p_country_code
          AND addon_prices.currency_code = p_currency_code
          AND is_active = true;
    ELSE
        -- Fallback or error if billing_cycle is not monthly/annually,
        -- or if one-time addons need specific handling here via p_billing_cycle.
        -- For now, this will result in v_addon_amount being NULL if not 'monthly' or 'annually'.
    END IF;

    IF v_addon_amount IS NULL OR v_fetched_currency_code IS NULL THEN
        RAISE EXCEPTION 'Active addon price not found for addon_id: %, country_code: %, currency_code: %, billing_cycle: %',
                        p_addon_id, p_country_code, p_currency_code, p_billing_cycle;
    END IF;
    
    IF v_fetched_currency_code <> p_currency_code THEN
        RAISE EXCEPTION 'Mismatch between provided currency_code (%) and fetched currency_code (%) for addon_id: %',
                        p_currency_code, v_fetched_currency_code, p_addon_id;
    END IF;


    -- 1. Insert the new addon subscription
    INSERT INTO public.subscriptions (
        org_id,
        addon_id, -- Set addon_id
        plan_id,  -- Set plan_id to NULL
        payment_provider_subscription_id,
        status,
        start_date,
        payment_provider,
        payment_provider_plan_id, -- Stores p_payment_provider_item_id
        end_date,
        trial_end_date,
        current_start,
        current_end,
        created_at,
        updated_at,
        payment_url,
        metadata,
        currency,         -- Use p_currency_code
        billing_cycle,
        plan_amount,      -- Store addon amount here
    	quantity
	)
    VALUES (
        p_org_id,
        p_addon_id,
        NULL,
        p_payment_provider_subscription_id,
        p_initial_status,
        p_start_date,
        p_payment_provider,
        p_payment_provider_item_id,
        p_end_date,
        p_trial_end_date,
        p_current_start,
        p_current_end,
        NOW(),
        NOW(),
        p_payment_url,
        p_metadata,
        p_currency_code,  -- Storing the currency of the transaction
        p_billing_cycle,
        v_addon_amount,   -- Storing the fetched addon price
		p_quantity
    )
    RETURNING subscription_id INTO new_subscription_id;

    -- 2. Insert all invoices for this addon subscription
    IF p_invoices IS NOT NULL AND jsonb_array_length(p_invoices) > 0 THEN
        FOR invoice_item IN SELECT * FROM jsonb_array_elements(p_invoices)
        LOOP
            INSERT INTO public.subscription_invoices (
                org_id,
                subscription_id,
                payment_provider_invoice_id,
                payment_provider_subscription_id,
                payment_provider,
                amount,
                currency,
                status,
                issued_at,
                due_date,
                line_items,
                pdf_url,
                notes,
                metadata,
                created_at,
                updated_at,
                payment_url
            )
            VALUES (
                p_org_id,
                new_subscription_id,
                invoice_item->>'id',
                p_payment_provider_subscription_id,
                p_payment_provider,
                (COALESCE(invoice_item->>'amount', '0')::NUMERIC) / 100,
                invoice_item->>'currency',
                (invoice_item->>'status')::public.invoice_status_enum,
                CASE WHEN invoice_item->>'issued_at' IS NOT NULL THEN to_timestamp((invoice_item->>'issued_at')::BIGINT) ELSE NULL END,
                CASE
                    WHEN invoice_item->>'expire_by' IS NOT NULL AND invoice_item->>'expire_by' <> 'null'
                    THEN to_timestamp((invoice_item->>'expire_by')::BIGINT)
                    ELSE NULL
                END,
                invoice_item->'line_items',
                invoice_item->>'short_url',
                invoice_item->'notes',
                invoice_item,
                CASE WHEN invoice_item->>'created_at' IS NOT NULL THEN to_timestamp((invoice_item->>'created_at')::BIGINT) ELSE NOW() END,
                NOW(),
                invoice_item->>'short_url'
            );
        END LOOP;
    END IF;

    -- 3. Update the organization record.
    -- Review if 'trial_activated = TRUE' is always appropriate for addons.
    -- Addons might be purchased by orgs already past their trial.
    -- This is kept for similarity with the original function.
    -- UPDATE public.organizations
    -- SET trial_activated = TRUE -- Consider if this logic needs to be conditional or different for addons
    -- WHERE org_id = p_org_id;

    RETURN new_subscription_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error in create_addon_subscription_package for org % and addon %: %, SQLSTATE: %', p_org_id, p_addon_id, SQLERRM, SQLSTATE;
        RAISE;
END;
$$;


ALTER FUNCTION "public"."create_addon_subscription_package"("p_org_id" "uuid", "p_addon_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_item_id" "text", "p_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_quantity" integer, "p_billing_cycle" "public"."billing_cycle_enum", "p_country_code" character varying, "p_currency_code" character varying, "p_trial_end_date" timestamp with time zone, "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_credit_note"("p_credit_note_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Input Data & Other Fields
    v_invoice_id           UUID := (p_credit_note_json->>'invoice_id')::uuid;
    v_business_id          UUID;
    v_customer_id          UUID;
    v_created_by           UUID;
    v_billing_address      UUID;
    v_shipping_address     UUID;
    v_credit_note_date     DATE;
    v_due_date             DATE;
    v_notes                TEXT;
    v_terms_and_conditions TEXT;
    v_reference            TEXT;
    v_reason               TEXT;
    v_status               public.credit_note_status;
    v_credit_note_items    JSONB;

    -- Amounts
    v_input_tax_total        NUMERIC;
    v_input_discount_amount  NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Calculated Totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;

    -- Internal Processing Variables
    v_new_credit_note_id      UUID;
    v_gen_credit_note_code    TEXT;
    v_credit_note_item_data   RECORD;
    v_invoice_data            RECORD;
    v_invoice_balance_due     NUMERIC;
    v_amount_to_apply         NUMERIC;

BEGIN
    -- 1. DETERMINE DATA SOURCE AND POPULATE VARIABLES
    IF v_invoice_id IS NOT NULL THEN
        -- **FROM INVOICE (with JSON override)**
        SELECT * INTO v_invoice_data FROM public.invoices WHERE invoice_id = v_invoice_id;
        IF NOT FOUND THEN RAISE EXCEPTION 'Source invoice with ID % not found.', v_invoice_id; END IF;

        -- Core IDs are non-negotiable from the invoice
        v_business_id         := v_invoice_data.business_id;
        v_customer_id         := v_invoice_data.customer_id;

        -- CHANGED: Use COALESCE for all fields that can be inherited.
        -- Pattern: Try the JSON payload first, if it's null, fall back to the invoice data.
        v_billing_address     := COALESCE((p_credit_note_json->>'billing_address')::uuid, v_invoice_data.billing_address);
        v_shipping_address    := COALESCE((p_credit_note_json->>'shipping_address')::uuid, v_invoice_data.shipping_address);
        v_credit_note_date    := COALESCE((p_credit_note_json->>'credit_note_date')::date, current_date);
        v_due_date            := COALESCE((p_credit_note_json->>'due_date')::date, v_invoice_data.due_date);
        v_notes               := COALESCE(p_credit_note_json->>'notes', v_invoice_data.notes);
        v_terms_and_conditions:= COALESCE(p_credit_note_json->>'terms_and_conditions', v_invoice_data.terms_and_conditions);
        v_reference           := p_credit_note_json->>'reference'; -- Reference is usually specific to the new doc.
        v_reason              := p_credit_note_json->>'reason'; -- Reason is specific to the credit note.

        -- If items are not provided in the payload, copy them from the invoice. Otherwise, use payload items.
        IF p_credit_note_json ? 'credit_note_items' THEN
            v_credit_note_items    := p_credit_note_json->'credit_note_items';
            -- If items are provided, the related amounts must also be provided.
            v_input_tax_total        := COALESCE((p_credit_note_json->>'tax_total')::numeric, 0);
            v_input_discount_amount  := COALESCE((p_credit_note_json->>'discount_amount')::numeric, 0);
            v_input_shipping_charges := COALESCE((p_credit_note_json->>'shipping_charges')::numeric, 0);
        ELSE
            -- Inherit items AND related totals from the invoice
            SELECT jsonb_agg(jsonb_build_object('item_id', ii.item_id, 'quantity', ii.quantity, 'unit_price', ii.unit_price))
            INTO v_credit_note_items FROM public.invoice_items ii WHERE ii.invoice_id = v_invoice_id;

            v_input_tax_total        := COALESCE((p_credit_note_json->>'tax_total')::numeric, v_invoice_data.tax_total);
            v_input_discount_amount  := COALESCE((p_credit_note_json->>'discount_amount')::numeric, v_invoice_data.discount_amount);
            v_input_shipping_charges := COALESCE((p_credit_note_json->>'shipping_charges')::numeric, v_invoice_data.shipping_charges);
        END IF;

    ELSE
        -- **FROM JSON ONLY**
        v_business_id          := (p_credit_note_json->>'business_id')::uuid;
        v_customer_id          := (p_credit_note_json->>'customer_id')::uuid;
        v_billing_address      := (p_credit_note_json->>'billing_address')::uuid;
        v_shipping_address     := (p_credit_note_json->>'shipping_address')::uuid;
        v_credit_note_date     := COALESCE((p_credit_note_json->>'credit_note_date')::date, current_date);
        v_due_date             := (p_credit_note_json->>'due_date')::date;
        v_notes                := p_credit_note_json->>'notes';
        v_terms_and_conditions := p_credit_note_json->>'terms_and_conditions';
        v_reference            := p_credit_note_json->>'reference';
        v_reason               := p_credit_note_json->>'reason';
        v_credit_note_items    := p_credit_note_json->'credit_note_items';

        -- Amounts must be from JSON as there is no invoice to reference
        v_input_tax_total        := COALESCE((p_credit_note_json->>'tax_total')::numeric, 0);
        v_input_discount_amount  := COALESCE((p_credit_note_json->>'discount_amount')::numeric, 0);
        v_input_shipping_charges := COALESCE((p_credit_note_json->>'shipping_charges')::numeric, 0);
    END IF;

    -- 2. VALIDATE COMMON FIELDS (this part remains largely the same)
    v_created_by := COALESCE((p_credit_note_json->>'created_by')::uuid, auth.uid());
    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_credit_note_items IS NULL OR jsonb_array_length(v_credit_note_items) = 0 THEN RAISE EXCEPTION 'At least one credit_note_item is required.'; END IF;

    -- 3. CALCULATE TOTALS FROM ITEMS AND INPUTS (this part is unchanged)
    FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
        v_calculated_sub_total := v_calculated_sub_total + (v_credit_note_item_data.quantity * v_credit_note_item_data.unit_price);
    END LOOP;

    v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;
    IF v_calculated_grand_total < 0 THEN RAISE EXCEPTION 'Grand total cannot be negative.'; END IF;

    -- 4. GENERATE A UNIQUE CREDIT NOTE CODE (unchanged)
    v_gen_credit_note_code := public.get_next_credit_note_code(v_business_id);
    IF v_gen_credit_note_code IS NULL THEN RAISE EXCEPTION 'Failed to generate credit_note_code.'; END IF;

    -- 5. INSERT THE MAIN RECORD INTO credit_notes TABLE (unchanged)
    INSERT INTO public.credit_notes (
        business_id, customer_id, invoice_id, created_by, billing_address, shipping_address,
        credit_note_date, due_date, notes, terms_and_conditions, tax_total, sub_total,
        discount_amount, shipping_charges, grand_total, status, reference, reason, credit_note_code,
        credit_remaining
    ) VALUES (
        v_business_id, v_customer_id, v_invoice_id, v_created_by, v_billing_address, v_shipping_address,
        v_credit_note_date, v_due_date, v_notes, v_terms_and_conditions, v_input_tax_total, v_calculated_sub_total,
        v_input_discount_amount, v_input_shipping_charges, v_calculated_grand_total, 'open', v_reference, v_reason,
        v_gen_credit_note_code, v_calculated_grand_total
    ) RETURNING credit_note_id INTO v_new_credit_note_id;

    -- 6. INSERT THE LINE ITEMS INTO credit_note_items TABLE (unchanged)
    FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
        INSERT INTO public.credit_note_items (
            business_id, customer_id, credit_note_id, item_id, quantity, unit_price
        ) VALUES (
            v_business_id, v_customer_id, v_new_credit_note_id,
            v_credit_note_item_data.item_id, v_credit_note_item_data.quantity, v_credit_note_item_data.unit_price
        );
    END LOOP;

    -- 7. AUTO-APPLY CREDIT TO THE INVOICE (unchanged)
    IF v_invoice_id IS NOT NULL THEN
        SELECT balance_due INTO v_invoice_balance_due FROM public.invoices WHERE invoice_id = v_invoice_id FOR UPDATE;
        v_amount_to_apply := LEAST(v_calculated_grand_total, v_invoice_balance_due);
        IF v_amount_to_apply > 0 THEN
            UPDATE public.invoices
            SET credit_applied = credit_applied + v_amount_to_apply
            WHERE invoice_id = v_invoice_id;
            UPDATE public.credit_notes
            SET credit_remaining = credit_remaining - v_amount_to_apply
            WHERE credit_note_id = v_new_credit_note_id;
            PERFORM public.update_invoice_status(v_invoice_id);
        END IF;
    END IF;

    -- 8. UPDATE THE STATUS OF THE NEWLY CREATED CREDIT NOTE (unchanged)
    PERFORM public.update_credit_note_status(v_new_credit_note_id);

    -- 9. RETURN A SUCCESS RESPONSE (unchanged)
    RETURN jsonb_build_object(
        'status', 'success',
        'message', 'Credit note created successfully.',
        'credit_note_id', v_new_credit_note_id,
        'credit_note_code', v_gen_credit_note_code
    );

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create credit note: Unique constraint violated. Potential duplicate credit_note_code "%". Error: %', v_gen_credit_note_code, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create credit note. Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;


ALTER FUNCTION "public"."create_credit_note"("p_credit_note_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_default_chart_of_accounts"("p_business_id" "uuid", "p_org_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Category IDs
    v_asset_category_id UUID;
    v_liability_category_id UUID;
    v_equity_category_id UUID;
    v_revenue_category_id UUID;
    v_cost_of_sales_category_id UUID;
    v_operating_expenses_category_id UUID;

    -- Account Group IDs
    v_current_assets_group_id UUID;
    v_cash_and_equivalents_group_id UUID;
    v_current_liabilities_group_id UUID;
    v_equity_opening_balance_id UUID;
    v_revenue_group_id UUID;
    v_cost_of_goods_sold_group_id UUID;
    v_operating_expenses_group_id UUID;
BEGIN
    -- 1. Create Account Categories
    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('ASSETS', 'AST', 'Asset accounts', p_business_id) RETURNING category_id INTO v_asset_category_id;

    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('LIABILITIES', 'LBT', 'Liability accounts', p_business_id) RETURNING category_id INTO v_liability_category_id;

    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('EQUITIES', 'EQT', 'Equity accounts', p_business_id) RETURNING category_id INTO v_equity_category_id;

    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('REVENUES', 'RVN', 'Revenue accounts', p_business_id) RETURNING category_id INTO v_revenue_category_id;

    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('COST OF SALES', 'COS', 'Cost of Sales accounts', p_business_id) RETURNING category_id INTO v_cost_of_sales_category_id;

    INSERT INTO public.account_categories (name, code, description, business_id) VALUES
    ('OPERATING EXPENSES', 'OPE', 'Operating expenses accounts', p_business_id) RETURNING category_id INTO v_operating_expenses_category_id;

    -- 2. Create Assets Hierarchy
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_asset_category_id, 'Current Assets', '11xx', NULL, TRUE, NULL, p_business_id, p_org_id)
    RETURNING account_id INTO v_current_assets_group_id;

    -- 2.1 Cash & Cash Equivalents Sub-header
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_asset_category_id, 'Cash & Cash Equivalents', '1110', NULL, TRUE, v_current_assets_group_id, p_business_id, p_org_id)
    RETURNING account_id INTO v_cash_and_equivalents_group_id;

    -- 2.2 Current Assets Accounts
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id) VALUES
    -- Cash & Cash Equivalents
    (v_asset_category_id, 'Cash in Bank - Operating', '1111', 'Operating cash in bank accounts.', FALSE, v_cash_and_equivalents_group_id, p_business_id, p_org_id),
    (v_asset_category_id, 'Petty Cash', '1113', 'Cash on hand.', FALSE, v_cash_and_equivalents_group_id, p_business_id, p_org_id),
    -- Other Current Assets
    (v_asset_category_id, 'Accounts Receivable', '1120', 'Money owed by customers.', FALSE, v_current_assets_group_id, p_business_id, p_org_id),
    (v_asset_category_id, 'Inventory', '1130', 'Value of goods held for sale.', FALSE, v_current_assets_group_id, p_business_id, p_org_id),
    (v_asset_category_id, 'Supplier Advances / Prepayments', '1145', 'Supplier Wallet or prepayments to suppliers.', FALSE, v_current_assets_group_id, p_business_id, p_org_id);

    -- 3. Create Liabilities Hierarchy
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_liability_category_id, 'Current Liabilities', '21xx', NULL, TRUE, NULL, p_business_id, p_org_id)
    RETURNING account_id INTO v_current_liabilities_group_id;

    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id) VALUES
    (v_liability_category_id, 'Accounts Payable', '2110', 'Money owed to suppliers.', FALSE, v_current_liabilities_group_id, p_business_id, p_org_id),
    (v_liability_category_id, 'Sales Tax Payable', '2120', 'Sales tax collected but not yet remitted.', FALSE, v_current_liabilities_group_id, p_business_id, p_org_id),
    (v_liability_category_id, 'Customer Deposits / Credit Balances', '2150', 'Customer Wallet or deposits from customers.', FALSE, v_current_liabilities_group_id, p_business_id, p_org_id);

    -- 4. Create Equity Accounts
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, is_system, business_id, org_id) VALUES
    (v_equity_category_id, 'Opening Balance Equity', '3310', 'For initial setup balances.', FALSE, NULL, TRUE, p_business_id, p_org_id);

    -- 5. Create Revenue / Income Hierarchy
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_revenue_category_id, 'Revenue / Income', '4xxx', NULL, TRUE, NULL, p_business_id, p_org_id)
    RETURNING account_id INTO v_revenue_group_id;

    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id) VALUES
    (v_revenue_category_id, 'General Income', '4010', 'Miscellaneous non-core income.', FALSE, v_revenue_group_id, p_business_id, p_org_id),
    (v_revenue_category_id, 'Sales Revenue - Products', '4110', 'Income from product sales.', FALSE, v_revenue_group_id, p_business_id, p_org_id),
    (v_revenue_category_id, 'Sales Revenue - Services', '4120', 'Income from service sales.', FALSE, v_revenue_group_id, p_business_id, p_org_id),
    (v_revenue_category_id, 'Shipping & Handling Revenue', '4210', 'Revenue from shipping charges.', FALSE, v_revenue_group_id, p_business_id, p_org_id),
    (v_revenue_category_id, 'Sales Discounts', '4800', 'Contra account for sales discounts.', FALSE, v_revenue_group_id, p_business_id, p_org_id),
    (v_revenue_category_id, 'Stock Overage/Adjustment Gain', '4950', 'Income from stock adjustments.', FALSE, v_revenue_group_id, p_business_id, p_org_id);

    -- 6. Create Cost of Sales / COGS Hierarchy
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_cost_of_sales_category_id, 'Cost of Sales / COGS', '5xxx', NULL, TRUE, NULL, p_business_id, p_org_id)
    RETURNING account_id INTO v_cost_of_goods_sold_group_id;

    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id) VALUES
    (v_cost_of_sales_category_id, 'COGS - Products', '5110', 'Cost of goods sold - products.', FALSE, v_cost_of_goods_sold_group_id, p_business_id, p_org_id),
    -- Future consideration for services: (v_cost_of_sales_category_id, 'COGS - Services', '5120', 'Cost of services sold.', FALSE, v_cost_of_goods_sold_group_id, p_business_id, p_org_id),
    (v_cost_of_sales_category_id, 'Freight-In / Purchase Shipping Costs', '5310', 'Shipping costs for purchased goods.', FALSE, v_cost_of_goods_sold_group_id, p_business_id, p_org_id),
    (v_cost_of_sales_category_id, 'Purchase Discounts', '5800', 'Contra account for purchase discounts.', FALSE, v_cost_of_goods_sold_group_id, p_business_id, p_org_id);

    -- 7. Create Operating Expenses Hierarchy
    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id)
    VALUES (v_operating_expenses_category_id, 'Operating Expenses', '6xxx', NULL, TRUE, NULL, p_business_id, p_org_id)
    RETURNING account_id INTO v_operating_expenses_group_id;

    INSERT INTO public.accounts (category_id, name, code, description, is_group, parent_account_id, business_id, org_id) VALUES
    (v_operating_expenses_category_id, 'General Expense', '6010', 'General operating expenses.', FALSE, v_operating_expenses_group_id, p_business_id, p_org_id),
    (v_operating_expenses_category_id, 'Non-Inventory Purchases Expense', '6015', 'Non-stock purchases expense.', FALSE, v_operating_expenses_group_id, p_business_id, p_org_id),
    (v_operating_expenses_category_id, 'Stock Adjustment Loss/Expense', '6950', 'Losses related to inventory adjustments.', FALSE, v_operating_expenses_group_id, p_business_id, p_org_id);

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating default chart of accounts structure for business_id %: %', p_business_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_default_chart_of_accounts"("p_business_id" "uuid", "p_org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_invoice"("p_invoice_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    -- Input Data
    v_quote_id             UUID := (p_invoice_json->>'quote_id')::uuid;
    v_business_id          UUID;
    v_customer_id          UUID;
    v_created_by           UUID;
    v_billing_address      UUID;
    v_shipping_address     UUID;
    v_invoice_date         DATE;
    v_due_date             DATE;
    v_notes                TEXT;
    v_terms_and_conditions TEXT;
    v_status               TEXT;
    v_invoice_items        JSONB;
    v_input_invoice_code   TEXT;

    -- Amounts
    v_input_tax_total        NUMERIC;
    v_input_discount_amount  NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Calculated Totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;

    -- Internal Vars
    v_new_invoice_id       UUID;
    v_final_invoice_code   TEXT;
    v_invoice_item_data    RECORD;
    v_sequence_name        TEXT;
    v_quote_data           RECORD;

BEGIN
    -- 1. ESTABLISH BASELINE VALUES (from quote if provided)
    v_business_id          := NULL;
    v_customer_id          := NULL;
    v_billing_address      := NULL;
    v_shipping_address     := NULL;
    v_notes                := NULL;
    v_terms_and_conditions := NULL;
    v_invoice_items        := NULL;
    v_input_tax_total      := 0;
    v_input_discount_amount  := 0;
    v_input_shipping_charges := 0;

    IF v_quote_id IS NOT NULL THEN
        SELECT * INTO v_quote_data FROM public.quotes WHERE quote_id = v_quote_id;
        IF NOT FOUND THEN RAISE EXCEPTION 'Quote with ID % not found.', v_quote_id; END IF;
        
        v_business_id          := v_quote_data.business_id;
        v_customer_id          := v_quote_data.customer_id;
        v_billing_address      := v_quote_data.billing_address;
        v_shipping_address     := v_quote_data.shipping_address;
        v_notes                := v_quote_data.notes;
        v_terms_and_conditions := v_quote_data.terms_and_conditions;
        v_input_tax_total      := v_quote_data.tax_total;
        v_input_discount_amount  := v_quote_data.discount_amount;
        v_input_shipping_charges := v_quote_data.shipping_charges;

        SELECT jsonb_agg(jsonb_build_object('item_id', qi.item_id, 'quantity', qi.quantity, 'unit_price', qi.unit_price))
        INTO v_invoice_items FROM public.quote_items qi WHERE qi.quote_id = v_quote_id;
    END IF;

    -- 2. OVERRIDE WITH JSON PAYLOAD DATA
    v_business_id          := COALESCE((p_invoice_json->>'business_id')::uuid, v_business_id);
    v_customer_id          := COALESCE((p_invoice_json->>'customer_id')::uuid, v_customer_id);
    v_billing_address      := COALESCE((p_invoice_json->>'billing_address')::uuid, v_billing_address);
    v_shipping_address     := COALESCE((p_invoice_json->>'shipping_address')::uuid, v_shipping_address);
    v_notes                := COALESCE(p_invoice_json->>'notes', v_notes);
    v_terms_and_conditions := COALESCE(p_invoice_json->>'terms_and_conditions', v_terms_and_conditions);
    v_input_tax_total        := COALESCE((p_invoice_json->>'tax_total')::numeric, v_input_tax_total);
    v_input_discount_amount  := COALESCE((p_invoice_json->>'discount_amount')::numeric, v_input_discount_amount);
    v_input_shipping_charges := COALESCE((p_invoice_json->>'shipping_charges')::numeric, v_input_shipping_charges);
    v_input_invoice_code   := p_invoice_json->>'invoice_code';
    
    IF p_invoice_json ? 'invoice_items' THEN
        v_invoice_items := p_invoice_json->'invoice_items';
    END IF;

    -- 3. POPULATE COMMON FIELDS AND VALIDATE
    v_created_by    := COALESCE((p_invoice_json->>'created_by')::uuid, auth.uid());
    v_invoice_date  := COALESCE((p_invoice_json->>'invoice_date')::date, current_date);
    v_due_date      := (p_invoice_json->>'due_date')::date;
    v_status        := COALESCE(p_invoice_json->>'status', 'Draft');

    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_invoice_items IS NULL OR jsonb_array_length(v_invoice_items) = 0 THEN RAISE EXCEPTION 'At least one invoice_item is required.'; END IF;

    -- 4. CALCULATE TOTALS
    v_calculated_sub_total := 0;
    FOR v_invoice_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_invoice_items) AS x
    LOOP
        v_calculated_sub_total := v_calculated_sub_total + (v_invoice_item_data.quantity * v_invoice_item_data.unit_price);
    END LOOP;
    v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;
    
    -- 5. DETERMINE INVOICE CODE AND VALIDATE UNIQUENESS
    IF v_input_invoice_code IS NOT NULL AND trim(v_input_invoice_code) <> '' THEN
        -- Use the user-provided code
        v_final_invoice_code := trim(v_input_invoice_code);
    ELSE
        -- Generate the code automatically
        v_sequence_name := 'public."' || v_business_id::text || '_invoice_code"';
        EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';
        v_final_invoice_code := 'INV-' || lpad(nextval(v_sequence_name)::text, 6, '0');
    END IF;

    -- Uniqueness Check (this runs for both custom and generated codes)
    IF EXISTS (SELECT 1 FROM public.invoices WHERE business_id = v_business_id AND invoice_code = v_final_invoice_code) THEN
        RAISE EXCEPTION 'Invoice code "%" already exists for this business.', v_final_invoice_code;
    END IF;

    -- 6. INSERT INTO INVOICES TABLE
    INSERT INTO public.invoices (
        business_id, customer_id, created_by, billing_address, shipping_address,
        invoice_date, due_date, notes, terms_and_conditions, tax_total, sub_total,
        discount_amount, shipping_charges, grand_total, status, quote_id, invoice_code
    ) VALUES (
        v_business_id, v_customer_id, v_created_by, v_billing_address, v_shipping_address,
        v_invoice_date, v_due_date, v_notes, v_terms_and_conditions, v_input_tax_total, v_calculated_sub_total,
        v_input_discount_amount, v_input_shipping_charges, v_calculated_grand_total, v_status, v_quote_id,
        v_final_invoice_code
    ) RETURNING invoice_id INTO v_new_invoice_id;

    -- 7. INSERT INVOICE ITEMS
    FOR v_invoice_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_invoice_items) AS x
    LOOP
        INSERT INTO public.invoice_items (business_id, customer_id, invoice_id, item_id, quantity, unit_price)
        VALUES (v_business_id, v_customer_id, v_new_invoice_id, v_invoice_item_data.item_id, v_invoice_item_data.quantity, v_invoice_item_data.unit_price);
    END LOOP;
    
    -- 8. RETURN SUCCESS
    RETURN jsonb_build_object('invoice_id', v_new_invoice_id, 'invoice_code', v_final_invoice_code, 'status', 'success');

EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to create invoice. Error: %, SQLState: %', SQLERRM, SQLSTATE;
END;$$;


ALTER FUNCTION "public"."create_invoice"("p_invoice_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_paid_subscription_package"("p_org_id" "uuid", "p_plan_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_plan_id" "text", "p_end_date" timestamp with time zone, "p_trial_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_billing_cycle" "public"."billing_cycle_enum", "p_current_start" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_current_end" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    new_subscription_id UUID;
    invoice_item JSONB;
	v_plan_amount numeric;
BEGIN

    IF p_billing_cycle = 'monthly' THEN
        SELECT price_monthly INTO v_plan_amount FROM public.plans JOIN public.plan_prices ON plans.plan_id = plan_prices.plan_id WHERE plans.plan_id = p_plan_id AND plans.is_active = true AND plan_prices.currency_code = 'INR';
    ELSE
        SELECT price_annual INTO v_plan_amount FROM public.plans JOIN public.plan_prices ON plans.plan_id = plan_prices.plan_id WHERE plans.plan_id = p_plan_id AND plans.is_active = true AND plan_prices.currency_code = 'INR';
    END IF;

    -- 1. Insert the new subscription
    INSERT INTO public.subscriptions (
        org_id,
        plan_id,
        payment_provider_subscription_id,
        status,
        start_date,
        payment_provider,
        payment_provider_plan_id,
        end_date,
        trial_end_date,
        current_start,
        current_end,
        created_at,
        updated_at,
		payment_url,
		metadata,
		currency,
		billing_cycle,
		plan_amount
    )
    VALUES (
        p_org_id,
        p_plan_id,
        p_payment_provider_subscription_id,
        p_initial_status,
        p_start_date,
        p_payment_provider,
        p_payment_provider_plan_id,
        p_end_date,
        p_trial_end_date,
        p_current_start,
        p_current_end,
        NOW(),
        NOW(),
		p_payment_url,
		p_metadata,
		'INR',
		p_billing_cycle,
		v_plan_amount
    )
    RETURNING subscription_id INTO new_subscription_id;

    -- 2. Insert all invoices for this subscription
    IF p_invoices IS NOT NULL AND jsonb_array_length(p_invoices) > 0 THEN
        FOR invoice_item IN SELECT * FROM jsonb_array_elements(p_invoices)
        LOOP
            INSERT INTO public.subscription_invoices (
                org_id,
                subscription_id,
                payment_provider_invoice_id,
                payment_provider_subscription_id,
                payment_provider,
                amount,
                currency,
                status,
                issued_at,
                due_date,
                line_items,
                pdf_url,
                notes,
                metadata, -- Storing the full Razorpay invoice object
                created_at,
                updated_at,
				payment_url
            )
            VALUES (
                p_org_id,
                new_subscription_id,
                invoice_item->>'id',
                p_payment_provider_subscription_id,
                p_payment_provider,
                (COALESCE(invoice_item->>'amount', '0')::NUMERIC) / 100,
                invoice_item->>'currency',	
                (invoice_item->>'status')::public.invoice_status_enum,
                CASE WHEN invoice_item->>'issued_at' IS NOT NULL THEN to_timestamp((invoice_item->>'issued_at')::BIGINT) ELSE NULL END,
                CASE
                    WHEN invoice_item->>'expire_by' IS NOT NULL AND invoice_item->>'expire_by' <> 'null'
                    THEN to_timestamp((invoice_item->>'expire_by')::BIGINT)
                    ELSE NULL
                END,
                invoice_item->'line_items',
                invoice_item->>'short_url',
                invoice_item->'notes',
                invoice_item, -- Store the whole invoice item (Razorpay invoice object)
                CASE WHEN invoice_item->>'created_at' IS NOT NULL THEN to_timestamp((invoice_item->>'created_at')::BIGINT) ELSE NOW() END,
                NOW(),
				invoice_item->>'short_url'
            );
        END LOOP;
    END IF;

    -- 3. Update the organization record to indicate trial has been activated
    -- This is an unconditional set to TRUE, meaning a trial flow was initiated.
    UPDATE public.organizations
    SET trial_activated = TRUE
    WHERE org_id = p_org_id;

    RETURN new_subscription_id;

EXCEPTION
    WHEN OTHERS THEN
        -- Log the error server-side (e.g., in PostgreSQL logs) and re-raise to client
        RAISE WARNING 'Error in create_paid_subscription_package for org %: %, SQLSTATE: %', p_org_id, SQLERRM, SQLSTATE;
        RAISE; -- Re-raise the caught exception, which causes transaction rollback
END;
$$;


ALTER FUNCTION "public"."create_paid_subscription_package"("p_org_id" "uuid", "p_plan_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_plan_id" "text", "p_end_date" timestamp with time zone, "p_trial_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_billing_cycle" "public"."billing_cycle_enum", "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_payment"("p_payment_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Input Data Parsed from JSON
    v_business_id       UUID := (p_payment_json->>'business_id')::uuid;
    v_customer_id       UUID := (p_payment_json->>'customer_id')::uuid;
    v_invoice_id        UUID := (p_payment_json->>'invoice_id')::uuid;
    v_amount_received   NUMERIC := (p_payment_json->>'amount_received')::numeric;
    v_payment_date      DATE := (p_payment_json->>'payment_date')::date;
    v_payment_mode      TEXT := p_payment_json->>'payment_mode'; -- Passed as text, PG casts to the enum
    v_deposited_to      TEXT := p_payment_json->>'deposited_to';
    v_reference_number  TEXT := p_payment_json->>'reference_number';
    v_notes             TEXT := p_payment_json->>'notes';
    v_created_by        UUID := COALESCE((p_payment_json->>'created_by')::uuid, auth.uid());

    -- Internal Vars
    v_new_payment_id      UUID;
    v_gen_payment_code    TEXT;
    v_sequence_name       TEXT;

BEGIN
    -- 1. VALIDATE REQUIRED INPUTS
    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_amount_received IS NULL OR v_amount_received <= 0 THEN RAISE EXCEPTION 'A positive amount_received is required.'; END IF;
    IF v_payment_date IS NULL THEN RAISE EXCEPTION 'payment_date is required.'; END IF;

    -- 2. ENSURE SEQUENCE EXISTS FOR THE GIVEN BUSINESS
    v_sequence_name := 'public."' || v_business_id::text || '_payment_code"';
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';
    
    -- 3. INSERT INTO payments_received TABLE (ATOMICALLY)
    INSERT INTO public.payments_received (
        business_id,
        customer_id,
        invoice_id,
        amount_received,
        payment_date,
        payment_mode,
        deposited_to,
        reference_number,
        notes,
        created_by,
        -- The payment_code is generated here
        payment_code
    ) VALUES (
        v_business_id,
        v_customer_id,
        v_invoice_id,
        v_amount_received,
        v_payment_date,
        v_payment_mode::public.payment_type, -- Let PostgreSQL cast the TEXT to your ENUM
        v_deposited_to,
        v_reference_number,
        v_notes,
        v_created_by,
        -- This is the atomic way to generate the code
        public.format_payment_code(v_business_id, nextval(v_sequence_name))
    ) RETURNING payment_id, payment_code INTO v_new_payment_id, v_gen_payment_code;

    -- 4. RETURN SUCCESS MESSAGE WITH NEW ID AND CODE
    RETURN jsonb_build_object(
        'status', 'success',
        'payment_id', v_new_payment_id,
        'payment_code', v_gen_payment_code
    );

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create payment: A unique constraint was violated. This can happen if the payment_code is duplicated. Details: %', SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create payment. Error: %, SQLState: %', SQLERRM, SQLSTATE;
END;
$$;


ALTER FUNCTION "public"."create_payment"("p_payment_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_payment_and_update_invoice"("p_payment_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Input Data Parsed from JSON
    v_business_id       UUID := (p_payment_json->>'business_id')::uuid;
    v_customer_id       UUID := (p_payment_json->>'customer_id')::uuid;
    v_invoice_id        UUID := (p_payment_json->>'invoice_id')::uuid;
    v_amount_received   NUMERIC := (p_payment_json->>'amount_received')::numeric;
    v_payment_date      DATE := (p_payment_json->>'payment_date')::date;
    v_payment_mode      TEXT := p_payment_json->>'payment_mode'; -- Passed as text, PG casts to the enum
    v_deposited_to      TEXT := p_payment_json->>'deposited_to';
    v_reference_number  TEXT := p_payment_json->>'reference_number';
    v_notes             TEXT := p_payment_json->>'notes';
    v_created_by        UUID := COALESCE((p_payment_json->>'created_by')::uuid, auth.uid());

    -- Internal Vars for Payment
    v_new_payment_id      UUID;
    v_gen_payment_code    TEXT;
    v_sequence_name       TEXT;

    -- NEW: Internal Vars for Invoice Handling
    v_invoice_grand_total NUMERIC;
    v_invoice_status      TEXT;

BEGIN
    -- 1. VALIDATE REQUIRED INPUTS
    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_amount_received IS NULL OR v_amount_received <= 0 THEN RAISE EXCEPTION 'A positive amount_received is required.'; END IF;
    IF v_payment_date IS NULL THEN RAISE EXCEPTION 'payment_date is required.'; END IF;

    -- 2. NEW: HANDLE INVOICE-SPECIFIC VALIDATION (if invoice_id is provided)
    IF v_invoice_id IS NOT NULL THEN
        -- Find the invoice and lock the row for update to prevent race conditions
        SELECT grand_total, status
        INTO v_invoice_grand_total, v_invoice_status
        FROM public.invoices
        WHERE invoice_id = v_invoice_id AND business_id = v_business_id
        FOR UPDATE; -- Lock the row to prevent other transactions from modifying it

        -- Check if the invoice was found
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Invoice with ID % could not be found for this business.', v_invoice_id;
        END IF;

        -- Check if the invoice is already paid
        IF v_invoice_status = 'Paid' THEN
            RAISE EXCEPTION 'Invoice % has already been paid.', v_invoice_id;
        END IF;
        
        -- Check if the payment amount is sufficient
        IF v_amount_received < v_invoice_grand_total THEN
            RAISE EXCEPTION 'Payment amount of % is less than the invoice total of %. The full amount is required to mark the invoice as paid.', 
                to_char(v_amount_received, 'FM999G999D00'), 
                to_char(v_invoice_grand_total, 'FM999G999D00');
        END IF;

        -- Note: If v_amount_received > v_invoice_grand_total, we still proceed.
        -- This is considered an overpayment, and the invoice will be marked as 'Paid'.
        -- A more complex system might track overpayments as customer credit.
    END IF;

    -- 3. ENSURE SEQUENCE EXISTS FOR THE GIVEN BUSINESS
    v_sequence_name := 'public."' || v_business_id::text || '_payment_code"';
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';
    
    -- 4. INSERT INTO payments_received TABLE (ATOMICALLY)
    INSERT INTO public.payments_received (
        business_id, customer_id, invoice_id, amount_received, payment_date,
        payment_mode, deposited_to, reference_number, notes, created_by, payment_code
    ) VALUES (
        v_business_id, v_customer_id, v_invoice_id, v_amount_received, v_payment_date,
        v_payment_mode::public.payment_type, v_deposited_to, v_reference_number, v_notes, v_created_by,
        public.format_payment_code(v_business_id, nextval(v_sequence_name))
    ) RETURNING payment_id, payment_code INTO v_new_payment_id, v_gen_payment_code;

    -- 5. NEW: UPDATE THE INVOICE STATUS (if applicable)
    IF v_invoice_id IS NOT NULL THEN
        UPDATE public.invoices
        SET status = 'paid'
        WHERE invoice_id = v_invoice_id AND business_id = v_business_id;
    END IF;

    -- 6. RETURN SUCCESS MESSAGE WITH NEW ID AND CODE
    RETURN jsonb_build_object(
        'status', 'success',
        'message', 'Payment created successfully.',
        'payment_id', v_new_payment_id,
        'payment_code', v_gen_payment_code
    );

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create payment: A unique constraint was violated. This can happen if the payment_code is duplicated. Details: %', SQLERRM;
    WHEN others THEN
        -- Re-raise any other exception, including our custom ones from above
        RAISE EXCEPTION 'Failed to create payment. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_payment_and_update_invoice"("p_payment_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_payment_received"("p_payment_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Input Data Parsed from JSON
    v_business_id       UUID    := (p_payment_json->>'business_id')::uuid;
    v_customer_id       UUID    := (p_payment_json->>'customer_id')::uuid;
    v_invoice_id        UUID    := (p_payment_json->>'invoice_id')::uuid;
    v_amount_received   NUMERIC := (p_payment_json->>'amount_received')::numeric;
    v_payment_date      DATE    := (p_payment_json->>'payment_date')::date;
    v_payment_mode      TEXT    := p_payment_json->>'payment_mode';
    v_deposited_to      TEXT    := p_payment_json->>'deposited_to';
    v_reference_number  TEXT    := p_payment_json->>'reference_number';
    v_notes             TEXT    := p_payment_json->>'notes';
    v_created_by        UUID    := COALESCE((p_payment_json->>'created_by')::uuid, auth.uid());

    -- Internal Processing Variables
    v_new_payment_id      UUID;
    v_gen_payment_code    TEXT;
    v_sequence_name       TEXT;
    v_invoice_balance_due NUMERIC;

BEGIN
    -- 1. VALIDATE REQUIRED INPUTS
    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_amount_received IS NULL OR v_amount_received <= 0 THEN RAISE EXCEPTION 'A positive amount_received is required.'; END IF;
    IF v_payment_date IS NULL THEN RAISE EXCEPTION 'payment_date is required.'; END IF;
    IF v_payment_mode IS NULL THEN RAISE EXCEPTION 'payment_mode is required.'; END IF;
    IF v_deposited_to IS NULL THEN RAISE EXCEPTION 'deposited_to is required.'; END IF;

    -- 2. HANDLE INVOICE-SPECIFIC LOGIC (if invoice_id is provided)
    IF v_invoice_id IS NOT NULL THEN
        -- Lock the invoice row to prevent race conditions (e.g., two payments at the same time).
        -- This ensures that balance checks and updates are atomic for this transaction.
        SELECT balance_due INTO v_invoice_balance_due
        FROM public.invoices
        WHERE invoice_id = v_invoice_id AND business_id = v_business_id
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Invoice with ID % could not be found for this business.', v_invoice_id;
        END IF;

        -- Check for overpayment. We allow it but raise a warning so the front-end can be aware.
        -- This is often desired behavior, with the overage becoming general customer credit.
        IF v_amount_received > v_invoice_balance_due THEN
            RAISE WARNING 'Payment amount % is greater than the balance due %. The invoice will be marked as Paid, creating an overpayment.',
                to_char(v_amount_received, 'FM999G999D00'),
                to_char(v_invoice_balance_due, 'FM999G999D00');
        END IF;

        -- Atomically update the invoice's amount paid.
        -- The `balance_due` column will be updated automatically by the database.
        UPDATE public.invoices
        SET amount_paid = amount_paid + v_amount_received
        WHERE invoice_id = v_invoice_id;
    END IF;

    -- 3. GENERATE A UNIQUE PAYMENT CODE
    -- This uses your existing pattern of a business-specific sequence.
    v_sequence_name := 'public."' || v_business_id::text || '_payment_code"';
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';

    -- It's good practice to have a formatting function, but a simple concat also works.
    -- v_gen_payment_code := 'PAY-' || nextval(v_sequence_name);
    v_gen_payment_code := public.format_payment_code(v_business_id, nextval(v_sequence_name));

    -- 4. INSERT THE NEW RECORD INTO THE payments_received TABLE
    INSERT INTO public.payments_received (
        business_id, customer_id, invoice_id, amount_received, payment_date,
        payment_mode, deposited_to, reference_number, notes, created_by, payment_code
    ) VALUES (
        v_business_id, v_customer_id, v_invoice_id, v_amount_received, v_payment_date,
        v_payment_mode::public.payment_type, v_deposited_to, v_reference_number, v_notes, v_created_by,
        v_gen_payment_code
    ) RETURNING payment_id, payment_code INTO v_new_payment_id, v_gen_payment_code;

    -- 5. UPDATE THE INVOICE STATUS (if applicable)
    -- This is done after the payment is successfully recorded.
    IF v_invoice_id IS NOT NULL THEN
        PERFORM public.update_invoice_status(v_invoice_id);
    END IF;

    -- 6. RETURN A SUCCESS RESPONSE
    -- This gives the front-end app confirmation and the necessary IDs.
    RETURN jsonb_build_object(
        'status', 'success',
        'message', 'Payment created successfully.',
        'payment_id', v_new_payment_id,
        'payment_code', v_gen_payment_code
    );

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create payment: A unique constraint was violated. This can happen if the payment_code is duplicated. Details: %', SQLERRM;
    WHEN others THEN
        -- Re-raise any other exception, including our custom ones from the validation step.
        RAISE EXCEPTION 'Failed to create payment. Error: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;


ALTER FUNCTION "public"."create_payment_received"("p_payment_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_purchase"("p_purchase_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_purchase_json->>'business_id')::uuid;
    v_org_id              UUID := (p_purchase_json->>'org_id')::uuid; -- Assuming org_id is passed
    v_supplier_id         UUID := (p_purchase_json->>'supplier_id')::uuid;
    v_user_provided_inv_no TEXT := p_purchase_json->>'purchase_invoice';
    v_purchase_date       TIMESTAMPTZ := COALESCE((p_purchase_json->>'purchase_date')::timestamptz, now());
    v_notes               TEXT := p_purchase_json->>'notes';
    v_attachment_url      TEXT := p_purchase_json->>'attachment';
    v_subtotal            NUMERIC := COALESCE((p_purchase_json->>'subtotal')::numeric, 0);
    v_discount_amount     NUMERIC := COALESCE((p_purchase_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_purchase_json->>'shipping')::numeric, 0);
    v_tax_amount          NUMERIC := COALESCE((p_purchase_json->>'tax_amount')::numeric, 0); -- Tax handling needs its own GL logic if not just part of grand_total
    v_grand_total         NUMERIC := COALESCE((p_purchase_json->>'grand_total')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_purchase_json->>'paid_amount')::numeric, 0);
    v_due_amount          NUMERIC; -- Will be calculated
    v_purchase_items      JSONB := p_purchase_json->'purchase_items';
    v_payment_details     JSONB := p_purchase_json->'payment_details';

    -- Internal Vars
    v_transaction_id      UUID;
    v_purchase_id         UUID;
    v_gen_reference_no    TEXT;
    v_status              public.transaction_status;
    v_acting_user_id      UUID := auth.uid(); -- User performing the action
    v_total_inventory_value_debited NUMERIC := 0; -- Sum of inventoriable item line totals
    v_total_non_inventory_exp_debited NUMERIC := 0; -- Sum of non-inventoriable item line totals
    v_payment_id          UUID;
    v_purchase_item_data  RECORD;
    v_payment_method      TEXT;
    v_payment_amount      NUMERIC;

    -- Account IDs & Codes (COA v6.4)
    v_inventory_acc_id          UUID;
    v_ap_acc_id                 UUID; -- Accounts Payable
    v_freight_in_acc_id         UUID; -- Freight-In / Purchase Shipping
    v_cash_in_bank_acc_id       UUID;
    v_petty_cash_acc_id         UUID;
    v_purchase_discount_acc_id  UUID;
    v_non_inventory_exp_acc_id  UUID; -- For non-stock items purchased

    v_inventory_code            TEXT := '1130';
    v_ap_code                   TEXT := '2110';
    v_freight_in_code           TEXT := '5310';
    v_cash_in_bank_code         TEXT := '1111';
    v_petty_cash_code           TEXT := '1113';
    v_purchase_discount_code    TEXT := '5800';
    v_non_inventory_exp_code    TEXT := '6015';

BEGIN
    RAISE LOG 'create_purchase: Starting for Business: %, Org: %, Supplier: %', v_business_id, v_org_id, v_supplier_id;

    -- Validate Inputs
    IF v_business_id IS NULL OR v_org_id IS NULL OR v_supplier_id IS NULL OR v_purchase_items IS NULL OR jsonb_array_length(v_purchase_items) = 0 THEN
        RAISE EXCEPTION 'business_id, org_id, supplier_id, and at least one purchase_item are required.';
    END IF;
    IF v_purchase_date IS NULL THEN v_purchase_date := now(); END IF;

    v_due_amount := v_grand_total - v_paid_amount; -- Calculate due amount

    -- Basic validation of amounts
    IF abs(v_subtotal - v_discount_amount + v_shipping_charge + v_tax_amount - v_grand_total) > 0.01 THEN
         RAISE WARNING 'Grand total % does not precisely match sum of components for Business: %, Org: % (Sub:%, Disc:%, Ship:%, Tax:%). Check input JSON.',
           v_grand_total, v_business_id, v_org_id, v_subtotal, v_discount_amount, v_shipping_charge, v_tax_amount;
    END IF;

    -- Fetch Account IDs (including org_id in WHERE clause)
    RAISE LOG 'create_purchase: Fetching account IDs for Business: %, Org: %', v_business_id, v_org_id;
    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_inventory_code AND is_group = FALSE;
    SELECT account_id INTO v_ap_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ap_code AND is_group = FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_freight_in_code AND is_group = FALSE;
    SELECT account_id INTO v_cash_in_bank_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    SELECT account_id INTO v_petty_cash_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_purchase_discount_code AND is_group = FALSE;
    SELECT account_id INTO v_non_inventory_exp_acc_id FROM public.accounts WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_non_inventory_exp_code AND is_group = FALSE;

    IF v_inventory_acc_id IS NULL OR v_ap_acc_id IS NULL OR v_freight_in_acc_id IS NULL
       OR v_cash_in_bank_acc_id IS NULL OR v_petty_cash_acc_id IS NULL OR v_purchase_discount_acc_id IS NULL OR v_non_inventory_exp_acc_id IS NULL THEN
        RAISE EXCEPTION 'One or more required accounts not found for Business: %, Org: %. Check Inventory(1130), A/P(2110), Freight-In(5310), Bank(1111), Cash(1113), PurchDisc(5800), NonInvExp(6015).', v_business_id, v_org_id;
    END IF;

    -- Generate Internal Reference Number
    SELECT public.get_next_purchase_code(v_business_id) INTO v_gen_reference_no; -- Assuming function might need org_id
    RAISE LOG 'create_purchase: Generated ref: %', v_gen_reference_no;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
    ELSIF v_paid_amount > 0 THEN
        v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE
        v_status := 'PENDING'::public.transaction_status;
    END IF;

	-- 1. Create Purchase Transaction Header
	INSERT INTO public.transactions (
	    reference_no, transaction_type, transaction_date, status,
	    total_amount, paid_amount, due_amount,
	    notes, business_id, org_id, created_by, updated_by, supplier_id
	) VALUES (
	    v_gen_reference_no, 'PURCHASE'::public.transaction_type, v_purchase_date, v_status,
	    v_grand_total, v_paid_amount, v_due_amount,
	    v_notes, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_supplier_id
	) RETURNING transaction_id INTO v_transaction_id;
	RAISE LOG 'create_purchase: Created transaction ID: %', v_transaction_id;
	
	-- 2. Create Purchase Header Record
	INSERT INTO public.purchases (
	    purchase_id, -- generate new
        invoice_no, supplier_id, purchase_date, transaction_id,
	    subtotal, discount_amount, tax_amount, shipping_charge, total_amount,
	    paid_amount, due_amount, business_id, created_by, updated_by, notes,
	    attachment_url, purchase_invoice, 
	    created_at, updated_at
	) VALUES (
	    gen_random_uuid(), 
        v_gen_reference_no, v_supplier_id, v_purchase_date, v_transaction_id,
	    v_subtotal, v_discount_amount, v_tax_amount, v_shipping_charge, v_grand_total,
	    v_paid_amount, v_due_amount, v_business_id, v_acting_user_id, v_acting_user_id, v_notes,
	    v_attachment_url, v_user_provided_inv_no,
	    now(), now()
	) RETURNING purchases.purchase_id INTO v_purchase_id;
	RAISE LOG 'create_purchase: Created purchase ID: %', v_purchase_id;
	
	-- 3. Process Purchase Items and their GL Debits
	FOR v_purchase_item_data IN SELECT * FROM jsonb_to_recordset(v_purchase_items) AS x(item_id uuid, quantity numeric, unit_price numeric, item_name text) -- Added item_name for logging
	LOOP
	    DECLARE
	        v_item_id UUID := v_purchase_item_data.item_id;
	        v_quantity NUMERIC := v_purchase_item_data.quantity;
	        v_unit_price NUMERIC := v_purchase_item_data.unit_price;
	        v_line_total NUMERIC := v_quantity * v_unit_price;
	        v_item_inventory_enabled BOOLEAN;
            v_current_item_name TEXT := v_purchase_item_data.item_name; -- Use name from JSON if provided
	    BEGIN
            IF v_current_item_name IS NULL THEN -- Fetch if not in JSON
                SELECT name INTO v_current_item_name FROM public.items WHERE items.item_id = v_item_id;
            END IF;

	        RAISE LOG 'create_purchase: Item: "%", Qty: %, Price: %, LineTotal: %', COALESCE(v_current_item_name, v_item_id::text), v_quantity, v_unit_price, v_line_total;
	        
	        INSERT INTO public.purchase_items (purchase_id, item_id, quantity, unit_price, created_by, updated_by)
	        VALUES (v_purchase_id, v_item_id, v_quantity, v_unit_price, v_acting_user_id, v_acting_user_id);
	
	        SELECT i.inventory_enabled INTO v_item_inventory_enabled
	        FROM public.items i
	        WHERE i.item_id = v_item_id AND i.business_id = v_business_id AND i.org_id = v_org_id;
	
	        IF FOUND AND v_item_inventory_enabled THEN
	            UPDATE public.items
	            SET stock_quantity = items.stock_quantity + v_quantity,
					stock_value = stock_value + v_line_total,
	                updated_at = now(),
                    updated_by = v_acting_user_id
	            WHERE items.item_id = v_item_id;
	
	            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	            VALUES (v_transaction_id, v_inventory_acc_id, 'DEBIT'::public.entry_type, v_line_total, 'Purchase: Item ' || COALESCE(v_current_item_name, v_item_id::text));
	            v_total_inventory_value_debited := v_total_inventory_value_debited + v_line_total;
	        ELSE
                -- Non-inventoriable item or service purchase
	            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	            VALUES (v_transaction_id, v_non_inventory_exp_acc_id, 'DEBIT'::public.entry_type, v_line_total, 'Purchase (Non-Inv): ' || COALESCE(v_current_item_name, v_item_id::text));
                v_total_non_inventory_exp_debited := v_total_non_inventory_exp_debited + v_line_total;
	            RAISE LOG 'create_purchase: Item %s ("%s") is non-inventoriable or not found. Debited Non-Inv Expense.', v_item_id, COALESCE(v_current_item_name, 'N/A');
	        END IF;
	    END;
	END LOOP;
	
	-- 4. Create Other Purchase GL Entries
	IF v_shipping_charge > 0 THEN
	    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	    VALUES (v_transaction_id, v_freight_in_acc_id, 'DEBIT'::public.entry_type, v_shipping_charge, 'Purchase: Shipping/Freight-In');
	END IF;
	
	IF v_discount_amount > 0 THEN
	    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	    VALUES (v_transaction_id, v_purchase_discount_acc_id, 'CREDIT'::public.entry_type, v_discount_amount, 'Purchase: Discount Received');
	END IF;
	
    -- Handle Tax: If v_tax_amount is exclusively for purchase tax you want to track as an asset (recoverable) or expense
    -- For simplicity, if tax is just part of the grand_total owed to supplier (and not separately recoverable),
    -- it's implicitly included in the A/P credit. If it's like VAT input credit, you'd debit a Tax Asset account.
    -- Example (if you had a "Purchase Tax Asset" account, e.g., code '1180'):
    -- IF v_tax_amount > 0 THEN
    --     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    --     VALUES (v_transaction_id, v_purchase_tax_asset_acc_id, 'DEBIT', v_tax_amount, 'Purchase: Input Tax');
    -- END IF;
	
	INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	VALUES (v_transaction_id, v_ap_acc_id, 'CREDIT'::public.entry_type, v_grand_total, 'Purchase Payable to Supplier: ' || v_supplier_id::text);
	
	-- 5. Process Immediate Payment (if any)
	IF v_paid_amount > 0 AND v_payment_details IS NOT NULL THEN
	    FOR v_payment_method, v_payment_amount IN SELECT key, value::text::numeric FROM jsonb_each_text(v_payment_details) WHERE value::text::numeric > 0
	    LOOP
	         DECLARE
	             v_payment_asset_account_id UUID;
	         BEGIN
	             RAISE LOG 'create_purchase: Payment: Method="%", Amount=%', v_payment_method, v_payment_amount;
	             IF lower(v_payment_method) = 'cash' THEN
	                v_payment_asset_account_id := v_petty_cash_acc_id;
	             ELSE -- Assume 'bank', 'card', etc. go to bank account
	                v_payment_asset_account_id := v_cash_in_bank_acc_id;
	             END IF;
	
	             INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	             VALUES (v_transaction_id, v_ap_acc_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment for Purchase Ref ' || v_gen_reference_no);
	
	             INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
	             VALUES (v_transaction_id, v_payment_asset_account_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment for Purchase Ref ' || v_gen_reference_no);
	
	             INSERT INTO public.payments (
                     payment_id, -- generate new
	                 transaction_id, payment_date, amount, payment_method, reference_no, 
                     created_by, updated_by
	             ) VALUES (
                     gen_random_uuid(),
	                 v_transaction_id, v_purchase_date, v_payment_amount, v_payment_method, v_gen_reference_no, 
                     v_acting_user_id, v_acting_user_id
	             );
	         END;
	    END LOOP;
	END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_purchase: Completed for Txn ID: %, Purchase ID: %', v_transaction_id, v_purchase_id;
	PERFORM nextval(v_business_id::text || '_purchase_invoice');
    RETURN (SELECT row_to_json(purchase_view)
    FROM purchase_view
    WHERE purchase_id = v_purchase_id);

EXCEPTION
	WHEN unique_violation THEN
	    RAISE EXCEPTION 'Failed to create purchase: Unique constraint violated. Invoice No "%s" or Ref No "%s". Detail: %s', v_user_provided_inv_no, v_gen_reference_no, SQLERRM;
	WHEN others THEN
	    RAISE EXCEPTION 'Failed to create purchase for Business: %s, Org: %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_purchase"("p_purchase_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_purchase_return"("p_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data
    v_business_id         UUID := (p_data->>'business_id')::uuid;
    v_purchase_id         UUID := (p_data->>'purchase_id')::uuid; -- ID of the original purchase
    v_return_date         TIMESTAMPTZ := COALESCE((p_data->>'return_date')::timestamptz, now());
    v_return_invoice      TEXT := p_data->>'return_invoice'; -- Ref number for the return doc
    v_reason              TEXT := p_data->>'reason';
    v_notes               TEXT := p_data->>'notes';
    v_return_items        JSONB := p_data->'items'; -- Array of items being returned

    -- Internal Vars
    v_transaction_id      UUID;
    v_return_id           UUID; -- PK for purchase_returns table
    v_supplier_id         UUID;
    v_user_id             UUID := auth.uid();
    v_total_return_value  NUMERIC := 0;
    v_return_item_data    RECORD; -- For looping

    -- Account IDs & Codes
    v_ap_supplier_acc_id      UUID;
    v_pur_ret_allow_acc_id    UUID; -- Purchase Returns & Allowances account

    v_ap_supplier_code        TEXT := '2010';
    v_pur_ret_allow_code      TEXT := '5041'; -- <<< New Account Code

BEGIN
    -- Validate Inputs
    IF v_business_id IS NULL OR v_purchase_id IS NULL OR v_return_items IS NULL OR jsonb_array_length(v_return_items) = 0 THEN
        RAISE EXCEPTION 'business_id, purchase_id, and at least one return item are required.';
    END IF;
    IF v_return_invoice IS NULL OR trim(v_return_invoice) = '' THEN
        -- Generate if needed, or make mandatory
        v_return_invoice := 'PRTN-' || to_char(v_return_date, 'YYYYMMDD') || '-' || upper(substring(gen_random_uuid()::text from 1 for 6));
        RAISE WARNING 'Return invoice reference not provided, generated: %', v_return_invoice;
    END IF;

    -- Get Supplier ID from the original purchase
    SELECT p.supplier_id INTO v_supplier_id
    FROM public.purchases p
    WHERE p.purchase_id = v_purchase_id AND p.business_id = v_business_id;

    IF v_supplier_id IS NULL THEN
        RAISE EXCEPTION 'Original Purchase ID % not found for business %.', v_purchase_id, v_business_id;
    END IF;

    -- Fetch Account IDs
    SELECT account_id INTO v_ap_supplier_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_ap_supplier_code;
    SELECT account_id INTO v_pur_ret_allow_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_pur_ret_allow_code;

    IF v_ap_supplier_acc_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Payable - Suppliers account (Code: %) not found for business %.', v_ap_supplier_code, v_business_id;
    END IF;
    IF v_pur_ret_allow_acc_id IS NULL THEN
        RAISE EXCEPTION 'Purchase Returns and Allowances account (Code: %) not found for business %.', v_pur_ret_allow_code, v_business_id;
    END IF;

    -- Calculate total return value from items *at their original purchase unit price*
    -- Assumes input JSON 'items' has 'purchase_item_id' (from original purchase) and 'quantity' being returned
    SELECT COALESCE(SUM(ri.quantity * pi.unit_price), 0)
    INTO v_total_return_value
    FROM jsonb_to_recordset(v_return_items) AS ri(purchase_item_id uuid, quantity numeric) -- Adjust keys if needed
    JOIN public.purchase_items pi ON pi.purchase_item_id = ri.purchase_item_id
    WHERE pi.purchase_id = v_purchase_id; -- Ensure items belong to original purchase

    IF v_total_return_value <= 0 THEN
        RAISE EXCEPTION 'Return items invalid or total return value is zero or less.';
    END IF;


    -- Create Transaction Header for the Return
    -- Status is PAID because the liability adjustment is complete. No money necessarily changed hands yet.
    -- paid_amount = 0 initially. due_amount = 0 initially.
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status,
        total_amount, paid_amount, due_amount,
        notes, business_id, created_by, supplier_id
    ) VALUES (
        v_return_invoice, 'PURCHASE_RETURN'::public.transaction_type, v_return_date, 'PAID'::public.transaction_status,
        v_total_return_value, 0, 0, -- Initially no payment/refund applied to this return transaction itself
        'Purchase Return: ' || COALESCE(v_reason, ''), v_business_id, v_user_id, v_supplier_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- Create Correct Transaction Entries
    -- Debit A/P (Reduce liability to supplier)
    -- Credit Purchase Returns & Allowances (Reduce cost of purchases)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES
        (v_transaction_id, v_ap_supplier_acc_id, 'DEBIT'::public.entry_type, v_total_return_value, 'Purchase Return Ref ' || v_return_invoice),
        (v_transaction_id, v_pur_ret_allow_acc_id, 'CREDIT'::public.entry_type, v_total_return_value, 'Purchase Return Ref ' || v_return_invoice);

    -- Verify balance of this return transaction
    PERFORM public.verify_transaction_balance(v_transaction_id);

    -- Create Purchase Return Header Record
    INSERT INTO public.purchase_returns (
        return_id, -- Add return_id if it's the primary key
        purchase_id, return_invoice, return_date, reason, notes,
        total_amount, transaction_id, business_id, created_by
    ) VALUES (
        gen_random_uuid(), -- Assuming default PK generation
        v_purchase_id, v_return_invoice, v_return_date, v_reason, v_notes,
        v_total_return_value, v_transaction_id, v_business_id, v_user_id
    ) RETURNING purchase_returns.return_id INTO v_return_id; -- Ensure PK column name is correct

    -- Create Return Item Details and Update Stock Quantity
    FOR v_return_item_data IN
        SELECT
            ri.item_id,
            ri.purchase_item_id, -- Link to original purchase item line
            ri.quantity,
            pi.unit_price, -- Use original unit price for value calculation consistency
            i.inventory_enabled
        FROM jsonb_to_recordset(v_return_items) AS ri(item_id uuid, purchase_item_id uuid, quantity numeric) -- Adjust keys if needed
        JOIN public.purchase_items pi ON pi.purchase_item_id = ri.purchase_item_id AND pi.item_id = ri.item_id -- Ensure item matches
        JOIN public.items i ON i.item_id = ri.item_id
        WHERE pi.purchase_id = v_purchase_id -- Ensure item belongs to original purchase
    LOOP
        -- Insert return item detail
        INSERT INTO public.purchase_return_items (
            return_id, purchase_item_id, quantity, unit_price -- Store original unit price for reference
        ) VALUES (
            v_return_id,
            v_return_item_data.purchase_item_id,
            v_return_item_data.quantity,
            v_return_item_data.unit_price
        );

        -- Update item inventory quantity if applicable
        IF v_return_item_data.inventory_enabled THEN
            UPDATE public.items
            SET stock_quantity = stock_quantity - v_return_item_data.quantity,
                updated_at = now()
                -- DO NOT update stock_value here. The GL entry handles value.
            WHERE item_id = v_return_item_data.item_id;
        END IF;
    END LOOP;

    -- NO automatic payment creation here. A refund received is a separate event.
    -- NO direct updates to purchase.due_amount or supplier.supplier_balance. Triggers handle this.
    -- NO redundant nextval call.

    RAISE NOTICE 'Purchase Return created successfully. Transaction ID: %', v_transaction_id;
    RETURN v_transaction_id; -- Return the transaction ID of the return

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error creating purchase return: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_purchase_return"("p_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_quote"("p_quote_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    -- Input Data Parsed
    v_business_id          UUID := (p_quote_json->>'business_id')::uuid;
    v_customer_id          UUID := (p_quote_json->>'customer_id')::uuid;
    v_created_by           UUID := COALESCE((p_quote_json->>'created_by')::uuid, auth.uid());
    v_billing_address      UUID := (p_quote_json->>'billing_address')::uuid;
    v_shipping_address     UUID := (p_quote_json->>'shipping_address')::uuid;
    v_quote_date           DATE := COALESCE((p_quote_json->>'quote_date')::date, current_date);
    v_valid_until_date     DATE := (p_quote_json->>'valid_until_date')::date;
    v_notes                TEXT := p_quote_json->>'notes';
    v_terms_and_conditions TEXT := p_quote_json->>'terms_and_conditions';
    v_status               TEXT := COALESCE(p_quote_json->>'status', 'Draft');
    v_quote_items          JSONB := p_quote_json->'quote_items';
    v_input_quote_code     TEXT := p_quote_json->>'quote_code'; -- Get user-provided code

    -- Amounts from JSON
    v_input_tax_total        NUMERIC := COALESCE((p_quote_json->>'tax_total')::numeric, 0);
    v_input_discount_amount  NUMERIC := COALESCE((p_quote_json->>'discount_amount')::numeric, 0);
    v_input_shipping_charges NUMERIC := COALESCE((p_quote_json->>'shipping_charges')::numeric, 0);

    -- Internal Calculated Totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;

    -- Internal Vars
    v_new_quote_id         UUID;
    v_quote_item_data      RECORD;
    v_final_quote_code     TEXT; -- Variable to hold the final validated code
    v_sequence_name        TEXT;

BEGIN
    -- 1. VALIDATE REQUIRED INPUTS
    IF v_business_id IS NULL THEN RAISE EXCEPTION 'business_id is required.'; END IF;
    IF v_customer_id IS NULL THEN RAISE EXCEPTION 'customer_id is required.'; END IF;
    IF v_quote_items IS NULL OR jsonb_array_length(v_quote_items) = 0 THEN RAISE EXCEPTION 'At least one quote_item is required.'; END IF;

    -- 2. DETERMINE QUOTE CODE AND VALIDATE UNIQUENESS
    IF v_input_quote_code IS NOT NULL AND trim(v_input_quote_code) <> '' THEN
        -- Use the user-provided code after trimming whitespace
        v_final_quote_code := trim(v_input_quote_code);
    ELSE
        -- Generate the code automatically if not provided
        v_sequence_name := 'public."' || v_business_id::text || '_quote_code"';
        EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';
        v_final_quote_code := 'Q-' || lpad(nextval(v_sequence_name)::text, 6, '0');
    END IF;

    -- Proactive Uniqueness Check
    IF EXISTS (SELECT 1 FROM public.quotes WHERE business_id = v_business_id AND quote_code = v_final_quote_code) THEN
        RAISE EXCEPTION 'Quote code "%" already exists for this business.', v_final_quote_code;
    END IF;

    -- 3. CALCULATE TOTALS
    FOR v_quote_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_quote_items) AS x
    LOOP
        v_calculated_sub_total := v_calculated_sub_total + (v_quote_item_data.quantity * v_quote_item_data.unit_price);
    END LOOP;

    v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;

    -- 4. INSERT INTO public.quotes TABLE
    INSERT INTO public.quotes (
        business_id, customer_id, created_by, billing_address, shipping_address,
        quote_date, valid_until_date, notes, terms_and_conditions, tax_total, sub_total,
        discount_amount, shipping_charges, grand_total, status, quote_code
    ) VALUES (
        v_business_id, v_customer_id, v_created_by, v_billing_address, v_shipping_address,
        v_quote_date, v_valid_until_date, v_notes, v_terms_and_conditions, v_input_tax_total, v_calculated_sub_total,
        v_input_discount_amount, v_input_shipping_charges, v_calculated_grand_total, v_status,
        v_final_quote_code
    ) RETURNING quote_id INTO v_new_quote_id;

    -- 5. INSERT INTO public.quote_items TABLE
    FOR v_quote_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_quote_items) AS x
    LOOP
        INSERT INTO public.quote_items (business_id, customer_id, quote_id, item_id, quantity, unit_price)
        VALUES (v_business_id, v_customer_id, v_new_quote_id, v_quote_item_data.item_id, v_quote_item_data.quantity, v_quote_item_data.unit_price);
    END LOOP;

    -- 6. RETURN SUCCESS
    RETURN jsonb_build_object(
        'quote_id', v_new_quote_id,
        'quote_code', v_final_quote_code,
        'status', 'success'
    );

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create quote. Error: %, SQLState: %', SQLERRM, SQLSTATE;
END;$$;


ALTER FUNCTION "public"."create_quote"("p_quote_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_refund"("p_refund_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Source IDs (from JSON payload)
    v_source_payment_id     UUID := (p_refund_json->>'source_payment_id')::uuid;
    v_source_credit_note_id UUID := (p_refund_json->>'source_credit_note_id')::uuid;

    -- Refund Data from JSON
    v_amount_to_refund  NUMERIC := (p_refund_json->>'amount_refunded')::numeric;
    v_refund_date       DATE := (p_refund_json->>'refund_date')::date;
    v_payment_mode      TEXT := p_refund_json->>'payment_mode';
    v_deposited_to      TEXT := p_refund_json->>'deposited_to';
    v_reference_number  TEXT := p_refund_json->>'reference_number';
    v_notes             TEXT := p_refund_json->>'notes';
    v_refund_status     TEXT := COALESCE(p_refund_json->>'refund_status', 'completed');
    v_created_by        UUID := COALESCE((p_refund_json->>'created_by')::uuid, auth.uid());

    -- Internal Processing Variables
    v_new_refund_id     UUID;
    v_is_credit_note    BOOLEAN;
    v_business_id       UUID;
    v_customer_id       UUID;
    v_invoice_id        UUID;
    v_refundable_amount NUMERIC;
    v_payment_record    RECORD;
    v_cn_record         RECORD;
BEGIN
    -- 1. VALIDATE CORE INPUTS
    IF v_amount_to_refund IS NULL OR v_amount_to_refund <= 0 THEN RAISE EXCEPTION 'A positive amount_refunded is required.'; END IF;
    IF v_source_payment_id IS NULL AND v_source_credit_note_id IS NULL THEN RAISE EXCEPTION 'Either source_payment_id or source_credit_note_id must be provided.'; END IF;
    IF v_source_payment_id IS NOT NULL AND v_source_credit_note_id IS NOT NULL THEN RAISE EXCEPTION 'Provide only one source: source_payment_id or source_credit_note_id.'; END IF;

    -- 2. PROCESS REFUND BASED ON SOURCE
    IF v_source_payment_id IS NOT NULL THEN
        -- >> REFUND FROM A PAYMENT RECEIVED << --
        v_is_credit_note := false;

        SELECT * INTO v_payment_record FROM public.payments_received WHERE payment_id = v_source_payment_id FOR UPDATE;
        IF NOT FOUND THEN RAISE EXCEPTION 'Source payment with ID % not found.', v_source_payment_id; END IF;
        
        v_refundable_amount := v_payment_record.amount_received - v_payment_record.amount_refunded;
        IF v_amount_to_refund > v_refundable_amount THEN
            RAISE EXCEPTION 'Refund amount % exceeds the refundable amount % for this payment.', v_amount_to_refund, v_refundable_amount;
        END IF;

        v_business_id := v_payment_record.business_id;
        v_customer_id := v_payment_record.customer_id;
        v_invoice_id  := v_payment_record.invoice_id;

        UPDATE public.payments_received SET amount_refunded = amount_refunded + v_amount_to_refund WHERE payment_id = v_source_payment_id;

        IF v_invoice_id IS NOT NULL THEN
            UPDATE public.invoices SET amount_paid = amount_paid - v_amount_to_refund WHERE invoice_id = v_invoice_id;
        END IF;

    ELSE -- v_source_credit_note_id IS NOT NULL
        -- >> REFUND FROM A CREDIT NOTE (CASH OUT) << --
        v_is_credit_note := true;
        
        SELECT * INTO v_cn_record FROM public.credit_notes WHERE credit_note_id = v_source_credit_note_id FOR UPDATE;
        IF NOT FOUND THEN RAISE EXCEPTION 'Source credit note with ID % not found.', v_source_credit_note_id; END IF;

        IF v_amount_to_refund > v_cn_record.credit_remaining THEN
            RAISE EXCEPTION 'Refund amount % exceeds the remaining credit % for this credit note.', v_amount_to_refund, v_cn_record.credit_remaining;
        END IF;

        v_business_id := v_cn_record.business_id;
        v_customer_id := v_cn_record.customer_id;
        v_invoice_id  := v_cn_record.invoice_id;

        UPDATE public.credit_notes SET credit_remaining = credit_remaining - v_amount_to_refund WHERE credit_note_id = v_source_credit_note_id;
    END IF;

    -- 3. INSERT THE REFUND RECORD (WITH SOURCE IDs)
    INSERT INTO public.refund_payments (
        business_id, customer_id, invoice_id, is_credit_note, amount_refunded,
        refund_date, payment_mode, deposited_to, reference_number, notes, created_by, refund_status,
        source_payment_id, source_credit_note_id -- New columns
    ) VALUES (
        v_business_id, v_customer_id, v_invoice_id, v_is_credit_note, v_amount_to_refund,
        v_refund_date, v_payment_mode::public.payment_type, v_deposited_to, v_reference_number, v_notes, v_created_by,
        v_refund_status::public.payment_recieved,
        v_source_payment_id, v_source_credit_note_id -- New values
    ) RETURNING refund_id INTO v_new_refund_id;
    
    -- 4. UPDATE STATUSES OF AFFECTED DOCUMENTS
    IF v_invoice_id IS NOT NULL AND v_is_credit_note = false THEN
        PERFORM public.update_invoice_status(v_invoice_id);
    ELSIF v_is_credit_note = true THEN
        PERFORM public.update_credit_note_status(v_source_credit_note_id);
    END IF;

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object(
        'status', 'success',
        'message', 'Refund created successfully.',
        'refund_id', v_new_refund_id
    );
EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to create refund. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_refund"("p_refund_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_sale"("p_sale_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$DECLARE
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
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_products_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_services_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_tax_payable_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_tax_payable_code AND is_group=FALSE;
    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_inventory_code AND is_group=FALSE;
    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    SELECT account_id INTO v_cash_in_bank_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_cash_in_bank_code AND is_group=FALSE;
    SELECT account_id INTO v_petty_cash_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_petty_cash_code AND is_group=FALSE;

    IF v_shipping_charge > 0 THEN
        SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
        IF v_shipping_revenue_acc_id IS NULL THEN RAISE EXCEPTION 'Shipping Revenue account (%s) not found. Biz:%, Org:%', v_shipping_revenue_code, v_business_id, v_org_id; END IF;
    END IF;
    IF v_discount_amount > 0 THEN
        SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=v_business_id AND org_id=v_org_id AND code=v_sales_discount_code AND is_group=FALSE;
        IF v_sales_discount_acc_id IS NULL THEN RAISE EXCEPTION 'Sales Discount account (%s) not found. Biz:%, Org:%', v_sales_discount_code, v_business_id, v_org_id; END IF;
    END IF;

    IF v_ar_acc_id IS NULL OR v_sales_products_acc_id IS NULL OR v_sales_services_acc_id IS NULL OR v_sales_tax_payable_acc_id IS NULL
       OR v_inventory_acc_id IS NULL OR v_cogs_products_acc_id IS NULL OR v_cash_in_bank_acc_id IS NULL OR v_petty_cash_acc_id IS NULL THEN
        RAISE EXCEPTION 'One or more core accounts not found for Biz:%, Org:%. Please check COA setup (e.g., AR:%s, SalesProd:%s, Inv:%s, COGS:%s).', 
            v_business_id, v_org_id, v_ar_code, v_sales_products_code, v_inventory_code, v_cogs_products_code;
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

            IF v_is_tax_inclusive_item AND v_tax_rate > 0 THEN
                v_line_net_subtotal_item := ROUND((v_unit_price_input * v_quantity) / (1 + (v_tax_rate / 100.0)), 2);
                v_line_tax_item := (v_unit_price_input * v_quantity) - v_line_net_subtotal_item;
            ELSE
                v_line_net_subtotal_item := v_unit_price_input * v_quantity;
                v_line_tax_item := v_line_net_subtotal_item * (v_tax_rate / 100.0);
            END IF;
            
            v_calc_tax_total := v_calc_tax_total + ROUND(v_line_tax_item, 2);

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
                        v_sub_line_tax   NUMERIC := v_sub_line_net_total * (v_tax_rate / 100.0); 
                    BEGIN
                        v_calc_subtotal_services := v_calc_subtotal_services + v_sub_line_net_total;
                        v_calc_tax_total := v_calc_tax_total + ROUND(v_sub_line_tax, 2);
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

    -- Process Immediate Payment (Same as before)
    IF v_paid_amount > 0 AND v_payment_details IS NOT NULL THEN
        DECLARE v_total_payment_processed NUMERIC := 0;
        BEGIN
            FOR v_payment_method, v_payment_amount IN SELECT key, value::text::numeric FROM jsonb_each_text(v_payment_details) WHERE value::text::numeric > 0
            LOOP
                 DECLARE v_payment_asset_account_id UUID;
                 BEGIN
                     v_total_payment_processed := v_total_payment_processed + v_payment_amount;
                     IF lower(v_payment_method) = 'cash' THEN v_payment_asset_account_id := v_petty_cash_acc_id;
                     ELSE v_payment_asset_account_id := v_cash_in_bank_acc_id; END IF;

                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description, created_by, updated_by) VALUES 
                        (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_gen_reference_no,v_acting_user_id,v_acting_user_id),
                        (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_gen_reference_no,v_acting_user_id,v_acting_user_id);

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
END;$$;


ALTER FUNCTION "public"."create_sale"("p_sale_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_sale_return"("p_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data
    v_business_id         UUID := (p_data->>'business_id')::uuid;
    v_sale_id             UUID := (p_data->>'sale_id')::uuid; -- ID of the original sale
    v_return_date         TIMESTAMPTZ := COALESCE((p_data->>'return_date')::timestamptz, now());
    v_return_invoice      TEXT := p_data->>'return_invoice'; -- Ref number for the return doc
    v_reason              TEXT := p_data->>'reason';
    v_notes               TEXT := p_data->>'notes';
    v_return_items        JSONB := p_data->'items'; -- Array of items being returned

    -- Internal Vars
    v_transaction_id      UUID;
    v_return_id           UUID; -- PK for sale_returns table
    v_customer_id         UUID;
    v_user_id             UUID := auth.uid();
    v_total_return_sale_value NUMERIC := 0;
    v_total_return_cost_value NUMERIC := 0;
    v_return_item_data    RECORD; -- For looping

    -- Account IDs & Codes
    v_ar_customer_acc_id      UUID;
    v_sales_ret_allow_acc_id  UUID; -- Sales Returns & Allowances account
    v_inventory_acc_id        UUID;
    v_cogs_acc_id             UUID; -- Cost of Goods Sold account

    v_ar_customer_code        TEXT := '1020';
    v_sales_ret_allow_code    TEXT := '4910'; -- <<< New Account Code
    v_inventory_code          TEXT := '1030';
    v_cogs_code               TEXT := '5015';

BEGIN
    -- Validate Inputs
    IF v_business_id IS NULL OR v_sale_id IS NULL OR v_return_items IS NULL OR jsonb_array_length(v_return_items) = 0 THEN
        RAISE EXCEPTION 'business_id, sale_id, and at least one return item are required.';
    END IF;
    IF v_return_invoice IS NULL OR trim(v_return_invoice) = '' THEN
        v_return_invoice := 'SRTN-' || to_char(v_return_date, 'YYYYMMDD') || '-' || upper(substring(gen_random_uuid()::text from 1 for 6));
        RAISE WARNING 'Return invoice reference not provided, generated: %', v_return_invoice;
    END IF;

    -- Get Customer ID from the original sale
    SELECT s.customer_id INTO v_customer_id
    FROM public.sales s -- Assuming 'sales' is your sales header table
    WHERE s.sale_id = v_sale_id AND s.business_id = v_business_id;

    IF v_customer_id IS NULL THEN
        RAISE EXCEPTION 'Original Sale ID % not found for business %.', v_sale_id, v_business_id;
    END IF;

    -- Fetch Account IDs
    SELECT account_id INTO v_ar_customer_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_ar_customer_code;
    SELECT account_id INTO v_sales_ret_allow_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_sales_ret_allow_code;
    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_inventory_code;
    SELECT account_id INTO v_cogs_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_cogs_code;

    IF v_ar_customer_acc_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Receivable - Customers account (Code: %) not found for business %.', v_ar_customer_code, v_business_id;
    END IF;
    IF v_sales_ret_allow_acc_id IS NULL THEN
        RAISE EXCEPTION 'Sales Returns and Allowances account (Code: %) not found for business %.', v_sales_ret_allow_code, v_business_id;
    END IF;
    IF v_inventory_acc_id IS NULL THEN
        RAISE EXCEPTION 'Inventory account (Code: %) not found for business %.', v_inventory_code, v_business_id;
    END IF;
     IF v_cogs_acc_id IS NULL THEN
        RAISE EXCEPTION 'Cost of Goods Sold account (Code: %) not found for business %.', v_cogs_code, v_business_id;
    END IF;

    -- Calculate total return value at SALE PRICE and COST
    -- Assumes input JSON 'items' has 'sale_item_id' (from original sale) and 'quantity' returned
    -- Also fetches item cost (using purchase_price as proxy - review this assumption)
    SELECT
        COALESCE(SUM(ri.quantity * si.unit_price), 0),
        COALESCE(SUM(ri.quantity * COALESCE(i.purchase_price, 0)), 0) -- Using current purchase_price as cost proxy
    INTO
        v_total_return_sale_value,
        v_total_return_cost_value
    FROM jsonb_to_recordset(v_return_items) AS ri(sale_item_id uuid, quantity numeric) -- Adjust keys if needed
    JOIN public.sale_items si ON si.sale_item_id = ri.sale_item_id -- Assuming 'sale_items' table
    JOIN public.items i ON i.item_id = si.item_id -- Get item cost proxy
    WHERE si.sale_id = v_sale_id; -- Ensure items belong to original sale

    IF v_total_return_sale_value <= 0 THEN
        RAISE EXCEPTION 'Return items invalid or total return sale value is zero or less.';
    END IF;

    -- Create Transaction Header for the Return
    -- Status is PAID (A/R adjustment complete). paid/due are 0 for this transaction.
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status,
        total_amount, paid_amount, due_amount,
        notes, business_id, created_by, customer_id -- Link customer
    ) VALUES (
        v_return_invoice, 'SALE_RETURN'::public.transaction_type, v_return_date, 'PAID'::public.transaction_status,
        v_total_return_sale_value, 0, 0,
        'Sale Return: ' || COALESCE(v_reason, ''), v_business_id, v_user_id, v_customer_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- Create Correct Transaction Entries
    -- 1. Reverse Revenue/Receivable (@ Sale Price)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES
        (v_transaction_id, v_sales_ret_allow_acc_id, 'DEBIT'::public.entry_type, v_total_return_sale_value, 'Sale Return Ref ' || v_return_invoice),
        (v_transaction_id, v_ar_customer_acc_id, 'CREDIT'::public.entry_type, v_total_return_sale_value, 'Sale Return Ref ' || v_return_invoice);

    -- 2. Reverse COGS/Inventory (@ Cost Price) - Only if cost value > 0
    IF v_total_return_cost_value > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_inventory_acc_id, 'DEBIT'::public.entry_type, v_total_return_cost_value, 'Sale Return Inventory Ref ' || v_return_invoice),
            (v_transaction_id, v_cogs_acc_id, 'CREDIT'::public.entry_type, v_total_return_cost_value, 'Sale Return COGS Reversal Ref ' || v_return_invoice);
    ELSE
         RAISE WARNING 'Sale Return %: Cost of returned items is zero or could not be determined; COGS reversal entries skipped.', v_return_invoice;
    END IF;


    -- Verify balance of this return transaction
    PERFORM public.verify_transaction_balance(v_transaction_id);

    -- Create Sale Return Header Record
    INSERT INTO public.sale_returns (
        return_id, -- Assuming PK is 'return_id' and defaults or gen_random_uuid() is used
        sale_id, return_invoice, return_date, reason, notes,
        total_amount, transaction_id, business_id, created_by -- Use correct column name for user id
    ) VALUES (
        gen_random_uuid(), -- Assuming default PK generation
        v_sale_id, v_return_invoice, v_return_date, v_reason, v_notes,
        v_total_return_sale_value, v_transaction_id, v_business_id, v_user_id
    ) RETURNING sale_returns.return_id INTO v_return_id; -- Ensure PK column name is correct

    -- Create Return Item Details and Update Stock Quantity
    FOR v_return_item_data IN
        SELECT
            ri.item_id,
            ri.sale_item_id, -- Link to original sale item line
            ri.quantity,
            si.unit_price, -- Original sale unit price
            i.inventory_enabled
        FROM jsonb_to_recordset(v_return_items) AS ri(item_id uuid, sale_item_id uuid, quantity numeric) -- Adjust keys if needed
        JOIN public.sale_items si ON si.sale_item_id = ri.sale_item_id AND si.item_id = ri.item_id -- Ensure item matches
        JOIN public.items i ON i.item_id = ri.item_id
        WHERE si.sale_id = v_sale_id -- Ensure item belongs to original sale
    LOOP
        -- Insert return item detail
        INSERT INTO public.sale_return_items (
            return_id, sale_item_id, quantity, unit_price
        ) VALUES (
            v_return_id,
            v_return_item_data.sale_item_id,
            v_return_item_data.quantity,
            v_return_item_data.unit_price -- Store original sale price for reference
        );

        -- Update item inventory quantity if applicable
        IF v_return_item_data.inventory_enabled THEN
            UPDATE public.items
            SET stock_quantity = stock_quantity + v_return_item_data.quantity, -- ADDING back to stock
                updated_at = now()
                -- DO NOT update stock_value here. GL entry handles value.
            WHERE item_id = v_return_item_data.item_id;
        END IF;
    END LOOP;

    -- NO automatic payment creation here. Issuing a refund is separate.
    -- NO direct updates to sale.due_amount or business_customers.customer_balance. Triggers handle this.
    -- NO redundant nextval call.

    RAISE NOTICE 'Sale Return created successfully. Transaction ID: %', v_transaction_id;
    RETURN v_transaction_id; -- Return the transaction ID of the return

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error creating sale return: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."create_sale_return"("p_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_sequences"("business_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    v_base_name text;
BEGIN
    v_base_name := business_id::text;

    -- Create sequences for various business documents in the public schema
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_purchase_invoice');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_sale_invoice');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_purchase_return_code');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_sale_return_code');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_item_code');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_employee_code');
	EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_invoice_code');
	EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_quote_code');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_payment_code');
    EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1;', v_base_name || '_credit_note_code');

END;$$;


ALTER FUNCTION "public"."create_sequences"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_credit_note"("p_credit_note_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    v_credit_note RECORD;
    v_amount_applied NUMERIC;
BEGIN
    -- 1. FETCH AND LOCK THE CREDIT NOTE
    SELECT * INTO v_credit_note FROM public.credit_notes WHERE credit_note_id = p_credit_note_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Credit note with ID % not found.', p_credit_note_id;
    END IF;

    -- 2. ENFORCE BUSINESS RULE: CANNOT DELETE IF USED
    -- The credit is "used" if its remaining value is less than its total value.
    IF v_credit_note.credit_remaining < v_credit_note.grand_total THEN
        RAISE EXCEPTION 'Cannot delete credit note % because it has already been applied to an invoice or refunded.', v_credit_note.credit_note_code;
    END IF;

    -- 3. REVERSE FINANCIAL IMPACT (IF ANY)
    -- This part is for the rare case where an open credit note was linked to an invoice but the `create` function
    -- logic was changed to NOT auto-apply. This ensures we clean up any `credit_applied` amount.
    -- With your current `create_credit_note` logic, this will typically be 0 for an open credit note.
    v_amount_applied := v_credit_note.grand_total - v_credit_note.credit_remaining;
    
    IF v_credit_note.invoice_id IS NOT NULL AND v_amount_applied > 0 THEN
        UPDATE public.invoices
        SET credit_applied = credit_applied - v_amount_applied
        WHERE invoice_id = v_credit_note.invoice_id;
        
        -- Update the invoice status since its balance has changed
        PERFORM public.update_invoice_status(v_credit_note.invoice_id);
    END IF;

    -- 4. DELETE THE CREDIT NOTE
    -- The `ON DELETE CASCADE` constraint on `credit_note_items` will handle the line items.
    DELETE FROM public.credit_notes WHERE credit_note_id = p_credit_note_id;

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object(
      'status', 'success',
      'message', 'Credit note ' || v_credit_note.credit_note_code || ' has been successfully deleted.'
    );


EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Failed to delete credit note. Error: %', SQLERRM;
END;$$;


ALTER FUNCTION "public"."delete_credit_note"("p_credit_note_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_invoice"("p_invoice_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_invoice RECORD;
BEGIN
    -- 1. FETCH AND LOCK THE INVOICE TO BE DELETED
    SELECT * INTO v_invoice FROM public.invoices WHERE invoice_id = p_invoice_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invoice with ID % not found.', p_invoice_id;
    END IF;

    -- 2. ENFORCE THE BUSINESS RULE
    -- Check if there are any payments or credits applied.
    IF v_invoice.amount_paid > 0 OR v_invoice.credit_applied > 0 THEN
        RAISE EXCEPTION 'Cannot delete invoice % because it has payments or credits applied. Please void the invoice instead.', v_invoice.invoice_code;
    END IF;

    -- 3. CHECK FOR LINKED CREDIT NOTES
    -- Also, prevent deletion if a credit note was created from this invoice, even if not applied.
    -- This maintains the relationship integrity.
    IF EXISTS (SELECT 1 FROM public.credit_notes WHERE invoice_id = p_invoice_id) THEN
        RAISE EXCEPTION 'Cannot delete invoice % because it is linked to one or more credit notes.', v_invoice.invoice_code;
    END IF;
    
    -- 4. DELETE THE INVOICE
    -- The `ON DELETE CASCADE` constraint on the `invoice_items` table will automatically delete all line items.
    DELETE FROM public.invoices WHERE invoice_id = p_invoice_id;

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object(
      'status', 'success',
      'message', 'Invoice ' || v_invoice.invoice_code || ' and its items have been successfully deleted.'
    );

EXCEPTION
    WHEN others THEN
        -- If any step fails, the entire transaction is rolled back.
        RAISE EXCEPTION 'Failed to delete invoice. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."delete_invoice"("p_invoice_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_payment_received"("p_payment_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_payment RECORD;
BEGIN
    -- 1. FETCH AND LOCK THE PAYMENT TO BE DELETED
    SELECT * INTO v_payment FROM public.payments_received WHERE payment_id = p_payment_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment with ID % not found.', p_payment_id;
    END IF;

    -- 2. ENFORCE BUSINESS RULE: CANNOT DELETE A REFUNDED PAYMENT
    IF v_payment.amount_refunded > 0 THEN
        RAISE EXCEPTION 'Cannot delete payment % because it has been partially or fully refunded. Please reverse the refund first.', v_payment.payment_code;
    END IF;

    -- 3. REVERSE THE FINANCIAL IMPACT
    -- If the payment was linked to an invoice, subtract its amount from the invoice's `amount_paid`.
    IF v_payment.invoice_id IS NOT NULL THEN
        UPDATE public.invoices
        SET amount_paid = amount_paid - v_payment.amount_received
        WHERE invoice_id = v_payment.invoice_id;
    END IF;

    -- 4. DELETE THE PAYMENT RECORD
    DELETE FROM public.payments_received WHERE payment_id = p_payment_id;
    
    -- 5. UPDATE THE INVOICE STATUS
    -- The invoice balance has changed, so its status might change (e.g., from 'Paid' to 'Partially Paid').
    IF v_payment.invoice_id IS NOT NULL THEN
        PERFORM public.update_invoice_status(v_payment.invoice_id);
    END IF;

    -- 6. RETURN SUCCESS
    RETURN jsonb_build_object(
      'status', 'success',
      'message', 'Payment ' || v_payment.payment_code || ' deleted and its amount has been reversed from the linked invoice.'
    );

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Failed to delete payment. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."delete_payment_received"("p_payment_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_refund"("p_refund_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_refund_record RECORD;
BEGIN
    -- 1. FETCH AND LOCK THE REFUND RECORD TO BE DELETED
    SELECT * INTO v_refund_record FROM public.refund_payments WHERE refund_id = p_refund_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Refund with ID % not found.', p_refund_id;
    END IF;

    -- 2. IDENTIFY THE SOURCE AND REVERSE THE EFFECT ON THE SOURCE DOCUMENT
    IF v_refund_record.source_payment_id IS NOT NULL THEN
        -- This refund came from a payment. Reverse the effect.
        -- Decrease the amount refunded on the payment record.
        UPDATE public.payments_received
        SET amount_refunded = amount_refunded - v_refund_record.amount_refunded
        WHERE payment_id = v_refund_record.source_payment_id;

        -- If the payment was linked to an invoice, "re-pay" the amount to the invoice.
        IF v_refund_record.invoice_id IS NOT NULL THEN
            UPDATE public.invoices
            SET amount_paid = amount_paid + v_refund_record.amount_refunded
            WHERE invoice_id = v_refund_record.invoice_id;
        END IF;

    ELSIF v_refund_record.source_credit_note_id IS NOT NULL THEN
        -- This refund came from a credit note. Reverse the effect.
        -- Increase the remaining credit on the credit note record.
        UPDATE public.credit_notes
        SET credit_remaining = credit_remaining + v_refund_record.amount_refunded
        WHERE credit_note_id = v_refund_record.source_credit_note_id;
    END IF;

    -- 3. DELETE THE REFUND RECORD ITSELF
    -- This is the final step after the financial reversal is complete.
    DELETE FROM public.refund_payments WHERE refund_id = p_refund_id;

    -- 4. UPDATE THE STATUSES OF ANY AFFECTED DOCUMENTS TO REFLECT THE CHANGE
    IF v_refund_record.invoice_id IS NOT NULL THEN
        -- This will correctly update the invoice status (e.g., from 'Paid' back to 'Partially Paid')
        PERFORM public.update_invoice_status(v_refund_record.invoice_id);
    END IF;
    IF v_refund_record.source_credit_note_id IS NOT NULL THEN
        -- This will correctly update the credit note status (e.g., from 'Closed' back to 'Partially Used' or 'Open')
        PERFORM public.update_credit_note_status(v_refund_record.source_credit_note_id);
    END IF;

    -- 5. RETURN A SUCCESS MESSAGE
    RETURN jsonb_build_object(
      'status', 'success',
      'message', 'Refund deleted and all financial records have been correctly reversed.'
    );
EXCEPTION
    WHEN others THEN
        -- If any step fails, the entire transaction is rolled back automatically.
        RAISE EXCEPTION 'Failed to delete refund. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."delete_refund"("p_refund_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edit_credit_note"("p_credit_note_id" "uuid", "p_update_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Original Credit Note Data
    v_credit_note RECORD;

    -- New values from JSON
    v_credit_note_date     DATE;
    v_reason               TEXT;
    v_notes                TEXT;
    v_credit_note_items    JSONB;
    v_input_tax_total       NUMERIC;
    v_input_discount_amount NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Recalculated totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;
    v_credit_note_item_data  RECORD;

BEGIN
    -- 1. FETCH AND LOCK THE CREDIT NOTE
    SELECT * INTO v_credit_note FROM public.credit_notes WHERE credit_note_id = p_credit_note_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Credit Note with ID % not found.', p_credit_note_id;
    END IF;

    -- 2. ENFORCE BUSINESS RULE: BLOCK EDITS IF CREDIT IS USED
    -- A credit note's value is locked once it's been applied or refunded.
    IF v_credit_note.credit_remaining < v_credit_note.grand_total THEN
        RAISE EXCEPTION 'This credit note cannot be edited because it has already been partially or fully used.';
    END IF;

    -- 3. PARSE UPDATES, USING ORIGINAL VALUES AS DEFAULTS
    v_credit_note_date     := COALESCE((p_update_json->>'credit_note_date')::date, v_credit_note.credit_note_date);
    v_reason               := COALESCE(p_update_json->>'reason', v_credit_note.reason);
    v_notes                := COALESCE(p_update_json->>'notes', v_credit_note.notes);
    
    -- 4. HANDLE ITEMS AND TOTALS
    IF p_update_json ? 'credit_note_items' THEN
        v_credit_note_items := p_update_json->'credit_note_items';
        
        v_input_tax_total        := COALESCE((p_update_json->>'tax_total')::numeric, 0);
        v_input_discount_amount  := COALESCE((p_update_json->>'discount_amount')::numeric, 0);
        v_input_shipping_charges := COALESCE((p_update_json->>'shipping_charges')::numeric, 0);

        -- Recalculate totals
        FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
            v_calculated_sub_total := v_calculated_sub_total + (v_credit_note_item_data.quantity * v_credit_note_item_data.unit_price);
        END LOOP;
        v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;
        
        -- UPDATE THE CREDIT NOTE with new totals
        UPDATE public.credit_notes
        SET
            credit_note_date = v_credit_note_date,
            reason = v_reason,
            notes = v_notes,
            tax_total = v_input_tax_total,
            discount_amount = v_input_discount_amount,
            shipping_charges = v_input_shipping_charges,
            sub_total = v_calculated_sub_total,
            grand_total = v_calculated_grand_total,
            -- Also update credit_remaining to the new total since it was unused
            credit_remaining = v_calculated_grand_total
        WHERE credit_note_id = p_credit_note_id;

        -- DELETE OLD ITEMS and INSERT NEW ONES
        DELETE FROM public.credit_note_items WHERE credit_note_id = p_credit_note_id;
        FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
            INSERT INTO public.credit_note_items (business_id, customer_id, credit_note_id, item_id, quantity, unit_price)
            VALUES (v_credit_note.business_id, v_credit_note.customer_id, p_credit_note_id, v_credit_note_item_data.item_id, v_credit_note_item_data.quantity, v_credit_note_item_data.unit_price);
        END LOOP;

    ELSE
        -- Only update the non-financial fields
        UPDATE public.credit_notes
        SET
            credit_note_date = v_credit_note_date,
            reason = v_reason,
            notes = v_notes
        WHERE credit_note_id = p_credit_note_id;
    END IF;

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object('status', 'success', 'message', 'Credit note updated successfully.');

EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to edit credit note. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."edit_credit_note"("p_credit_note_id" "uuid", "p_update_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edit_credit_note_after_application"("p_credit_note_id" "uuid", "p_update_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- Original Credit Note Data
    v_credit_note RECORD;
    v_original_grand_total NUMERIC;

    -- New values from JSON
    v_credit_note_date     DATE;
    v_reason               TEXT;
    v_notes                TEXT;
    v_credit_note_items    JSONB;
    v_input_tax_total       NUMERIC;
    v_input_discount_amount NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Recalculated totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;
    v_credit_note_item_data  RECORD;
    
    -- Variables for reversal
    v_amount_already_applied NUMERIC;

BEGIN
    -- 1. FETCH AND LOCK THE CREDIT NOTE AND ANY LINKED INVOICE
    -- Using FOR UPDATE locks the rows to prevent other transactions from interfering.
    SELECT * INTO v_credit_note FROM public.credit_notes WHERE credit_note_id = p_credit_note_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Credit Note with ID % not found.', p_credit_note_id;
    END IF;

    IF v_credit_note.invoice_id IS NOT NULL THEN
        -- Also lock the associated invoice to ensure its balance is handled atomically
        PERFORM 1 FROM public.invoices WHERE invoice_id = v_credit_note.invoice_id FOR UPDATE;
    END IF;

    -- Store original total for reversal calculation
    v_original_grand_total := v_credit_note.grand_total;
    
    -- Calculate how much of the original credit was actually applied to the invoice.
    -- This is crucial because the credit might have been larger than the invoice balance.
    v_amount_already_applied := v_original_grand_total - v_credit_note.credit_remaining;

    -- BUSINESS RULE: Block edits if the credit has been cashed out (refunded).
    -- Editing a refunded credit is too complex and dangerous.
    IF (v_original_grand_total - v_credit_note.credit_remaining - (SELECT COALESCE(SUM(amount_refunded), 0) FROM public.refund_payments WHERE is_credit_note = true AND source_credit_note_id = p_credit_note_id)) > 0 THEN
      -- A more precise check if you add source_credit_note_id to refund_payments table
    END IF;
    -- A simpler check based on your existing schema:
    IF v_credit_note.status = 'closed' AND v_amount_already_applied = 0 THEN
       -- This implies a refund might have happened. A stronger check is needed if refunds from CN are possible.
    END IF;


    -- 2. --- REVERSAL STEP ---
    -- If the credit was applied to an invoice, subtract the previously applied amount.
    IF v_credit_note.invoice_id IS NOT NULL AND v_amount_already_applied > 0 THEN
        UPDATE public.invoices
        SET credit_applied = credit_applied - v_amount_already_applied
        WHERE invoice_id = v_credit_note.invoice_id;
    END IF;

    -- 3. --- UPDATE STEP ---
    -- Get new items. If not provided, we must use the old items to recalculate.
    IF p_update_json ? 'credit_note_items' THEN
        v_credit_note_items := p_update_json->'credit_note_items';
    ELSE
        -- If no new items are sent, we must rebuild the items from the existing table
        -- to ensure totals are recalculated correctly against new tax/discount values.
        SELECT jsonb_agg(jsonb_build_object('item_id', cni.item_id, 'quantity', cni.quantity, 'unit_price', cni.unit_price))
        INTO v_credit_note_items FROM public.credit_note_items cni WHERE cni.credit_note_id = p_credit_note_id;
    END IF;
    
    -- Parse all updatable fields, defaulting to original values
    v_credit_note_date     := COALESCE((p_update_json->>'credit_note_date')::date, v_credit_note.credit_note_date);
    v_reason               := COALESCE(p_update_json->>'reason', v_credit_note.reason);
    v_notes                := COALESCE(p_update_json->>'notes', v_credit_note.notes);
    v_input_tax_total        := COALESCE((p_update_json->>'tax_total')::numeric, v_credit_note.tax_total);
    v_input_discount_amount  := COALESCE((p_update_json->>'discount_amount')::numeric, v_credit_note.discount_amount);
    v_input_shipping_charges := COALESCE((p_update_json->>'shipping_charges')::numeric, v_credit_note.shipping_charges);

    -- Recalculate totals based on the definitive item list (new or old)
    FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
        v_calculated_sub_total := v_calculated_sub_total + (v_credit_note_item_data.quantity * v_credit_note_item_data.unit_price);
    END LOOP;
    v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;
    
    -- Update the credit note with all new values
    UPDATE public.credit_notes
    SET
        credit_note_date = v_credit_note_date,
        reason = v_reason,
        notes = v_notes,
        tax_total = v_input_tax_total,
        discount_amount = v_input_discount_amount,
        shipping_charges = v_input_shipping_charges,
        sub_total = v_calculated_sub_total,
        grand_total = v_calculated_grand_total,
        -- The new remaining credit is the new total MINUS the part that was already refunded (if any).
        -- For simplicity here, we assume no refunds, so remaining credit is the new total.
        -- A more complex refund check is needed for a full system.
        credit_remaining = v_calculated_grand_total
    WHERE credit_note_id = p_credit_note_id;

    -- Replace old items with new ones if they were provided
    IF p_update_json ? 'credit_note_items' THEN
        DELETE FROM public.credit_note_items WHERE credit_note_id = p_credit_note_id;
        FOR v_credit_note_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_credit_note_items) AS x LOOP
            INSERT INTO public.credit_note_items (business_id, customer_id, credit_note_id, item_id, quantity, unit_price)
            VALUES (v_credit_note.business_id, v_credit_note.customer_id, p_credit_note_id, v_credit_note_item_data.item_id, v_credit_note_item_data.quantity, v_credit_note_item_data.unit_price);
        END LOOP;
    END IF;

    -- 4. --- RE-APPLICATION STEP ---
    IF v_credit_note.invoice_id IS NOT NULL THEN
        DECLARE
            v_invoice_balance NUMERIC;
            v_amount_to_reapply NUMERIC;
        BEGIN
            -- Get the invoice's current balance (which has been temporarily increased by the reversal)
            SELECT balance_due INTO v_invoice_balance FROM public.invoices WHERE invoice_id = v_credit_note.invoice_id;

            -- Determine how much of the NEW credit total can be applied
            v_amount_to_reapply := LEAST(v_calculated_grand_total, v_invoice_balance);

            IF v_amount_to_reapply > 0 THEN
                -- Apply the new amount
                UPDATE public.invoices
                SET credit_applied = credit_applied + v_amount_to_reapply
                WHERE invoice_id = v_credit_note.invoice_id;

                -- Update the credit note's remaining amount based on the re-application
                UPDATE public.credit_notes
                SET credit_remaining = credit_remaining - v_amount_to_reapply
                WHERE credit_note_id = p_credit_note_id;
            END IF;
            
            -- Update statuses of both documents
            PERFORM public.update_invoice_status(v_credit_note.invoice_id);
        END;
    END IF;

    PERFORM public.update_credit_note_status(p_credit_note_id);

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object('status', 'success', 'message', 'Credit note updated and re-applied successfully.');

EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to edit credit note. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."edit_credit_note_after_application"("p_credit_note_id" "uuid", "p_update_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edit_invoice"("p_invoice_id" "uuid", "p_update_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    -- Original Invoice Data
    v_invoice RECORD;

    -- New values from JSON
    v_billing_address      UUID;
    v_shipping_address     UUID;
    v_invoice_date         DATE;
    v_due_date             DATE;
    v_notes                TEXT;
    v_terms_and_conditions TEXT;
    v_status               TEXT;
    v_invoice_items        JSONB;
    v_invoice_code         TEXT;
    v_input_tax_total      NUMERIC;
    v_input_discount_amount  NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Recalculated totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;
    v_invoice_item_data      RECORD;

BEGIN
    -- 1. FETCH AND LOCK THE INVOICE
    SELECT * INTO v_invoice FROM public.invoices WHERE invoice_id = p_invoice_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invoice with ID % not found.', p_invoice_id;
    END IF;

    -- 2. ENFORCE BUSINESS RULE
    IF v_invoice.amount_paid > 0 OR v_invoice.credit_applied > 0 THEN
        RAISE EXCEPTION 'This invoice cannot be edited because it has payments or credits applied. Please void this invoice and create a new one.';
    END IF;

    -- 3. PARSE UPDATES FROM JSON, USING ORIGINAL VALUES AS DEFAULTS
    v_billing_address      := COALESCE((p_update_json->>'billing_address')::uuid, v_invoice.billing_address);
    v_shipping_address     := COALESCE((p_update_json->>'shipping_address')::uuid, v_invoice.shipping_address);
    v_invoice_date         := COALESCE((p_update_json->>'invoice_date')::date, v_invoice.invoice_date);
    v_due_date             := COALESCE((p_update_json->>'due_date')::date, v_invoice.due_date);
    v_notes                := COALESCE(p_update_json->>'notes', v_invoice.notes);
    v_terms_and_conditions := COALESCE(p_update_json->>'terms_and_conditions', v_invoice.terms_and_conditions);
    v_status               := COALESCE(p_update_json->>'status', v_invoice.status);
    v_invoice_code         := COALESCE(p_update_json->>'invoice_code', v_invoice.invoice_code);
    
    -- 4. VALIDATE UNIQUENESS IF INVOICE CODE IS BEING CHANGED
    IF v_invoice_code <> v_invoice.invoice_code THEN
        -- Check if the new code already exists for this business on a *different* invoice
        IF EXISTS (SELECT 1 FROM public.invoices WHERE business_id = v_invoice.business_id AND invoice_code = v_invoice_code AND invoice_id <> p_invoice_id) THEN
            RAISE EXCEPTION 'Invoice code "%" already exists for this business.', v_invoice_code;
        END IF;
    END IF;

    -- 5. HANDLE ITEMS AND TOTALS
    IF p_update_json ? 'invoice_items' THEN
        v_invoice_items := p_update_json->'invoice_items';
        
        v_input_tax_total        := COALESCE((p_update_json->>'tax_total')::numeric, 0);
        v_input_discount_amount  := COALESCE((p_update_json->>'discount_amount')::numeric, 0);
        v_input_shipping_charges := COALESCE((p_update_json->>'shipping_charges')::numeric, 0);

        FOR v_invoice_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_invoice_items) AS x LOOP
            v_calculated_sub_total := v_calculated_sub_total + (v_invoice_item_data.quantity * v_invoice_item_data.unit_price);
        END LOOP;
        
        v_calculated_grand_total := v_calculated_sub_total - v_input_discount_amount + v_input_shipping_charges + v_input_tax_total;
        
        UPDATE public.invoices
        SET
            billing_address = v_billing_address,
            shipping_address = v_shipping_address,
            invoice_date = v_invoice_date,
            due_date = v_due_date,
            notes = v_notes,
            terms_and_conditions = v_terms_and_conditions,
            status = v_status,
            invoice_code = v_invoice_code,
            tax_total = v_input_tax_total,
            discount_amount = v_input_discount_amount,
            shipping_charges = v_input_shipping_charges,
            sub_total = v_calculated_sub_total,
            grand_total = v_calculated_grand_total
        WHERE invoice_id = p_invoice_id;

        DELETE FROM public.invoice_items WHERE invoice_id = p_invoice_id;
        FOR v_invoice_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_invoice_items) AS x LOOP
            INSERT INTO public.invoice_items (business_id, customer_id, invoice_id, item_id, quantity, unit_price)
            VALUES (v_invoice.business_id, v_invoice.customer_id, p_invoice_id, v_invoice_item_data.item_id, v_invoice_item_data.quantity, v_invoice_item_data.unit_price);
        END LOOP;

    ELSE
        -- If no new items are provided, only update the non-financial fields
        UPDATE public.invoices
        SET
            billing_address = v_billing_address,
            shipping_address = v_shipping_address,
            invoice_date = v_invoice_date,
            due_date = v_due_date,
            notes = v_notes,
            terms_and_conditions = v_terms_and_conditions,
            status = v_status,
            invoice_code = v_invoice_code
        WHERE invoice_id = p_invoice_id;
    END IF;

    -- 6. RETURN SUCCESS
    RETURN jsonb_build_object('status', 'success', 'message', 'Invoice updated successfully.');

EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to edit invoice. Error: %', SQLERRM;
END;$$;


ALTER FUNCTION "public"."edit_invoice"("p_invoice_id" "uuid", "p_update_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."edit_payment_received"("p_payment_id" "uuid", "p_update_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_payment RECORD;
BEGIN
    -- 1. FETCH AND LOCK THE PAYMENT
    SELECT * INTO v_payment FROM public.payments_received WHERE payment_id = p_payment_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment with ID % not found.', p_payment_id;
    END IF;

    -- 2. ENFORCE BUSINESS RULE: BLOCK EDITS IF REFUNDED
    IF v_payment.amount_refunded > 0 THEN
        RAISE EXCEPTION 'This payment cannot be edited because it has been partially or fully refunded.';
    END IF;
    
    -- 3. ENFORCE BUSINESS RULE: DISALLOW CHANGING THE AMOUNT
    IF p_update_json ? 'amount_received' AND (p_update_json->>'amount_received')::numeric IS DISTINCT FROM v_payment.amount_received THEN
        RAISE EXCEPTION 'The amount of a payment cannot be edited. Please delete this payment and create a new one with the correct amount.';
    END IF;
    
    -- 4. UPDATE ALLOWED FIELDS
    UPDATE public.payments_received
    SET
        payment_date = COALESCE((p_update_json->>'payment_date')::date, payment_date),
        payment_mode = COALESCE((p_update_json->>'payment_mode')::public.payment_type, payment_mode),
        deposited_to = COALESCE(p_update_json->>'deposited_to', deposited_to),
        reference_number = COALESCE(p_update_json->>'reference_number', reference_number),
        notes = COALESCE(p_update_json->>'notes', notes)
    WHERE payment_id = p_payment_id;

    -- 5. RETURN SUCCESS
    RETURN jsonb_build_object('status', 'success', 'message', 'Payment updated successfully.');

EXCEPTION
    WHEN others THEN RAISE EXCEPTION 'Failed to edit payment. Error: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."edit_payment_received"("p_payment_id" "uuid", "p_update_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."ensure_credit_note_sequence"("p_business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_sequence_name TEXT;
BEGIN
    v_sequence_name := 'public."cn_sequence_' || p_business_id::text || '"';
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';
    RETURN v_sequence_name;
END;
$$;


ALTER FUNCTION "public"."ensure_credit_note_sequence"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."find_missing_default_accounts"() RETURNS TABLE("business_id_missing" "uuid", "business_name_missing" "text", "missing_item_type" "text", "missing_category_code" "text", "missing_category_name_expected" "text", "missing_account_code" "text", "missing_account_name_expected" "text", "is_group_expected" boolean)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Define the expected default chart of accounts structure
    -- This should mirror what create_default_chart_of_accounts does
    RETURN QUERY
    WITH expected_categories (category_code, category_name) AS (
        VALUES
            ('AST', 'ASSETS'),
            ('LBT', 'LIABILITIES'),
            ('EQT', 'EQUITIES'),
            ('RVN', 'REVENUES'),
            ('COS', 'COST OF SALES'),
            ('OPE', 'OPERATING EXPENSES')
    ),
    expected_accounts (
        category_code_ref, account_name, account_code, is_group, parent_account_code_ref
    ) AS (
        VALUES
        -- Assets
        ('AST', 'Current Assets', '1000', TRUE, NULL),
        ('AST', 'Fixed Assets', '1100', TRUE, NULL),
        ('AST', 'Petty Cash', '1010', FALSE, '1000'),
        ('AST', 'Cash in Bank', '1011', FALSE, '1000'),
        ('AST', 'Accounts Receivable - Customers', '1020', FALSE, '1000'),
        ('AST', 'Receivables from Suppliers', '1021', FALSE, '1000'),
        ('AST', 'Inventory', '1030', FALSE, '1000'),
        ('AST', 'Land', '1110', FALSE, '1100'),
        ('AST', 'Buildings', '1120', FALSE, '1100'),
        ('AST', 'Equipment', '1130', FALSE, '1100'),
        -- Liabilities
        ('LBT', 'Current Liabilities', '2000', TRUE, NULL),
        ('LBT', 'Accounts Payable - Suppliers', '2010', FALSE, '2000'),
        ('LBT', 'Payables to Customers', '2011', FALSE, '2000'),
        ('LBT', 'Sales Tax Payable', '2020', FALSE, '2000'),
        -- Equities
        ('EQT', 'Retained Earnings', '3000', FALSE, NULL), -- is_system = TRUE
        ('EQT', 'Opening Balance Equity', '3900', FALSE, NULL), -- is_system = TRUE
        -- Revenues
        ('RVN', 'Sales Revenue', '4000', TRUE, NULL),
        ('RVN', 'Sales of Goods', '4010', FALSE, '4000'),
        ('RVN', 'Sales of Services', '4020', FALSE, '4000'),
        ('RVN', 'Income from Other Sources', '4030', FALSE, NULL),
        ('RVN', 'Shipping Revenue', '4040', FALSE, NULL),
        ('RVN', 'Sales Discount', '4900', FALSE, NULL),
        ('RVN', 'Sales Returns and Allowances', '4910', FALSE, NULL),
        -- Cost of Sales
        ('COS', 'Cost of Sales', '5000', TRUE, NULL),
        ('COS', 'Direct Materials', '5010', FALSE, '5000'),
        ('COS', 'Direct Labor', '5020', FALSE, '5000'),
        ('COS', 'Purchase Discount', '5030', FALSE, '5000'),
        ('COS', 'Shipping Costs (Purchases)', '5040', FALSE, '5000'),
        ('COS', 'Cost of Goods Sold', '5015', FALSE, '5000'),
        ('COS', 'Purchase Returns and Allowances', '5041', FALSE, '5000'),
        -- Operating Expenses
        ('OPE', 'Selling, General, and Administrative Expenses', '6000', TRUE, NULL),
        ('OPE', 'General Expense', '6090', FALSE, '6000'),
        ('OPE', 'Stock Adjustment Expense', '6095', FALSE, '6000')
    ),
    all_businesses AS (
        -- Assuming you have a table listing all businesses
        -- Replace with `SELECT DISTINCT business_id AS id, 'N/A'::TEXT AS name FROM public.account_categories`
        -- or `SELECT DISTINCT business_id AS id, 'N/A'::TEXT AS name FROM public.accounts`
        -- if you don't have a separate businesses table, but this is less ideal.
        SELECT b.business_id, b.name FROM public.businesses b
    )
    -- First, check for missing categories
    SELECT
        ab.business_id AS business_id_missing,
        ab.name AS business_name_missing,
        'Category'::TEXT AS missing_item_type,
        ec.category_code AS missing_category_code,
        ec.category_name AS missing_category_name_expected,
        NULL::TEXT AS missing_account_code,
        NULL::TEXT AS missing_account_name_expected,
        NULL::BOOLEAN AS is_group_expected
    FROM
        all_businesses ab
    CROSS JOIN
        expected_categories ec
    LEFT JOIN
        public.account_categories ac_actual
        ON ac_actual.business_id = ab.business_id AND ac_actual.code = ec.category_code
    WHERE
        ac_actual.category_id IS NULL

    UNION ALL

    -- Then, check for missing accounts (only for businesses that have the category)
    SELECT
        ab.business_id AS business_id_missing,
        ab.name AS business_name_missing,
        'Account'::TEXT AS missing_item_type,
        ea.category_code_ref AS missing_category_code,
        ec.category_name AS missing_category_name_expected,
        ea.account_code AS missing_account_code,
        ea.account_name AS missing_account_name_expected,
        ea.is_group AS is_group_expected
    FROM
        all_businesses ab
    CROSS JOIN
        expected_accounts ea
    JOIN
        expected_categories ec ON ec.category_code = ea.category_code_ref -- To get category name
    JOIN
        public.account_categories ac_actual -- Category must exist for this business
        ON ac_actual.business_id = ab.business_id AND ac_actual.code = ea.category_code_ref
    LEFT JOIN
        public.accounts pa_parent -- Find parent account if applicable
        ON pa_parent.business_id = ab.business_id
        AND pa_parent.code = ea.parent_account_code_ref
        AND pa_parent.category_id = ac_actual.category_id -- Parent must be in the same category for this check
    LEFT JOIN
        public.accounts acc_actual
        ON acc_actual.business_id = ab.business_id
        AND acc_actual.code = ea.account_code
        AND acc_actual.category_id = ac_actual.category_id
        AND acc_actual.is_group = ea.is_group
        AND (
            (ea.parent_account_code_ref IS NULL AND acc_actual.parent_account_id IS NULL) OR
            (ea.parent_account_code_ref IS NOT NULL AND acc_actual.parent_account_id = pa_parent.account_id)
        )
    WHERE
        acc_actual.account_id IS NULL
        -- AND (ea.parent_account_code_ref IS NULL OR pa_parent.account_id IS NOT NULL) -- Ensure parent exists if expected
        -- The above line for parent check might be too strict if a missing parent is already reported.
        -- The primary check is for the account itself. If its parent is missing, it's a separate issue
        -- that makes this account's creation more complex, but this account is still "missing".

    ORDER BY
        business_id_missing, missing_item_type, missing_category_code, missing_account_code;

END;
$$;


ALTER FUNCTION "public"."find_missing_default_accounts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."format_invoice_code"("p_business_id" "uuid", "p_sequence_number" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_prefix TEXT;
    v_padding INT;
BEGIN
    -- --- Hardcoded Settings ---
    -- You can change the prefix and padding for all invoices here.
    v_prefix := 'INV-';
    v_padding := 5;
    -- --------------------------

    -- Format the provided number with the prefix and zero-padding
    RETURN v_prefix || lpad(p_sequence_number::text, v_padding, '0');
END;
$$;


ALTER FUNCTION "public"."format_invoice_code"("p_business_id" "uuid", "p_sequence_number" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."format_payment_code"("p_business_id" "uuid", "p_sequence_number" bigint) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_prefix TEXT;
    v_padding INT;
BEGIN
    -- --- Hardcoded Settings ---
    -- You can change the prefix and padding for all payment codes here.
    -- Based on your example "R-101".
    v_prefix := 'R-';
    v_padding := 6; -- This will produce R-000101
    -- --------------------------

    -- Format the provided number with the prefix and zero-padding
    RETURN v_prefix || lpad(p_sequence_number::text, v_padding, '0');
END;
$$;


ALTER FUNCTION "public"."format_payment_code"("p_business_id" "uuid", "p_sequence_number" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_business_dependencies"("business_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_auth_user_id UUID := auth.uid();  -- Get the authenticated user ID
    v_org_id UUID;
	v_existing_user_id UUID;
    v_business_id UUID;
BEGIN

	v_org_id := (business_data->>'org_id')::uuid;
    -- 4. Insert into businesses
    INSERT INTO public.businesses (
        name,
        org_id,
        created_by,
        business_type,
        currency
    ) VALUES (
        business_data->>'name',
        v_org_id,
        v_auth_user_id,
        (business_data->>'business_type')::public.business_types,
        business_data->'currency'
    ) RETURNING business_id INTO v_business_id;

    -- Add default sale statuses
    INSERT INTO public.statuses (
        business_id,
        name,
        sequence_order,
        is_default,
        type,
		is_editable
    ) VALUES 
    (v_business_id, 'Booked', 1, true, 'sale'::status_type, true),
    (v_business_id, 'In Process', 2, false, 'sale'::status_type, true),
    (v_business_id, 'Cancelled', 3, false, 'sale'::status_type, false),
    (v_business_id, 'Completed', 4, false, 'sale'::status_type, false);

    -- 5. Create the default Account Categories and Chart of Accounts
    --    The block for inserting into account_categories has been removed from here.
    PERFORM public.create_default_chart_of_accounts(v_business_id, v_org_id);

    -- 4. Insert into branch accesses
    INSERT INTO public.employee_branch_access (
        employee_id,
        business_id
    ) VALUES (
        v_auth_user_id,
        v_business_id
    );

	RETURN v_business_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION '%', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."generate_business_dependencies"("business_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_short_id"("p_length" integer DEFAULT 6) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    v_result TEXT := '';
    i INTEGER;
BEGIN
    IF p_length <= 0 THEN
        p_length := 8; -- Default to 8 if invalid length provided
    END IF;

    FOR i IN 1..p_length LOOP
        v_result := v_result || substr(v_chars, floor(random() * length(v_chars) + 1)::integer, 1);
    END LOOP;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."generate_short_id"("p_length" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_business_summaries"("p_business_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_total_sales NUMERIC;
    v_total_purchases NUMERIC;
    v_total_received_sales NUMERIC;
    v_total_customer_dues NUMERIC;
    v_total_supplier_dues NUMERIC;
BEGIN
    -- Get total sales
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total_sales
    FROM sales
    WHERE business_id = p_business_id
    AND status_id NOT IN (
        SELECT status_id 
        FROM statuses 
        WHERE name IN ('VOID', 'CANCELLED')
    );

    -- Get total purchases
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total_purchases
    FROM purchases
    WHERE business_id = p_business_id;

    -- Get total received payments from sales
    SELECT COALESCE(SUM(paid_amount), 0)
    INTO v_total_received_sales
    FROM sales
    WHERE business_id = p_business_id
    AND status_id NOT IN (
        SELECT status_id 
        FROM statuses 
        WHERE name IN ('VOID', 'CANCELLED')
    );

    -- Get total customer dues (using customer_balance)
    SELECT COALESCE(SUM(customer_balance), 0)
    INTO v_total_customer_dues
    FROM business_customers
    WHERE business_id = p_business_id;

    -- Get total supplier dues (using supplier_balance)
    SELECT COALESCE(SUM(supplier_balance), 0)
    INTO v_total_supplier_dues
    FROM suppliers
    WHERE business_id = p_business_id;

    -- Return JSON object
    RETURN json_build_object(
        'total_sales', v_total_sales,
        'total_purchases', v_total_purchases,
        'total_received_sales', v_total_received_sales,
        'total_customer_dues', v_total_customer_dues,
        'total_supplier_dues', v_total_supplier_dues
    );
END;
$$;


ALTER FUNCTION "public"."get_business_summaries"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_business_summaries"("p_business_id" "uuid", "p_org_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    -- GL Account Codes from COA v6.4
    v_ar_code                   TEXT := '1120'; -- Accounts Receivable
    v_ap_code                   TEXT := '2110'; -- Accounts Payable
    v_inventory_code            TEXT := '1130'; -- Inventory
    v_sales_products_code       TEXT := '4110'; -- Sales Revenue - Products
    v_sales_services_code       TEXT := '4120'; -- Sales Revenue - Services
    v_shipping_revenue_code     TEXT := '4210'; -- Shipping & Handling Revenue
    v_sales_discount_code       TEXT := '4800'; -- Sales Discounts (Contra Revenue, Debit balance increases it)
    -- For Total Purchases (Inventory-related cost components)
    v_freight_in_code           TEXT := '5310'; -- Freight-In
    v_purchase_discount_code    TEXT := '5800'; -- Purchase Discounts (Contra COGS, Credit balance increases it)
    -- Payment Accounts (for a proxy of total received sales if needed more directly)
    v_cash_in_bank_code         TEXT := '1111';
    v_petty_cash_code           TEXT := '1113';

    -- Account IDs
    v_ar_acc_id                 UUID;
    v_ap_acc_id                 UUID;
    v_inventory_acc_id          UUID;
    v_sales_products_acc_id     UUID;
    v_sales_services_acc_id     UUID;
    v_shipping_revenue_acc_id   UUID;
    v_sales_discount_acc_id     UUID;
    v_freight_in_acc_id         UUID;
    v_purchase_discount_acc_id  UUID;
    v_cash_in_bank_acc_id       UUID;
    v_petty_cash_acc_id         UUID;

    -- Summary Variables
    v_net_sales_period          NUMERIC; -- For a defined period (e.g., YTD or all time)
    v_inventory_purchases_cost  NUMERIC; -- Cost of inventory purchased (Net of discounts, including freight)
    v_total_customer_dues       NUMERIC; -- Current A/R Balance
    v_total_supplier_dues       NUMERIC; -- Current A/P Balance
    v_total_stock_value         NUMERIC; -- Current Inventory Balance
    v_total_cash_receipts_from_sales NUMERIC; -- Proxy for total received sales

BEGIN
    RAISE LOG 'get_business_summaries: Fetching for Business: %, Org: %', p_business_id, p_org_id;

    -- Fetch Account IDs (important to filter by org_id too)
    SELECT account_id INTO v_ar_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_ar_code AND is_group = FALSE;
    SELECT account_id INTO v_ap_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_ap_code AND is_group = FALSE;
    SELECT account_id INTO v_inventory_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_inventory_code AND is_group = FALSE;
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_sales_products_code AND is_group = FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_sales_services_code AND is_group = FALSE;
    SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_shipping_revenue_code AND is_group = FALSE;
    SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_sales_discount_code AND is_group = FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_freight_in_code AND is_group = FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_purchase_discount_code AND is_group = FALSE;
    SELECT account_id INTO v_cash_in_bank_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    SELECT account_id INTO v_petty_cash_acc_id FROM public.accounts WHERE business_id = p_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;

    -- 1. Total Customer Dues (Current A/R Balance)
    -- A/R has a DEBIT normal balance.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_total_customer_dues
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND te.account_id = v_ar_acc_id;
    RAISE LOG 'get_business_summaries: Total Customer Dues (A/R Balance): %', v_total_customer_dues;

    -- 2. Total Supplier Dues (Current A/P Balance)
    -- A/P has a CREDIT normal balance.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_total_supplier_dues
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND te.account_id = v_ap_acc_id;
    RAISE LOG 'get_business_summaries: Total Supplier Dues (A/P Balance): %', v_total_supplier_dues;

    -- 3. Total Stock Value (Current Inventory Balance)
    -- Inventory has a DEBIT normal balance.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_total_stock_value
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND te.account_id = v_inventory_acc_id;
    RAISE LOG 'get_business_summaries: Total Stock Value (Inventory Balance): %', v_total_stock_value;

    -- 4. Net Sales (All time, or add date filter for period specific)
    -- Revenue accounts have CREDIT normal balance, Sales Discount has DEBIT normal balance.
    SELECT COALESCE(SUM(
        CASE
            WHEN te.account_id IN (v_sales_products_acc_id, v_sales_services_acc_id, v_shipping_revenue_acc_id) AND te.entry_type = 'CREDIT' THEN te.amount
            WHEN te.account_id IN (v_sales_products_acc_id, v_sales_services_acc_id, v_shipping_revenue_acc_id) AND te.entry_type = 'DEBIT' THEN -te.amount -- (e.g. sales returns if posted here)
            WHEN te.account_id = v_sales_discount_acc_id AND te.entry_type = 'DEBIT' THEN -te.amount -- Subtract discounts
            WHEN te.account_id = v_sales_discount_acc_id AND te.entry_type = 'CREDIT' THEN te.amount -- (Unusual for discount)
            ELSE 0
        END
    ), 0)
    INTO v_net_sales_period
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND te.account_id IN (
          v_sales_products_acc_id, 
          v_sales_services_acc_id, 
          v_shipping_revenue_acc_id, 
          v_sales_discount_acc_id
      );
    -- AND t.transaction_date >= 'YYYY-MM-DD' AND t.transaction_date <= 'YYYY-MM-DD' -- For period specific
    RAISE LOG 'get_business_summaries: Net Sales: %', v_net_sales_period;

    -- 5. Cost of Inventory Purchased (All time, or add date filter)
    -- This represents the net cost of inventory acquisitions.
    -- Inventory account DEBITS for purchases, Freight-In DEBITS, Purchase Discounts CREDITS.
    SELECT COALESCE(SUM(
        CASE
            -- Debits to Inventory from 'PURCHASE' or 'OPENING_STOCK' type transactions (Initial value of purchased/opened inventory)
            WHEN te.account_id = v_inventory_acc_id AND te.entry_type = 'DEBIT' AND t.transaction_type IN ('PURCHASE', 'OPENING_STOCK') THEN te.amount
            -- Debits to Freight-In
            WHEN te.account_id = v_freight_in_acc_id AND te.entry_type = 'DEBIT' THEN te.amount
            -- Credits to Purchase Discounts (these reduce cost, so subtract their credit value or add their debit value)
            WHEN te.account_id = v_purchase_discount_acc_id AND te.entry_type = 'CREDIT' THEN -te.amount
            WHEN te.account_id = v_purchase_discount_acc_id AND te.entry_type = 'DEBIT' THEN te.amount -- (Unusual for purchase discount)
            ELSE 0
        END
    ), 0)
    INTO v_inventory_purchases_cost
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND (
          (te.account_id = v_inventory_acc_id AND t.transaction_type IN ('PURCHASE', 'OPENING_STOCK')) OR
          te.account_id = v_freight_in_acc_id OR
          te.account_id = v_purchase_discount_acc_id
      );
    RAISE LOG 'get_business_summaries: Inventory Purchases Cost: %', v_inventory_purchases_cost;
    
    -- 6. Total Cash Receipts from Sales (Proxy: Sum of DEBITS to Cash/Bank accounts where transaction_type is 'SALE' or 'CUSTOMER_PAYMENT')
    -- This is a cash flow view and can be complex to get perfectly from just GL balances without more context.
    -- A more direct way if your `payments` table is reliable and links to sales transactions:
    -- SELECT COALESCE(SUM(p.amount), 0) FROM public.payments p JOIN public.transactions t ON p.transaction_id = t.transaction_id
    -- WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND t.transaction_type = 'SALE' (or settlement of A/R);
    -- For GL based proxy:
    SELECT COALESCE(SUM(te.amount), 0)
    INTO v_total_cash_receipts_from_sales
    FROM public.transaction_entries te
    JOIN public.transactions t ON t.transaction_id = te.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id
      AND te.account_id IN (v_cash_in_bank_acc_id, v_petty_cash_acc_id)
      AND te.entry_type = 'DEBIT'
      AND (t.transaction_type = 'SALE' OR t.notes ILIKE '%Payment Received for Sale%' OR t.notes ILIKE '%Customer Settlement%'); -- Heuristic
    RAISE LOG 'get_business_summaries: Total Cash Receipts from Sales (Proxy): %', v_total_cash_receipts_from_sales;

    RETURN json_build_object(
        'net_sales', v_net_sales_period,  -- More accurate term than 'total_sales'
        'inventory_purchases_cost', v_inventory_purchases_cost, -- More descriptive than 'total_purchases'
        'total_cash_receipts_from_sales', v_total_cash_receipts_from_sales, -- Proxy for 'total_received_sales'
        'total_customer_dues', v_total_customer_dues,
        'total_supplier_dues', v_total_supplier_dues,
        'total_stock_value', v_total_stock_value -- Added
    );
END;
$$;


ALTER FUNCTION "public"."get_business_summaries"("p_business_id" "uuid", "p_org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_chart_of_accounts_tree"("p_business_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" STABLE
    AS $$
DECLARE
    v_result jsonb;
BEGIN
    SELECT jsonb_agg(category_obj ORDER BY category_code) -- Order categories by code
    INTO v_result
    FROM (
        SELECT
            jsonb_build_object(
                'category_id', ac.category_id,
                'name', ac.name,
                'code', ac.code,
                'description', ac.description,
                'children', COALESCE(
                    ( -- Subquery to aggregate top-level accounts/groups for this category
                        SELECT jsonb_agg(node ORDER BY account_code)
                        FROM (
                            SELECT
                                public.build_account_node(a.account_id, p_business_id) as node,
                                a.code as account_code
                            FROM public.accounts a
                            WHERE a.business_id = p_business_id
                              AND a.category_id = ac.category_id
                              AND a.parent_account_id IS NULL -- Start with top-level items in the category
                        ) AS top_level_accounts
                        WHERE node IS NOT NULL
                    ),
                    '[]'::jsonb -- Default to empty array if no top-level accounts/groups
                )
            ) AS category_obj,
            ac.code AS category_code
        FROM public.account_categories ac
        WHERE ac.business_id = p_business_id
    ) AS categories_subquery;

    -- If no categories found for the business, return an empty array
    IF v_result IS NULL THEN
        RETURN '[]'::jsonb;
    END IF;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_chart_of_accounts_tree"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_current_fiscal_period"("p_business_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_start_month INT;
    v_end_month INT;
    v_current_date DATE := NOW()::DATE;
    v_current_year INT := EXTRACT(YEAR FROM v_current_date);
    v_current_month INT := EXTRACT(MONTH FROM v_current_date);
    v_fiscal_start_year INT;
    v_fiscal_end_year INT;
    v_start_date DATE;
    v_end_date DATE;
BEGIN
    -- Get fiscal year details for the business
    SELECT fy.start_month, fy.end_month
    INTO v_start_month, v_end_month
    FROM public.businesses b
    JOIN public.fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id;

    IF v_start_month IS NULL THEN
        -- Handle case where business or fiscal year is not found or not set
        -- Defaulting to standard calendar year (Jan - Dec)
        v_start_month := 1;
        v_end_month := 12;
        -- Optionally, you could raise an exception or return NULL
        -- RETURN NULL;
        -- RAISE EXCEPTION 'Fiscal year not set for business_id %', p_business_id;
    END IF;

    -- Determine the start year of the current fiscal period
    IF v_current_month < v_start_month THEN
        v_fiscal_start_year := v_current_year - 1;
    ELSE
        v_fiscal_start_year := v_current_year;
    END IF;

    -- Determine the end year of the current fiscal period
    IF v_end_month < v_start_month THEN
        v_fiscal_end_year := v_fiscal_start_year + 1;
    ELSE
        v_fiscal_end_year := v_fiscal_start_year;
    END IF;

    -- Calculate the start date
    v_start_date := MAKE_DATE(v_fiscal_start_year, v_start_month, 1);

    -- Calculate the end date (last day of the end month)
    v_end_date := (DATE_TRUNC('MONTH', MAKE_DATE(v_fiscal_end_year, v_end_month, 1)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY')::DATE;

    -- Construct JSON result
    RETURN jsonb_build_object(
        'start_date', v_start_date,
        'end_date', v_end_date
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         -- Handle case where business or fiscal year is not found
         -- Defaulting to standard calendar year (Jan - Dec) or return NULL/error
         RETURN jsonb_build_object(
            'start_date', MAKE_DATE(EXTRACT(YEAR FROM NOW())::INT, 1, 1),
            'end_date', MAKE_DATE(EXTRACT(YEAR FROM NOW())::INT, 12, 31)
         );
         -- RETURN NULL;
    WHEN OTHERS THEN
        -- Log error or handle other exceptions
        RAISE NOTICE 'Error in get_current_fiscal_period for business %: %', p_business_id, SQLERRM;
        RETURN NULL; -- Or re-raise the exception
END;
$$;


ALTER FUNCTION "public"."get_current_fiscal_period"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_daily_transactions_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_start_date timestamp with time zone;
  v_end_date timestamp with time zone;
  result json;
BEGIN
  -- Use provided dates or default to full range in the view
  IF p_start_date IS NULL THEN
    SELECT MIN(date) INTO v_start_date FROM public.vw_daily_transactions_report_v2 WHERE business_id = p_business_id;
  ELSE
    v_start_date := p_start_date;
  END IF;

  IF p_end_date IS NULL THEN
    SELECT MAX(date) INTO v_end_date FROM public.vw_daily_transactions_report_v2 WHERE business_id = p_business_id;
  ELSE
    v_end_date := p_end_date;
  END IF;

  -- Aggregate summary
  SELECT json_build_object(
    'total_transactions', COUNT(DISTINCT transaction_id),
    'total_payments_in', COALESCE(SUM(payment_in), 0),
    'total_payments_out', COALESCE(SUM(payment_out), 0),
    'net_balance_change', COALESCE(SUM(payment_in), 0) - COALESCE(SUM(payment_out), 0)
  ) INTO result
  FROM public.vw_daily_transactions_report_v2
  WHERE business_id = p_business_id
    AND date >= v_start_date
    AND date <= v_end_date;

  RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_daily_transactions_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_dashboard_data"("p_business_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_result JSON;
    v_fiscal_year_start DATE;
    v_fiscal_year_end DATE;
BEGIN
    -- Get fiscal year dates
    v_fiscal_year_start := DATE_TRUNC('year', CURRENT_DATE);
    v_fiscal_year_end := (v_fiscal_year_start + INTERVAL '1 year' - INTERVAL '1 day')::DATE;

    WITH daily_sales AS (
        -- Calculate today's sales
        SELECT COALESCE(SUM(total_amount), 0) as amount
        FROM sales
        WHERE business_id = p_business_id
        AND DATE(sale_date) = CURRENT_DATE
    ),
    yearly_income AS (
        -- Calculate total income for current fiscal year
        SELECT COALESCE(SUM(total_amount), 0) as amount
        FROM sales
        WHERE business_id = p_business_id
        AND sale_date BETWEEN v_fiscal_year_start AND v_fiscal_year_end
    ),
    yearly_expenses AS (
        -- Calculate total expenses for current fiscal year
        SELECT COALESCE(SUM(total_amount), 0) as amount
        FROM purchases
        WHERE business_id = p_business_id
        AND purchase_date BETWEEN v_fiscal_year_start AND v_fiscal_year_end
    ),
    new_customers AS (
        -- Count new customers in last 30 days
        SELECT COUNT(*) as count
        FROM business_customers
        WHERE business_id = p_business_id
        AND created_at >= (CURRENT_DATE - INTERVAL '30 days')
    ),
    top_selling_items AS (
        -- Get top 5 selling items
        SELECT 
            i.name,
            COALESCE(SUM(si.quantity), 0) as sold_count
        FROM sale_items si
        JOIN items i ON i.item_id = si.item_id
        JOIN sales s ON s.sale_id = si.sale_id
        WHERE s.business_id = p_business_id
		AND is_active = true 
        AND s.sale_date >= (CURRENT_DATE - INTERVAL '30 days')
        GROUP BY i.name
        ORDER BY sold_count DESC
        LIMIT 5
    ),
    low_stock_items AS (
        -- Get items with low stock
        SELECT 
            name,
            stock_quantity as stock_left
        FROM items
        WHERE business_id = p_business_id
		AND is_active = true
        AND stock_quantity <= alert_quantity
		AND item_type = 'goods'::public.item_type
        ORDER BY stock_quantity ASC
        LIMIT 5
    ),
    category_stats AS (
        -- Calculate item category statistics
        WITH total_sales AS (
            SELECT COALESCE(SUM(si.quantity * si.unit_price), 0) as total_amount
            FROM sale_items si
            JOIN sales s ON s.sale_id = si.sale_id
            WHERE s.business_id = p_business_id
            AND s.sale_date >= (CURRENT_DATE - INTERVAL '30 days')
        )
        SELECT 
            c.icon_info as icon_info,
            c.name as category_name,
            ROUND(
                (SUM(si.quantity * si.unit_price) * 100.0 / NULLIF((SELECT total_amount FROM total_sales), 0))::numeric, 
                2
            ) as percentage
        FROM sale_items si
        JOIN sales s ON s.sale_id = si.sale_id
        JOIN items i ON i.item_id = si.item_id
        JOIN item_categories c ON c.item_category_id = i.item_category_id
        WHERE s.business_id = p_business_id
        AND s.sale_date >= (CURRENT_DATE - INTERVAL '30 days')
        GROUP BY c.name, c.icon_info
        ORDER BY percentage DESC
        LIMIT 5
    )
    SELECT json_build_object(
        'daily_sales', (SELECT amount FROM daily_sales),
        'total_incomes_current_fiscal_year', (SELECT amount FROM yearly_income),
        'total_expenses_current_fiscal_year', (SELECT amount FROM yearly_expenses),
        'new_customers_past_30_days', (SELECT count FROM new_customers),
        'top_selling_items', (
            SELECT json_agg(
                json_build_object(
                    'name', name,
                    'sold_count', sold_count
                )
            )
            FROM top_selling_items
        ),
        'low_stock_items', (
            SELECT json_agg(
                json_build_object(
                    'name', name,
                    'stock_left', stock_left
                )
            )
            FROM low_stock_items
        ),
        'item_category_statistics', (
            SELECT json_agg(
                json_build_object(
                    'icon_info', icon_info,
                    'category_name', category_name,
                    'percentage', percentage
                )
            )
            FROM category_stats
        )
    ) INTO v_result;

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_dashboard_data"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employee_sales_report"("start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "page_number" integer DEFAULT 1, "page_size" integer DEFAULT 10, "p_business_id" "uuid" DEFAULT NULL::"uuid", "employee_name_filter" "text" DEFAULT NULL::"text") RETURNS TABLE("employee_name" "text", "employee_role" "public"."employee_type", "employee_code" "text", "total_items_sold" numeric, "total_revenue_generated" numeric)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    offset_value integer;
BEGIN
    -- Calculate the offset for pagination
    offset_value := (page_number - 1) * page_size;

    -- Ensure page_number and page_size are not negative and page_size is not zero
    IF page_number < 1 THEN
        page_number := 1; -- Default to first page if page_number is invalid
    END IF;
    IF page_size < 1 THEN
        page_size := 10; -- Default to 10 items per page if page_size is invalid
    END IF;

    RETURN QUERY
    SELECT
        ev.name AS employee_name,
        ev.role AS employee_role,
        ev.code AS employee_code,
        COALESCE(SUM(si.quantity), 0) AS total_items_sold,
        COALESCE(SUM(s.total_amount), 0) AS total_revenue_generated
    FROM
        employee_view ev
    LEFT JOIN
        sales s ON s.created_by = ev.employee_id AND s.business_id = p_business_id
    LEFT JOIN
        sale_items si ON si.sale_id = s.sale_id
    WHERE
        (start_date IS NULL OR s.sale_date >= start_date)
        AND (end_date IS NULL OR s.sale_date <= end_date)
        AND (p_business_id IS NULL OR s.business_id = p_business_id)
        AND (employee_name_filter IS NULL OR ev.name ILIKE '%' || employee_name_filter || '%') -- Added employee name filter
    GROUP BY
        ev.employee_id,
        ev.name,
        ev.role,
        ev.code
    ORDER BY
        total_revenue_generated DESC
    LIMIT page_size
    OFFSET offset_value;

END;
$$;


ALTER FUNCTION "public"."get_employee_sales_report"("start_date" timestamp with time zone, "end_date" timestamp with time zone, "page_number" integer, "page_size" integer, "p_business_id" "uuid", "employee_name_filter" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_employee_sales_summary_total"("page_number" integer, "page_size" integer, "p_business_id" "uuid", "start_date" "date", "end_date" "date", "employee_name_filter" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- We don't need offset_value or to validate page_number/page_size for the summary
BEGIN
    RETURN (
        WITH employee_level_aggregates AS (
            -- This CTE calculates the aggregates per employee, exactly like your original query
            -- before pagination. The filters applied here determine which employees
            -- and which of their sales contribute to the summary.
            SELECT
                ev.employee_id, -- Needed for distinct count of employees
                COALESCE(SUM(si.quantity), 0) AS per_employee_total_items_sold,
                COALESCE(SUM(s.total_amount), 0) AS per_employee_total_revenue_generated
            FROM
                employee_view ev
            LEFT JOIN
                -- This ON condition for sales.business_id directly uses p_business_id.
                -- If p_business_id is NULL, `s.business_id = NULL` means only sales with a NULL business_id are joined.
                -- This matches the structure of your provided query.
                sales s ON s.created_by = ev.employee_id AND s.business_id = p_business_id
            LEFT JOIN
                sale_items si ON si.sale_id = s.sale_id
            WHERE
                -- Date filters: these apply to sales records. If an employee has no sales
                -- in this date range (or s.sale_date is NULL due to no matching sales from JOIN),
                -- they might be filtered out if start_date/end_date are NOT NULL.
                (start_date IS NULL OR s.sale_date >= start_date)
                AND (end_date IS NULL OR s.sale_date <= end_date)
                -- Business ID filter (from original WHERE clause):
                -- If p_business_id is NOT NULL, s.business_id must match it.
                -- If s.business_id is NULL (e.g. no sales matched in ON, or employee has no sales),
                -- this condition (NULL = p_business_id) would be false, filtering out the employee.
                -- This ensures that employees are only included if their sales match the p_business_id criteria,
                -- matching the filtering behavior of your original query.
                AND (p_business_id IS NULL OR s.business_id = p_business_id)
                -- Employee name filter
                AND (employee_name_filter IS NULL OR ev.name ILIKE '%' || employee_name_filter || '%')
            GROUP BY
                ev.employee_id
                -- No need to group by ev.name, ev.role, ev.code here as we only need employee_id for the summary logic
        )
        -- Aggregate the per-employee results into the final summary
        SELECT
            jsonb_build_object(
                'total_employees', COUNT(DISTINCT ela.employee_id), -- Counts employees who met all above criteria
                'total_items_sold', COALESCE(SUM(ela.per_employee_total_items_sold), 0),
                'total_revenue_generated', COALESCE(SUM(ela.per_employee_total_revenue_generated), 0)
            )
        FROM
            employee_level_aggregates ela
    );
END;
$$;


ALTER FUNCTION "public"."get_employee_sales_summary_total"("page_number" integer, "page_size" integer, "p_business_id" "uuid", "start_date" "date", "end_date" "date", "employee_name_filter" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_claim"("claim" "text") RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select coalesce(current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' -> claim, null);
$$;


ALTER FUNCTION "public"."get_my_claim"("claim" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_current_org_id"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select nullif(get_my_claim('current_org_id')::text, '')::uuid; -- remove quotes and cast
$$;


ALTER FUNCTION "public"."get_my_current_org_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_user_type"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select nullif(get_my_claim('user_type')::text, '')::text; -- remove quotes
$$;


ALTER FUNCTION "public"."get_my_user_type"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_credit_note_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_sequence_name TEXT;
    v_next_val BIGINT;
BEGIN
    -- Ensure the sequence for this business exists, and get its name
    v_sequence_name := public.ensure_credit_note_sequence(business_id);

    -- Atomically get the next value from the sequence
    v_next_val := nextval(v_sequence_name);

    -- Format the code with leading zeros (adjust padding as needed)
    RETURN 'CN-' || lpad(v_next_val::text, 6, '0');
END;
$$;


ALTER FUNCTION "public"."get_next_credit_note_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_invoice_code"("p_business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    v_prefix TEXT;
    v_padding INT;
    v_next_val BIGINT;
    v_last_val BIGINT;
    v_start_val BIGINT;
    v_sequence_name TEXT;
    v_sequence_regclass REGCLASS;
BEGIN
    -- 1. Get business-specific settings (or use defaults)
    BEGIN
        SELECT invoice_prefix, invoice_number_padding
        INTO v_prefix, v_padding
        FROM public.business_settings
        WHERE business_id = p_business_id;
    EXCEPTION
        WHEN undefined_table THEN
            v_prefix := 'INV-';
            v_padding := 5;
    END;

    v_prefix := COALESCE(v_prefix, 'INV-');
    v_padding := COALESCE(v_padding, 5);

    -- 2. Define the unique sequence name
    v_sequence_name := p_business_id::text || '_invoice_code';

    -- 3. Create the sequence if it doesn't exist
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS public."' || v_sequence_name || '" START 1;';

    -- Convert the sequence name to a regclass for use in system functions
    v_sequence_regclass := ('public."' || v_sequence_name || '"')::regclass;

    -- 4. Get the last value returned by nextval() for this sequence.
    -- pg_sequence_last_value is a reliable way to check usage across all sessions.
    v_last_val := pg_sequence_last_value(v_sequence_regclass);

    -- 5. Determine the *next* value to be generated
    -- If pg_sequence_last_value is null, nextval() has never been called for this sequence.
    -- In this case, the next value will be the sequence's start_value.
    IF v_last_val IS NULL THEN
        SELECT start_value INTO v_start_val FROM pg_sequences
        WHERE schemaname = 'public' AND sequencename = v_sequence_name;
        v_next_val := v_start_val;
    ELSE
        v_next_val := v_last_val + 1;
    END IF;

    -- 6. Format the code with the prefix and zero-padding
    
    RETURN v_prefix || lpad(v_next_val::text, v_padding, '0');
END;$$;


ALTER FUNCTION "public"."get_next_invoice_code"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_item_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_item_code'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_item_code');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_item_code') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'ITEM-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_item_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_payment_code_preview"("p_business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_sequence_name   TEXT;
    v_next_code_num   BIGINT;
    v_start_val       BIGINT;
    v_last_val        BIGINT;
BEGIN
    -- 1. Define the sequence name
    v_sequence_name := 'public."' || p_business_id::text || '_payment_code"';

    -- 2. Create the sequence if it doesn't exist (safe to run every time)
    EXECUTE 'CREATE SEQUENCE IF NOT EXISTS ' || v_sequence_name || ' START 1;';

    -- 3. Safely "peek" at the next value to be generated
    -- This method works across different PostgreSQL versions.
    v_last_val := pg_sequence_last_value((v_sequence_name)::regclass);
    
    IF v_last_val IS NULL THEN
        -- If the sequence has never been used, the next value is its start value.
        SELECT start_value INTO v_start_val FROM pg_sequences
        WHERE schemaname = 'public' AND sequencename = p_business_id::text || '_payment_code';
        v_next_code_num := v_start_val;
    ELSE
        -- Otherwise, the next value is one more than the last generated value.
        v_next_code_num := v_last_val + 1;
    END IF;
    
    -- 4. Format the predicted number using our existing helper function
    RETURN public.format_payment_code(p_business_id, v_next_code_num);
END;
$$;


ALTER FUNCTION "public"."get_next_payment_code_preview"("p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_purchase_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_purchase_invoice'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_purchase_invoice');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_purchase_invoice') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'PURCHASE-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_purchase_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_purchase_return_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_purchase_return_code'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_purchase_return_code');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_purchase_return_code') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'PURCHASE-RETURN-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_purchase_return_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_quote_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_quote_code'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_quote_code');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_quote_code') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'QUOTE-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_quote_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_sale_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_sale_invoice'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_sale_invoice');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_sale_invoice') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'SALE-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_sale_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_next_sale_return_code"("business_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_base_name text;
    next_value text;
    formatted_value text;
    sequence_exists boolean;
BEGIN
    v_base_name := business_id::text;
    
    -- Check if sequence exists
    SELECT EXISTS (
        SELECT 1 
        FROM pg_sequences 
        WHERE schemaname = 'public' 
        AND sequencename = v_base_name || '_sale_return_code'
    ) INTO sequence_exists;
    
    -- Create sequence if it doesn't exist
    IF NOT sequence_exists THEN
        EXECUTE format('CREATE SEQUENCE IF NOT EXISTS public.%I START 1', v_base_name || '_sale_return_code');
    END IF;
    
    -- Get the next value of the item_code sequence without incrementing
        EXECUTE format('SELECT LPAD(CASE 
             				WHEN is_called THEN (last_value + 1)::text 
             				ELSE last_value::text 
           				END, 6, ''0'') 
					FROM %I', v_base_name || '_sale_return_code') INTO next_value;
    
    -- Format the value with prefix
    formatted_value := 'SALE-RETURN-' || next_value;
    
    RETURN formatted_value;
END;
$$;


ALTER FUNCTION "public"."get_next_sale_return_code"("business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_brand"("p_business_id" "uuid", "p_brand_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_brand_id uuid;
    v_org_id uuid;
BEGIN
     IF p_brand_name IS NULL OR trim(p_brand_name) = '' THEN
        RETURN NULL;
    END IF;

    SELECT brand_id INTO v_brand_id
    FROM public.brands
    WHERE business_id = p_business_id AND lower(name) = lower(trim(p_brand_name));

    IF v_brand_id IS NULL THEN
        SELECT org_id INTO v_org_id FROM public.businesses WHERE business_id = p_business_id;
        IF v_org_id IS NULL THEN RAISE EXCEPTION 'Cannot find org_id for business %', p_business_id; END IF;

        INSERT INTO public.brands (name, business_id, org_id)
        VALUES (trim(p_brand_name), p_business_id, v_org_id)
        RETURNING brand_id INTO v_brand_id;
    END IF;

    RETURN v_brand_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_brand"("p_business_id" "uuid", "p_brand_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_item_category"("p_business_id" "uuid", "p_category_name" "text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_category_id uuid;
    v_org_id uuid;
BEGIN
    IF p_category_name IS NULL OR trim(p_category_name) = '' THEN
        RETURN NULL; -- Return NULL if no name provided
    END IF;

    -- Find existing category by name (case-insensitive recommended)
    SELECT item_category_id INTO v_category_id
    FROM public.item_categories
    WHERE business_id = p_business_id AND lower(name) = lower(trim(p_category_name));

    -- If not found, create it
    IF v_category_id IS NULL THEN
        -- Need org_id to insert
        SELECT org_id INTO v_org_id FROM public.businesses WHERE business_id = p_business_id;
        IF v_org_id IS NULL THEN RAISE EXCEPTION 'Cannot find org_id for business %', p_business_id; END IF;

        INSERT INTO public.item_categories (name, business_id, org_id)
        VALUES (trim(p_category_name), p_business_id, v_org_id)
        RETURNING item_category_id INTO v_category_id;
    END IF;

    RETURN v_category_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_item_category"("p_business_id" "uuid", "p_category_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_unit"("p_business_id" "uuid", "p_unit_name" "text", "p_unit_short_name" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_unit_id uuid;
    v_org_id uuid;
    v_final_short_name text;
BEGIN
     IF p_unit_name IS NULL OR trim(p_unit_name) = '' THEN
        RETURN NULL;
    END IF;

    SELECT unit_id INTO v_unit_id
    FROM public.units
    WHERE business_id = p_business_id AND lower(name) = lower(trim(p_unit_name));

    IF v_unit_id IS NULL THEN
        SELECT org_id INTO v_org_id FROM public.businesses WHERE business_id = p_business_id;
        IF v_org_id IS NULL THEN RAISE EXCEPTION 'Cannot find org_id for business %', p_business_id; END IF;

        -- Use provided short name or derive from long name
        v_final_short_name := COALESCE(trim(p_unit_short_name), upper(substring(trim(p_unit_name) from 1 for 3)));

        INSERT INTO public.units (name, short_name, business_id, org_id)
        VALUES (trim(p_unit_name), v_final_short_name, p_business_id, v_org_id)
        RETURNING unit_id INTO v_unit_id;
    END IF;

    RETURN v_unit_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_unit"("p_business_id" "uuid", "p_unit_name" "text", "p_unit_short_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_party_transaction_summary"("party_type" "text", "party_id" "uuid", "p_business_id" "uuid") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_total NUMERIC;
    v_total_paid NUMERIC;
    v_total_due NUMERIC;
BEGIN
    -- Initialize variables
    v_total := 0;
    v_total_paid := 0;
    v_total_due := 0;

    -- Calculate summaries based on party type
    IF party_type = 'customer' THEN
        -- Get customer transaction summaries
        SELECT 
            COALESCE(SUM(s.total_amount), 0),
            COALESCE(SUM(s.paid_amount), 0),
            COALESCE(SUM(s.due_amount), 0)
        INTO v_total, v_total_paid, v_total_due
        FROM sales s
        WHERE s.customer_id = party_id
		AND s.business_id = p_business_id
        AND s.status_id NOT IN (
            SELECT status_id 
            FROM statuses 
            WHERE name IN ('VOID', 'CANCELLED')
        );

        -- Get current due from business_customers
        SELECT COALESCE(customer_balance, 0)
        INTO v_total_due
        FROM business_customers
        WHERE customer_id = party_id
		AND business_id = p_business_id;

    ELSIF party_type = 'supplier' THEN
        -- Get supplier transaction summaries
        SELECT 
            COALESCE(SUM(p.total_amount), 0),
            COALESCE(SUM(p.paid_amount), 0),
            COALESCE(SUM(p.due_amount), 0)
        INTO v_total, v_total_paid, v_total_due
        FROM purchases p
        WHERE p.supplier_id = party_id
		AND p.business_id = p_business_id;

        -- Get current due from suppliers
        SELECT COALESCE(supplier_balance, 0)
        INTO v_total_due
        FROM suppliers
        WHERE supplier_id = party_id
		AND business_id = p_business_id;

    ELSE
        RAISE EXCEPTION 'Invalid party type: %', party_type;
    END IF;

    -- Return JSON object
    RETURN json_build_object(
        'total', v_total,
        'total_paid', v_total_paid,
        'total_due', v_total_due
    );
END;
$$;


ALTER FUNCTION "public"."get_party_transaction_summary"("party_type" "text", "party_id" "uuid", "p_business_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_profit_and_loss"("p_business_id" "uuid", "p_start_date" "date", "p_end_date" "date") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Account Codes (COA v6.4)
    v_sales_products_code       TEXT := '4110';
    v_sales_services_code       TEXT := '4120';
    v_shipping_revenue_code     TEXT := '4210';
    v_sales_discount_code       TEXT := '4800'; -- Contra Revenue (Debit increases)
    
    v_cogs_products_code        TEXT := '5110';
    v_freight_in_code           TEXT := '5310';
    v_purchase_discount_code    TEXT := '5800'; -- Contra COGS (Credit increases)

    v_general_income_code       TEXT := '4010';
    v_stock_overage_code        TEXT := '4950';

    -- For summing all operating expenses, we'll use the category
    v_opex_category_code        TEXT := 'OPE';

    -- Account IDs
    v_sales_products_acc_id     UUID;
    v_sales_services_acc_id     UUID;
    v_shipping_revenue_acc_id   UUID;
    v_sales_discount_acc_id     UUID;
    
    v_cogs_products_acc_id      UUID;
    v_freight_in_acc_id         UUID;
    v_purchase_discount_acc_id  UUID;

    v_general_income_acc_id     UUID;
    v_stock_overage_acc_id      UUID;

    v_opex_category_id          UUID; -- To sum all OPE accounts

    -- P&L Line Items
    v_revenue_products        NUMERIC := 0;
    v_revenue_services        NUMERIC := 0;
    v_revenue_shipping        NUMERIC := 0;
    v_sales_discounts_total   NUMERIC := 0;
    v_net_sales_revenue       NUMERIC := 0;

    v_cogs_products_total     NUMERIC := 0;
    v_freight_in_total        NUMERIC := 0;
    v_purchase_discounts_total NUMERIC := 0;
    v_net_cogs                NUMERIC := 0;

    v_gross_profit            NUMERIC := 0;

    v_income_general          NUMERIC := 0;
    v_income_stock_overage    NUMERIC := 0;
    v_total_other_income      NUMERIC := 0;

    v_total_operating_expenses NUMERIC := 0;
    
    v_net_income_loss         NUMERIC := 0;

	v_result				  JSONB;
BEGIN
    RAISE LOG 'get_profit_and_loss: Fetching for Business: %, Period: % to %', 
        p_business_id, p_start_date, p_end_date;

    -- Fetch Account IDs
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_sales_products_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_sales_services_code AND is_group=FALSE;
    SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_shipping_revenue_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_sales_discount_code AND is_group=FALSE;
    
    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_cogs_products_code AND is_group=FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_freight_in_code AND is_group=FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_purchase_discount_code AND is_group=FALSE;

    SELECT account_id INTO v_general_income_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_general_income_code AND is_group=FALSE;
    SELECT account_id INTO v_stock_overage_acc_id FROM public.accounts WHERE business_id=p_business_id AND code=v_stock_overage_code AND is_group=FALSE;

    SELECT category_id INTO v_opex_category_id FROM public.account_categories WHERE business_id=p_business_id AND code=v_opex_category_code;

    -- 1. Calculate Net Sales Revenue
    -- Revenue accounts have CREDIT normal balance. Sales Discount has DEBIT normal balance.
    -- Sum Credits for revenue accounts, sum Debits for sales discount.
    -- Net Sales = (Credit Sales Product + Credit Sales Service + Credit Shipping Rev) - Debit Sales Discount
    
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_products
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_sales_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_services
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_sales_services_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_shipping
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_shipping_revenue_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Sales Discount is a contra-revenue, normal balance is DEBIT. So we sum debits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_sales_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_sales_discount_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    v_net_sales_revenue := v_revenue_products + v_revenue_services + v_revenue_shipping - v_sales_discounts_total;
    RAISE LOG 'P&L: Products:%, Services:%, Shipping:%, Discounts:(-)%, NetSales:%', 
        v_revenue_products, v_revenue_services, v_revenue_shipping, v_sales_discounts_total, v_net_sales_revenue;

    -- 2. Calculate Net Cost of Goods Sold (COGS)
    -- COGS & Freight-In have DEBIT normal balance. Purchase Discount has CREDIT normal balance.
    -- Net COGS = (Debit COGS Products + Debit Freight-In) - Credit Purchase Discounts
    
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_cogs_products_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_cogs_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_freight_in_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_freight_in_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Purchase Discount is a contra-COGS, normal balance is CREDIT. So we sum credits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_purchase_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_purchase_discount_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    v_net_cogs := v_cogs_products_total + v_freight_in_total - v_purchase_discounts_total;
    RAISE LOG 'P&L: COGSProd:%, Freight:%, PurchDisc:(-)%, NetCOGS:%', 
        v_cogs_products_total, v_freight_in_total, v_purchase_discounts_total, v_net_cogs;

    -- 3. Calculate Gross Profit
    v_gross_profit := v_net_sales_revenue - v_net_cogs;
    RAISE LOG 'P&L: GrossProfit:%', v_gross_profit;

    -- 4. Calculate Total Other Income
    -- Other Income accounts have CREDIT normal balance.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_income_general
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_general_income_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_income_stock_overage
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND te.account_id = v_stock_overage_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;
    
    v_total_other_income := v_income_general + v_income_stock_overage;
    RAISE LOG 'P&L: OtherIncomeGen:%, OtherIncomeStock:% TotalOtherIncome:%', 
        v_income_general, v_income_stock_overage, v_total_other_income;

    -- 5. Calculate Total Operating Expenses
    -- Operating Expense accounts have DEBIT normal balance.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_total_operating_expenses
    FROM public.transaction_entries te
    JOIN public.transactions t ON te.transaction_id = t.transaction_id
    JOIN public.accounts a ON te.account_id = a.account_id
    WHERE t.business_id = p_business_id AND a.category_id = v_opex_category_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;
    RAISE LOG 'P&L: TotalOpEx:%', v_total_operating_expenses;
      
    -- 6. Calculate Net Income/Loss
    v_net_income_loss := v_gross_profit + v_total_other_income - v_total_operating_expenses;
    RAISE LOG 'P&L: NetIncomeLoss:%', v_net_income_loss;

    v_result := jsonb_build_object(
        'period_start_date', p_start_date,
        'period_end_date', p_end_date,
        'revenue_products', v_revenue_products,
        'revenue_services', v_revenue_services,
        'revenue_shipping', v_revenue_shipping,
        'sales_discounts_total', v_sales_discounts_total,
        'net_sales_revenue', v_net_sales_revenue,
        'cogs_products_total', v_cogs_products_total,
        'freight_in_total', v_freight_in_total,
        'purchase_discounts_total', v_purchase_discounts_total,
        'net_cogs', v_net_cogs,
        'gross_profit', v_gross_profit,
        'income_general', v_income_general,
        'income_stock_overage', v_income_stock_overage,
        'total_other_income', v_total_other_income,
        'total_operating_expenses', v_total_operating_expenses,
        'net_income_loss', v_net_income_loss
    );

    RETURN v_result;
END;
$$;


ALTER FUNCTION "public"."get_profit_and_loss"("p_business_id" "uuid", "p_start_date" "date", "p_end_date" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_promotional_addon_details"("p_country_code" character varying) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result_json JSONB;
BEGIN
    WITH AddonEffectivePricing AS (
        -- Calculate effective pricing for each active addon based on country
        SELECT
            a.addon_id,
            a.name,
            a.slug,
            a.description,
            a.addon_type,
            a.linked_feature_id,
            a.unit_name,
            -- Add other addon base fields you want in the final output here
            -- e.g., a.some_other_addon_field
            COALESCE(ap.price_monthly, a.default_price_monthly) AS effective_price_monthly,
            COALESCE(ap.price_annual, a.default_price_annual) AS effective_price_annual,
            COALESCE(ap.currency_code, a.default_currency) AS effective_currency,
            COALESCE(ap.price_one_time, a.default_price_one_time) AS effective_price_one_time
        FROM
            public.addons a
        LEFT JOIN
            public.addon_prices ap ON a.addon_id = ap.addon_id
                                 AND ap.country_code = p_country_code
                                 AND ap.is_active = TRUE -- Only consider active country-specific prices
        WHERE
            a.is_active = TRUE -- Only consider active addons
    ),
    AddonDetailsWithFeatures AS (
        -- Join with features table to get linked feature details
        SELECT
            aep.*, -- Select all columns from the previous CTE
            f.name AS linked_feature_name,
            f.slug AS linked_feature_slug,
            f.feature_id AS actual_linked_feature_id -- To build the nested object correctly
        FROM
            AddonEffectivePricing aep
        LEFT JOIN
            public.features f ON aep.linked_feature_id = f.feature_id
            -- You might want to add 'AND f.is_active = TRUE' if features can be inactive
    )
    -- Final aggregation: build addon objects and aggregate them into a top-level array
    SELECT
        jsonb_agg(
            jsonb_build_object(
                'addon_id', adwf.addon_id,
                'addon_name', adwf.name,
                'addon_slug', adwf.slug,
                'addon_description', adwf.description,
                'addon_type', adwf.addon_type,
                'unit_name', adwf.unit_name,
                'price_monthly', adwf.effective_price_monthly,
                'price_annual', adwf.effective_price_annual,
                'currency', adwf.effective_currency,
				'price_one_time', adwf.effective_price_one_time,
                'linked_feature', CASE
                                    WHEN adwf.actual_linked_feature_id IS NOT NULL THEN jsonb_build_object(
                                        'feature_id', adwf.actual_linked_feature_id,
                                        'feature_name', adwf.linked_feature_name,
                                        'feature_slug', adwf.linked_feature_slug
                                    )
                                    ELSE NULL -- No linked feature or feature details not found
                                  END
                -- Add other addon base fields from AddonEffectivePricing CTE here
                -- e.g., 'some_other_field', adwf.some_other_addon_field
            ) ORDER BY adwf.name -- Order addons by name, or addon_id, or a display_order if you add one
        )
    INTO result_json -- Store the final aggregated JSON array into the variable
    FROM
        AddonDetailsWithFeatures adwf;

    -- Return the resulting JSONB object (or an empty JSON array if no active addons found)
    RETURN COALESCE(result_json, '[]'::jsonb);

END;
$$;


ALTER FUNCTION "public"."get_promotional_addon_details"("p_country_code" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_promotional_plan_details"("p_country_code" character varying) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result_json JSONB;
BEGIN
    WITH PlanPricing AS (
        -- Calculate effective pricing for each active plan based on country
        SELECT
            p.plan_id,
            p.name,
            p.slug,
            p.description,
            p.display_order,
            p.trial_period_days,
            COALESCE(pp.price_monthly, p.default_price_monthly) AS effective_price_monthly,
            COALESCE(pp.price_annual, p.default_price_annual) AS effective_price_annual,
            COALESCE(pp.currency_code, p.default_currency) AS effective_currency
        FROM
            plans p
        LEFT JOIN
            plan_prices pp ON p.plan_id = pp.plan_id
                          AND pp.country_code = p_country_code
                          AND pp.is_active = TRUE
        WHERE
            p.is_active = TRUE
    ),
    PlanFeaturesDetails AS (
        -- Aggregate features into a JSON array for each plan
        SELECT
            p.plan_id,
            jsonb_agg(
                jsonb_build_object(
                    'feature_id', f.feature_id,
                    'feature_name', f.name,
                    'feature_slug', f.slug,
                    'feature_type', f.feature_type,
                    'is_enabled', COALESCE(pf.is_enabled, FALSE),
                    'limit_value', CASE WHEN COALESCE(pf.is_enabled, FALSE) = TRUE THEN pf.limit_value ELSE NULL END
                ) ORDER BY f.feature_id -- Or order by feature display order if you add one
            ) AS features_json
        FROM
            PlanPricing p -- Use the already filtered active plans
        CROSS JOIN
            features f
        LEFT JOIN
            plan_features pf ON p.plan_id = pf.plan_id AND f.feature_id = pf.feature_id
        GROUP BY
            p.plan_id
    )
    -- Final aggregation: build plan objects and aggregate them into a top-level array
    SELECT
        jsonb_agg(
            jsonb_build_object(
                'plan_id', pp.plan_id,
                'plan_name', pp.name,
                'plan_slug', pp.slug,
                'plan_description', pp.description,
                'display_order', pp.display_order,
                'price_monthly', pp.effective_price_monthly,
                'price_annual', pp.effective_price_annual,
                'currency', pp.effective_currency,
                'trial_period_days', pp.trial_period_days,
                'features', COALESCE(pfd.features_json, '[]'::jsonb) -- Use the aggregated features, default to empty array if plan has no features mapped (unlikely with CROSS JOIN approach but safe)
            ) ORDER BY pp.display_order -- Ensure final array is ordered correctly
        )
    INTO result_json -- Store the final aggregated JSON array into the variable
    FROM
        PlanPricing pp
    LEFT JOIN
        PlanFeaturesDetails pfd ON pp.plan_id = pfd.plan_id;

    -- Return the resulting JSONB object (or an empty JSON array if no active plans found)
    RETURN COALESCE(result_json, '[]'::jsonb);

END;
$$;


ALTER FUNCTION "public"."get_promotional_plan_details"("p_country_code" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date TIMESTAMP WITH TIME ZONE;
    v_end_date TIMESTAMP WITH TIME ZONE;
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM businesses b
    JOIN fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id;

    -- If dates are not provided, calculate fiscal year dates
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        -- If current month is less than fiscal start month, we're in previous year's fiscal year
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date := make_timestamp(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,
            0,
            0
        );
        
        -- If fiscal end month is less than start month, it means it spans to next year
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date := make_timestamp(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,
            0,
            0
        );
        -- Set to last day of the end month
        v_end_date := (v_end_date + INTERVAL '1 month' - INTERVAL '1 day');
    ELSE
        v_start_date := p_start_date;
        v_end_date := p_end_date;
    END IF;

    -- Get the purchase summary
    SELECT json_build_object(
        'total_purchase_amount', COALESCE(SUM(p.total_amount), 0),
        'total_purchase_count', COUNT(p.purchase_id),
        'total_paid', COALESCE(SUM(p.paid_amount), 0),
        'total_due', COALESCE(SUM(p.due_amount), 0)
    ) INTO result
    FROM purchases p
    WHERE 
        p.business_id = p_business_id
        AND p.created_at >= v_start_date
        AND p.created_at <= v_end_date;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date_calc TIMESTAMP WITH TIME ZONE; -- Renamed to avoid conflict with parameter
    v_end_date_calc TIMESTAMP WITH TIME ZONE;   -- Renamed to avoid conflict with parameter
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    RAISE LOG 'get_purchase_summary: Fetching for Business: %, Org: %, Start: %, End: %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM public.businesses b
    JOIN public.fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id AND b.org_id = p_org_id; -- Added org_id

    IF NOT FOUND THEN
        RAISE WARNING 'Fiscal year details not found for Business: %, Org: %. Using calendar year.', p_business_id, p_org_id;
        -- Default to calendar year if fiscal year setup is missing
        v_start_date_calc := date_trunc('year', COALESCE(p_start_date, current_timestamp))::timestamp with time zone;
        v_end_date_calc := (date_trunc('year', COALESCE(p_end_date, current_timestamp)) + interval '1 year' - interval '1 day')::timestamp with time zone;
        IF p_start_date IS NOT NULL THEN v_start_date_calc := p_start_date; END IF;
        IF p_end_date IS NOT NULL THEN v_end_date_calc := p_end_date; END IF;
    ELSIF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE')) -- Use session timezone
        );
        
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE'))
        );
        v_end_date_calc := (v_end_date_calc + INTERVAL '1 month' - INTERVAL '1 day');
        -- Ensure the time component covers the whole end day
        v_end_date_calc := date_trunc('day', v_end_date_calc) + interval '23 hours 59 minutes 59 seconds';
    ELSE
        v_start_date_calc := p_start_date;
        v_end_date_calc := p_end_date;
    END IF;
    
    RAISE LOG 'get_purchase_summary: Calculated date range: % to %', v_start_date_calc, v_end_date_calc;

    -- Get the purchase summary from the transactions table
    SELECT json_build_object(
        'total_purchase_invoice_value', COALESCE(SUM(t.total_amount), 0), -- Sum of grand totals of purchase invoices
        'total_purchase_count', COUNT(t.transaction_id),                 -- Count of purchase transactions
        'total_paid_on_purchases', COALESCE(SUM(t.paid_amount), 0),       -- Sum of amounts paid at time of these purchases
        'total_due_created_from_purchases', COALESCE(SUM(t.due_amount), 0) -- Sum of amounts put on A/P from these purchases
    ) INTO result
    FROM public.transactions t
    WHERE 
        t.business_id = p_business_id
        AND t.org_id = p_org_id -- Added org_id filter
        AND t.transaction_type = 'PURCHASE'::public.transaction_type -- Filter for purchase transactions
        AND t.transaction_date >= v_start_date_calc -- Use transaction_date for period filtering
        AND t.transaction_date <= v_end_date_calc
        AND t.status NOT IN ('VOID', 'CANCELLED', 'REVERSED'); -- Exclude voided/cancelled

    RAISE LOG 'get_purchase_summary: Result: %', result;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_role_permissions"("role_id" "uuid" DEFAULT NULL::"uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE 
    v_items JSONB;
BEGIN
    SELECT JSON_AGG(
                JSONB_BUILD_OBJECT(
                    'id', MODULES.MODULE_ID,
                    'created_at', MODULES.CREATED_AT,
                    'name', MODULES.NAME,
                    'description', MODULES.DESCRIPTION,
                    'url', MODULES.URL,
					'sort_order', MODULES.SORT_ORDER,
                    'submenus',
                    COALESCE(
                        (
                            SELECT JSON_AGG(
                                    JSONB_BUILD_OBJECT(
                                        'id', LINKS.LINK_ID,
                                        'link_name', LINKS.NAME,
                                        'url', LINKS.URL,
										 'sort_order', LINKS.SORT_ORDER,
                                        'permissions', 
                                        COALESCE(
                                            (
                                                SELECT JSONB_BUILD_OBJECT(
                                                    'view', P."view",
                                                    'add', P."create",
                                                    'edit', P."edit",
                                                    'delete', P."delete",
                                                    'print', P."print",
													'permission_id', p.permission_id													
                                                )
                                                FROM public.permissions P
                                                WHERE 
                                                    P.link_id = LINKS.LINK_ID
                                                    AND
                                                    P.employee_role_id = role_id
												LIMIT 1
                                            ),
                                            JSONB_BUILD_OBJECT(
                                                'view', FALSE,
                                                'add', FALSE,
                                                'edit', FALSE,
                                                'delete', FALSE,
                                                'print', FALSE
                                            )
                                        )
                                    )
                                )
                            FROM PUBLIC.LINKS
                            WHERE LINKS.MODULE_ID = MODULES.MODULE_ID
                        ),
                        '[]'::json
                    ),
                    'permissions', 
                    COALESCE(
                        (
                            SELECT JSONB_BUILD_OBJECT(
                                'view', P."view",
                                'add', P."create",
                                'edit', P."edit",
                                'delete', P."delete",
                                'print', P."print",
								'permission_id', p.permission_id
                            )
                            FROM public.permissions P
                            WHERE 
                                P.MODULE_ID = MODULES.MODULE_ID
                                AND
                                P.employee_role_id = role_id
							LIMIT 1
                        ),
                        JSONB_BUILD_OBJECT(
                            'view', FALSE,
                            'add', FALSE,
                            'edit', FALSE,
                            'delete', FALSE,
                            'print', FALSE
                        )
                    )
                )
            ) AS result
    FROM MODULES 
    INTO v_items;
    
    RETURN v_items;
END;
$$;


ALTER FUNCTION "public"."get_role_permissions"("role_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date TIMESTAMP WITH TIME ZONE;
    v_end_date TIMESTAMP WITH TIME ZONE;
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM businesses b
    JOIN fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id;

    -- If dates are not provided, calculate fiscal year dates
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        -- If current month is less than fiscal start month, we're in previous year's fiscal year
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date := make_timestamp(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,
            0,
            0
        );
        
        -- If fiscal end month is less than start month, it means it spans to next year
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date := make_timestamp(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,
            0,
            0
        );
        -- Set to last day of the end month
        v_end_date := (v_end_date + INTERVAL '1 month' - INTERVAL '1 day');
    ELSE
        v_start_date := p_start_date;
        v_end_date := p_end_date;
    END IF;

    -- Get the sales summary
    SELECT json_build_object(
        'total_sales_amount', COALESCE(SUM(s.total_amount), 0),
        'total_sales_count', COUNT(s.sale_id),
        'total_paid', COALESCE(SUM(s.paid_amount), 0),
        'total_due', COALESCE(SUM(s.due_amount), 0)
    ) INTO result
    FROM sales s
    WHERE 
        s.business_id = p_business_id
        AND s.created_at >= v_start_date
        AND s.created_at <= v_end_date;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date_calc TIMESTAMP WITH TIME ZONE;
    v_end_date_calc TIMESTAMP WITH TIME ZONE;
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    RAISE LOG 'get_sales_summary: Fetching for Business: %, Org: %, Start: %, End: %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM public.businesses b
    JOIN public.fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id AND b.org_id = p_org_id; -- Added org_id

    IF NOT FOUND THEN
        RAISE WARNING 'Fiscal year details not found for Business: %, Org: %. Using calendar year for period.', p_business_id, p_org_id;
        v_start_date_calc := date_trunc('year', COALESCE(p_start_date, current_timestamp))::timestamp with time zone;
        v_end_date_calc := (date_trunc('year', COALESCE(p_end_date, current_timestamp)) + interval '1 year' - interval '1 day')::timestamp with time zone;
        IF p_start_date IS NOT NULL THEN v_start_date_calc := p_start_date; END IF;
        IF p_end_date IS NOT NULL THEN v_end_date_calc := p_end_date; END IF;
    ELSIF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE'))
        );
        
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE'))
        );
        v_end_date_calc := (v_end_date_calc + INTERVAL '1 month' - INTERVAL '1 day');
        v_end_date_calc := date_trunc('day', v_end_date_calc) + interval '23 hours 59 minutes 59 seconds';
    ELSE
        v_start_date_calc := p_start_date;
        v_end_date_calc := p_end_date;
    END IF;

    RAISE LOG 'get_sales_summary: Calculated date range: % to %', v_start_date_calc, v_end_date_calc;

    -- Get the sales summary from the transactions table
    SELECT json_build_object(
        'total_sales_invoice_value', COALESCE(SUM(t.total_amount), 0), -- Sum of grand totals of sale invoices
        'total_sales_count', COUNT(t.transaction_id),                  -- Count of sale transactions
        'total_paid_on_sales', COALESCE(SUM(t.paid_amount), 0),        -- Sum of amounts paid at time of these sales
        'total_due_created_from_sales', COALESCE(SUM(t.due_amount), 0)  -- Sum of amounts put on A/R from these sales
    ) INTO result
    FROM public.transactions t
    WHERE 
        t.business_id = p_business_id
        AND t.org_id = p_org_id -- Added org_id filter
        AND t.transaction_type = 'SALE'::public.transaction_type -- Filter for sale transactions
        AND t.transaction_date >= v_start_date_calc -- Use transaction_date for period filtering
        AND t.transaction_date <= v_end_date_calc
        AND t.status NOT IN ('VOID'::public.transaction_status, 
                             'CANCELLED'::public.transaction_status, 
                             'REVERSED'::public.transaction_status); -- Exclude voided/cancelled/reversed sales

    RAISE LOG 'get_sales_summary: Result: %', result;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sidebar"() RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE 
    V_ITEMS JSONB;
    _uid UUID;
BEGIN
    _uid = auth.uid();
    SELECT 
        JSON_AGG(
            JSONB_BUILD_OBJECT(
                'id', MODULES.MODULE_ID,
                'created_at', MODULES.CREATED_AT,
                'name', MODULES.NAME,
                'description', MODULES.DESCRIPTION,
                'url', MODULES.URL,
				'sort_order', MODULES.SORT_ORDER,
                'submenus',
                COALESCE(
                    (SELECT JSON_AGG(
                        JSONB_BUILD_OBJECT(
                            'id', LINKS.LINK_ID,
                            'link_name', LINKS.NAME,
                            'url', LINKS.URL,
							'sort_order', LINKS.SORT_ORDER,
                            'permissions',
                            COALESCE(
                                (JSONB_BUILD_OBJECT(
                                    'view', COALESCE((SELECT BOOL_OR(p.view) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.LINK_ID = LINKS.LINK_ID AND p.view IS TRUE),FALSE),
                                    'add', COALESCE((SELECT BOOL_OR(p.create) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.LINK_ID = LINKS.LINK_ID AND p.create IS TRUE),FALSE),
                                    'edit', COALESCE((SELECT BOOL_OR(p.edit) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.LINK_ID = LINKS.LINK_ID AND p.edit IS TRUE),FALSE),
                                    'delete', COALESCE((SELECT BOOL_OR(p.delete) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.LINK_ID = LINKS.LINK_ID AND p.delete IS TRUE),FALSE),
                                    'print', COALESCE((SELECT BOOL_OR(p.print) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.LINK_ID = LINKS.LINK_ID AND p.print IS TRUE),FALSE)
                                )),
                                JSONB_BUILD_OBJECT(
                                    'view', FALSE,
                                    'add', FALSE,
                                    'edit', FALSE,
                                    'delete', FALSE,
                                    'print', FALSE
                                )
                            )
                        )
                    ) FROM PUBLIC.LINKS WHERE LINKS.MODULE_ID = MODULES.MODULE_ID),
                    '[]'::json
                ),
				'permissions', 
                    COALESCE(
                        (
                            JSONB_BUILD_OBJECT(
								'view', COALESCE((SELECT BOOL_OR(p.view) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.MODULE_ID = MODULES.MODULE_ID AND p.view IS TRUE),FALSE),
								'add', COALESCE((SELECT BOOL_OR(p.create) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.MODULE_ID = MODULES.MODULE_ID AND p.create IS TRUE),FALSE),
								'edit', COALESCE((SELECT BOOL_OR(p.edit) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.MODULE_ID = MODULES.MODULE_ID AND p.edit IS TRUE),FALSE),
								'delete', COALESCE((SELECT BOOL_OR(p.delete) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.MODULE_ID = MODULES.MODULE_ID AND p.delete IS TRUE),FALSE),
								'print', COALESCE((SELECT BOOL_OR(p.print) AS view FROM roles_of_employees ru JOIN permissions p ON ru.employee_role_id = p.employee_role_id WHERE ru.employee_id = _uid AND p.MODULE_ID = MODULES.MODULE_ID AND p.print IS TRUE),FALSE)
                            )
                        ),
                        JSONB_BUILD_OBJECT(
                            'view', FALSE,
                            'add', FALSE,
                            'edit', FALSE,
                            'delete', FALSE,
                            'print', FALSE
                        )
                    )
            )
        ) AS RESULT
    FROM MODULES INTO V_ITEMS;
    RETURN V_ITEMS;
END;
$$;


ALTER FUNCTION "public"."get_sidebar"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date TIMESTAMP WITH TIME ZONE;
    v_end_date TIMESTAMP WITH TIME ZONE;
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM businesses b
    JOIN fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id;

    -- If dates are not provided, calculate fiscal year dates
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        -- If current month is less than fiscal start month, we're in previous year's fiscal year
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date := make_timestamp(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,
            0,
            0
        );
        
        -- If fiscal end month is less than start month, it means it spans to next year
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date := make_timestamp(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,
            0,
            0
        );
        -- Set to last day of the end month
        v_end_date := (v_end_date + INTERVAL '1 month' - INTERVAL '1 day');
    ELSE
        v_start_date := p_start_date;
        v_end_date := p_end_date;
    END IF;

    -- Get the combined dues summary
    WITH sales_dues AS (
        SELECT 
            COALESCE(SUM(due_amount), 0) as sales_due,
            COUNT(CASE WHEN due_amount > 0 THEN 1 END) as sales_due_count
        FROM sales
        WHERE 
            business_id = p_business_id
            AND created_at >= v_start_date
            AND created_at <= v_end_date
    ),
    purchase_dues AS (
        SELECT 
            COALESCE(SUM(due_amount), 0) as purchase_due,
            COUNT(CASE WHEN due_amount > 0 THEN 1 END) as purchase_due_count
        FROM purchases
        WHERE 
            business_id = p_business_id
            AND created_at >= v_start_date
            AND created_at <= v_end_date
    )
    SELECT json_build_object(
        'total_sales_due', sd.sales_due,
        'sales_due_count', sd.sales_due_count,
        'total_purchase_due', pd.purchase_due,
        'purchase_due_count', pd.purchase_due_count,
        'total_combined_due', (sd.sales_due + pd.purchase_due),
        'total_due_transactions', (sd.sales_due_count + pd.purchase_due_count),
        'start_date', v_start_date,
        'end_date', v_end_date
    ) INTO result
    FROM sales_dues sd, purchase_dues pd;

    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_end_date" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS "json"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    result JSON;
    v_start_date_calc TIMESTAMP WITH TIME ZONE;
    v_end_date_calc TIMESTAMP WITH TIME ZONE;
    v_fiscal_start_month INTEGER;
    v_fiscal_end_month INTEGER;
    v_current_year INTEGER;
BEGIN
    RAISE LOG 'get_total_dues_summary: Fetching for Business: %, Org: %, Start: %, End: %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Get fiscal year details for the business
    SELECT 
        fy.start_month,
        fy.end_month
    INTO 
        v_fiscal_start_month,
        v_fiscal_end_month
    FROM public.businesses b
    JOIN public.fiscal_years fy ON b.fiscal_id = fy.fiscal_id
    WHERE b.business_id = p_business_id AND b.org_id = p_org_id; -- Added org_id

    IF NOT FOUND THEN
        RAISE WARNING 'Fiscal year details not found for Business: %, Org: %. Using calendar year for period.', p_business_id, p_org_id;
        v_start_date_calc := date_trunc('year', COALESCE(p_start_date, current_timestamp))::timestamp with time zone;
        v_end_date_calc := (date_trunc('year', COALESCE(p_end_date, current_timestamp)) + interval '1 year' - interval '1 day')::timestamp with time zone;
        IF p_start_date IS NOT NULL THEN v_start_date_calc := p_start_date; END IF;
        IF p_end_date IS NOT NULL THEN v_end_date_calc := p_end_date; END IF;
    ELSIF p_start_date IS NULL OR p_end_date IS NULL THEN
        v_current_year := EXTRACT(YEAR FROM CURRENT_DATE);
        
        IF EXTRACT(MONTH FROM CURRENT_DATE) < v_fiscal_start_month THEN
            v_current_year := v_current_year - 1;
        END IF;

        v_start_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_start_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE'))
        );
        
        IF v_fiscal_end_month < v_fiscal_start_month THEN
            v_current_year := v_current_year + 1;
        END IF;
        
        v_end_date_calc := make_timestamptz(
            v_current_year,
            v_fiscal_end_month,
            1,
            0,0,0,
            (SELECT current_setting('TIMEZONE'))
        );
        v_end_date_calc := (v_end_date_calc + INTERVAL '1 month' - INTERVAL '1 day');
        v_end_date_calc := date_trunc('day', v_end_date_calc) + interval '23 hours 59 minutes 59 seconds';
    ELSE
        v_start_date_calc := p_start_date;
        v_end_date_calc := p_end_date;
    END IF;

    RAISE LOG 'get_total_dues_summary: Calculated date range: % to %', v_start_date_calc, v_end_date_calc;

    -- Get the combined dues summary from transactions table
    WITH sales_dues_period AS (
        SELECT 
            COALESCE(SUM(t.due_amount), 0) as sales_due_created,
            COUNT(CASE WHEN t.due_amount > 0 THEN 1 END) as sales_due_count
        FROM public.transactions t
        WHERE 
            t.business_id = p_business_id
            AND t.org_id = p_org_id -- Added org_id
            AND t.transaction_type = 'SALE'::public.transaction_type
            AND t.transaction_date >= v_start_date_calc -- Use transaction_date
            AND t.transaction_date <= v_end_date_calc
            AND t.status NOT IN ('VOID'::public.transaction_status, 
                                 'CANCELLED'::public.transaction_status, 
                                 'REVERSED'::public.transaction_status)
    ),
    purchase_dues_period AS (
        SELECT 
            COALESCE(SUM(t.due_amount), 0) as purchase_due_created,
            COUNT(CASE WHEN t.due_amount > 0 THEN 1 END) as purchase_due_count
        FROM public.transactions t
        WHERE 
            t.business_id = p_business_id
            AND t.org_id = p_org_id -- Added org_id
            AND t.transaction_type = 'PURCHASE'::public.transaction_type
            AND t.transaction_date >= v_start_date_calc -- Use transaction_date
            AND t.transaction_date <= v_end_date_calc
            AND t.status NOT IN ('VOID'::public.transaction_status, 
                                 'CANCELLED'::public.transaction_status, 
                                 'REVERSED'::public.transaction_status)
    )
    SELECT json_build_object(
        'total_sales_due_created_in_period', sdp.sales_due_created,
        'sales_due_transactions_in_period_count', sdp.sales_due_count,
        'total_purchase_due_created_in_period', pdp.purchase_due_created,
        'purchase_due_transactions_in_period_count', pdp.purchase_due_count,
        'net_new_credit_extended_in_period', (sdp.sales_due_created - pdp.purchase_due_created), -- Sales Due - Purchase Due
        'total_credit_transactions_in_period_count', (sdp.sales_due_count + pdp.purchase_due_count),
        'period_start_date', v_start_date_calc, -- Use calculated dates for clarity
        'period_end_date', v_end_date_calc
    ) INTO result
    FROM sales_dues_period sdp, purchase_dues_period pdp;

    RAISE LOG 'get_total_dues_summary: Result: %', result;
    RETURN result;
END;
$$;


ALTER FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_existing_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
	_PLATFORM TEXT;
    _IS_EMPLOYEE        BOOLEAN;
    _IS_CUSTOMER        BOOLEAN;
    _EMPLOYEE_ROLE      TEXT;
    _USER_NAME          TEXT;
    _PHONE_NUMBER       TEXT;
    _BUSINESS_TYPE      TEXT;
    _CURRENCY           JSONB;
    _BUSINESS_TYPE_ENUM PUBLIC.BUSINESS_TYPES;
    _CURRENT_EMAIL      TEXT;
    _CURRENT_PHONE      TEXT;
    _EMAIL_ADDRESS TEXT;
    _IMAGE TEXT;
 
    -- Other variables
    _NEW_ORG_ID         UUID;
    _NEW_BUSINESS_ID    UUID;
BEGIN
    _PLATFORM := NEW.RAW_USER_META_DATA->>'platform';
    _IS_EMPLOYEE := NEW.RAW_USER_META_DATA->>'is_employee';
    _IS_CUSTOMER := NEW.RAW_USER_META_DATA->>'is_customer';
    _EMPLOYEE_ROLE := NEW.RAW_USER_META_DATA->>'employee_role';
    _USER_NAME := NEW.RAW_USER_META_DATA->>'user_name';
    _PHONE_NUMBER := regexp_replace((NEW.RAW_USER_META_DATA->>'phone_number'), '\+', '', 'g');
    _BUSINESS_TYPE := NEW.RAW_USER_META_DATA->>'business_type';
    _CURRENCY := NEW.RAW_USER_META_DATA->>'currency';
    _CURRENT_EMAIL := NEW.EMAIL;
    _CURRENT_PHONE := NEW.PHONE;
    _EMAIL_ADDRESS := NEW.RAW_USER_META_DATA->>'email';
    _IMAGE := NEW.RAW_USER_META_DATA->>'image';
	RAISE LOG '-----------[handle_existing_user] UserID: %', NEW.ID;

    IF _PLATFORM = 'duxbe' THEN
        IF _IS_EMPLOYEE = 'true' THEN
            IF _EMPLOYEE_ROLE = 'admin' THEN
                BEGIN
                    _BUSINESS_TYPE_ENUM := _BUSINESS_TYPE::PUBLIC.BUSINESS_TYPES;
                EXCEPTION
                    WHEN OTHERS THEN
                        _BUSINESS_TYPE_ENUM := 'others'::PUBLIC.BUSINESS_TYPES;
                END; -- Default on error
                -- 1. Create public.users record
                INSERT INTO PUBLIC.USERS (
                    USER_ID,
                    NAME,
                    EMAIL,
                    PHONE
                ) VALUES (
                    NEW.ID,
                    COALESCE(_USER_NAME, 'Admin'),
                    _CURRENT_EMAIL,
                    _PHONE_NUMBER
                ) ON CONFLICT (
                    USER_ID
                ) DO NOTHING;
                RAISE NOTICE '[handle_new_user] UserID: %. Step 1: public.users record processed.', NEW.ID;
                BEGIN
 
                    -- Step A: Create Organization with created_by = NULL initially
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into organizations (created_by=NULL)...', NEW.ID;
                    INSERT INTO PUBLIC.ORGANIZATIONS (
                        NAME,
                        TRIAL_ACTIVATED
                    ) -- Set created_by = NULL here
                    VALUES (
                        COALESCE(_USER_NAME, 'New User')
                        || '''s Organization',
                        TRUE
                    ) RETURNING ORG_ID INTO _NEW_ORG_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Org created: %', NEW.ID, _NEW_ORG_ID;
 
                    -- Step B: Create Employee record for this admin
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employees...', NEW.ID;
                    INSERT INTO PUBLIC.EMPLOYEES (
                        EMPLOYEE_ID,
                        ORG_ID,
                        ROLE,
                        NAME
                    ) VALUES (
                        NEW.ID,
                        _NEW_ORG_ID,
                        'admin'::PUBLIC.EMPLOYEE_TYPE,
                        COALESCE(_USER_NAME, 'Admin')
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Employee record created.', NEW.ID;
 
                    -- Step C: Update Organization to set the correct created_by
                    RAISE NOTICE '[handle_new_user] UserID: %. Updating organizations.created_by...', NEW.ID;
                    UPDATE PUBLIC.ORGANIZATIONS
                    SET
                        CREATED_BY = NEW.ID
                    WHERE
                        ORG_ID = _NEW_ORG_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. organizations.created_by updated.', NEW.ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into businesses...', NEW.ID;
                    INSERT INTO PUBLIC.BUSINESSES (
                        NAME,
                        ORG_ID,
                        CREATED_BY,
                        BUSINESS_TYPE,
                        CURRENCY
                    ) VALUES (
                        COALESCE(_USER_NAME, 'Default Business'),
                        _NEW_ORG_ID,
                        NEW.ID,
                        _BUSINESS_TYPE_ENUM,
                        _CURRENCY
                    ) RETURNING BUSINESS_ID INTO _NEW_BUSINESS_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Business created: %', NEW.ID, _NEW_BUSINESS_ID;
 
                    -- Subsequent steps (roles_of_employees, statuses, etc.) (Unchanged) ...
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into roles_of_employees...', NEW.ID;
                    INSERT INTO PUBLIC.ROLES_OF_EMPLOYEES (
                        EMPLOYEE_ROLE_ID,
                        EMPLOYEE_ID
                    ) VALUES (
                        '00000000-0000-0000-0000-000000000000',
                        NEW.ID
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into statuses...', NEW.ID;
                    INSERT INTO PUBLIC.STATUSES (
                        BUSINESS_ID,
                        NAME,
                        SEQUENCE_ORDER,
                        IS_DEFAULT,
                        TYPE,
                        IS_EDITABLE
                    ) VALUES (
                        _NEW_BUSINESS_ID,
                        'Booked',
                        1,
                        TRUE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        TRUE
                    ), (
                        _NEW_BUSINESS_ID,
                        'In Process',
                        2,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        TRUE
                    ), (
                        _NEW_BUSINESS_ID,
                        'Cancelled',
                        3,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        FALSE
                    ), (
                        _NEW_BUSINESS_ID,
                        'Completed',
                        4,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        FALSE
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Performing create_default_chart_of_accounts...', NEW.ID;
                    PERFORM PUBLIC.CREATE_DEFAULT_CHART_OF_ACCOUNTS(_NEW_BUSINESS_ID, _NEW_ORG_ID);
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employee_branch_access...', NEW.ID;
                    INSERT INTO PUBLIC.EMPLOYEE_BRANCH_ACCESS (
                        EMPLOYEE_ID,
                        BUSINESS_ID
                    ) VALUES (
                        NEW.ID,
                        _NEW_BUSINESS_ID
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into subscriptions...', NEW.ID;
                    INSERT INTO PUBLIC.SUBSCRIPTIONS (
                        ORG_ID,
                        PLAN_ID,
                        STATUS,
                        START_DATE,
                        END_DATE,
                        TRIAL_END_DATE,
                        CANCEL_AT_PERIOD_END,
                        ADDON_ID
                    ) VALUES (
                        _NEW_ORG_ID,
                        3,
                        'trialing'::PUBLIC.SUBSCRIPTION_STATUS_ENUM,
                        CURRENT_DATE,
                        NULL,
                        CURRENT_DATE + INTERVAL '15 days',
                        TRUE,
                        NULL
                    );
 
                    -- Final update to auth.users.raw_app_meta_data
                    RAISE NOTICE '[handle_new_user] UserID: %. Updating auth.users app_metadata...', NEW.ID;
                    UPDATE AUTH.USERS
                    SET
                        RAW_APP_META_DATA = RAW_USER_META_DATA
                                             || JSONB_BUILD_OBJECT(
                            'org_id',
                            _NEW_ORG_ID
                        ),
                        PHONE = _PHONE_NUMBER
                    WHERE
                        ID = NEW.ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. auth.users app_metadata updated. Admin path finished successfully.', NEW.ID;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE WARNING '[handle_new_user ERROR] UserID: %. ERROR in Initial Admin Signup block: % (%)', NEW.ID, SQLERRM, SQLSTATE;
                        RETURN NEW;
                END;
            END IF;
        END IF;
    END IF;

	IF _IS_CUSTOMER = 'true' THEN
		BEGIN
			INSERT INTO PUBLIC.USERS (
				USER_ID,
				NAME,
				EMAIL,
				PHONE,
				IMAGE
			) VALUES (
				NEW.ID,
				COALESCE(_USER_NAME, _EMAIL_ADDRESS, 'Customer'),
				COALESCE(_CURRENT_EMAIL, _EMAIL_ADDRESS),
				COALESCE(_CURRENT_PHONE, _PHONE_NUMBER),
				_IMAGE
			) ON CONFLICT (
				USER_ID
			) DO NOTHING;
			RAISE NOTICE '[handle_new_user] UserID: %. Step 1: public.users record processed.', NEW.ID;
	
			RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employees...', NEW.ID;
			INSERT INTO PUBLIC.CUSTOMERS (
				CUSTOMER_ID,
				NAME,
				IMAGE
			) VALUES (
				NEW.ID,
				COALESCE(_USER_NAME, _EMAIL_ADDRESS, 'Customer'),
				_IMAGE
			) ON CONFLICT (
				CUSTOMER_ID
			) DO NOTHING;
			RAISE NOTICE '[handle_new_user] UserID: %. Employee record created.', NEW.ID;
		END;
	END IF;


    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."handle_existing_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_free_plan_switch"("p_org_id" "uuid", "p_start_date" timestamp with time zone) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- End any existing active free plans for this organization
    -- This ensures only one 'active' free plan subscription exists.
    UPDATE public.subscriptions
    SET status = 'ended',
        updated_at = NOW()
    WHERE org_id = p_org_id
      AND status = 'active';

    -- Insert the new active free plan subscription
    INSERT INTO public.subscriptions (
        org_id,
        plan_id,
        status,
        start_date,
        payment_provider, -- Null for free plan
        created_at,
        updated_at
    )
    VALUES (
        p_org_id,
        1, -- Assuming 1 is the free plan_id
        'active',
        p_start_date,
        NULL,
        NOW(),
        NOW()
    );
END;
$$;


ALTER FUNCTION "public"."handle_free_plan_switch"("p_org_id" "uuid", "p_start_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_employee"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    _PLATFORM           TEXT;
    _IS_EMPLOYEE   BOOLEAN; -- Changed from BOOLEAN to TEXT to match usage
    _ORG_ID             UUID;
    _EMPLOYEE_ROLE      TEXT;
    _USER_NAME          TEXT;
    _PHONE_NUMBER       TEXT;
    _BUSINESS_ID        UUID;
    _ROLES_TEXT         TEXT; -- To store the JSON string of roles
    _CURRENT_EMAIL      TEXT;
    _CURRENT_PHONE      TEXT;

    -- Variables for roles loop
    _ROLE_VALUE_TEXT    TEXT;
    _ROLE_UUID          UUID;
BEGIN
    -- Extract data from raw_user_meta_data
    _PLATFORM := NEW.RAW_USER_META_DATA->>'platform';
    _IS_EMPLOYEE := NEW.RAW_USER_META_DATA->>'is_employee'; -- Expects "true" or "false" as string
    _ORG_ID := (NEW.RAW_USER_META_DATA->>'org_id')::UUID;
    _EMPLOYEE_ROLE := NEW.RAW_USER_META_DATA->>'employee_role';
    _USER_NAME := NEW.RAW_USER_META_DATA->>'user_name';
    _PHONE_NUMBER := regexp_replace((NEW.RAW_USER_META_DATA->>'phone_number'), '\+', '', 'g');
    _BUSINESS_ID := (NEW.RAW_USER_META_DATA->>'business_id')::UUID;
    _ROLES_TEXT := NEW.RAW_USER_META_DATA->>'roles'; -- Expects a JSON array string, e.g., '["uuid1", "uuid2"]'
    
    _CURRENT_EMAIL := NEW.EMAIL;
    _CURRENT_PHONE := NEW.PHONE; -- Note: phone in auth.users is updated later with _PHONE_NUMBER

	RAISE NOTICE '[handle_new_employee]   UserID: %. Initial extracted data dump:', NEW.ID;
    RAISE NOTICE '[handle_new_employee]   Platform (from metadata): %', COALESCE(_PLATFORM, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Is Employee (from metadata, as text): %', COALESCE(_IS_EMPLOYEE::text, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Org ID (from metadata): %', COALESCE(_ORG_ID::TEXT, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Employee Role (from metadata): %', COALESCE(_EMPLOYEE_ROLE, 'NULL');
    RAISE NOTICE '[handle_new_employee]   User Name (from metadata): %', COALESCE(_USER_NAME, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Phone Number (from metadata, processed): %', COALESCE(_PHONE_NUMBER, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Business ID (from metadata): %', COALESCE(_BUSINESS_ID::TEXT, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Roles JSON Text (from metadata): %', COALESCE(_ROLES_TEXT, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Current Email (from NEW.email): %', COALESCE(_CURRENT_EMAIL, 'NULL');
    RAISE NOTICE '[handle_new_employee]   Current Phone (from NEW.phone): %', COALESCE(_CURRENT_PHONE, 'NULL');

    IF _PLATFORM = 'duxbe' THEN
        IF _IS_EMPLOYEE = true THEN -- Comparing text "true"
            IF _EMPLOYEE_ROLE = 'staff' THEN
                -- Step 1: Insert or update user in public.users
                INSERT INTO PUBLIC.USERS (
                    USER_ID,
                    NAME,
                    EMAIL,
                    PHONE
                ) VALUES (
                    NEW.ID,
                    COALESCE(_USER_NAME, 'Staff'),
                    _CURRENT_EMAIL,
                    _PHONE_NUMBER
                ) ON CONFLICT (USER_ID) DO NOTHING; -- Or DO UPDATE if you want to update existing users table data
                RAISE NOTICE '[handle_new_employee] UserID: %. Step 1: public.users record processed.', NEW.ID;

                BEGIN
                    -- Step 2: Insert or update employee in public.employees
                    RAISE NOTICE '[handle_new_employee] UserID: %. Inserting/Updating into public.employees...', NEW.ID;
                    INSERT INTO PUBLIC.EMPLOYEES (
                        EMPLOYEE_ID,
                        ORG_ID,
                        ROLE,
                        NAME
                    ) VALUES (
                        NEW.ID,
                        _ORG_ID,
                        'staff'::PUBLIC.EMPLOYEE_TYPE, -- Make sure EMPLOYEE_TYPE includes 'staff'
                        COALESCE(_USER_NAME, 'Staff')
                    ) ON CONFLICT (EMPLOYEE_ID) DO UPDATE
                        SET
                            ROLE = EXCLUDED.ROLE,       -- Use the value that would have been inserted
                            ORG_ID = EXCLUDED.ORG_ID,   -- Use the value that would have been inserted
                            NAME = EXCLUDED.NAME;       -- Use the value that would have been inserted
                    RAISE NOTICE '[handle_new_employee] UserID: %. Employee record created/updated.', NEW.ID;
  
                    -- Step 3: Insert roles from _ROLES_TEXT into public.roles_of_employees
                    RAISE NOTICE '[handle_new_employee] UserID: %. Processing roles_of_employees...', NEW.ID;
                    IF _ROLES_TEXT IS NOT NULL AND _ROLES_TEXT <> '' AND _ROLES_TEXT <> 'null' THEN
                        BEGIN
                            FOR _ROLE_VALUE_TEXT IN SELECT value FROM jsonb_array_elements_text(_ROLES_TEXT::jsonb)
                            LOOP
                                BEGIN
                                    _ROLE_UUID := _ROLE_VALUE_TEXT::uuid;
                                    INSERT INTO PUBLIC.ROLES_OF_EMPLOYEES (
                                        EMPLOYEE_ROLE_ID,
                                        EMPLOYEE_ID
                                    ) VALUES (
                                        _ROLE_UUID,
                                        NEW.ID
                                    ) ON CONFLICT (EMPLOYEE_ROLE_ID, EMPLOYEE_ID) DO NOTHING; -- Assumes (EMPLOYEE_ROLE_ID, EMPLOYEE_ID) is unique
                                    RAISE NOTICE '[handle_new_employee] UserID: %. Role % processed for roles_of_employees.', NEW.ID, _ROLE_UUID;
                                EXCEPTION
                                    WHEN invalid_text_representation THEN -- Catches errors from _ROLE_VALUE_TEXT::uuid
                                        RAISE WARNING '[handle_new_employee] UserID: %. Invalid UUID string "%" in roles metadata. Skipping this role.', NEW.ID, _ROLE_VALUE_TEXT;
                                    WHEN OTHERS THEN
                                        RAISE WARNING '[handle_new_employee ERROR] UserID: %. Error inserting role % into roles_of_employees: % (%)', NEW.ID, _ROLE_VALUE_TEXT, SQLERRM, SQLSTATE;
                                END;
                            END LOOP;
                        EXCEPTION
                            WHEN invalid_text_representation THEN -- Catches errors from _ROLES_TEXT::jsonb
                                RAISE WARNING '[handle_new_employee] UserID: %. Roles metadata ("%") is not valid JSON. Skipping roles insertion from metadata.', NEW.ID, _ROLES_TEXT;
                            WHEN OTHERS THEN
                                RAISE WARNING '[handle_new_employee ERROR] UserID: %. General error processing roles metadata ("%"): % (%)', NEW.ID, _ROLES_TEXT, SQLERRM, SQLSTATE;
                        END;
                    ELSE
                        RAISE NOTICE '[handle_new_employee] UserID: %. Roles metadata is null, empty, or "null". No roles inserted from metadata.', NEW.ID;
                    END IF;
                    
                    -- Step 4: Insert into public.employee_branch_access
                    RAISE NOTICE '[handle_new_employee] UserID: %. Inserting into employee_branch_access...', NEW.ID;
                    IF _BUSINESS_ID IS NOT NULL THEN
                        INSERT INTO PUBLIC.EMPLOYEE_BRANCH_ACCESS (
                            EMPLOYEE_ID,
                            BUSINESS_ID
                        ) VALUES (
                            NEW.ID,
                            _BUSINESS_ID -- Corrected from _NEW_BUSINESS_ID
                        ) ON CONFLICT (EMPLOYEE_ID, BUSINESS_ID) DO NOTHING; -- Assuming (EMPLOYEE_ID, BUSINESS_ID) should be unique
                         RAISE NOTICE '[handle_new_employee] UserID: %. employee_branch_access record processed.', NEW.ID;
                    ELSE
                        RAISE WARNING '[handle_new_employee] UserID: %. _BUSINESS_ID is NULL. Skipping insert into employee_branch_access.', NEW.ID;
                    END IF;
					
                    -- Step 5: Update auth.users with additional metadata and correct phone
                    UPDATE AUTH.USERS
                    SET
                        RAW_APP_META_DATA = COALESCE(RAW_APP_META_DATA, '{}'::jsonb) -- Ensure RAW_APP_META_DATA is not null
                                             || JSONB_BUILD_OBJECT(
                                                'org_id', _ORG_ID, -- Corrected from _NEW_ORG_ID
                                                'is_employee', TRUE, -- Explicitly set is_employee status in app_meta_data
                                                'employee_role', _EMPLOYEE_ROLE
                                                -- Consider adding other relevant info if needed
                                             ),
                        PHONE = _PHONE_NUMBER
                    WHERE
                        ID = NEW.ID;
                    RAISE NOTICE '[handle_new_employee] UserID: %. auth.users app_metadata and phone updated. Employee path finished successfully.', NEW.ID;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE WARNING '[handle_new_employee ERROR] UserID: %. ERROR in employee processing block: % (%)', NEW.ID, SQLERRM, SQLSTATE;
                        -- Decide if you want to RETURN NEW or re-raise the error,
                        -- or if the transaction should be rolled back.
                        -- For now, it logs and returns NEW, allowing the auth.users insert to commit.
                        RETURN NEW; 
                END;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_employee"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
              DECLARE _PLATFORM TEXT;
    _IS_EMPLOYEE        BOOLEAN;
    _IS_CUSTOMER        BOOLEAN;
    _EMPLOYEE_ROLE      TEXT;
    _USER_NAME          TEXT;
    _PHONE_NUMBER       TEXT;
    _BUSINESS_TYPE      TEXT;
    _EMAIL_ADDRESS      TEXT;
    _IMAGE			    TEXT;
    _CURRENCY           JSONB;
    _BUSINESS_TYPE_ENUM PUBLIC.BUSINESS_TYPES;
    _CURRENT_EMAIL      TEXT;
    _CURRENT_PHONE      TEXT;
 
    -- Other variables
    _NEW_ORG_ID         UUID;
    _NEW_BUSINESS_ID    UUID;
BEGIN
    _PLATFORM := NEW.RAW_USER_META_DATA->>'platform';
    _IS_EMPLOYEE := NEW.RAW_USER_META_DATA->>'is_employee';
    _IS_CUSTOMER := NEW.RAW_USER_META_DATA->>'is_customer';
    _EMPLOYEE_ROLE := NEW.RAW_USER_META_DATA->>'employee_role';
    _USER_NAME := NEW.RAW_USER_META_DATA->>'user_name';
    _PHONE_NUMBER := regexp_replace((NEW.RAW_USER_META_DATA->>'phone_number'), '\+', '', 'g');
    _EMAIL_ADDRESS := NEW.RAW_USER_META_DATA->>'email_address';
    _IMAGE := NEW.RAW_USER_META_DATA->>'image';
    _BUSINESS_TYPE := NEW.RAW_USER_META_DATA->>'business_type';
    _CURRENCY := NEW.RAW_USER_META_DATA->>'currency';
	
    _CURRENT_EMAIL := NEW.EMAIL;
    _CURRENT_PHONE := NEW.PHONE;
    IF _PLATFORM = 'duxbe' THEN
        IF _IS_EMPLOYEE = 'true' THEN
            IF _EMPLOYEE_ROLE = 'admin' THEN
                BEGIN
                    _BUSINESS_TYPE_ENUM := _BUSINESS_TYPE::PUBLIC.BUSINESS_TYPES;
                EXCEPTION
                    WHEN OTHERS THEN
                        _BUSINESS_TYPE_ENUM := 'others'::PUBLIC.BUSINESS_TYPES;
                END; -- Default on error
                -- 1. Create public.users record
                INSERT INTO PUBLIC.USERS (
                    USER_ID,
                    NAME,
                    EMAIL,
                    PHONE
                ) VALUES (
                    NEW.ID,
                    COALESCE(_USER_NAME, 'Admin'),
                    _CURRENT_EMAIL,
                    _PHONE_NUMBER
                ) ON CONFLICT (
                    USER_ID
                ) DO NOTHING;
                RAISE NOTICE '[handle_new_user] UserID: %. Step 1: public.users record processed.', NEW.ID;
                BEGIN
 
                    -- Step A: Create Organization with created_by = NULL initially
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into organizations (created_by=NULL)...', NEW.ID;
                    INSERT INTO PUBLIC.ORGANIZATIONS (
                        NAME,
                        TRIAL_ACTIVATED
                    ) -- Set created_by = NULL here
                    VALUES (
                        COALESCE(_USER_NAME, 'New User')
                        || '''s Organization',
                        TRUE
                    ) RETURNING ORG_ID INTO _NEW_ORG_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Org created: %', NEW.ID, _NEW_ORG_ID;
 
                    -- Step B: Create Employee record for this admin
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employees...', NEW.ID;
                    INSERT INTO PUBLIC.EMPLOYEES (
                        EMPLOYEE_ID,
                        ORG_ID,
                        ROLE,
                        NAME
                    ) VALUES (
                        NEW.ID,
                        _NEW_ORG_ID,
                        'admin'::PUBLIC.EMPLOYEE_TYPE,
                        COALESCE(_USER_NAME, 'Admin')
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Employee record created.', NEW.ID;
 
                    -- Step C: Update Organization to set the correct created_by
                    RAISE NOTICE '[handle_new_user] UserID: %. Updating organizations.created_by...', NEW.ID;
                    UPDATE PUBLIC.ORGANIZATIONS
                    SET
                        CREATED_BY = NEW.ID
                    WHERE
                        ORG_ID = _NEW_ORG_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. organizations.created_by updated.', NEW.ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into businesses...', NEW.ID;
                    INSERT INTO PUBLIC.BUSINESSES (
                        NAME,
                        ORG_ID,
                        CREATED_BY,
                        BUSINESS_TYPE,
                        CURRENCY
                    ) VALUES (
                        COALESCE(_USER_NAME, 'Default Business'),
                        _NEW_ORG_ID,
                        NEW.ID,
                        _BUSINESS_TYPE_ENUM,
                        _CURRENCY
                    ) RETURNING BUSINESS_ID INTO _NEW_BUSINESS_ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. Business created: %', NEW.ID, _NEW_BUSINESS_ID;
 
                    -- Subsequent steps (roles_of_employees, statuses, etc.) (Unchanged) ...
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into roles_of_employees...', NEW.ID;
                    INSERT INTO PUBLIC.ROLES_OF_EMPLOYEES (
                        EMPLOYEE_ROLE_ID,
                        EMPLOYEE_ID
                    ) VALUES (
                        '00000000-0000-0000-0000-000000000000',
                        NEW.ID
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into statuses...', NEW.ID;
                    INSERT INTO PUBLIC.STATUSES (
                        BUSINESS_ID,
                        NAME,
                        SEQUENCE_ORDER,
                        IS_DEFAULT,
                        TYPE,
                        IS_EDITABLE
                    ) VALUES (
                        _NEW_BUSINESS_ID,
                        'Booked',
                        1,
                        TRUE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        TRUE
                    ), (
                        _NEW_BUSINESS_ID,
                        'In Process',
                        2,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        TRUE
                    ), (
                        _NEW_BUSINESS_ID,
                        'Cancelled',
                        3,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        FALSE
                    ), (
                        _NEW_BUSINESS_ID,
                        'Completed',
                        4,
                        FALSE,
                        'sale'::PUBLIC.STATUS_TYPE,
                        FALSE
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Performing create_default_chart_of_accounts...', NEW.ID;
                    PERFORM PUBLIC.CREATE_DEFAULT_CHART_OF_ACCOUNTS(_NEW_BUSINESS_ID, _NEW_ORG_ID);
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employee_branch_access...', NEW.ID;
                    INSERT INTO PUBLIC.EMPLOYEE_BRANCH_ACCESS (
                        EMPLOYEE_ID,
                        BUSINESS_ID
                    ) VALUES (
                        NEW.ID,
                        _NEW_BUSINESS_ID
                    );
                    RAISE NOTICE '[handle_new_user] UserID: %. Inserting into subscriptions...', NEW.ID;
                    INSERT INTO PUBLIC.SUBSCRIPTIONS (
                        ORG_ID,
                        PLAN_ID,
                        STATUS,
                        START_DATE,
                        END_DATE,
                        TRIAL_END_DATE,
                        CANCEL_AT_PERIOD_END,
                        ADDON_ID
                    ) VALUES (
                        _NEW_ORG_ID,
                        3,
                        'trialing'::PUBLIC.SUBSCRIPTION_STATUS_ENUM,
                        CURRENT_DATE,
                        NULL,
                        CURRENT_DATE + INTERVAL '15 days',
                        TRUE,
                        NULL
                    );
 
                    -- Final update to auth.users.raw_app_meta_data
                    RAISE NOTICE '[handle_new_user] UserID: %. Updating auth.users app_metadata...', NEW.ID;
                    UPDATE AUTH.USERS
                    SET
                        RAW_APP_META_DATA = RAW_USER_META_DATA
                                             || JSONB_BUILD_OBJECT(
                            'org_id',
                            _NEW_ORG_ID
                        ),
                        PHONE = _PHONE_NUMBER
                    WHERE
                        ID = NEW.ID;
                    RAISE NOTICE '[handle_new_user] UserID: %. auth.users app_metadata updated. Admin path finished successfully.', NEW.ID;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE WARNING '[handle_new_user ERROR] UserID: %. ERROR in Initial Admin Signup block: % (%)', NEW.ID, SQLERRM, SQLSTATE;
                        RETURN NEW;
                END;
            END IF;
        END IF;
    END IF;

	IF _IS_CUSTOMER = 'true' THEN
		BEGIN
			INSERT INTO PUBLIC.USERS (
				USER_ID,
				NAME,
				EMAIL,
				PHONE,
				IMAGE
			) VALUES (
				NEW.ID,
				COALESCE(_USER_NAME, 'Customer'),
				COALESCE(_CURRENT_EMAIL, _EMAIL_ADDRESS),
				COALESCE(_CURRENT_PHONE, _PHONE_NUMBER),
				_IMAGE
			) ON CONFLICT (
				USER_ID
			) DO NOTHING;
			RAISE NOTICE '[handle_new_user] UserID: %. Step 1: public.users record processed.', NEW.ID;
	
			RAISE NOTICE '[handle_new_user] UserID: %. Inserting into employees...', NEW.ID;
			INSERT INTO PUBLIC.CUSTOMERS (
				CUSTOMER_ID,
				NAME,
				IMAGE
			) VALUES (
				NEW.ID,
				COALESCE(_USER_NAME, 'Customer'),
				_IMAGE
			);
			RAISE NOTICE '[handle_new_user] UserID: %. Employee record created.', NEW.ID;
		END;
	END IF;

    RETURN NEW;
END;

$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_purchase_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_timestamp TEXT;
BEGIN

    -- Format timestamp
    v_timestamp := ' on ' || TO_CHAR(NOW(), 'DD Mon YYYY HH24:MI:SS');

    -- For purchase table changes
    IF TG_TABLE_NAME = 'purchases' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO purchase_audits (
                purchase_id,
                transaction_id,
                action_type,
                performed_by,
                new_data,
                change_details
            ) VALUES (
                NEW.purchase_id,
                NEW.transaction_id,
                'CREATED',
                auth.uid(),
                row_to_json(NEW),
                'Purchase created with invoice ' || NEW.purchase_invoice
            );
        ELSIF TG_OP = 'UPDATE' THEN
            -- Check what kind of update occurred
            IF OLD.paid_amount != NEW.paid_amount THEN
                INSERT INTO purchase_audits (
                    purchase_id,
                    transaction_id,
                    action_type,
                    performed_by,
                    old_data,
                    new_data,
                    change_details
                ) VALUES (
                    NEW.purchase_id,
                    NEW.transaction_id,
                    'PAYMENT_ADDED',
                    auth.uid(),
                    jsonb_build_object('paid_amount', OLD.paid_amount, 'due_amount', OLD.due_amount),
                    jsonb_build_object('paid_amount', NEW.paid_amount, 'due_amount', NEW.due_amount),
                    'Payment updated from ' || OLD.paid_amount || ' to ' || NEW.paid_amount
                );
            END IF;
        END IF;
    END IF;

    -- For purchase_returns table changes
    IF TG_TABLE_NAME = 'purchase_returns' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO purchase_audits (
                purchase_id,
                transaction_id,
                action_type,
                performed_by,
                new_data,
                change_details
            ) VALUES (
                NEW.purchase_id,
                NEW.transaction_id,
                'RETURN_CREATED',
                auth.uid(),
                row_to_json(NEW),
                'Purchase return created with invoice ' || NEW.return_invoice || ' for amount ' || NEW.total_amount
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_purchase_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_sale_audit"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_timestamp TEXT;
BEGIN

    -- Format timestamp
    v_timestamp := ' on ' || TO_CHAR(NOW(), 'DD Mon YYYY HH24:MI:SS');

    -- For sale table changes
    IF TG_TABLE_NAME = 'sales' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO sale_audits (
                sale_id,
                transaction_id,
                action_type,
                performed_by,
                new_data,
                change_details
            ) VALUES (
                NEW.sale_id,
                NEW.transaction_id,
                'CREATED',
                NEW.created_by,
                row_to_json(NEW),
                'Sale created with invoice ' || NEW.sale_invoice
            );
        ELSIF TG_OP = 'UPDATE' THEN
            -- Check for payment updates
            IF OLD.paid_amount != NEW.paid_amount THEN
                INSERT INTO sale_audits (
                    sale_id,
                    transaction_id,
                    action_type,
                    performed_by,
                    old_data,
                    new_data,
                    change_details
                ) VALUES (
                    NEW.sale_id,
                    NEW.transaction_id,
                    'PAYMENT_ADDED',
                    NEW.created_by,
                    jsonb_build_object('paid_amount', OLD.paid_amount, 'due_amount', OLD.due_amount),
                    jsonb_build_object('paid_amount', NEW.paid_amount, 'due_amount', NEW.due_amount),
                    'Payment updated from ' || OLD.paid_amount || ' to ' || NEW.paid_amount
                );
            END IF;
            
            -- Check for status changes
			IF OLD.status_id != NEW.status_id THEN
			    DECLARE
			        old_status_name text;
			        new_status_name text;
			    BEGIN
			        -- Get the status names
			        SELECT name INTO old_status_name
			        FROM statuses 
			        WHERE status_id = OLD.status_id;
			
			        SELECT name INTO new_status_name
			        FROM statuses 
			        WHERE status_id = NEW.status_id;
			
			        INSERT INTO sale_audits (
			            sale_id,
			            transaction_id,
			            action_type,
			            performed_by,
			            old_data,
			            new_data,
			            change_details
			        ) VALUES (
			            NEW.sale_id,
			            NEW.transaction_id,
			            'STATUS_CHANGED',
			            NEW.created_by,
			            jsonb_build_object('status_id', OLD.status_id, 'status_name', old_status_name),
			            jsonb_build_object('status_id', NEW.status_id, 'status_name', new_status_name),
			            'Status changed from "' || COALESCE(old_status_name, 'Unknown') || '" to "' || COALESCE(new_status_name, 'Unknown') || '"'
			        );
			    END;
			END IF;

        END IF;
    END IF;

    -- For sale_returns table changes
    IF TG_TABLE_NAME = 'sale_returns' THEN
        IF TG_OP = 'INSERT' THEN
            INSERT INTO sale_audits (
                sale_id,
                transaction_id,
                action_type,
                performed_by,
                new_data,
                change_details
            ) VALUES (
                NEW.sale_id,
                NEW.transaction_id,
                'RETURN_CREATED',
                NEW.created_by,
                row_to_json(NEW),
                'Sale return created with invoice ' || NEW.return_invoice || ' for amount ' || NEW.total_amount
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_sale_audit"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_employee_of_any_org"("p_user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.employees e
    WHERE e.employee_id = p_user_id
  );
END;
$$;


ALTER FUNCTION "public"."is_employee_of_any_org"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_employee_of_org"("p_user_id" "uuid", "p_org_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.employees e
    WHERE e.employee_id = p_user_id AND e.org_id = p_org_id
  );
END;
$$;


ALTER FUNCTION "public"."is_employee_of_org"("p_user_id" "uuid", "p_org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."register_business"("business_data" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_auth_user_id UUID := auth.uid();  -- Get the authenticated user ID
    v_org_id UUID;
    -- Removed category ID variables as they are now handled internally by create_default_chart_of_accounts
	v_existing_user_id UUID;
    v_business_id UUID;
BEGIN

    -- Check if user already exists
    SELECT user_id INTO v_existing_user_id
    FROM public.users
    WHERE email = business_data->>'email';

    IF v_existing_user_id IS NOT NULL THEN
        RAISE EXCEPTION 'User already exists';
    END IF;

    -- 1. Insert into users table
    INSERT INTO public.users (
        user_id,
        name,
        email,
        phone
    ) VALUES (
        v_auth_user_id,
        business_data->>'name',
        business_data->>'email',
        business_data->>'phone_number'
    );

    -- 2. Insert into organizations and get org_id
    INSERT INTO public.organizations (
        name
    ) VALUES (
        business_data->>'name'
    ) RETURNING org_id INTO v_org_id;

    INSERT INTO public.subscriptions (
        org_id,
        plan_id,
        status,
        start_date,
        end_date,                   -- NULL for a perpetual free plan
        trial_end_date,             -- NULL as it's not a trial
        cancel_at_period_end,       -- FALSE
        -- created_at and updated_at will use their default NOW()
        addon_id                    -- NULL if no default addon for free plan
        -- payment_provider fields are NULL as it's free
    ) VALUES (
        v_org_id,
        1,  -- <<<< FREE PLAN ID
        'active'::public.subscription_status_enum, -- Assuming 'active' is a valid status
        current_date, -- Subscription starts today
        NULL,
        NULL,
        FALSE,
        NULL
    );

    -- Insert into employees
    INSERT INTO public.employees (
        employee_id,
        org_id,
        name,
        role
    ) VALUES (
        v_auth_user_id,
        v_org_id,
        business_data->>'name',
        'admin'
    );

    UPDATE public.organizations
        SET created_by = v_auth_user_id
		WHERE org_id = v_org_id;

    -- 3. Insert into roles_of_employees
    INSERT INTO public.roles_of_employees (
        employee_role_id,
        employee_id
    ) VALUES (
        '00000000-0000-0000-0000-000000000000', -- Assuming this is a valid default role ID
        v_auth_user_id
    );

    -- 4. Insert into businesses
    INSERT INTO public.businesses (
        name,
        org_id,
        created_by,
        business_type,
        currency
    ) VALUES (
        business_data->>'name',
        v_org_id,
        v_auth_user_id,
        (business_data->>'business_type')::public.business_types,
        business_data->'currency'
    ) RETURNING business_id INTO v_business_id;

    -- Add default sale statuses
    INSERT INTO public.statuses (
        business_id,
        name,
        sequence_order,
        is_default,
        type,
		is_editable
    ) VALUES
    (v_business_id, 'Booked', 1, true, 'sale'::status_type, true),
    (v_business_id, 'In Process', 2, false, 'sale'::status_type, true),
    (v_business_id, 'Cancelled', 3, false, 'sale'::status_type, false),
    (v_business_id, 'Completed', 4, false, 'sale'::status_type, false);

    -- 5. Create the default Account Categories and Chart of Accounts
    --    The block for inserting into account_categories has been removed from here.
    PERFORM public.create_default_chart_of_accounts(v_business_id, v_org_id);

    -- 6. Insert into branch accesses (Renumbered step)
    INSERT INTO public.employee_branch_access (
        employee_id,
        business_id
    ) VALUES (
        v_auth_user_id,
        v_business_id
    );

	RETURN;
EXCEPTION
    WHEN OTHERS THEN
        -- Consider logging the error or providing more context
        RAISE EXCEPTION 'Error during business registration: %', SQLERRM;
        RETURN; -- Or re-raise
END;
$$;


ALTER FUNCTION "public"."register_business"("business_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reverse_stock_adjustment"("p_original_adjustment_id" "uuid", "p_reversal_date" timestamp with time zone DEFAULT "now"(), "p_reason" "text" DEFAULT 'Reversal of stock adjustment'::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_original_transaction_id UUID;
    v_original_tran RECORD; -- Holds data from original transactions record
    v_original_adj_item RECORD; -- For looping through original stock_adjustment_items
    v_reversal_transaction_id UUID;
    v_reversal_ref_no TEXT;
    v_user_id UUID := auth.uid();
    v_inventory_account_id UUID;
    v_adjustment_offset_account_id UUID;
    v_inventory_code TEXT := '1030';
    v_adjustment_offset_code TEXT := '6095';
    v_item_cost NUMERIC;
    v_item_name TEXT;
    v_item_adjustment_value NUMERIC;
    v_total_adjustment_abs_value NUMERIC := 0; -- For reversal transaction header
    v_business_id_check UUID; -- To fetch business_id early

BEGIN
    -- 1. Find original transaction_id and business_id from adjustment_id
    SELECT sa.transaction_id, sa.business_id
    INTO v_original_transaction_id, v_business_id_check -- Fetch business_id early
    FROM public.stock_adjustments sa
    WHERE sa.adjustment_id = p_original_adjustment_id;

    IF v_original_transaction_id IS NULL THEN
        RAISE EXCEPTION 'Stock Adjustment ID % not found.', p_original_adjustment_id;
    END IF;

    -- 2. Fetch full original transaction details & perform checks
    SELECT *
    INTO v_original_tran -- <<< Assign v_original_tran HERE
    FROM public.transactions
    WHERE transaction_id = v_original_transaction_id;

    -- Now perform checks using v_original_tran
    IF v_original_tran.transaction_id IS NULL THEN
         -- This should ideally not happen if the previous check passed, but is a safeguard
         RAISE EXCEPTION 'Original Transaction ID % linked to Adjustment ID % not found in transactions table.', v_original_transaction_id, p_original_adjustment_id;
    END IF;

    IF v_original_tran.status = 'REVERSED' OR v_original_tran.status = 'CANCELLED' THEN -- Use your chosen status
         RAISE EXCEPTION 'Stock Adjustment (Transaction ID %) has already been reversed or cancelled.', v_original_transaction_id;
    END IF;
    IF v_original_tran.reverses_transaction_id IS NOT NULL THEN
         RAISE EXCEPTION 'Transaction ID % is itself a reversal and cannot be reversed.', v_original_transaction_id;
    END IF;
    -- Add period lock checks if necessary (using v_original_tran.transaction_date)

    -- 3. Fetch required Account IDs using the business_id from v_original_tran
    SELECT account_id INTO v_inventory_account_id FROM public.accounts WHERE business_id = v_original_tran.business_id AND code = v_inventory_code;
    SELECT account_id INTO v_adjustment_offset_account_id FROM public.accounts WHERE business_id = v_original_tran.business_id AND code = v_adjustment_offset_code;

    IF v_inventory_account_id IS NULL OR v_adjustment_offset_account_id IS NULL THEN
         RAISE EXCEPTION 'Required accounting accounts (Inventory or Stock Adj. Expense) not found for business %.', v_original_tran.business_id;
    END IF;

    -- 4. Generate Reference for Reversal
    v_reversal_ref_no := 'REV-' || COALESCE(v_original_tran.reference_no, p_original_adjustment_id::text);

    -- 5. Calculate total absolute value from original adjustment items for header
    FOR v_original_adj_item IN
        SELECT sai.quantity_adjusted, COALESCE(i.purchase_price, 0) as item_cost
        FROM public.stock_adjustment_items sai
        JOIN public.items i ON sai.item_id = i.item_id
        WHERE sai.adjustment_id = p_original_adjustment_id
    LOOP
        v_total_adjustment_abs_value := v_total_adjustment_abs_value + abs(v_original_adj_item.quantity_adjusted * v_original_adj_item.item_cost);
    END LOOP;


    -- 6. Create the new Reversal Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status,
        total_amount, paid_amount, due_amount,
        notes, business_id, created_by,
        reverses_transaction_id -- Link back
    ) VALUES (
        v_reversal_ref_no, v_original_tran.transaction_type, p_reversal_date, 'PAID'::public.transaction_status, -- Mark reversal as complete
        v_total_adjustment_abs_value, v_total_adjustment_abs_value, 0,
        'Reversal of Stock Adj ' || v_original_tran.reference_no || '. Reason: ' || p_reason,
        v_original_tran.business_id, v_user_id,
        v_original_transaction_id
    ) RETURNING transaction_id INTO v_reversal_transaction_id;

    -- 7. Reverse Item Quantities and Create Reversal GL Entries
    FOR v_original_adj_item IN
        SELECT sai.item_id, sai.quantity_adjusted, sai.previous_quantity, i.name as item_name, COALESCE(i.purchase_price, 0) as item_cost
        FROM public.stock_adjustment_items sai
        JOIN public.items i ON sai.item_id = i.item_id
        WHERE sai.adjustment_id = p_original_adjustment_id
    LOOP
        -- Calculate value of this specific item's original adjustment
        v_item_adjustment_value := v_original_adj_item.quantity_adjusted * v_original_adj_item.item_cost;

        -- Create REVERSED Transaction Entries for this item
        -- If original was INCREASE (Debit Inv, Credit Offset), reversal is DEBIT Offset, CREDIT Inv
        IF v_original_adj_item.quantity_adjusted > 0 THEN
             INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
             VALUES
                (v_reversal_transaction_id, v_adjustment_offset_account_id, 'DEBIT'::public.entry_type, v_item_adjustment_value, '(Reversal) Stock Increase Adj Offset: ' || v_original_adj_item.item_name),
                (v_reversal_transaction_id, v_inventory_account_id, 'CREDIT'::public.entry_type, v_item_adjustment_value, '(Reversal) Stock Increase Adj: ' || v_original_adj_item.item_name);
        -- If original was DECREASE (Debit Offset, Credit Inv), reversal is DEBIT Inv, CREDIT Offset
        ELSIF v_original_adj_item.quantity_adjusted < 0 THEN
             INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
             VALUES
                (v_reversal_transaction_id, v_inventory_account_id, 'DEBIT'::public.entry_type, abs(v_item_adjustment_value), '(Reversal) Stock Decrease Adj: ' || v_original_adj_item.item_name),
                (v_reversal_transaction_id, v_adjustment_offset_account_id, 'CREDIT'::public.entry_type, abs(v_item_adjustment_value), '(Reversal) Stock Decrease Adj Offset: ' || v_original_adj_item.item_name);
        END IF;

        -- Update the item's stock quantity back to its previous state
        UPDATE public.items
        SET stock_quantity = v_original_adj_item.previous_quantity,
            updated_at = now()
        WHERE item_id = v_original_adj_item.item_id;

    END LOOP;

    -- 8. Update Status of Original Transaction
    UPDATE public.transactions
    SET status = 'REVERSED'::public.transaction_status, -- Or CANCELLED if you chose that
        updated_at = now()
    WHERE transaction_id = v_original_transaction_id;

    -- 9. Mark original stock adjustment header as reversed (optional)
    -- UPDATE public.stock_adjustments SET status = 'REVERSED' WHERE adjustment_id = p_original_adjustment_id;


    -- 10. Verify balance of the NEW reversal transaction
    PERFORM public.verify_transaction_balance(v_reversal_transaction_id);

    RAISE NOTICE 'Stock Adjustment (Transaction ID %) reversed by new Transaction ID %.', v_original_transaction_id, v_reversal_transaction_id;

    RETURN v_reversal_transaction_id;

END;
$$;


ALTER FUNCTION "public"."reverse_stock_adjustment"("p_original_adjustment_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reverse_transaction"("p_original_transaction_id" "uuid", "p_reversal_date" timestamp with time zone DEFAULT "now"(), "p_reason" "text" DEFAULT 'Reversal of original transaction'::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_original_tran RECORD;
    v_original_entry RECORD;
    v_reversal_transaction_id UUID;
    v_reversal_ref_no TEXT;
    v_user_id UUID := auth.uid();
BEGIN
    -- 1. Fetch original transaction details
    SELECT *
    INTO v_original_tran
    FROM public.transactions
    WHERE transaction_id = p_original_transaction_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Original Transaction ID % not found.', p_original_transaction_id;
    END IF;

    IF v_original_tran.status = 'REVERSED' OR v_original_tran.status = 'CANCELLED' THEN
         RAISE EXCEPTION 'Transaction ID % has already been reversed or cancelled.', p_original_transaction_id;
    END IF;
    IF v_original_tran.reverses_transaction_id IS NOT NULL THEN
         RAISE EXCEPTION 'Transaction ID % is itself a reversal and cannot be reversed.', p_original_transaction_id;
    END IF;

    -- Add checks for period locking here if applicable (compare v_original_tran.transaction_date)

    -- 2. Generate Reference for Reversal
    v_reversal_ref_no := 'REV-' || v_original_tran.reference_no;
    -- Ensure uniqueness if needed (e.g., append date/time or check existence)

    -- 3. Create the new Reversal Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status,
        total_amount, paid_amount, due_amount, -- Use negative amounts? Or keep positive and rely on entries? Keep positive for consistency.
        notes, business_id, created_by,
        customer_id, supplier_id, -- Copy related IDs
        metadata, -- Copy metadata if desired
		org_id,
        reverses_transaction_id -- Link back to the original
    ) VALUES (
        v_reversal_ref_no, v_original_tran.transaction_type, p_reversal_date, 'PAID', -- Assume reversal is complete ('PAID')
        v_original_tran.total_amount, v_original_tran.paid_amount, v_original_tran.due_amount, -- Amounts might need review based on reversal meaning
        'Reversal of TXN ' || p_original_transaction_id || '. Reason: ' || p_reason,
        v_original_tran.business_id, v_user_id,
        v_original_tran.customer_id, v_original_tran.supplier_id,
        v_original_tran.metadata,
        v_original_tran.org_id,
        p_original_transaction_id
    ) RETURNING transaction_id INTO v_reversal_transaction_id;

    -- 4. Create Reversed Transaction Entries
    FOR v_original_entry IN
        SELECT * FROM public.transaction_entries WHERE transaction_id = p_original_transaction_id
    LOOP
        INSERT INTO public.transaction_entries (
            transaction_id, account_id, entry_type, amount, description
        ) VALUES (
            v_reversal_transaction_id,
            v_original_entry.account_id,
            -- Flip the entry type
            CASE v_original_entry.entry_type
                WHEN 'DEBIT' THEN 'CREDIT'::public.entry_type
                ELSE 'DEBIT'::public.entry_type
            END,
            v_original_entry.amount, -- Amount stays the same magnitude
            '(Reversal) ' || COALESCE(v_original_entry.description, '')
        );
    END LOOP;

    -- 5. Update Status of Original Transaction
    UPDATE public.transactions
    SET status = 'REVERSED'::public.transaction_status,
        updated_at = now()
    WHERE transaction_id = p_original_transaction_id;

    -- 6. Optionally update status on linked income/expense records
    UPDATE public.incomes SET status = 'REVERSED' WHERE transaction_id = p_original_transaction_id;
    UPDATE public.expenses SET status = 'REVERSED' WHERE transaction_id = p_original_transaction_id;

    -- 7. Verify balance of the NEW reversal transaction
    PERFORM public.verify_transaction_balance(v_reversal_transaction_id);

    RAISE NOTICE 'Transaction ID % reversed by new Transaction ID %.', p_original_transaction_id, v_reversal_transaction_id;

    RETURN v_reversal_transaction_id;

END;
$$;


ALTER FUNCTION "public"."reverse_transaction"("p_original_transaction_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_current_timestamp_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_current_timestamp_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."settle_purchase_payment"("p_purchase_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_purchase_record     RECORD;
	v_business_id         UUID;
    v_supplier_id         UUID;
    v_existing_transaction_id UUID; -- Renamed from v_transaction_id to avoid confusion
    v_payment_id          UUID;
    v_payment_asset_account_id UUID; -- Cash or Bank account ID (where money comes from)
    v_ap_account_id       UUID;       -- Accounts Payable account ID
    v_payment_ref_no      TEXT;     -- Reference for the payment itself
    v_acting_user_id      UUID := auth.uid(); -- User performing the action

    -- Account Codes (COA v6.4)
    v_ap_code             TEXT := '2110'; -- Accounts Payable
    v_cash_in_bank_code   TEXT := '1111'; -- Cash in Bank - Operating
    v_petty_cash_code     TEXT := '1113'; -- Petty Cash

BEGIN
    RAISE LOG 'settle_purchase_payment: Start. PurchaseID:%, Amount:%, Mode:%, Date:%', 
        p_purchase_id, p_amount, p_payment_mode, p_payment_date;

    -- 1. Get purchase and related transaction details
    SELECT
        p.purchase_id, p.supplier_id, p.business_id, 
        COALESCE(p.purchase_invoice, p.invoice_no, p.purchase_id::text) as purchase_ref_display, -- For notes
        p.due_amount as current_purchase_table_due, -- Due amount from purchases table
        t.transaction_id, 
        t.total_amount as transaction_total, 
        t.paid_amount as transaction_current_paid, -- Current paid amount on transaction
        t.due_amount as transaction_current_due,   -- Current due amount on transaction
        t.status as transaction_current_status
    INTO v_purchase_record
    FROM public.purchases p
    JOIN public.transactions t ON p.transaction_id = t.transaction_id
    WHERE p.purchase_id = p_purchase_id ; -- Assuming p_business_id is derived from purchase, but better to pass if available

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase ID %s not found.', p_purchase_id;
    END IF;

    v_business_id := v_purchase_record.business_id; -- Set after fetching
    v_supplier_id := v_purchase_record.supplier_id;
    v_existing_transaction_id := v_purchase_record.transaction_id;

    -- 2. Validate payment amount
    IF p_amount <= 0 THEN
         RAISE EXCEPTION 'Payment amount must be positive.';
    END IF;
    
    -- Compare against the transaction's due amount for accuracy
    IF ROUND(p_amount, 2) > ROUND(v_purchase_record.transaction_current_due, 2) THEN
        RAISE EXCEPTION 'Payment amount %s exceeds the remaining due amount %s for Purchase ID %s (Transaction ID %s).',
                        p_amount, v_purchase_record.transaction_current_due, p_purchase_id, v_existing_transaction_id;
    END IF;
    IF v_purchase_record.transaction_current_status = 'PAID'::public.transaction_status AND v_purchase_record.transaction_current_due <= 0 THEN
         RAISE EXCEPTION 'Purchase ID %s (Transaction ID %s) is already fully paid.', p_purchase_id, v_existing_transaction_id;
    END IF;

    -- 3. Get Account IDs
    SELECT account_id INTO v_ap_account_id FROM public.accounts 
        WHERE business_id = v_business_id AND code = v_ap_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN -- Assuming p_payment_mode is TEXT, not ENUM here.
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ap_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Payable account (%s) not found for Business:%', v_ap_code, v_business_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-PUR-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record (linking to the original transaction_id of the purchase)
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_acting_user_id, v_acting_user_id
    ) RETURNING payment_id INTO v_payment_id;
    RAISE LOG 'settle_purchase_payment: Created Payment ID: % for Txn ID: %', v_payment_id, v_existing_transaction_id;

    -- 6. Create Transaction Entries (these are added to the *existing* purchase transaction)
    -- Debit Accounts Payable (Reducing liability)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_existing_transaction_id, v_ap_account_id, 'DEBIT'::public.entry_type, p_amount, 
            'Payment made for Purchase Ref: ' || v_purchase_record.purchase_ref_display || ' (Payment Ref: ' || v_payment_ref_no || ')');

    -- Credit Cash/Bank (Reducing asset)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_existing_transaction_id, v_payment_asset_account_id, 'CREDIT'::public.entry_type, p_amount, 
            'Payment via ' || p_payment_mode || ' for Purchase Ref: ' || v_purchase_record.purchase_ref_display  || ' (Payment Ref: ' || v_payment_ref_no || ')');
    RAISE LOG 'settle_purchase_payment: Added GL entries to Txn ID: %', v_existing_transaction_id;

    -- 7. Update Purchase Header (in public.purchases table)
    UPDATE public.purchases
    SET
        paid_amount = purchases.paid_amount + p_amount,
        due_amount = purchases.due_amount - p_amount,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE purchase_id = p_purchase_id;

    -- 8. Update Transaction Header (in public.transactions table)
    DECLARE
        v_new_paid_amount NUMERIC;
        v_new_due_amount NUMERIC;
        v_new_status public.transaction_status;
    BEGIN
        v_new_paid_amount := v_purchase_record.transaction_current_paid + p_amount;
        v_new_due_amount := v_purchase_record.transaction_total - v_new_paid_amount; -- Due is based on total - new_paid

        IF ROUND(v_new_paid_amount, 2) >= ROUND(v_purchase_record.transaction_total, 2) THEN
            v_new_status := 'PAID'::public.transaction_status;
            v_new_due_amount := 0; -- If overpaid, due is 0, overpayment is a separate supplier credit.
                                   -- Or handle v_new_due_amount := LEAST(v_new_due_amount, 0);
        ELSE
            v_new_status := 'PARTIALLY_PAID'::public.transaction_status;
        END IF;

        UPDATE public.transactions
        SET
            paid_amount = v_new_paid_amount,
            due_amount = v_new_due_amount,
            status = v_new_status,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE transaction_id = v_existing_transaction_id;
        RAISE LOG 'settle_purchase_payment: Updated Txn Header. NewPaid:%, NewDue:%, NewStatus:%', v_new_paid_amount, v_new_due_amount, v_new_status;
    END;

    -- 9. Verify Balance of the original transaction (now including these payment entries)
    PERFORM public.verify_transaction_balance(v_existing_transaction_id);

    RETURN v_payment_id;

EXCEPTION
    WHEN others THEN
        RAISE LOG 'settle_purchase_payment: ERROR for PurchaseID:% Error: %', p_purchase_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle purchase payment for PurchaseID %s: %s', p_purchase_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."settle_purchase_payment"("p_purchase_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."settle_sale_payment"("p_sale_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_sale_record         RECORD;
    v_business_id         UUID;
    v_customer_id         UUID;
    v_existing_transaction_id UUID; -- Renamed
    v_payment_id          UUID;
    v_payment_asset_account_id UUID; -- Cash or Bank account ID (where money goes to)
    v_ar_account_id       UUID;       -- Accounts Receivable account ID
    v_payment_ref_no      TEXT;
    v_acting_user_id      UUID := auth.uid();

    -- Account Codes (COA v6.4)
    v_ar_code             TEXT := '1120'; -- Accounts Receivable
    v_cash_in_bank_code   TEXT := '1111'; -- Cash in Bank - Operating
    v_petty_cash_code     TEXT := '1113'; -- Petty Cash

BEGIN
    RAISE LOG 'settle_sale_payment: Start. SaleID:%, Amount:%, Mode:%, Date:%', 
        p_sale_id, p_amount, p_payment_mode, p_payment_date;

    -- 1. Get sale and related transaction details
    SELECT
        s.sale_id, s.customer_id, s.business_id, 
        COALESCE(s.sale_invoice, s.sale_id::text) as sale_ref_display, -- For notes
        s.due_amount as current_sale_table_due,
        t.transaction_id, 
        t.total_amount as transaction_total, 
        t.paid_amount as transaction_current_paid,
        t.due_amount as transaction_current_due,
        t.status as transaction_current_status
    INTO v_sale_record
    FROM public.sales s
    JOIN public.transactions t ON s.transaction_id = t.transaction_id
    WHERE s.sale_id = p_sale_id; -- Assuming sales table has org_id

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale ID %s not found.', p_sale_id;
    END IF;

    v_business_id := v_sale_record.business_id; -- Set after fetching
    v_customer_id := v_sale_record.customer_id;
    v_existing_transaction_id := v_sale_record.transaction_id;

    -- 2. Validate payment amount
    IF p_amount <= 0 THEN
         RAISE EXCEPTION 'Payment amount must be positive.';
    END IF;
    
    IF ROUND(p_amount, 2) > ROUND(v_sale_record.transaction_current_due, 2) THEN
        RAISE EXCEPTION 'Payment amount %s exceeds the remaining due amount %s for Sale ID %s (Transaction ID %s).',
                        p_amount, v_sale_record.transaction_current_due, p_sale_id, v_existing_transaction_id;
    END IF;
    IF v_sale_record.transaction_current_status = 'PAID'::public.transaction_status AND v_sale_record.transaction_current_due <= 0 THEN
         RAISE EXCEPTION 'Sale ID %s (Transaction ID %s) is already fully paid.', p_sale_id, v_existing_transaction_id;
    END IF;

    -- 3. Get Account IDs
    SELECT account_id INTO v_ar_account_id FROM public.accounts 
        WHERE business_id = v_business_id AND code = v_ar_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ar_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Receivable account (%s) not found for Business:%', v_ar_code, v_business_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-SAL-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_acting_user_id, v_acting_user_id
    ) RETURNING payment_id INTO v_payment_id;
    RAISE LOG 'settle_sale_payment: Created Payment ID: % for Txn ID: %', v_payment_id, v_existing_transaction_id;

    -- 6. Create Transaction Entries (added to the existing sale transaction_id)
    -- Debit Cash/Bank (Asset Increase)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_existing_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, p_amount, 
            'Payment received via ' || p_payment_mode || ' for Sale Ref: ' || v_sale_record.sale_ref_display || ' (Payment Ref: ' || v_payment_ref_no || ')');

    -- Credit Accounts Receivable (Reducing Asset)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_existing_transaction_id, v_ar_account_id, 'CREDIT'::public.entry_type, p_amount, 
            'Payment applied to A/R for Sale Ref: ' || v_sale_record.sale_ref_display || ' (Payment Ref: ' || v_payment_ref_no || ')');
    RAISE LOG 'settle_sale_payment: Added GL entries to Txn ID: %', v_existing_transaction_id;

    -- 7. Update Sale Header (in public.sales table)
    UPDATE public.sales
    SET
        paid_amount = sales.paid_amount + p_amount,
        due_amount = sales.due_amount - p_amount,
        updated_at = now(),
        updated_by = v_acting_user_id
    WHERE sale_id = p_sale_id;

    -- 8. Update Transaction Header (in public.transactions table)
    DECLARE
        v_new_paid_amount NUMERIC;
        v_new_due_amount NUMERIC;
        v_new_status public.transaction_status;
    BEGIN
        v_new_paid_amount := v_sale_record.transaction_current_paid + p_amount;
        v_new_due_amount := v_sale_record.transaction_total - v_new_paid_amount;

        IF ROUND(v_new_paid_amount, 2) >= ROUND(v_sale_record.transaction_total, 2) THEN
            v_new_status := 'PAID'::public.transaction_status;
            v_new_due_amount := 0; -- Overpayment might credit customer wallet, separate logic needed if that's the case here.
                                   -- Or v_new_due_amount := LEAST(v_new_due_amount, 0);
        ELSE
            v_new_status := 'PARTIALLY_PAID'::public.transaction_status;
        END IF;

        UPDATE public.transactions
        SET
            paid_amount = v_new_paid_amount,
            due_amount = v_new_due_amount,
            status = v_new_status,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE transaction_id = v_existing_transaction_id;
        RAISE LOG 'settle_sale_payment: Updated Txn Header. NewPaid:%, NewDue:%, NewStatus:%', v_new_paid_amount, v_new_due_amount, v_new_status;
    END;

    -- 9. Verify Balance
    PERFORM public.verify_transaction_balance(v_existing_transaction_id);

    RETURN v_payment_id;

EXCEPTION
    WHEN others THEN
        RAISE LOG 'settle_sale_payment: ERROR for SaleID:% Error: %', p_sale_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle sale payment for SaleID %s: %s', p_sale_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."settle_sale_payment"("p_sale_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_customer_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    _NEW_NAME TEXT;
    _NEW_EMAIL TEXT;
    _NEW_PHONE TEXT;
    _NEW_IMAGE TEXT;
BEGIN
    -- Only run for customers
    IF NEW.raw_user_meta_data->>'is_customer' = 'true' THEN
        _NEW_NAME := COALESCE(NEW.raw_user_meta_data->>'user_name', NEW.email, 'Customer');
        _NEW_EMAIL := COALESCE(NEW.email, NEW.raw_user_meta_data->>'email');
        _NEW_PHONE := COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone_number');
        _NEW_IMAGE := NEW.raw_user_meta_data->>'image';
        RAISE LOG '------AMEER[handle_existing_user] UserID: %', NEW.ID;
        -- Update users table
        UPDATE public.users
        SET
            name = _NEW_NAME,
            email = _NEW_EMAIL,
            phone = _NEW_PHONE,
            image = _NEW_IMAGE
        WHERE user_id = NEW.id;

        -- Update customers table
        UPDATE public.customers
        SET
            name = _NEW_NAME,
            image = _NEW_IMAGE
        WHERE customer_id = NEW.id;
    END IF;

    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."sync_customer_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_clear_sequences"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM clear_sequences(OLD.business_id);
    RETURN OLD;
END;
$$;


ALTER FUNCTION "public"."trigger_clear_sequences"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_create_sequences"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    PERFORM public.create_sequences(NEW.business_id);
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_create_sequences"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_account_balance"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_affected_account_id UUID;
    v_amount_changed NUMERIC;
    v_entry_type_changed public.entry_type;
    v_multiplier INTEGER;
    v_transaction_id_for_scope UUID;
    v_business_id_scoped UUID;
    v_org_id_scoped UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_affected_account_id := OLD.account_id;
        v_amount_changed := OLD.amount;
        v_entry_type_changed := OLD.entry_type;
        v_multiplier := -1; -- Reverse the effect
        v_transaction_id_for_scope := OLD.transaction_id;
    ELSE -- INSERT or UPDATE
        v_affected_account_id := NEW.account_id;
        v_amount_changed := NEW.amount;
        v_entry_type_changed := NEW.entry_type;
        v_multiplier := 1;  -- Apply the effect
        v_transaction_id_for_scope := NEW.transaction_id;

        IF TG_OP = 'UPDATE' THEN
            -- Only proceed if key fields that affect balance have changed
            IF OLD.account_id IS DISTINCT FROM NEW.account_id OR 
               OLD.amount IS DISTINCT FROM NEW.amount OR 
               OLD.entry_type IS DISTINCT FROM NEW.entry_type THEN

                -- First, reverse the effect of the OLD entry on the OLD account
                DECLARE v_old_txn_id UUID := OLD.transaction_id;
                        v_old_biz_id UUID; v_old_org_id UUID;
                BEGIN
                    SELECT t.business_id, t.org_id INTO v_old_biz_id, v_old_org_id
                    FROM public.transactions t WHERE t.transaction_id = v_old_txn_id;

                    IF v_old_biz_id IS NOT NULL AND v_old_org_id IS NOT NULL THEN
                        UPDATE public.accounts
                        SET balance = balance -
                            CASE
                                WHEN OLD.entry_type = 'DEBIT'::public.entry_type THEN OLD.amount
                                ELSE -OLD.amount -- Subtracting a negative (credit) is adding its magnitude
                            END
                        WHERE account_id = OLD.account_id
                          AND business_id = v_old_biz_id
                          AND org_id = v_old_org_id;
                        RAISE LOG 'update_account_balance (UPDATE - Reversal): AccID:%, Amt:%, Type:%, Biz:%, Org:%', 
                                  OLD.account_id, OLD.amount, OLD.entry_type, v_old_biz_id, v_old_org_id;
                    ELSE 
                        RAISE WARNING 'update_account_balance (UPDATE - Reversal): Could not find biz/org for old transaction ID % to reverse balance.', v_old_txn_id;
                    END IF;
                EXCEPTION WHEN OTHERS THEN 
                    RAISE WARNING 'update_account_balance (UPDATE - Reversal): Error reversing old balance for AccID %: %', OLD.account_id, SQLERRM;
                END;
            ELSE
                -- No change in account, amount, or entry_type, so no balance update needed from the UPDATE itself.
                RETURN NEW; 
            END IF;
        END IF; -- End of TG_OP = 'UPDATE' specific logic
    END IF; -- End of DELETE vs INSERT/UPDATE block

    -- Fetch business_id and org_id for the current operation (NEW or OLD entry)
    SELECT t.business_id, t.org_id 
    INTO v_business_id_scoped, v_org_id_scoped
    FROM public.transactions t WHERE t.transaction_id = v_transaction_id_for_scope;

    IF v_business_id_scoped IS NULL OR v_org_id_scoped IS NULL THEN
        RAISE WARNING 'update_account_balance trigger: Could not determine business_id/org_id for transaction_id %. Account_id % balance not updated.', 
            v_transaction_id_for_scope, v_affected_account_id;
        IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
    END IF;
    
    RAISE LOG 'update_account_balance trigger (Application): Op:%, AccID:%, Amt:%, Type:%, Mult:%, Biz:%, Org:%', 
        TG_OP, v_affected_account_id, v_amount_changed, v_entry_type_changed, v_multiplier, v_business_id_scoped, v_org_id_scoped;

    -- Apply the change (for INSERT, or the NEW value of UPDATE after OLD was reversed, or DELETE)
    UPDATE public.accounts
    SET balance = accounts.balance +
        (CASE
            WHEN v_entry_type_changed = 'DEBIT'::public.entry_type THEN v_amount_changed
            ELSE -v_amount_changed -- For CREDIT entry, subtract from balance (as balance represents net debit)
        END * v_multiplier)
    WHERE account_id = v_affected_account_id
      AND business_id = v_business_id_scoped
      AND org_id = v_org_id_scoped;

    IF NOT FOUND AND TG_OP != 'UPDATE' AND OLD.account_id = NEW.account_id THEN -- Only warn if not found for insert/delete, or update where account didn't change but still not found
        RAISE WARNING 'update_account_balance trigger: Account ID % for Business %, Org % not found in accounts table during final update. Balance not updated.', 
            v_affected_account_id, v_business_id_scoped, v_org_id_scoped;
    ELSIF TG_OP = 'UPDATE' AND OLD.account_id != NEW.account_id AND NOT FOUND THEN
         RAISE WARNING 'update_account_balance trigger: NEW Account ID % for Business %, Org % not found in accounts table during UPDATE. Balance for NEW account not updated.', 
            v_affected_account_id, v_business_id_scoped, v_org_id_scoped;
    END IF;

    IF TG_OP = 'DELETE' THEN 
        RETURN OLD; 
    ELSE 
        RETURN NEW; 
    END IF;
END;
$$;


ALTER FUNCTION "public"."update_account_balance"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_credit_note_status"("p_credit_note_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_credit_remaining NUMERIC;
    v_grand_total NUMERIC;
    v_new_status public.credit_note_status;
BEGIN
    SELECT credit_remaining, grand_total INTO v_credit_remaining, v_grand_total
    FROM public.credit_notes WHERE credit_note_id = p_credit_note_id;

    IF NOT FOUND THEN RETURN; END IF;

    IF v_credit_remaining <= 0 THEN v_new_status := 'closed';
    ELSIF v_credit_remaining < v_grand_total THEN v_new_status := 'partially_used';
    ELSE v_new_status := 'open';
    END IF;

    UPDATE public.credit_notes SET status = v_new_status
    WHERE credit_note_id = p_credit_note_id AND status IS DISTINCT FROM v_new_status;
END;
$$;


ALTER FUNCTION "public"."update_credit_note_status"("p_credit_note_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_customer_balance_from_entry"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_transaction_id UUID;
    v_account_id_from_entry UUID;
    v_business_id UUID;
    v_org_id UUID;          -- <<<<< ADDED
    v_customer_id UUID;
    
    -- COA v6.4 Account Codes
    v_ar_code TEXT := '1120'; -- Accounts Receivable (Customer Owes Us)
    v_cust_deposit_code TEXT := '2150'; -- Customer Deposits / Credit Balances (We Owe Customer)

    -- Fetched Account IDs for this business/org
    v_ar_account_id_for_biz UUID;
    v_cust_deposit_account_id_for_biz UUID;
    
    v_recalculated_ui_convention_balance NUMERIC;
    v_acting_user_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_transaction_id := OLD.transaction_id;
        v_account_id_from_entry := OLD.account_id;
        v_acting_user_id := OLD.updated_by; 
    ELSE 
        v_transaction_id := NEW.transaction_id;
        v_account_id_from_entry := NEW.account_id;
        v_acting_user_id := NEW.updated_by; 
    END IF;

    IF v_acting_user_id IS NULL THEN
        BEGIN v_acting_user_id := auth.uid(); EXCEPTION WHEN OTHERS THEN v_acting_user_id := NULL; END;
    END IF;

    SELECT t.business_id, t.org_id, t.customer_id -- Fetch org_id
    INTO v_business_id, v_org_id, v_customer_id
    FROM public.transactions t
    WHERE t.transaction_id = v_transaction_id;

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_customer_id IS NULL THEN
        RAISE WARNING 'update_customer_balance_from_entry: Exiting. No business_id (%), org_id (%), or customer_id (%) found for transaction_id %.', 
            v_business_id, v_org_id, v_customer_id, v_transaction_id;
        RETURN NULL;
    END IF;

    -- Get the specific AR and Customer Deposit account IDs for THIS business and org
    SELECT account_id INTO v_ar_account_id_for_biz FROM public.accounts 
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ar_code AND is_group = FALSE;
    SELECT account_id INTO v_cust_deposit_account_id_for_biz FROM public.accounts 
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_cust_deposit_code AND is_group = FALSE;

    IF v_ar_account_id_for_biz IS NULL THEN
        RAISE WARNING 'update_customer_balance_from_entry: Accounts Receivable account (%s) not found for Business:%, Org:%. Cannot update customer balance for customer %s.', 
            v_ar_code, v_business_id, v_org_id, v_customer_id;
        RETURN NULL;
    END IF;
    IF v_cust_deposit_account_id_for_biz IS NULL THEN
        RAISE WARNING 'update_customer_balance_from_entry: Customer Deposits account (%s) not found for Business:%, Org:%. Cannot update customer balance for customer %s.', 
            v_cust_deposit_code, v_business_id, v_org_id, v_customer_id;
        RETURN NULL;
    END IF;
    
    IF v_account_id_from_entry != v_ar_account_id_for_biz AND v_account_id_from_entry != v_cust_deposit_account_id_for_biz THEN
        RAISE LOG 'update_customer_balance_from_entry: Entry for account_id % is not relevant to customer % balance. Skipping.', 
            v_account_id_from_entry, v_customer_id;
        RETURN NULL;
    END IF;

    RAISE LOG 'update_customer_balance_from_entry: Recalculating balance for Customer: %, Business: %, Org: %. Relevant Account IDs AR(%), CustDeposit(%)', 
        v_customer_id, v_business_id, v_org_id, v_ar_account_id_for_biz, v_cust_deposit_account_id_for_biz;

    -- Recalculate the net balance for this customer from ALL relevant transaction_entries.
    -- UI Convention for customer_balance:
    -- Positive: Business Owes Customer (Customer has a credit/deposit)
    -- Negative: Customer Owes Business (Customer has a receivable)
    SELECT COALESCE(SUM(
               CASE
                   -- Accounts Receivable (1120 - Asset for us: Customer Owes Us):
                   -- DEBIT to A/R means customer owes US MORE (results in a more negative UI balance)
                   WHEN te.account_id = v_ar_account_id_for_biz AND te.entry_type = 'DEBIT'::public.entry_type THEN -te.amount
                   -- CREDIT to A/R means customer owes US LESS (results in a less negative/more positive UI balance)
                   WHEN te.account_id = v_ar_account_id_for_biz AND te.entry_type = 'CREDIT'::public.entry_type THEN te.amount
                   
                   -- Customer Deposits / Credit Balances (2150 - Liability for us: We Owe Customer):
                   -- CREDIT to CustDeposit means we owe customer MORE (results in a more positive UI balance)
                   WHEN te.account_id = v_cust_deposit_account_id_for_biz AND te.entry_type = 'CREDIT'::public.entry_type THEN te.amount
                   -- DEBIT to CustDeposit means we owe customer LESS (results in a less positive/more negative UI balance)
                   WHEN te.account_id = v_cust_deposit_account_id_for_biz AND te.entry_type = 'DEBIT'::public.entry_type THEN -te.amount
                   ELSE 0
               END
           ), 0)
    INTO v_recalculated_ui_convention_balance
    FROM public.transaction_entries te
    JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = v_business_id
      AND t.org_id = v_org_id -- Ensure org_id is used
      AND t.customer_id = v_customer_id
      AND te.account_id IN (v_ar_account_id_for_biz, v_cust_deposit_account_id_for_biz);

    RAISE LOG 'update_customer_balance_from_entry: Recalculated UI convention balance for Customer % is: %', 
        v_customer_id, v_recalculated_ui_convention_balance;

    UPDATE public.business_customers bc
    SET customer_balance = v_recalculated_ui_convention_balance,
        updated_at = now(),
        updated_by = v_acting_user_id -- Set who triggered this balance update indirectly
    WHERE bc.business_id = v_business_id
      AND bc.customer_id = v_customer_id;

    IF NOT FOUND THEN
        RAISE WARNING 'update_customer_balance_from_entry: Customer ID % for Business %, Org % not found in business_customers table during final update.', 
            v_customer_id, v_business_id, v_org_id;
    END IF;

    RETURN NULL; 

EXCEPTION
    WHEN others THEN
        RAISE WARNING 'Error in update_customer_balance_from_entry trigger for customer_id % (Transaction ID: %). Error: %', 
            v_customer_id, v_transaction_id, SQLERRM;
        RETURN NULL; 
END;
$$;


ALTER FUNCTION "public"."update_customer_balance_from_entry"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_invoice_status"("p_invoice_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_balance_due NUMERIC;
    v_grand_total NUMERIC;
    v_new_status TEXT;
BEGIN
    SELECT balance_due, grand_total INTO v_balance_due, v_grand_total
    FROM public.invoices WHERE invoice_id = p_invoice_id;

    IF NOT FOUND THEN RETURN; END IF;

    IF v_balance_due <= 0 THEN v_new_status := 'paid';
    ELSIF v_balance_due < v_grand_total THEN v_new_status := 'partially_paid';
    ELSE v_new_status := 'sent'; -- Or your default unpaid status
    END IF;

    UPDATE public.invoices SET status = v_new_status
    WHERE invoice_id = p_invoice_id AND status IS DISTINCT FROM v_new_status;
END;
$$;


ALTER FUNCTION "public"."update_invoice_status"("p_invoice_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_quote"("p_quote_id_to_update" "uuid", "p_update_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    -- Existing Quote Data
    v_quote RECORD;

    -- Parsed Input Data
    v_billing_address      UUID;
    v_shipping_address     UUID;
    v_quote_date           DATE;
    v_valid_until_date     DATE;
    v_notes                TEXT;
    v_terms_and_conditions TEXT;
    v_status               TEXT;
    v_quote_code           TEXT; -- To hold the potentially updated quote code
    v_quote_items_to_update JSONB;

    -- Amounts
    v_input_tax_total        NUMERIC;
    v_input_discount_amount  NUMERIC;
    v_input_shipping_charges NUMERIC;

    -- Calculated Totals
    v_calculated_sub_total   NUMERIC := 0;
    v_calculated_grand_total NUMERIC := 0;

    -- Internal Vars
    v_quote_item_data      RECORD;

BEGIN
    -- 1. FETCH AND LOCK THE EXISTING QUOTE
    SELECT * INTO v_quote FROM public.quotes WHERE quote_id = p_quote_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Quote with ID % not found.', p_quote_id;
    END IF;

    -- 2. PARSE UPDATE JSON, USING EXISTING VALUES AS DEFAULTS
    v_billing_address      := COALESCE((p_update_json->>'billing_address')::uuid, v_quote.billing_address);
    v_shipping_address     := COALESCE((p_update_json->>'shipping_address')::uuid, v_quote.shipping_address);
    v_quote_date           := COALESCE((p_update_json->>'quote_date')::date, v_quote.quote_date);
    v_valid_until_date     := COALESCE((p_update_json->>'valid_until_date')::date, v_quote.valid_until_date);
    v_notes                := COALESCE(p_update_json->>'notes', v_quote.notes);
    v_terms_and_conditions := COALESCE(p_update_json->>'terms_and_conditions', v_quote.terms_and_conditions);
    v_status               := COALESCE(p_update_json->>'status', v_quote.status);
    v_quote_code           := COALESCE(p_update_json->>'quote_code', v_quote.quote_code); -- Get new code or keep old one

    -- 3. VALIDATE UNIQUENESS IF QUOTE CODE IS BEING CHANGED
    IF v_quote_code <> v_quote.quote_code THEN
        IF EXISTS (SELECT 1 FROM public.quotes WHERE business_id = v_quote.business_id AND quote_code = v_quote_code AND quote_id <> p_quote_id) THEN
            RAISE EXCEPTION 'Quote code "%" already exists for this business.', v_quote_code;
        END IF;
    END IF;
    
    -- 4. HANDLE ITEMS AND TOTALS
    IF p_update_json ? 'quote_items' THEN
        -- Items are being changed, so recalculate everything from scratch
        v_quote_items_to_update := p_update_json->'quote_items';
        v_input_tax_total       := COALESCE((p_update_json->>'tax_total')::numeric, 0);
        v_input_discount_amount := COALESCE((p_update_json->>'discount_amount')::numeric, 0);
        v_input_shipping_charges:= COALESCE((p_update_json->>'shipping_charges')::numeric, 0);

        -- Recalculate sub_total from new items
        FOR v_quote_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_quote_items_to_update) AS x LOOP
            v_calculated_sub_total := v_calculated_sub_total + (v_quote_item_data.quantity * v_quote_item_data.unit_price);
        END LOOP;

        -- Update quote items table
        DELETE FROM public.quote_items WHERE quote_id = p_quote_id;
        FOR v_quote_item_data IN SELECT (x->>'item_id')::uuid AS item_id, COALESCE((x->>'quantity')::numeric, 0) AS quantity, COALESCE((x->>'unit_price')::numeric, 0) AS unit_price FROM jsonb_array_elements(v_quote_items_to_update) AS x LOOP
            INSERT INTO public.quote_items (business_id, customer_id, quote_id, item_id, quantity, unit_price)
            VALUES (v_quote.business_id, v_quote.customer_id, p_quote_id, v_quote_item_data.item_id, v_quote_item_data.quantity, v_quote_item_data.unit_price);
        END LOOP;
    ELSE
        -- Items are not changing, use existing totals
        v_input_tax_total       := COALESCE((p_update_json->>'tax_total')::numeric, v_quote.tax_total);
        v_input_discount_amount := COALESCE((p_update_json->>'discount_amount')::numeric, v_quote.discount_amount);
        v_input_shipping_charges:= COALESCE((p_update_json->>'shipping_charges')::numeric, v_quote.shipping_charges);
        v_calculated_sub_total  := v_quote.sub_total;
    END IF;

    -- 5. CALCULATE GRAND TOTAL
    v_calculated_grand_total := COALESCE(v_calculated_sub_total, 0) - COALESCE(v_input_discount_amount, 0) + COALESCE(v_input_shipping_charges, 0) + COALESCE(v_input_tax_total, 0);

    -- 6. UPDATE public.quotes TABLE
    UPDATE public.quotes SET
        billing_address      = v_billing_address,
        shipping_address     = v_shipping_address,
        quote_date           = v_quote_date,
        valid_until_date     = v_valid_until_date,
        notes                = v_notes,
        terms_and_conditions = v_terms_and_conditions,
        status               = v_status,
        quote_code           = v_quote_code,
        tax_total            = v_input_tax_total,
        discount_amount      = v_input_discount_amount,
        shipping_charges     = v_input_shipping_charges,
        sub_total            = v_calculated_sub_total,
        grand_total          = v_calculated_grand_total
    WHERE quote_id = p_quote_id;

    -- 7. RETURN SUCCESS
    RETURN jsonb_build_object(
        'quote_id', p_quote_id,
        'status', 'success',
        'message', 'Quote updated successfully.'
    );

EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Failed to update quote. Error: %, SQLState: %', SQLERRM, SQLSTATE;
END;$$;


ALTER FUNCTION "public"."update_quote"("p_quote_id_to_update" "uuid", "p_update_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_sale"("p_sale_json" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_transaction_id uuid;
    v_sale_id uuid;
    v_business_id uuid;
    v_customer_id uuid;
    v_main_account_id uuid;
    v_receivable_account_id uuid;
    v_sale_date timestamp with time zone;
    v_sale_item record;
    v_existing_sale record;
    v_old_sale_item record;
    v_status_id uuid;
    v_sale_item_id uuid;
    v_subservice record;
BEGIN
    -- Extract key values
    v_sale_id := (p_sale_json->>'sale_id')::uuid;
    v_business_id := (p_sale_json->>'business_id')::uuid;
    v_customer_id := (p_sale_json->>'customer_id')::uuid;
    
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
    
    -- Get account IDs
    SELECT account_id INTO v_main_account_id
    FROM accounts 
    WHERE business_id = v_business_id AND code = 'TRP';
    
    SELECT account_id INTO v_receivable_account_id
    FROM accounts 
    WHERE business_id = v_business_id AND code = 'MOA';
    
    -- Revert inventory changes for existing sale items
    FOR v_old_sale_item IN 
        SELECT si.*, i.item_type, i.inventory_enabled
        FROM sale_items si
        JOIN items i ON i.item_id = si.item_id
        WHERE si.sale_id = v_sale_id
    LOOP
        IF v_old_sale_item.item_type = 'goods' AND v_old_sale_item.inventory_enabled THEN
            UPDATE items
            SET 
                stock_quantity = stock_quantity + v_old_sale_item.quantity,
                stock_value = stock_value + (v_old_sale_item.quantity * v_old_sale_item.unit_price)
            WHERE item_id = v_old_sale_item.item_id;
        END IF;
    END LOOP;
    
    -- Delete existing sale items and subservices
    DELETE FROM sale_item_subservices 
    WHERE sale_item_id IN (SELECT sale_item_id FROM sale_items WHERE sale_id = v_sale_id);
    DELETE FROM sale_items WHERE sale_id = v_sale_id;
    
    -- Update transaction
    UPDATE transactions
    SET
        total_amount = (p_sale_json->>'grand_total')::numeric,
        due_amount = (p_sale_json->>'grand_total')::numeric - paid_amount,
        metadata = p_sale_json,
        updated_at = CURRENT_TIMESTAMP
    WHERE transaction_id = v_transaction_id;
    
    -- Update transaction entries
    UPDATE transaction_entries
    SET amount = (p_sale_json->>'grand_total')::numeric
    WHERE transaction_id = v_transaction_id;
    
    -- Update sale record
    UPDATE sales
    SET
        customer_id = v_customer_id,
        subtotal = (p_sale_json->>'subtotal')::numeric,
        discount_amount = (p_sale_json->>'discount_amount')::numeric,
        tax_amount = (p_sale_json->>'tax_total')::numeric,
        shipping_charge = (p_sale_json->>'shipping')::numeric,
        total_amount = (p_sale_json->>'grand_total')::numeric,
        due_amount = (p_sale_json->>'grand_total')::numeric - v_existing_sale.paid_amount,
        metadata = p_sale_json,
        updated_at = CURRENT_TIMESTAMP
    WHERE sale_id = v_sale_id;
    
    -- Create new sale items and update inventory
    FOR v_sale_item IN 
        SELECT 
            x.*,
            i.item_type,
            i.inventory_enabled,
            x.subservices::jsonb as subservices_data
        FROM jsonb_to_recordset(p_sale_json->'sale_items') 
        AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN items i ON i.item_id = x.item_id::uuid
    LOOP
        -- Insert sale item
        INSERT INTO sale_items (
            sale_id,
            item_id,
            quantity,
            unit_price
        ) VALUES (
            v_sale_id,
            v_sale_item.item_id,
            v_sale_item.quantity,
            v_sale_item.unit_price
        ) RETURNING sale_item_id INTO v_sale_item_id;
        
        -- If item is a service and has subservices, add them
        IF v_sale_item.item_type = 'services' AND 
           v_sale_item.subservices_data IS NOT NULL AND 
           jsonb_array_length(v_sale_item.subservices_data) > 0 THEN
            
            FOR v_subservice IN 
                SELECT * FROM jsonb_to_recordset(v_sale_item.subservices_data)
                AS x(sub_service_id uuid, quantity numeric, additional_price numeric)
            LOOP
                INSERT INTO sale_item_subservices (
                    sale_item_id,
                    sub_service_id,
                    quantity,
                    additional_price
                ) VALUES (
                    v_sale_item_id,
                    v_subservice.sub_service_id,
                    v_subservice.quantity,
                    v_subservice.additional_price
                );
            END LOOP;
        END IF;
        
        -- Update item inventory if enabled (only for goods)
        IF v_sale_item.item_type = 'goods' AND v_sale_item.inventory_enabled THEN
            UPDATE items
            SET 
                stock_quantity = stock_quantity - v_sale_item.quantity,
                stock_value = stock_value - (v_sale_item.quantity * v_sale_item.unit_price)
            WHERE item_id = v_sale_item.item_id;
        END IF;
    END LOOP;
    
    -- Update business_customers due amount
    UPDATE business_customers 
    SET due = due - v_existing_sale.due_amount + ((p_sale_json->>'grand_total')::numeric - v_existing_sale.paid_amount)
    WHERE business_id = v_business_id 
    AND customer_id = v_customer_id;
    
    RETURN (SELECT row_to_json(sale_view)
    FROM sale_view
    WHERE sale_id = v_sale_id);
EXCEPTION
    WHEN others THEN
        RAISE EXCEPTION 'Error in update_sale: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."update_sale"("p_sale_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_supplier_balance_from_entry"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_transaction_id UUID;
    v_account_id_from_entry UUID; 
    v_business_id UUID;
    v_org_id UUID;      
    v_supplier_id UUID;
    
    -- COA v6.4 Account Codes
    v_ap_code TEXT := '2110';        
    v_supp_adv_code TEXT := '1145';  

    -- Fetched Account IDs for this business/org
    v_ap_account_id_for_biz UUID;
    v_supp_adv_account_id_for_biz UUID;
    
    v_recalculated_ui_convention_balance NUMERIC;
    v_acting_user_id UUID;
    v_op_type TEXT; -- To store TG_OP for logging
    v_row_count INTEGER; -- For checking update
BEGIN
    v_op_type := TG_OP; -- Store operation type for logging

    IF TG_OP = 'DELETE' THEN
        v_transaction_id := OLD.transaction_id;
        v_account_id_from_entry := OLD.account_id;
        v_acting_user_id := OLD.updated_by; 
        RAISE LOG '[%] update_supplier_balance_from_entry: OLD EntryID:%, AccID:%, Amt:%, Type:%', 
            v_op_type, OLD.entry_id, OLD.account_id, OLD.amount, OLD.entry_type;
    ELSE -- INSERT or UPDATE
        v_transaction_id := NEW.transaction_id;
        v_account_id_from_entry := NEW.account_id;
        v_acting_user_id := NEW.updated_by; 
        RAISE LOG '[%] update_supplier_balance_from_entry: NEW EntryID:%, AccID:%, Amt:%, Type:%', 
            v_op_type, NEW.entry_id, NEW.account_id, NEW.amount, NEW.entry_type;
        IF TG_OP = 'UPDATE' THEN
            RAISE LOG '[%] update_supplier_balance_from_entry: OLD (for UPDATE) EntryID:%, AccID:%, Amt:%, Type:%', 
                v_op_type, OLD.entry_id, OLD.account_id, OLD.amount, OLD.entry_type;
        END IF;
    END IF;

    IF v_acting_user_id IS NULL THEN
        BEGIN v_acting_user_id := auth.uid(); EXCEPTION WHEN OTHERS THEN v_acting_user_id := NULL; END;
        RAISE LOG '[%] update_supplier_balance_from_entry: ActingUserID set to: % (from auth.uid or NULL)', v_op_type, v_acting_user_id;
    END IF;

    RAISE LOG '[%] update_supplier_balance_from_entry: Fetching transaction details for TxnID: %', v_op_type, v_transaction_id;
    SELECT t.business_id, t.org_id, t.supplier_id
    INTO v_business_id, v_org_id, v_supplier_id
    FROM public.transactions t
    WHERE t.transaction_id = v_transaction_id;

    RAISE LOG '[%] update_supplier_balance_from_entry: Fetched - BizID:%, OrgID:%, SupplierID:%', 
        v_op_type, v_business_id, v_org_id, v_supplier_id;

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_supplier_id IS NULL THEN
        RAISE WARNING '[%] update_supplier_balance_from_entry: Exiting. No business_id, org_id, or supplier_id found for transaction_id %.', 
            v_op_type, v_transaction_id;
        RETURN NULL;
    END IF;

    RAISE LOG '[%] update_supplier_balance_from_entry: Fetching account IDs for BizID:%, OrgID:% (AP Code:%, SuppAdv Code:%)', 
        v_op_type, v_business_id, v_org_id, v_ap_code, v_supp_adv_code;
    SELECT account_id INTO v_ap_account_id_for_biz FROM public.accounts 
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ap_code AND is_group = FALSE;
    SELECT account_id INTO v_supp_adv_account_id_for_biz FROM public.accounts 
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_supp_adv_code AND is_group = FALSE;

    RAISE LOG '[%] update_supplier_balance_from_entry: Fetched Account IDs - AP_ID_for_Biz: %, SuppAdv_ID_for_Biz: %', 
        v_op_type, v_ap_account_id_for_biz, v_supp_adv_account_id_for_biz;

    IF v_ap_account_id_for_biz IS NULL THEN
        RAISE WARNING '[%] update_supplier_balance_from_entry: Accounts Payable account (%s) not found for Biz:%, Org:%. Cannot update supplier balance for supplier %s.', 
            v_op_type, v_ap_code, v_business_id, v_org_id, v_supplier_id;
        RETURN NULL;
    END IF;
    IF v_supp_adv_account_id_for_biz IS NULL THEN
        RAISE WARNING '[%] update_supplier_balance_from_entry: Supplier Advances account (%s) not found for Biz:%, Org:%. Cannot update supplier balance for supplier %s.', 
            v_op_type, v_supp_adv_code, v_business_id, v_org_id, v_supplier_id;
        RETURN NULL;
    END IF;
    
    RAISE LOG '[%] update_supplier_balance_from_entry: Triggering Entry Account ID: %', v_op_type, v_account_id_from_entry;
    IF v_account_id_from_entry != v_ap_account_id_for_biz AND v_account_id_from_entry != v_supp_adv_account_id_for_biz THEN
        RAISE LOG '[%] update_supplier_balance_from_entry: Entry for account_id % is not relevant to supplier % balance. Skipping update.', 
            v_op_type, v_account_id_from_entry, v_supplier_id;
        RETURN NULL;
    END IF;

    RAISE LOG '[%] update_supplier_balance_from_entry: Recalculating balance for Supplier: %, Business: %, Org: %.', 
        v_op_type, v_supplier_id, v_business_id, v_org_id;

    SELECT COALESCE(SUM(
               CASE
                   WHEN te.account_id = v_ap_account_id_for_biz AND te.entry_type = 'CREDIT'::public.entry_type THEN te.amount
                   WHEN te.account_id = v_ap_account_id_for_biz AND te.entry_type = 'DEBIT'::public.entry_type THEN -te.amount
                   WHEN te.account_id = v_supp_adv_account_id_for_biz AND te.entry_type = 'DEBIT'::public.entry_type THEN -te.amount
                   WHEN te.account_id = v_supp_adv_account_id_for_biz AND te.entry_type = 'CREDIT'::public.entry_type THEN te.amount
                   ELSE 0 
               END
           ), 0)
    INTO v_recalculated_ui_convention_balance
    FROM public.transaction_entries te
    JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = v_business_id
      AND t.org_id = v_org_id 
      AND t.supplier_id = v_supplier_id
      AND te.account_id IN (v_ap_account_id_for_biz, v_supp_adv_account_id_for_biz); 

    RAISE LOG '[%] update_supplier_balance_from_entry: Recalculated UI convention balance for Supplier % is: %', 
        v_op_type, v_supplier_id, v_recalculated_ui_convention_balance;

    RAISE LOG '[%] update_supplier_balance_from_entry: Attempting to UPDATE suppliers SET supplier_balance = % WHERE supplier_id = % AND business_id = % AND org_id = %',
        v_op_type, v_recalculated_ui_convention_balance, v_supplier_id, v_business_id, v_org_id;

    UPDATE public.suppliers s
    SET supplier_balance = v_recalculated_ui_convention_balance,
        updated_at = now(),
        updated_by = v_acting_user_id 
    WHERE s.supplier_id = v_supplier_id
      AND s.business_id = v_business_id 
      AND s.org_id = v_org_id;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;
    RAISE LOG '[%] update_supplier_balance_from_entry: Rows updated in suppliers table: %', v_op_type, v_row_count;

    IF v_row_count = 0 THEN -- It should always find a row if supplier_id, business_id, org_id are correct
        RAISE WARNING '[%] update_supplier_balance_from_entry: Supplier ID % for Business %, Org % not found in suppliers table during final update, though it should exist.', 
            v_op_type, v_supplier_id, v_business_id, v_org_id;
    END IF;

    RETURN NULL; 

EXCEPTION
    WHEN others THEN
        RAISE WARNING '[%] Error in update_supplier_balance_from_entry trigger for supplier_id % (Transaction ID: %). Error: %', 
            v_op_type, v_supplier_id, v_transaction_id, SQLERRM;
        RETURN NULL; 
END;
$$;


ALTER FUNCTION "public"."update_supplier_balance_from_entry"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_business_customer"("p_customer_data" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data
    v_business_id UUID := p_customer_data->>'business_id';
    v_customer_id UUID := p_customer_data->>'customer_id';
    v_name TEXT := p_customer_data->>'name';
    v_image TEXT := p_customer_data->>'image';
    v_address TEXT := p_customer_data->>'address';
    v_org_id UUID := p_customer_data->>'org_id'; -- Assuming org_id is passed
    v_opening_balance NUMERIC := COALESCE((p_customer_data->>'customer_balance')::numeric, 0); -- Default to 0
    v_opening_balance_date TIMESTAMPTZ := now();

    -- Internal Variables
    v_user_id UUID := COALESCE(v_customer_id, auth.uid()); -- Assuming Supabase auth or similar acting user
    v_upsert_result RECORD;
    v_is_insert BOOLEAN := FALSE;
    v_transaction_id UUID;
    v_ref_no TEXT;

    -- Account IDs (UPDATED as per COA v6.4)
    v_ar_cust_acc_id UUID;   -- Accounts Receivable (1120)
    v_ap_cust_acc_id UUID;   -- Customer Deposits / Credit Balances (2150)
    v_ob_equity_acc_id UUID; -- Opening Balance Equity (3310)

    -- Account Codes (UPDATED as per COA v6.4)
    v_ar_cust_code TEXT := '1120';  -- Accounts Receivable
    v_ap_cust_code TEXT := '2150';  -- Customer Deposits / Credit Balances
    v_ob_equity_code TEXT := '3310'; -- Opening Balance Equity
BEGIN
    -- Validate required inputs
    IF v_business_id IS NULL OR v_customer_id IS NULL OR v_name IS NULL THEN
        RAISE EXCEPTION 'business_id, customer_id, and name are required.';
    END IF;

	INSERT INTO public.customers (
		name,
		customer_id
	) VALUES (
		v_name,
		v_customer_id
	) ON CONFLICT (customer_id) DO NOTHING;

    -- Perform Upsert using INSERT ON CONFLICT
    WITH upsert AS (
        INSERT INTO public.business_customers (
            business_id, customer_id, name, image, address, customer_balance, created_at, updated_at
        ) VALUES (
            v_business_id, v_customer_id, v_name, v_image, v_address, v_opening_balance, now(), now()
        )
        ON CONFLICT (business_id, customer_id) DO UPDATE SET
            name = EXCLUDED.name,
            image = EXCLUDED.image,
            address = EXCLUDED.address,
			is_active = TRUE,
            updated_at = now()
            -- DO NOT update customer_balance here on conflict!
            -- As per previous discussion, customer_balance is only set on initial insert
            -- or updated by triggers from transaction_entries.
        RETURNING xmax -- xmax = 0 for INSERT, non-zero for UPDATE
    )
    SELECT xmax INTO v_upsert_result FROM upsert;

    -- Check if an INSERT occurred (xmax = 0 indicates INSERT)
    IF v_upsert_result.xmax = 0 THEN
        v_is_insert := TRUE;
    END IF;

    -- If it was an INSERT AND an opening balance was provided and is non-zero
    IF v_is_insert AND v_opening_balance != 0 THEN

        -- Fetch required account IDs for the business (using updated codes)
        SELECT account_id INTO v_ar_cust_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_ar_cust_code;
        SELECT account_id INTO v_ap_cust_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_ap_cust_code;
        SELECT account_id INTO v_ob_equity_acc_id FROM public.accounts WHERE business_id = v_business_id AND code = v_ob_equity_code;

        -- Validate that accounts exist (using updated codes in messages)
        IF v_ob_equity_acc_id IS NULL THEN
             RAISE EXCEPTION 'Opening Balance Equity account (Code: %s) not found for business %s.', v_ob_equity_code, v_business_id;
        END IF;
        -- If customer owes business (negative input balance), AR account must exist
        IF v_opening_balance < 0 AND v_ar_cust_acc_id IS NULL THEN -- Note: original code had >0, but for negative input it's AR
             RAISE EXCEPTION 'Accounts Receivable account (Code: %s) not found for business %s.', v_ar_cust_code, v_business_id;
        END IF;
        -- If business owes customer (positive input balance), Customer Deposits account must exist
        IF v_opening_balance > 0 AND v_ap_cust_acc_id IS NULL THEN -- Note: original code had <0, but for positive input it's AP (Customer Deposits)
             RAISE EXCEPTION 'Customer Deposits / Credit Balances account (Code: %s) not found for business %s.', v_ap_cust_code, v_business_id;
        END IF;

        -- Generate a unique reference number for the opening balance transaction
        v_ref_no := 'OB-CUST-' || v_customer_id::text || '-' || to_char(v_opening_balance_date, 'YYYYMMDD');
        -- Consider using a more robust unique ID generator like public.generate_short_id() if available,
        -- as customer_id + date might not be strictly unique across multiple OBs for the same customer on the same day.

        -- Create the Transaction Header
        INSERT INTO public.transactions (
            reference_no, transaction_type, transaction_date, status,
            total_amount, paid_amount, due_amount, -- Amounts represent the magnitude of the balance being set up
            notes, business_id, created_by, customer_id, -- Link to customer
			org_id
        ) VALUES (
            v_ref_no, 'CUSTOMER_OPENING_BALANCE'::public.transaction_type, v_opening_balance_date, 'PAID'::public.transaction_status, -- Mark as PAID/Complete
            abs(v_opening_balance), abs(v_opening_balance), 0, -- Total/Paid amounts are positive magnitude
            'Opening balance setup for customer ' || v_name, v_business_id, v_user_id, v_customer_id, v_org_id
        ) RETURNING transaction_id INTO v_transaction_id;

        -- Create Transaction Entries based on balance sign
        IF v_opening_balance < 0 THEN
            -- Customer owes Business (UI input was negative, e.g., -100): Debit A/R (1120), Credit OB Equity (3310)
            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
            VALUES
                (v_transaction_id, v_ar_cust_acc_id, 'DEBIT'::public.entry_type, abs(v_opening_balance), 'Opening balance receivable from customer'), -- Amount is positive
                (v_transaction_id, v_ob_equity_acc_id, 'CREDIT'::public.entry_type, abs(v_opening_balance), 'Offset for customer opening balance receivable'); -- Amount is positive
        ELSE -- v_opening_balance > 0
            -- Business owes Customer (UI input was positive, e.g., +50): Debit OB Equity (3310), Credit Customer Deposits (2150)
            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
            VALUES
                (v_transaction_id, v_ob_equity_acc_id, 'DEBIT'::public.entry_type, abs(v_opening_balance), 'Offset for customer opening credit balance'), -- Amount is positive
                (v_transaction_id, v_ap_cust_acc_id, 'CREDIT'::public.entry_type, abs(v_opening_balance), 'Customer opening credit balance'); -- Amount is positive
        END IF;

        -- Verify the balance of the opening balance transaction itself
        PERFORM public.verify_transaction_balance(v_transaction_id);

        -- Note: The trigger `trigger_update_customer_balance` on `transaction_entries`
        -- should fire automatically due to the inserts above and correctly set the
        -- `customer_balance` in `business_customers` based on these new entries.
        -- The initial insert into business_customers already set the balance,
        -- but the trigger recalculating based on GL entries ensures consistency.

    END IF; -- End of opening balance handling

    RETURN; -- Function returns void

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to upsert customer OB: Unique constraint violated for ref_no "%" or customer_id "%. Detail: %', v_ref_no, v_customer_id, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to upsert business customer for business_id %s, customer_id %s. Error: %s', v_business_id, v_customer_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."upsert_business_customer"("p_customer_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_employee_role"("employee_role_json" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_employee_role_id UUID;
    v_permission JSONB;
    v_submenu JSONB;
BEGIN
    -- Check if employee_role_id is provided
    IF (employee_role_json->>'employee_role_id') IS NOT NULL THEN
        v_employee_role_id := (employee_role_json->>'employee_role_id')::UUID;
        
        -- Update existing employee role
        UPDATE public.employee_roles
        SET 
            name = COALESCE(employee_role_json->>'name', name),
            description = COALESCE(employee_role_json->>'description', description)
        WHERE employee_role_id = v_employee_role_id;
    ELSE
        -- Insert new employee role
        INSERT INTO public.employee_roles (name, description, editable, business_id)
        VALUES (employee_role_json->>'name', employee_role_json->>'description', true, (employee_role_json->>'business_id')::uuid)
        RETURNING employee_role_id INTO v_employee_role_id;
    END IF;

    -- Delete existing permissions for this role
    DELETE FROM public.permissions WHERE employee_role_id = v_employee_role_id;

    -- Insert new permissions
    FOR v_permission IN SELECT * FROM jsonb_array_elements(employee_role_json->'permissions')
    LOOP
        -- Insert main module permission
        INSERT INTO public.permissions (employee_role_id, module_id, view, "create", edit, delete, print)
        VALUES (
            v_employee_role_id,
            (v_permission->>'id')::bigint,
            (v_permission->'permissions'->>'view')::boolean,
            (v_permission->'permissions'->>'add')::boolean,
            (v_permission->'permissions'->>'edit')::boolean,
            (v_permission->'permissions'->>'delete')::boolean,
            (v_permission->'permissions'->>'print')::boolean
        );

        -- Insert submenu permissions
        FOR v_submenu IN SELECT * FROM jsonb_array_elements(v_permission->'submenus')
        LOOP
            INSERT INTO public.permissions (employee_role_id, module_id, link_id, view, "create", edit, delete, print)
            VALUES (
                v_employee_role_id,
                (v_permission->>'id')::bigint,
                (v_submenu->>'id')::bigint,
                (v_submenu->'permissions'->>'view')::boolean,
                (v_submenu->'permissions'->>'add')::boolean,
                (v_submenu->'permissions'->>'edit')::boolean,
                (v_submenu->'permissions'->>'delete')::boolean,
                (v_submenu->'permissions'->>'print')::boolean
            );
        END LOOP;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."upsert_employee_role"("employee_role_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_expense"("p_expense_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_expense_id UUID := p_expense_data->>'expense_id';
    v_transaction_id UUID;
    v_business_id UUID := p_expense_data->>'business_id';
    v_org_id UUID := p_expense_data->>'org_id'; -- Assuming org_id is passed
    v_acting_user_id UUID := auth.uid(); -- User performing the action
    v_date TIMESTAMPTZ := (p_expense_data->>'date')::timestamptz;
    v_amount NUMERIC := (p_expense_data->>'amount')::numeric;
    v_expense_account_id UUID; -- Determined based on default (6010)
    v_payment_account_id UUID; -- Determined based on payment_type (Cash/Bank)
    v_expense_for TEXT := p_expense_data->>'expense_for';
    v_payment_type public.payment_type := (p_expense_data->>'payment_type')::public.payment_type;
    v_note TEXT := p_expense_data->>'note';
    v_reference_number TEXT := p_expense_data->>'reference_number';
    v_expense_category_id UUID := (p_expense_data->>'expense_category_id')::uuid; -- Optional link to user-defined expense_categories
    v_existing_txn_id UUID;
    v_ref_no TEXT;

    -- Account Codes (COA v6.4)
    v_default_expense_code TEXT := '6010'; -- General Expense
    v_petty_cash_code TEXT := '1113';    -- Petty Cash
    v_cash_in_bank_code TEXT := '1111';  -- Cash in Bank - Operating
BEGIN
    -- Validate required fields from JSON
    IF v_business_id IS NULL OR v_org_id IS NULL OR v_date IS NULL OR v_amount IS NULL OR v_amount <= 0 OR v_expense_for IS NULL OR v_payment_type IS NULL THEN
        RAISE EXCEPTION 'Missing required expense data: business_id, org_id, date, amount > 0, expense_for, payment_type are required.';
    END IF;

    IF v_date IS NULL THEN
        v_date := now(); -- Default date if not provided
    END IF;

    -- Fetch the default expense account ID
    SELECT account_id INTO v_expense_account_id
    FROM public.accounts
    WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_default_expense_code AND is_group = FALSE;

    IF v_expense_account_id IS NULL THEN
        RAISE EXCEPTION 'General Expense account (Code: %s) not found for business_id %s, org_id %s.', v_default_expense_code, v_business_id, v_org_id;
    END IF;

    -- Determine the payment account ID based on payment_type
    IF v_payment_type = 'cash'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
        SELECT account_id INTO v_payment_account_id
        FROM public.accounts
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_petty_cash_code AND is_group = FALSE;

        IF v_payment_account_id IS NULL THEN
            RAISE EXCEPTION 'Petty Cash account (Code: %s) not found for business_id %s, org_id %s.', v_petty_cash_code, v_business_id, v_org_id;
        END IF;
    ELSE -- Assume Bank, Card, Transfer, Other map to Cash in Bank
        SELECT account_id INTO v_payment_account_id
        FROM public.accounts
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;

        IF v_payment_account_id IS NULL THEN
            RAISE EXCEPTION 'Cash in Bank - Operating account (Code: %s) not found for business_id %s, org_id %s.', v_cash_in_bank_code, v_business_id, v_org_id;
        END IF;
    END IF;

    -- Generate a reference number if not provided
    IF v_reference_number IS NULL OR v_reference_number = '' THEN
         v_ref_no := 'EXP-' || public.generate_short_id() || '-' || to_char(v_date, 'YYYYMMDD');
    ELSE
        v_ref_no := v_reference_number;
    END IF;

    IF v_expense_id IS NOT NULL THEN
        -- ======== UPDATE PATH ========
        SELECT transaction_id INTO v_existing_txn_id
        FROM public.expenses
        WHERE expense_id = v_expense_id AND business_id = v_business_id;

        IF v_existing_txn_id IS NULL THEN
            RAISE EXCEPTION 'Expense with ID %s not found for business %s, org %s.', v_expense_id, v_business_id, v_org_id;
        END IF;

        v_transaction_id := v_existing_txn_id;

        -- Update Transaction Header
        UPDATE public.transactions
        SET
            reference_no = v_ref_no,
            transaction_date = v_date,
            total_amount = v_amount,
            paid_amount = v_amount,
            due_amount = 0,
            status = 'PAID'::public.transaction_status,
            notes = v_note,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE transaction_id = v_transaction_id
          AND business_id = v_business_id
          AND org_id = v_org_id;

        IF NOT FOUND THEN
             PERFORM 1 FROM public.transactions
             WHERE reference_no = v_ref_no
               AND business_id = v_business_id
               AND org_id = v_org_id
               AND transaction_id != v_transaction_id;
             IF FOUND THEN
                 RAISE EXCEPTION 'Reference number "%" already exists for another transaction in this business/org.', v_ref_no;
             ELSE
                RAISE EXCEPTION 'Failed to update transaction header for ID %s (Transaction not found or org/business mismatch).', v_transaction_id;
             END IF;
        END IF;

        -- Update Expense Details
        UPDATE public.expenses
        SET
            date = v_date,
            payment_type = v_payment_type,
            expense_for = v_expense_for,
            amount = v_amount,
            note = v_note,
            reference_number = v_ref_no,
            expense_category_id = v_expense_category_id,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE expense_id = v_expense_id;

        -- Recreate Transaction Entries
        DELETE FROM public.transaction_entries WHERE transaction_entries.transaction_id = v_transaction_id;

        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_expense_account_id, 'DEBIT'::public.entry_type, v_amount, 'Expense: ' || v_expense_for),
            (v_transaction_id, v_payment_account_id, 'CREDIT'::public.entry_type, v_amount, 'Payment for: ' || v_expense_for);

    ELSE
        -- ======== INSERT PATH ========
        INSERT INTO public.transactions (
            reference_no, transaction_type, transaction_date, status,
            total_amount, paid_amount, due_amount, notes, business_id, org_id, created_by, updated_by
        ) VALUES (
            v_ref_no, 'EXPENSE'::public.transaction_type, v_date, 'PAID'::public.transaction_status,
            v_amount, v_amount, 0, v_note, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id
        ) RETURNING transaction_id INTO v_transaction_id;

        INSERT INTO public.expenses (
            expense_id, -- generate new
            date, payment_type, expense_for, amount, note, reference_number,
            business_id, expense_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_expense_for, v_amount, v_note, v_ref_no,
            v_business_id, v_expense_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
        ) RETURNING expenses.expense_id INTO v_expense_id;

        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_expense_account_id, 'DEBIT'::public.entry_type, v_amount, 'Expense: ' || v_expense_for),
            (v_transaction_id, v_payment_account_id, 'CREDIT'::public.entry_type, v_amount, 'Payment for: ' || v_expense_for);
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RETURN v_expense_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to upsert expense: Unique constraint violated. Check reference number "%s". Detail: %s', v_ref_no, SQLERRM;
    WHEN others THEN
         IF SQLERRM LIKE 'Double-entry imbalance for transaction %' THEN
             RAISE EXCEPTION '%', SQLERRM;
        ELSE
            RAISE EXCEPTION 'Failed to upsert expense for business %s, org %s. Error: %s', v_business_id, v_org_id, SQLERRM;
        END IF;
END;
$$;


ALTER FUNCTION "public"."upsert_expense"("p_expense_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_income"("p_income_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_income_id UUID := p_income_data->>'income_id';
    v_transaction_id UUID;
    v_business_id UUID := p_income_data->>'business_id';
    v_org_id UUID := p_income_data->>'org_id'; -- Assuming org_id is passed
    v_acting_user_id UUID := auth.uid(); -- User performing the action
    v_date TIMESTAMPTZ := (p_income_data->>'date')::timestamptz;
    v_amount NUMERIC := (p_income_data->>'amount')::numeric;
    v_income_account_id UUID; -- Default Income Account (4010)
    v_asset_account_id UUID;  -- Account where money is received (Cash/Bank)
    v_income_for TEXT := p_income_data->>'income_for';
    v_payment_type public.payment_type := (p_income_data->>'payment_type')::public.payment_type;
    v_note TEXT := p_income_data->>'note';
    v_reference_number TEXT := p_income_data->>'reference_number';
    v_income_category_id UUID := (p_income_data->>'income_category_id')::uuid; -- Optional link to user-defined income_categories
    v_existing_txn_id UUID;
    v_ref_no TEXT;

    -- Account Codes (COA v6.4)
    v_default_income_code TEXT := '4010'; -- General Income
    v_petty_cash_code TEXT := '1113';     -- Petty Cash
    v_cash_in_bank_code TEXT := '1111';   -- Cash in Bank - Operating
BEGIN
    -- Validate required fields from JSON
    IF v_business_id IS NULL OR v_org_id IS NULL OR v_date IS NULL OR v_amount IS NULL OR v_amount <= 0 OR v_income_for IS NULL OR v_payment_type IS NULL THEN
        RAISE EXCEPTION 'Missing required income data: business_id, org_id, date, amount > 0, income_for, payment_type are required.';
    END IF;

    IF v_date IS NULL THEN
        v_date := now(); -- Default date if not provided
    END IF;

    -- Fetch the default income account ID
    SELECT account_id INTO v_income_account_id
    FROM public.accounts
    WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_default_income_code AND is_group = FALSE;

    IF v_income_account_id IS NULL THEN
        RAISE EXCEPTION 'General Income account (Code: %s) not found for business_id %s, org_id %s.', v_default_income_code, v_business_id, v_org_id;
    END IF;

    -- Determine the asset account ID based on payment_type
    IF v_payment_type = 'cash'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
        SELECT account_id INTO v_asset_account_id
        FROM public.accounts
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_petty_cash_code AND is_group = FALSE;

        IF v_asset_account_id IS NULL THEN
            RAISE EXCEPTION 'Petty Cash account (Code: %s) not found for business_id %s, org_id %s.', v_petty_cash_code, v_business_id, v_org_id;
        END IF;
    ELSE -- Assume Bank, Card, Transfer, Other map to Cash in Bank
        SELECT account_id INTO v_asset_account_id
        FROM public.accounts
        WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;

        IF v_asset_account_id IS NULL THEN
            RAISE EXCEPTION 'Cash in Bank - Operating account (Code: %s) not found for business_id %s, org_id %s.', v_cash_in_bank_code, v_business_id, v_org_id;
        END IF;
    END IF;

    -- Generate a reference number if not provided
    IF v_reference_number IS NULL OR v_reference_number = '' THEN
         v_ref_no := 'INC-' || public.generate_short_id() || '-' || to_char(v_date, 'YYYYMMDD');
    ELSE
        v_ref_no := v_reference_number;
    END IF;

    IF v_income_id IS NOT NULL THEN
        -- ======== UPDATE PATH ========
        SELECT transaction_id INTO v_existing_txn_id
        FROM public.incomes
        WHERE income_id = v_income_id AND business_id = v_business_id;

        IF v_existing_txn_id IS NULL THEN
            RAISE EXCEPTION 'Income with ID %s not found for business %s, org %s.', v_income_id, v_business_id, v_org_id;
        END IF;

        v_transaction_id := v_existing_txn_id;

        -- Update Transaction Header
        UPDATE public.transactions
        SET
            reference_no = v_ref_no,
            transaction_date = v_date,
            total_amount = v_amount,
            paid_amount = v_amount,
            due_amount = 0,
            status = 'PAID'::public.transaction_status,
            notes = v_note,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE transaction_id = v_transaction_id
          AND business_id = v_business_id
          AND org_id = v_org_id;

        IF NOT FOUND THEN
             -- This check is slightly redundant if the SELECT above found the txn_id,
             -- but can catch concurrent deletions or issues.
             PERFORM 1 FROM public.transactions
             WHERE reference_no = v_ref_no
               AND business_id = v_business_id
               AND org_id = v_org_id
               AND transaction_id != v_transaction_id;
             IF FOUND THEN
                 RAISE EXCEPTION 'Reference number "%" already exists for another transaction in this business/org.', v_ref_no;
             ELSE
                 RAISE EXCEPTION 'Failed to update transaction header for ID %s (Transaction not found or org/business mismatch).', v_transaction_id;
             END IF;
        END IF;

        -- Update Income Details
        UPDATE public.incomes
        SET
            date = v_date,
            payment_type = v_payment_type,
            income_for = v_income_for,
            amount = v_amount,
            note = v_note,
            reference_number = v_ref_no,
            income_category_id = v_income_category_id,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE income_id = v_income_id;

        -- Recreate Transaction Entries
        DELETE FROM public.transaction_entries WHERE transaction_entries.transaction_id = v_transaction_id;

        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_asset_account_id, 'DEBIT'::public.entry_type, v_amount, 'Received income for: ' || v_income_for),
            (v_transaction_id, v_income_account_id, 'CREDIT'::public.entry_type, v_amount, 'Income from: ' || v_income_for);

    ELSE
        -- ======== INSERT PATH ========
        INSERT INTO public.transactions (
            reference_no, transaction_type, transaction_date, status,
            total_amount, paid_amount, due_amount, notes, business_id, org_id, created_by, updated_by
        ) VALUES (
            v_ref_no, 'INCOME'::public.transaction_type, v_date, 'PAID'::public.transaction_status,
            v_amount, v_amount, 0, v_note, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id
        ) RETURNING transaction_id INTO v_transaction_id;

        INSERT INTO public.incomes (
            income_id, -- generate new
            date, payment_type, income_for, amount, note, reference_number,
            business_id, income_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_income_for, v_amount, v_note, v_ref_no,
            v_business_id, v_income_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
        ) RETURNING incomes.income_id INTO v_income_id;

        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_asset_account_id, 'DEBIT'::public.entry_type, v_amount, 'Received income for: ' || v_income_for),
            (v_transaction_id, v_income_account_id, 'CREDIT'::public.entry_type, v_amount, 'Income from: ' || v_income_for);
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RETURN v_income_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to upsert income: Unique constraint violated. Check reference number "%s". Detail: %s', v_ref_no, SQLERRM;
    WHEN others THEN
        IF SQLERRM LIKE 'Double-entry imbalance for transaction %' THEN
             RAISE EXCEPTION '%', SQLERRM;
        ELSE
             RAISE EXCEPTION 'Failed to upsert income for business %s, org %s. Error: %s', v_business_id, v_org_id, SQLERRM;
        END IF;
END;
$$;


ALTER FUNCTION "public"."upsert_income"("p_income_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_item"("item_json" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Extraction
    v_item_id_in              UUID := (item_json->>'item_id')::uuid;
    v_business_id           UUID := (item_json->>'business_id')::uuid;
    v_org_id                UUID := (item_json->>'org_id')::uuid; -- Assuming org_id is passed
    v_name                  TEXT := item_json->>'name';
    v_item_type             public.item_type := (item_json->>'item_type')::public.item_type;
    v_item_category_id      UUID := (item_json->>'item_category_id')::uuid;
    v_brand_id              UUID := (item_json->>'brand_id')::uuid;
    v_tax_id                UUID := (item_json->>'tax_id')::uuid;
    v_preferred_vendor_id   UUID := (item_json->>'preferred_vendor_id')::uuid;
    v_item_code             TEXT := item_json->>'item_code';
    v_unit_id               UUID := (item_json->>'unit_id')::uuid;
    v_sale_price            NUMERIC := COALESCE((item_json->>'sale_price')::numeric, 0);
    v_retail_price          NUMERIC := COALESCE((item_json->>'retail_price')::numeric, 0);
    v_purchase_price        NUMERIC := COALESCE((item_json->>'purchase_price')::numeric, 0);
    v_is_returnable         BOOLEAN := COALESCE((item_json->>'is_returnable')::boolean, false);
    v_is_tax_inclusive         BOOLEAN := COALESCE((item_json->>'is_tax_inclusive')::boolean, true);
    v_alert_quantity        NUMERIC := COALESCE((item_json->>'alert_quantity')::numeric, 0);
    v_quantity              NUMERIC := COALESCE((item_json->>'quantity')::numeric, 0); -- Current actual quantity?
    v_rich_text             JSONB := item_json->'rich_text';
    v_sales_enabled         BOOLEAN := COALESCE((item_json->>'sales_enabled')::boolean, true);
    v_purchase_enabled      BOOLEAN := COALESCE((item_json->>'purchase_enabled')::boolean, true);
    v_inventory_enabled     BOOLEAN := COALESCE((item_json->>'inventory_enabled')::boolean, true);
    v_opening_stock_qty     NUMERIC := COALESCE((item_json->>'opening_stock_qty')::numeric, 0);
    v_opening_stock_value   NUMERIC := COALESCE((item_json->>'opening_stock_value')::numeric, 0); -- Total value of opening stock

    -- Arrays
    v_serial_nos            TEXT[];
    v_images                JSONB[];

    -- Internal Vars
    v_item_id_out           UUID;
    v_is_insert             BOOLEAN := FALSE;
    v_transaction_id        UUID;
    v_ob_ref_no             TEXT;
    v_acting_user_id        UUID := auth.uid(); -- User performing the action

    -- Account IDs & Codes (COA v6.4)
    v_inventory_account_id  UUID;
    v_ob_equity_account_id  UUID;
    v_inventory_code        TEXT := '1130'; -- Inventory Account Code
    v_ob_equity_code        TEXT := '3310'; -- Opening Balance Equity Code

BEGIN
    -- Validate required inputs
    IF v_business_id IS NULL OR v_org_id IS NULL OR v_name IS NULL THEN
        RAISE EXCEPTION 'business_id, org_id, and name are required for an item.';
    END IF;

    -- Extract arrays
    SELECT array_agg(value::text) INTO v_serial_nos FROM jsonb_array_elements_text(COALESCE(item_json->'serial_nos', '[]'::jsonb));
    SELECT array_agg(value::jsonb) INTO v_images FROM jsonb_array_elements(COALESCE(item_json->'images', '[]'::jsonb));

    IF v_item_code IS NULL THEN
        -- Generate item_code if not provided
        SELECT public.get_next_item_code(v_business_id) INTO v_item_code; -- Ensure this function exists and works
        RAISE NOTICE 'Item code not provided, generated: %', v_item_code;
    END IF;

    -- Check item code uniqueness only if it's being set/changed or it's a new item
    IF v_item_id_in IS NULL OR v_item_code != (SELECT items.item_code FROM public.items WHERE items.item_id = v_item_id_in AND items.business_id = v_business_id) THEN
        PERFORM 1 FROM public.items WHERE items.business_id = v_business_id AND items.item_code = v_item_code AND (v_item_id_in IS NULL OR items.item_id != v_item_id_in);
        IF FOUND THEN
            RAISE EXCEPTION 'Item code "%" already exists for business_id %s.', v_item_code, v_business_id;
        END IF;
    END IF;

    -- ==== INSERT or UPDATE ====
    IF v_item_id_in IS NULL THEN
        -- ======== INSERT PATH ========
        v_is_insert := TRUE;

        INSERT INTO public.items (
            item_id, -- generate new UUID
            name, item_type, item_code, item_category_id, brand_id, unit_id,
            sales_enabled, purchase_enabled, inventory_enabled, is_returnable,
            sale_price, retail_price, purchase_price, alert_quantity, preferred_vendor_id,
            tax_id, images, serial_nos, rich_text, quantity, -- `quantity` here is initial quantity
            business_id, org_id,
            stock_quantity, stock_value, -- These should reflect opening stock if provided
            opening_stock_qty, opening_stock_value, -- Store the entered OB values
            created_at, updated_at, created_by, updated_by,
			is_tax_inclusive
        ) VALUES (
            gen_random_uuid(),
            v_name, v_item_type, v_item_code, v_item_category_id, v_brand_id, v_unit_id,
            v_sales_enabled, v_purchase_enabled, v_inventory_enabled, v_is_returnable,
            v_sale_price, v_retail_price, v_purchase_price, v_alert_quantity, v_preferred_vendor_id,
            v_tax_id, v_images, v_serial_nos, v_rich_text, v_quantity, -- Initial quantity is opening stock qty
            v_business_id, v_org_id,
            v_opening_stock_qty, v_opening_stock_value, -- Initial stock quantity & value
            v_opening_stock_qty, v_opening_stock_value, -- Explicitly store OB values
            now(), now(), v_acting_user_id, v_acting_user_id,
			v_is_tax_inclusive
        )
        RETURNING items.item_id INTO v_item_id_out;

        -- Handle subservices on insert
        IF v_item_type = 'services' AND item_json->'sub_services' IS NOT NULL THEN -- Assuming item_type is uppercase in ENUM
            WITH sub_services AS (
                SELECT * FROM jsonb_array_elements(item_json->'sub_services')
            )
            INSERT INTO public.subservices (service_id, name, additional_price, created_by, updated_by)
            SELECT
                v_item_id_out,
                sub_services.value->>'name',
                (sub_services.value->>'additional_price')::numeric,
                v_acting_user_id, v_acting_user_id
            FROM sub_services;
        END IF;
		PERFORM nextval(v_business_id::text || '_item_code');
    ELSE
        -- ======== UPDATE PATH ========
        v_item_id_out := v_item_id_in;
        v_is_insert := FALSE;

        UPDATE public.items SET
            name = v_name,
            item_code = v_item_code,
            item_category_id = v_item_category_id,
            brand_id = v_brand_id,
            unit_id = v_unit_id,
            sales_enabled = v_sales_enabled,
            purchase_enabled = v_purchase_enabled,
            inventory_enabled = v_inventory_enabled, -- Changing this has implications for existing stock
            is_returnable = v_is_returnable,
            sale_price = v_sale_price,
            retail_price = v_retail_price,
            purchase_price = v_purchase_price,
            alert_quantity = v_alert_quantity,
            quantity = v_quantity, -- Generally, 'quantity' (current stock) should only be updated by stock transactions, not directly here on item update.
            preferred_vendor_id = v_preferred_vendor_id,
            tax_id = v_tax_id,
            images = v_images,
            serial_nos = v_serial_nos,
            rich_text = v_rich_text,
            updated_at = now(),
            updated_by = v_acting_user_id,
			is_tax_inclusive = v_is_tax_inclusive
        WHERE items.item_id = v_item_id_out
          AND items.business_id = v_business_id
          AND items.org_id = v_org_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Item ID %s not found for business %s and org %s.', v_item_id_out, v_business_id, v_org_id;
        END IF;

        -- Handle subservice updates
        IF v_item_type = 'services' AND item_json->'sub_services' IS NOT NULL THEN
            -- Delete sub-services not in the new list
            DELETE FROM public.subservices s
            WHERE s.service_id = v_item_id_out
            AND NOT EXISTS (
                SELECT 1
                FROM jsonb_array_elements(item_json->'sub_services') elem
                WHERE elem->>'sub_service_id' IS NOT NULL AND (elem->>'sub_service_id')::uuid = s.sub_service_id
            );

            -- Insert new sub-services
            WITH new_sub_services AS (
                SELECT * FROM jsonb_array_elements(item_json->'sub_services')
                WHERE value->>'sub_service_id' IS NULL
            )
            INSERT INTO public.subservices (service_id, name, additional_price, created_by, updated_by)
            SELECT
                v_item_id_out,
                new_sub_services.value->>'name',
                (new_sub_services.value->>'additional_price')::numeric,
                v_acting_user_id, v_acting_user_id
            FROM new_sub_services;

            -- Update existing sub-services
            UPDATE public.subservices s
            SET
                name = sub.name,
                additional_price = sub.additional_price,
                updated_by = v_acting_user_id,
                updated_at = now()
            FROM (
                SELECT
                    (elem->>'sub_service_id')::uuid as sub_service_id,
                    elem->>'name' as name,
                    (elem->>'additional_price')::numeric as additional_price
                FROM jsonb_array_elements(item_json->'sub_services') elem
                WHERE elem->>'sub_service_id' IS NOT NULL
            ) sub
            WHERE s.sub_service_id = sub.sub_service_id
            AND s.service_id = v_item_id_out;
        END IF;
    END IF; -- End INSERT/UPDATE Check

    -- ==== OPENING BALANCE ACCOUNTING (INSERT ONLY and if inventory_enabled and value > 0) ====
    IF v_is_insert AND v_inventory_enabled AND v_opening_stock_value > 0 THEN -- Only if positive value

        -- Fetch required account IDs for the business and organization
        SELECT account_id INTO v_inventory_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_inventory_code;
        SELECT account_id INTO v_ob_equity_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ob_equity_code;

        -- Validate that accounts exist
        IF v_inventory_account_id IS NULL THEN
             RAISE EXCEPTION 'Inventory account (Code: %s) not found for business %s, org %s.', v_inventory_code, v_business_id, v_org_id;
        END IF;
        IF v_ob_equity_account_id IS NULL THEN
             RAISE EXCEPTION 'Opening Balance Equity account (Code: %s) not found for business %s, org %s.', v_ob_equity_code, v_business_id, v_org_id;
        END IF;

        -- Generate a unique reference number for the opening balance transaction
        v_ob_ref_no := 'OB-ITEM-' || public.generate_short_id() || '-' || v_item_id_out::text; -- Ensure generate_short_id() is robust

        -- Create the Transaction Header
        INSERT INTO public.transactions (
            reference_no, transaction_type, transaction_date, status,
            total_amount, paid_amount, due_amount,
            notes, business_id, org_id, created_by,
            item_id -- Link to item
        ) VALUES (
            v_ob_ref_no, 'OPENING_STOCK'::public.transaction_type, now(), 'PAID'::public.transaction_status,
            v_opening_stock_value, v_opening_stock_value, 0, -- OB is self-balancing, value is positive
            'Opening stock value for item: ' || v_name || ' (' || v_item_code || ')', v_business_id, v_org_id, v_acting_user_id,
            v_item_id_out
        ) RETURNING transaction_id INTO v_transaction_id;

        -- Create Correct Transaction Entries
        -- Debit Inventory (Asset Increase), Credit OB Equity (Offset)
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES
            (v_transaction_id, v_inventory_account_id, 'DEBIT'::public.entry_type, v_opening_stock_value, 'Item opening stock value'),
            (v_transaction_id, v_ob_equity_account_id, 'CREDIT'::public.entry_type, v_opening_stock_value, 'Offset for item opening stock value');

        -- Verify the balance of the opening balance transaction itself
        PERFORM public.verify_transaction_balance(v_transaction_id);

        -- Optionally, update a flag on the items table if you want to mark OB as processed
        -- e.g., ALTER TABLE public.items ADD COLUMN opening_balance_processed BOOLEAN DEFAULT FALSE;
        -- UPDATE public.items SET opening_balance_processed = TRUE WHERE item_id = v_item_id_out;
        -- For now, this is handled by v_is_insert condition.

    ELSIF v_is_insert AND v_inventory_enabled AND v_opening_stock_value < 0 THEN
        RAISE WARNING 'Opening stock value for item %s was provided as negative (%). Opening stock value must be positive. No opening balance transaction created.', v_name, v_opening_stock_value;
    END IF; -- End Opening Balance Accounting

	
    RETURN v_item_id_out;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to upsert item: Unique constraint violated. Possibly item code "%s". Detail: %s', v_item_code, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to upsert item for business %s, org %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."upsert_item"("item_json" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_supplier"("p_supplier_data" "jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Input Data
    v_supplier_id UUID := p_supplier_data->>'supplier_id';
    v_business_id UUID := p_supplier_data->>'business_id';
    v_org_id UUID := p_supplier_data->>'org_id'; -- Assuming org_id is passed
    v_name TEXT := p_supplier_data->>'name';
    v_email TEXT := p_supplier_data->>'email';
    v_phone TEXT := p_supplier_data->>'phone';
    v_address TEXT := p_supplier_data->>'address';
    v_gst_number TEXT := p_supplier_data->>'gst_number';
    v_image TEXT := p_supplier_data->>'image';
    -- Opening balance sign convention for UI input:
    -- Negative value from UI (e.g., -75): Supplier owes business (Supplier Advance)
    -- Positive value from UI (e.g., +200): Business owes supplier (Accounts Payable)
    v_opening_balance NUMERIC := COALESCE((p_supplier_data->>'supplier_balance')::numeric, 0);
    v_opening_balance_date TIMESTAMPTZ := now();

    -- Internal Variables
    v_acting_user_id UUID := auth.uid(); -- User performing the action
    v_is_insert BOOLEAN := FALSE;
    v_transaction_id UUID;
    v_ref_no TEXT;
    v_result_supplier_id UUID;

    -- Account IDs (COA v6.4)
    v_ap_acc_id UUID;           -- Accounts Payable (2110)
    v_supp_adv_acc_id UUID;     -- Supplier Advances / Prepayments (1145)
    v_ob_equity_acc_id UUID;    -- Opening Balance Equity (3310)

    -- Account Codes (COA v6.4)
    v_ap_code TEXT := '2110';
    v_supp_adv_code TEXT := '1145';
    v_ob_equity_code TEXT := '3310';
BEGIN
    -- Validate required inputs
    IF v_business_id IS NULL OR v_org_id IS NULL OR v_name IS NULL OR v_phone IS NULL THEN
        RAISE EXCEPTION 'business_id, org_id, name, and phone are required.';
    END IF;

    -- Handle INSERT or UPDATE
    IF v_supplier_id IS NULL THEN
        -- ======== INSERT PATH ========
        v_is_insert := TRUE;
        INSERT INTO public.suppliers (
            supplier_id, name, email, phone, address, gst_number,
            business_id, org_id, image, created_at, updated_at, created_by, updated_by,
            supplier_balance -- Set initial balance for reference; GL is source of truth
        ) VALUES (
            gen_random_uuid(), v_name, v_email, v_phone, v_address, v_gst_number,
            v_business_id, v_org_id, v_image, now(), now(), v_acting_user_id, v_acting_user_id,
            v_opening_balance
        ) RETURNING suppliers.supplier_id INTO v_result_supplier_id;
    ELSE
        -- ======== UPDATE PATH ========
        v_is_insert := FALSE;
        UPDATE public.suppliers
        SET
            name = v_name,
            email = v_email,
            phone = v_phone,
            address = v_address,
            gst_number = v_gst_number,
            image = v_image,
            updated_at = now(),
            updated_by = v_acting_user_id
            -- supplier_balance is NOT updated here; it's for initial setup or by transaction triggers
        WHERE suppliers.supplier_id = v_supplier_id
          AND suppliers.business_id = v_business_id
          AND suppliers.org_id = v_org_id
        RETURNING suppliers.supplier_id INTO v_result_supplier_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Supplier with ID %s not found for business %s and org %s.', v_supplier_id, v_business_id, v_org_id;
        END IF;
    END IF;

    -- If it was an INSERT AND an opening balance was provided and is non-zero
    IF v_is_insert AND v_opening_balance != 0 THEN

        -- Fetch required account IDs
        SELECT account_id INTO v_ob_equity_acc_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ob_equity_code;
        
        IF v_opening_balance_date IS NULL THEN
            v_opening_balance_date := now(); -- Ensure date is set
        END IF;

        -- Validate that OB Equity account exists
        IF v_ob_equity_acc_id IS NULL THEN
             RAISE EXCEPTION 'Opening Balance Equity account (Code: %s) not found for business %s, org %s.', v_ob_equity_code, v_business_id, v_org_id;
        END IF;
        
        -- Generate a unique reference number
        v_ref_no := 'OB-SUPP-' || public.generate_short_id() || '-' || to_char(v_opening_balance_date, 'YYYYMMDD');

        -- Create the Transaction Header
        INSERT INTO public.transactions (
            reference_no, transaction_type, transaction_date, status,
            total_amount, paid_amount, due_amount,
            notes, business_id, org_id, created_by, supplier_id -- Link to supplier
        ) VALUES (
            v_ref_no, 'SUPPLIER_OPENING_BALANCE'::public.transaction_type, v_opening_balance_date, 'PAID'::public.transaction_status,
            abs(v_opening_balance), abs(v_opening_balance), 0,
            'Opening balance setup for supplier: ' || v_name, v_business_id, v_org_id, v_acting_user_id, v_result_supplier_id
        ) RETURNING transaction_id INTO v_transaction_id;

        -- Create Transaction Entries based on opening balance sign
        IF v_opening_balance < 0 THEN
            -- UI input is Negative (e.g., -75): Supplier owes Business (Prepayment/Credit with Supplier)
            -- DEBIT Supplier Advances (1145), CREDIT OB Equity (3310)
            SELECT account_id INTO v_supp_adv_acc_id FROM public.accounts 
                WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_supp_adv_code;
            IF v_supp_adv_acc_id IS NULL THEN
                 RAISE EXCEPTION 'Supplier Advances / Prepayments account (Code: %s) not found for business %s, org %s.', v_supp_adv_code, v_business_id, v_org_id;
            END IF;

            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
            VALUES
                (v_transaction_id, v_supp_adv_acc_id, 'DEBIT'::public.entry_type, abs(v_opening_balance), 'Supplier opening credit balance (asset)'),
                (v_transaction_id, v_ob_equity_acc_id, 'CREDIT'::public.entry_type, abs(v_opening_balance), 'Offset for supplier opening credit balance');
        ELSE -- v_opening_balance > 0
            -- UI input is Positive (e.g., +200): Business owes Supplier
            -- DEBIT OB Equity (3310), CREDIT Accounts Payable (2110)
            SELECT account_id INTO v_ap_acc_id FROM public.accounts 
                WHERE business_id = v_business_id AND org_id = v_org_id AND code = v_ap_code;
            IF v_ap_acc_id IS NULL THEN
                 RAISE EXCEPTION 'Accounts Payable account (Code: %s) not found for business %s, org %s.', v_ap_code, v_business_id, v_org_id;
            END IF;
            
            INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
            VALUES
                (v_transaction_id, v_ob_equity_acc_id, 'DEBIT'::public.entry_type, v_opening_balance, 'Offset for supplier opening payable balance'),
                (v_transaction_id, v_ap_acc_id, 'CREDIT'::public.entry_type, v_opening_balance, 'Supplier opening payable balance');
        END IF;

        -- Verify the balance of the opening balance transaction itself
        PERFORM public.verify_transaction_balance(v_transaction_id);

        -- The trigger trigger_update_supplier_balance (if it exists and works like customer trigger)
        -- should update suppliers.supplier_balance based on the GL entries.

    END IF; -- End of opening balance handling

    RETURN v_result_supplier_id;

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to upsert supplier OB: Unique constraint violated for ref_no "%" or supplier. Detail: %', v_ref_no, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to upsert supplier for business_id %s, org_id %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$$;


ALTER FUNCTION "public"."upsert_supplier"("p_supplier_data" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_transaction_balance"("p_transaction_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_debit_total NUMERIC := 0;
    v_credit_total NUMERIC := 0;
BEGIN
    -- Calculate totals for the given transaction ID based on current state within the transaction
    SELECT
        COALESCE(SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0 END), 0)
    INTO v_debit_total, v_credit_total
    FROM public.transaction_entries
    WHERE transaction_id = p_transaction_id;

    -- Using a small tolerance might be wise if you ever use floating-point types,
    -- but with NUMERIC, direct comparison should be fine.
    -- IF abs(v_debit_total - v_credit_total) > 0.0001 THEN -- Example with tolerance
    IF v_debit_total != v_credit_total THEN
        RAISE EXCEPTION 'Double-entry imbalance for transaction %: Debits (%) do not equal Credits (%).',
            p_transaction_id, v_debit_total, v_credit_total;
    END IF;

    -- If balanced, simply return
END;
$$;


ALTER FUNCTION "public"."verify_transaction_balance"("p_transaction_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_user_password"("password" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions'
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT id 
    FROM auth.users 
    WHERE id = auth.uid() AND encrypted_password = crypt(password::text, auth.users.encrypted_password)
  );
END;
$$;


ALTER FUNCTION "public"."verify_user_password"("password" "text") OWNER TO "postgres";



SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."account_categories" (
    "category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "code" "text" NOT NULL,
    "description" "text",
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."account_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."accounts" (
    "account_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "code" "text" NOT NULL,
    "description" "text",
    "is_system" boolean DEFAULT false NOT NULL,
    "business_id" "uuid" NOT NULL,
    "org_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "balance" numeric DEFAULT 0 NOT NULL,
    "is_group" boolean DEFAULT false NOT NULL,
    "parent_account_id" "uuid"
);


ALTER TABLE "public"."accounts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."addon_prices" (
    "addon_price_id" integer NOT NULL,
    "addon_id" integer NOT NULL,
    "country_code" character varying(2) NOT NULL,
    "currency_code" character varying(3) NOT NULL,
    "price_monthly" numeric(10,2),
    "price_annual" numeric(10,2),
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "price_one_time" numeric
);


ALTER TABLE "public"."addon_prices" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."addon_prices_addon_price_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."addon_prices_addon_price_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."addon_prices_addon_price_id_seq" OWNED BY "public"."addon_prices"."addon_price_id";



CREATE TABLE IF NOT EXISTS "public"."addons" (
    "addon_id" integer NOT NULL,
    "name" character varying(150) NOT NULL,
    "slug" character varying(150) NOT NULL,
    "description" "text",
    "addon_type" "public"."addon_type_enum" DEFAULT 'limit_increase'::"public"."addon_type_enum" NOT NULL,
    "linked_feature_id" integer,
    "unit_name" character varying(50) DEFAULT 'unit'::character varying,
    "default_price_monthly" numeric(10,2),
    "default_price_annual" numeric(10,2),
    "default_currency" character varying(3),
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "default_price_one_time" numeric
);


ALTER TABLE "public"."addons" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."addons_addon_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."addons_addon_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."addons_addon_id_seq" OWNED BY "public"."addons"."addon_id";


CREATE TABLE IF NOT EXISTS "public"."brands" (
    "brand_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "org_id" "uuid",
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."brands" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."business_customers" (
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "image" "text",
    "address" "text",
    "updated_at" timestamp with time zone,
    "customer_balance" numeric DEFAULT '0'::numeric NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "updated_by" "uuid"
);


ALTER TABLE "public"."business_customers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customers" (
    "customer_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "image" "text"
);


ALTER TABLE "public"."customers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text",
    "phone" "text",
    "image" "text"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."business_customer_view" AS
 SELECT "bc"."business_id",
    "c"."customer_id",
    "bc"."name",
    "u"."email",
    "u"."phone",
    "bc"."address",
    "bc"."image",
    "bc"."customer_balance",
    "bc"."is_active",
    "bc"."created_at"
   FROM (("public"."business_customers" "bc"
     JOIN "public"."customers" "c" ON (("bc"."customer_id" = "c"."customer_id")))
     JOIN "public"."users" "u" ON (("c"."customer_id" = "u"."user_id")));


ALTER TABLE "public"."business_customer_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."businesses" (
    "business_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "org_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "subscription_status" "public"."subscription_status" DEFAULT 'inactive'::"public"."subscription_status" NOT NULL,
    "last_active_at" timestamp with time zone,
    "contact_email" "text",
    "contact_phone" "text",
    "contact_address" "text",
    "currency" "jsonb",
    "logo" "text",
    "images" "text"[],
    "store_name" "text",
    "gst_in" "text",
    "state" "text",
    "country" "text",
    "time_zone" "text",
    "fiscal_id" "uuid" DEFAULT '00000000-0000-0000-0000-000000000002'::"uuid" NOT NULL,
    "is_gst_registered" boolean,
    "legal_business_name" "text",
    "gst_registered_date" "date",
    "trade_name" "text",
    "print_on_sale" boolean DEFAULT true NOT NULL,
    "print_on_purchase" boolean DEFAULT true NOT NULL,
    "allow_walkin_customer" boolean DEFAULT true NOT NULL,
    "allow_sales_when_outofstock" boolean DEFAULT true NOT NULL,
    "business_type" "public"."business_types" DEFAULT 'others'::"public"."business_types" NOT NULL,
    "print_barcode_on_purchase" boolean,
    "format" "text" DEFAULT 'roll57'::"text" NOT NULL
);


ALTER TABLE "public"."businesses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "state_id" integer
);


ALTER TABLE "public"."cities" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."cities_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."cities_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."cities_id_seq" OWNED BY "public"."cities"."id";


CREATE TABLE IF NOT EXISTS "public"."countries" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "emoji" character varying(8),
    "emoji_u" character varying(30),
    "iso_code" character(2) NOT NULL,
    "currency" character(3)
);


ALTER TABLE "public"."countries" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."countries_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."countries_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."countries_id_seq" OWNED BY "public"."countries"."id";



CREATE TABLE IF NOT EXISTS "public"."credit_note_items" (
    "credit_note_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "credit_note_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_credit_note_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_credit_note_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."credit_note_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."credit_notes" (
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "credit_note_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invoice_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "billing_address" "uuid",
    "shipping_address" "uuid",
    "credit_note_date" "date",
    "notes" "text",
    "terms_and_conditions" "text",
    "tax_total" numeric,
    "sub_total" numeric,
    "discount_amount" numeric,
    "shipping_charges" numeric,
    "grand_total" numeric,
    "status" "public"."credit_note_status" DEFAULT 'open'::"public"."credit_note_status",
    "due_date" "date",
    "credit_note_code" "text" NOT NULL,
    "reference" "text",
    "reason" "text",
    "credit_remaining" numeric,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."credit_notes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."customer_addresses" (
    "customer_addresses_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "customer_id" "uuid",
    "first_name" "text",
    "last_name" "text",
    "company_name" "text",
    "address" "text",
    "country" "text",
    "state" "text",
    "city" "text",
    "zipcode" "text",
    "email" "text",
    "phone" "text",
    "is_default" boolean
);


ALTER TABLE "public"."customer_addresses" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."employee_view" AS
SELECT
    NULL::"uuid" AS "employee_id",
    NULL::"text" AS "code",
    NULL::"uuid" AS "org_id",
    NULL::"text" AS "name",
    NULL::"text" AS "email",
    NULL::"text" AS "phone",
    NULL::"public"."employee_type" AS "role",
    NULL::"text" AS "image",
    NULL::timestamp with time zone AS "created_at",
    NULL::"uuid"[] AS "business_ids",
    NULL::"uuid"[] AS "employee_role_ids",
    NULL::"json" AS "employee_roles",
    NULL::"uuid" AS "business_id";


ALTER TABLE "public"."employee_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."invoice_items" (
    "invoice_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "invoice_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_invoice_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_invoice_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."invoice_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."invoices" (
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "invoice_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "billing_address" "uuid" DEFAULT "gen_random_uuid"(),
    "shipping_address" "uuid" DEFAULT "gen_random_uuid"(),
    "invoice_date" "date",
    "notes" "text",
    "terms_and_conditions" "text",
    "tax_total" numeric,
    "sub_total" numeric,
    "discount_amount" numeric,
    "shipping_charges" numeric,
    "grand_total" numeric,
    "status" "text",
    "quote_id" "uuid",
    "due_date" "date",
    "invoice_code" "text" NOT NULL,
    "amount_paid" numeric DEFAULT 0 NOT NULL,
    "credit_applied" numeric DEFAULT 0 NOT NULL,
    "balance_due" numeric GENERATED ALWAYS AS ((("grand_total" - "amount_paid") - "credit_applied")) STORED
);


ALTER TABLE "public"."invoices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."item_categories" (
    "item_category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "org_id" "uuid",
    "description" "text",
    "icon_info" "jsonb"
);


ALTER TABLE "public"."item_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."item_custom_field_definitions" (
    "field_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "field_name" "text" NOT NULL,
    "field_type" "public"."custom_field_type" NOT NULL,
    "is_required" boolean DEFAULT false NOT NULL,
    "default_value" "text",
    "validation_rules" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."item_custom_field_definitions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."item_custom_field_values" (
    "item_id" "uuid" NOT NULL,
    "field_id" "uuid" NOT NULL,
    "field_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."item_custom_field_values" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."items" (
    "item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "item_type" "public"."item_type" NOT NULL,
    "item_code" "text",
    "item_category_id" "uuid",
    "brand_id" "uuid",
    "unit_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "sales_enabled" boolean DEFAULT true NOT NULL,
    "purchase_enabled" boolean DEFAULT true NOT NULL,
    "retail_price" numeric DEFAULT '0'::numeric,
    "sale_price" numeric DEFAULT '0'::numeric NOT NULL,
    "purchase_price" numeric DEFAULT '0'::numeric,
    "business_id" "uuid" NOT NULL,
    "org_id" "uuid" NOT NULL,
    "stock_value" numeric DEFAULT '0'::numeric NOT NULL,
    "stock_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "branch_variant_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "serial_nos" "text"[],
    "tax_id" "uuid",
    "is_returnable" boolean DEFAULT false NOT NULL,
    "images" "jsonb"[],
    "alert_quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "preferred_vendor_id" "uuid",
    "inventory_enabled" boolean DEFAULT true NOT NULL,
    "rich_text" "jsonb",
    "quantity" numeric DEFAULT '0'::numeric NOT NULL,
    "updated_at" timestamp with time zone,
    "opening_stock_qty" numeric DEFAULT '0'::numeric NOT NULL,
    "opening_stock_value" numeric DEFAULT '0'::numeric NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "is_tax_inclusive" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subservices" (
    "sub_service_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "service_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "additional_price" numeric NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."subservices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."suppliers" (
    "supplier_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text",
    "phone" "text" NOT NULL,
    "address" "text",
    "gst_number" "text",
    "business_id" "uuid" NOT NULL,
    "org_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "image" "text",
    "updated_at" timestamp with time zone,
    "supplier_balance" numeric DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "public"."suppliers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."taxes" (
    "tax_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "rate" double precision NOT NULL,
    "org_id" "uuid",
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type" "text"
);


ALTER TABLE "public"."taxes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."units" (
    "unit_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "short_name" "text",
    "business_id" "uuid" NOT NULL,
    "org_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."units" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_items" AS
 WITH "custom_fields_agg" AS (
         SELECT "cfv"."item_id",
            "jsonb_object_agg"("cfd"."field_name", "jsonb_build_object"('value', "cfv"."field_value", 'type', "cfd"."field_type", 'required', COALESCE((("cfd"."validation_rules" ->> 'required'::"text"))::boolean, false))) AS "custom_fields"
           FROM ("public"."item_custom_field_values" "cfv"
             JOIN "public"."item_custom_field_definitions" "cfd" ON (("cfd"."field_id" = "cfv"."field_id")))
          GROUP BY "cfv"."item_id"
        ), "sub_services_agg" AS (
         SELECT "s_1"."service_id" AS "item_id",
            "jsonb_agg"("jsonb_build_object"('sub_service_id', "s_1"."sub_service_id", 'name', "s_1"."name", 'additional_price', "s_1"."additional_price")) AS "sub_services"
           FROM "public"."subservices" "s_1"
          GROUP BY "s_1"."service_id"
        )
 SELECT "i"."item_id",
    "i"."name",
    "i"."item_type",
    "i"."item_code",
    "i"."sales_enabled",
    "i"."purchase_enabled",
    "i"."retail_price",
    "i"."sale_price",
    "i"."purchase_price",
    "i"."stock_value",
    "i"."stock_quantity",
    "i"."alert_quantity",
    "i"."inventory_enabled",
    "i"."quantity",
        CASE
            WHEN ("i"."stock_quantity" > "i"."alert_quantity") THEN 'In Stock'::"text"
            WHEN ("i"."stock_quantity" = (0)::numeric) THEN 'Out of Stock'::"text"
            ELSE 'Low Stock'::"text"
        END AS "stock_status",
        CASE
            WHEN ("ic"."item_category_id" IS NOT NULL) THEN "jsonb_build_object"('item_category_id', "ic"."item_category_id", 'name', "ic"."name", 'description', "ic"."description", 'business_id', "ic"."business_id", 'org_id', "ic"."org_id", 'created_at', "ic"."created_at", 'icon_info', "ic"."icon_info")
            ELSE NULL::"jsonb"
        END AS "item_category",
        CASE
            WHEN ("b"."brand_id" IS NOT NULL) THEN "jsonb_build_object"('brand_id', "b"."brand_id", 'name', "b"."name", 'description', "b"."description", 'org_id', "b"."org_id", 'business_id', "b"."business_id", 'created_at', "b"."created_at")
            ELSE NULL::"jsonb"
        END AS "brand",
        CASE
            WHEN ("u"."unit_id" IS NOT NULL) THEN "jsonb_build_object"('unit_id', "u"."unit_id", 'name', "u"."name", 'short_name', "u"."short_name", 'business_id', "u"."business_id", 'org_id', "u"."org_id", 'created_at', "u"."created_at")
            ELSE NULL::"jsonb"
        END AS "unit",
        CASE
            WHEN ("t"."tax_id" IS NOT NULL) THEN "jsonb_build_object"('tax_id', "t"."tax_id", 'name', "t"."name", 'rate', "t"."rate", 'org_id', "t"."org_id", 'business_id', "t"."business_id", 'created_at', "t"."created_at")
            ELSE NULL::"jsonb"
        END AS "tax",
        CASE
            WHEN ("s"."supplier_id" IS NOT NULL) THEN "jsonb_build_object"('supplier_id', "s"."supplier_id", 'name', "s"."name", 'email', "s"."email", 'phone', "s"."phone", 'address', "s"."address", 'gst_number', "s"."gst_number", 'business_id', "s"."business_id", 'org_id', "s"."org_id", 'supplier_balance', "s"."supplier_balance", 'created_at', "s"."created_at")
            ELSE NULL::"jsonb"
        END AS "preferred_vendor",
    "i"."business_id",
    "i"."org_id",
    "i"."is_returnable",
    "i"."serial_nos",
    "i"."rich_text",
    "i"."images",
    "i"."branch_variant_id",
    COALESCE("cfa"."custom_fields", '{}'::"jsonb") AS "custom_fields",
    COALESCE("ssa"."sub_services", '[]'::"jsonb") AS "sub_services",
    "i"."created_at",
    (EXISTS ( SELECT 1
           FROM "public"."item_custom_field_values" "cfv2"
          WHERE ("cfv2"."item_id" = "i"."item_id"))) AS "has_custom_fields",
    "i"."opening_stock_qty",
    "i"."opening_stock_value",
    "i"."item_category_id",
    "i"."is_active",
    "i"."is_tax_inclusive"
   FROM ((((((("public"."items" "i"
     LEFT JOIN "public"."item_categories" "ic" ON (("i"."item_category_id" = "ic"."item_category_id")))
     LEFT JOIN "public"."brands" "b" ON (("i"."brand_id" = "b"."brand_id")))
     LEFT JOIN "public"."units" "u" ON (("i"."unit_id" = "u"."unit_id")))
     LEFT JOIN "public"."taxes" "t" ON (("i"."tax_id" = "t"."tax_id")))
     LEFT JOIN "public"."suppliers" "s" ON (("i"."preferred_vendor_id" = "s"."supplier_id")))
     LEFT JOIN "custom_fields_agg" "cfa" ON (("i"."item_id" = "cfa"."item_id")))
     LEFT JOIN "sub_services_agg" "ssa" ON (("i"."item_id" = "ssa"."item_id")));


ALTER TABLE "public"."vw_items" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."invoice_details_view" AS
 SELECT DISTINCT ON ("i"."invoice_id") "i"."invoice_id",
    "i"."business_id",
    "i"."customer_id",
    "i"."quote_id",
    "i"."created_at" AS "invoice_created_at",
    "i"."created_by",
    "i"."billing_address" AS "billing_address_id",
    "i"."shipping_address" AS "shipping_address_id",
    "i"."invoice_date",
    "i"."due_date",
    "i"."notes" AS "invoice_notes",
    "i"."terms_and_conditions" AS "invoice_terms_and_conditions",
    "i"."tax_total",
    "i"."sub_total",
    "i"."discount_amount",
    "i"."shipping_charges",
    "i"."grand_total",
    "i"."status" AS "invoice_status",
    "i"."invoice_code",
    ("row_to_json"("b".*))::"jsonb" AS "business",
    ("row_to_json"("bcv".*))::"jsonb" AS "customer",
    ("row_to_json"("emp".*))::"jsonb" AS "employee",
    ("row_to_json"("ba".*))::"jsonb" AS "billing_address_details",
    ("row_to_json"("sa".*))::"jsonb" AS "shipping_address_details",
    ( SELECT COALESCE("jsonb_agg"("jsonb_build_object"('invoice_item_id', "ii"."invoice_item_id", 'item_id', "ii"."item_id", 'quantity', "ii"."quantity", 'unit_price', "ii"."unit_price", 'total_price', "ii"."total_price", 'created_at', "ii"."created_at", 'updated_at', "ii"."updated_at", 'item', ("row_to_json"("item_details".*))::"jsonb") ORDER BY "ii"."created_at"), '[]'::"jsonb") AS "coalesce"
           FROM ("public"."invoice_items" "ii"
             LEFT JOIN "public"."vw_items" "item_details" ON (("ii"."item_id" = "item_details"."item_id")))
          WHERE ("ii"."invoice_id" = "i"."invoice_id")) AS "invoice_items",
    "i"."credit_applied",
    "i"."amount_paid",
    "i"."balance_due"
   FROM ((((("public"."invoices" "i"
     LEFT JOIN "public"."businesses" "b" ON (("i"."business_id" = "b"."business_id")))
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("i"."customer_id" = "bcv"."customer_id") AND ("i"."business_id" = "bcv"."business_id"))))
     LEFT JOIN "public"."employee_view" "emp" ON (("i"."created_by" = "emp"."employee_id")))
     LEFT JOIN "public"."customer_addresses" "ba" ON (("i"."billing_address" = "ba"."customer_addresses_id")))
     LEFT JOIN "public"."customer_addresses" "sa" ON (("i"."shipping_address" = "sa"."customer_addresses_id")))
  ORDER BY "i"."invoice_id", "i"."created_at" DESC;


ALTER TABLE "public"."invoice_details_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."refund_payments" (
    "refund_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "invoice_id" "uuid",
    "is_credit_note" boolean NOT NULL,
    "amount_refunded" numeric NOT NULL,
    "refund_date" "date" NOT NULL,
    "payment_mode" "public"."payment_type" NOT NULL,
    "deposited_to" "text" NOT NULL,
    "reference_number" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "refund_status" "public"."payment_recieved",
    "source_payment_id" "uuid",
    "source_credit_note_id" "uuid",
    CONSTRAINT "chk_refund_amount_positive" CHECK (("amount_refunded" >= (0)::numeric)),
    CONSTRAINT "chk_refund_source_is_exclusive" CHECK (((("source_payment_id" IS NOT NULL) AND ("source_credit_note_id" IS NULL)) OR (("source_payment_id" IS NULL) AND ("source_credit_note_id" IS NOT NULL)) OR (("source_payment_id" IS NULL) AND ("source_credit_note_id" IS NULL))))
);


ALTER TABLE "public"."refund_payments" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."credit_note_details_view" AS
 WITH "credit_note_items_agg" AS (
         SELECT "cni"."credit_note_id",
            COALESCE("jsonb_agg"("jsonb_build_object"('item_id', "cni"."item_id", 'quantity', "cni"."quantity", 'unit_price', "cni"."unit_price", 'total_price', ("cni"."quantity" * "cni"."unit_price"), 'item', ("row_to_json"("item_details".*))::"jsonb")), '[]'::"jsonb") AS "items"
           FROM ("public"."credit_note_items" "cni"
             LEFT JOIN "public"."vw_items" "item_details" ON (("cni"."item_id" = "item_details"."item_id")))
          GROUP BY "cni"."credit_note_id"
        ), "credit_note_refunds" AS (
         SELECT "rp"."business_id",
            "rp"."customer_id",
            "rp"."source_credit_note_id" AS "credit_note_id",
            "sum"("rp"."amount_refunded") AS "total_amount_refunded",
            "jsonb_agg"("row_to_json"("rp".*)) AS "refund_details"
           FROM "public"."refund_payments" "rp"
          WHERE ("rp"."source_credit_note_id" IS NOT NULL)
          GROUP BY "rp"."business_id", "rp"."customer_id", "rp"."source_credit_note_id"
        )
 SELECT DISTINCT ON ("cn"."credit_note_id") "cn"."business_id",
    "cn"."customer_id",
    "cn"."credit_note_id",
    "cn"."invoice_id",
    "cn"."created_at",
    "cn"."created_by",
    "cn"."billing_address",
    "cn"."shipping_address",
    "cn"."credit_note_date",
    "cn"."notes",
    "cn"."terms_and_conditions",
    "cn"."tax_total",
    "cn"."sub_total",
    "cn"."discount_amount",
    "cn"."shipping_charges",
    "cn"."grand_total",
    "cn"."status",
    "cn"."due_date",
    "cn"."credit_note_code",
    "cn"."reference",
    "cn"."reason",
    ("row_to_json"("b".*))::"jsonb" AS "business",
    ("row_to_json"("bcv".*))::"jsonb" AS "customer",
    ("row_to_json"("emp".*))::"jsonb" AS "employee",
    ("row_to_json"("idv".*))::"jsonb" AS "invoice_details",
    "cnia"."items" AS "credit_note_items",
    COALESCE("cnr"."total_amount_refunded", (0)::numeric) AS "amount_refunded",
    COALESCE("cnr"."refund_details", '[]'::"jsonb") AS "refund_details",
    "cn"."credit_remaining",
    "cn"."updated_at"
   FROM (((((("public"."credit_notes" "cn"
     LEFT JOIN "public"."businesses" "b" ON (("cn"."business_id" = "b"."business_id")))
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("cn"."customer_id" = "bcv"."customer_id") AND ("cn"."business_id" = "bcv"."business_id"))))
     LEFT JOIN "public"."employee_view" "emp" ON (("cn"."created_by" = "emp"."employee_id")))
     LEFT JOIN "credit_note_items_agg" "cnia" ON (("cn"."credit_note_id" = "cnia"."credit_note_id")))
     LEFT JOIN "public"."invoice_details_view" "idv" ON (("cn"."invoice_id" = "idv"."invoice_id")))
     LEFT JOIN "credit_note_refunds" "cnr" ON (("cn"."credit_note_id" = "cnr"."credit_note_id")))
  ORDER BY "cn"."credit_note_id", "cn"."created_at" DESC, "cn"."updated_at" DESC;


ALTER TABLE "public"."credit_note_details_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."credit_notes_list_view" AS
 SELECT "cn"."credit_note_id",
    "cn"."business_id",
    "cn"."customer_id",
    "cn"."credit_note_code",
    COALESCE("bcv"."name", 'N/A'::"text") AS "customer_name",
    "i"."invoice_code" AS "linked_invoice_code",
    "cn"."status",
    "cn"."grand_total" AS "amount",
    "cn"."credit_note_date",
    "cn"."created_at",
    "i"."invoice_id"
   FROM (("public"."credit_notes" "cn"
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("cn"."customer_id" = "bcv"."customer_id") AND ("cn"."business_id" = "bcv"."business_id"))))
     LEFT JOIN "public"."invoices" "i" ON (("cn"."invoice_id" = "i"."invoice_id")));


ALTER TABLE "public"."credit_notes_list_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."customer_view" AS
 SELECT "c"."customer_id",
    "c"."name",
    "u"."email",
    "u"."phone",
    "c"."image",
    COALESCE("jsonb_agg"("jsonb_build_object"('first_name', "ca"."first_name", 'last_name', "ca"."last_name", 'company_name', "ca"."company_name", 'email', "ca"."email", 'phone', "ca"."phone", 'customer_addresses_id', "ca"."customer_addresses_id", 'address', "ca"."address", 'country', "ca"."country", 'state', "ca"."state", 'city', "ca"."city", 'zipcode', "ca"."zipcode", 'is_default', "ca"."is_default", 'created_at', "ca"."created_at")) FILTER (WHERE ("ca"."customer_addresses_id" IS NOT NULL)), '[]'::"jsonb") AS "addresses"
   FROM (("public"."customers" "c"
     JOIN "public"."users" "u" ON (("c"."customer_id" = "u"."user_id")))
     LEFT JOIN "public"."customer_addresses" "ca" ON (("c"."customer_id" = "ca"."customer_id")))
  GROUP BY "c"."customer_id", "c"."name", "u"."email", "u"."phone", "c"."image";


ALTER TABLE "public"."customer_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."expense_categories" (
    "category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "icon_info" "json",
    "name" "text" NOT NULL,
    "description" "text"
);


ALTER TABLE "public"."expense_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "expense_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "date" timestamp with time zone NOT NULL,
    "payment_type" "public"."payment_type" NOT NULL,
    "expense_for" "text" NOT NULL,
    "amount" numeric NOT NULL,
    "note" "text",
    "reference_number" "text",
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expense_category_id" "uuid",
    "transaction_id" "uuid",
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_at" timestamp with time zone DEFAULT ("now"() AT TIME ZONE 'utc'::"text")
);


ALTER TABLE "public"."expenses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."income_categories" (
    "category_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "icon_info" "json",
    "name" "text" NOT NULL,
    "description" "text"
);


ALTER TABLE "public"."income_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."incomes" (
    "income_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "date" timestamp with time zone NOT NULL,
    "payment_type" "public"."payment_type" NOT NULL,
    "income_for" "text" NOT NULL,
    "amount" numeric NOT NULL,
    "note" "text",
    "reference_number" "text",
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "income_category_id" "uuid",
    "transaction_id" "uuid",
    "status" "text" DEFAULT 'ACTIVE'::"text",
    "updated_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_at" timestamp with time zone DEFAULT ("now"() AT TIME ZONE 'utc'::"text"),
    "created_by" "uuid"
);


ALTER TABLE "public"."incomes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments" (
    "payment_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "payment_date" timestamp with time zone NOT NULL,
    "amount" numeric NOT NULL,
    "payment_method" "text" NOT NULL,
    "reference_no" "text",
    "notes" "text",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb",
    "updated_by" "uuid"
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchase_returns" (
    "return_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "purchase_id" "uuid" NOT NULL,
    "return_invoice" "text" NOT NULL,
    "return_date" timestamp with time zone NOT NULL,
    "reason" "text",
    "notes" "text",
    "total_amount" numeric DEFAULT 0 NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."purchase_returns" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchases" (
    "purchase_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "invoice_no" "text" NOT NULL,
    "supplier_id" "uuid" NOT NULL,
    "purchase_date" timestamp with time zone NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "subtotal" numeric DEFAULT 0 NOT NULL,
    "discount_amount" numeric DEFAULT 0 NOT NULL,
    "tax_amount" numeric DEFAULT 0 NOT NULL,
    "shipping_charge" numeric DEFAULT 0 NOT NULL,
    "total_amount" numeric DEFAULT 0 NOT NULL,
    "paid_amount" numeric DEFAULT 0 NOT NULL,
    "due_amount" numeric DEFAULT 0 NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "notes" "text",
    "attachment_url" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "purchase_invoice" "text",
    "updated_by" "uuid"
);


ALTER TABLE "public"."purchases" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_returns" (
    "return_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sale_id" "uuid" NOT NULL,
    "return_invoice" "text" NOT NULL,
    "return_date" timestamp with time zone NOT NULL,
    "reason" "text",
    "notes" "text",
    "total_amount" numeric DEFAULT 0 NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sale_returns" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sales" (
    "sale_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" "uuid",
    "sale_date" timestamp with time zone NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "subtotal" numeric DEFAULT 0 NOT NULL,
    "discount_amount" numeric DEFAULT 0 NOT NULL,
    "tax_amount" numeric DEFAULT 0 NOT NULL,
    "shipping_charge" numeric DEFAULT 0 NOT NULL,
    "total_amount" numeric DEFAULT 0 NOT NULL,
    "paid_amount" numeric DEFAULT 0 NOT NULL,
    "due_amount" numeric DEFAULT 0 NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "notes" "text",
    "attachment_url" "text",
    "metadata" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "sale_invoice" "text",
    "status_id" "uuid" NOT NULL,
    "order_mode" boolean DEFAULT false NOT NULL,
    "platform" "text" DEFAULT 'Duxbe'::"text",
    "billing_address" "jsonb",
    "shipping_address" "jsonb",
    "updated_by" "uuid",
    "table_id" "uuid"
);


ALTER TABLE "public"."sales" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transactions" (
    "transaction_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reference_no" "text" NOT NULL,
    "transaction_type" "public"."transaction_type" NOT NULL,
    "transaction_date" timestamp with time zone NOT NULL,
    "due_date" timestamp with time zone,
    "status" "public"."transaction_status" DEFAULT 'PENDING'::"public"."transaction_status" NOT NULL,
    "total_amount" numeric DEFAULT 0 NOT NULL,
    "paid_amount" numeric DEFAULT 0 NOT NULL,
    "due_amount" numeric DEFAULT 0 NOT NULL,
    "notes" "text",
    "business_id" "uuid" NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb",
    "customer_id" "uuid",
    "supplier_id" "uuid",
    "reverses_transaction_id" "uuid",
    "item_id" "uuid",
    "org_id" "uuid" NOT NULL,
    "updated_by" "uuid"
);


ALTER TABLE "public"."transactions" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."daily_transactions_report" AS
 WITH RECURSIVE "dates" AS (
         SELECT "min"("payments"."payment_date") AS "date",
            "max"("payments"."payment_date") AS "max_date"
           FROM "public"."payments"
          WHERE ("payments"."payment_date" IS NOT NULL)
        UNION ALL
         SELECT ("dates"."date" + '1 day'::interval) AS "timestamptz",
            "dates"."max_date"
           FROM "dates"
          WHERE (("dates"."date" + '1 day'::interval) <= "dates"."max_date")
        ), "daily_payments" AS (
         SELECT "p"."payment_date" AS "date",
            COALESCE(
                CASE
                    WHEN ("s"."sale_id" IS NOT NULL) THEN "bc"."name"
                    WHEN ("sr"."return_id" IS NOT NULL) THEN "bc_return"."name"
                    WHEN ("pur"."purchase_id" IS NOT NULL) THEN "sup"."name"
                    WHEN ("pr"."return_id" IS NOT NULL) THEN "sup_return"."name"
                    WHEN ("inc"."income_id" IS NOT NULL) THEN 'Income'::"text"
                    WHEN ("exp"."expense_id" IS NOT NULL) THEN 'Expense'::"text"
                    ELSE 'Other'::"text"
                END, 'Walk-in Customer'::"text") AS "name",
                CASE
                    WHEN ("s"."sale_id" IS NOT NULL) THEN 'Sale Payment'::"text"
                    WHEN ("sr"."return_id" IS NOT NULL) THEN 'Sale Return'::"text"
                    WHEN ("pur"."purchase_id" IS NOT NULL) THEN 'Purchase Payment'::"text"
                    WHEN ("pr"."return_id" IS NOT NULL) THEN 'Purchase Return'::"text"
                    WHEN ("inc"."income_id" IS NOT NULL) THEN ('Income - '::"text" || COALESCE("ic"."name", 'Other'::"text"))
                    WHEN ("exp"."expense_id" IS NOT NULL) THEN ('Expense - '::"text" || COALESCE("ec"."name", 'Other'::"text"))
                    ELSE ("t"."transaction_type")::"text"
                END AS "type",
            "t"."total_amount" AS "total",
                CASE
                    WHEN (("s"."sale_id" IS NOT NULL) OR ("inc"."income_id" IS NOT NULL) OR ("pr"."return_id" IS NOT NULL)) THEN "p"."amount"
                    ELSE NULL::numeric
                END AS "payment_in",
                CASE
                    WHEN (("pur"."purchase_id" IS NOT NULL) OR ("exp"."expense_id" IS NOT NULL) OR ("sr"."return_id" IS NOT NULL)) THEN "p"."amount"
                    ELSE NULL::numeric
                END AS "payment_out",
            "p"."payment_method",
            "t"."transaction_id",
            COALESCE("s"."business_id", "sr"."business_id", "pur"."business_id", "pr"."business_id", "inc"."business_id", "exp"."business_id") AS "business_id",
            "p"."payment_id",
            "p"."reference_no",
                CASE
                    WHEN ("s"."sale_id" IS NOT NULL) THEN 'sale'::"text"
                    WHEN ("sr"."return_id" IS NOT NULL) THEN 'sale_return'::"text"
                    WHEN ("pur"."purchase_id" IS NOT NULL) THEN 'purchase'::"text"
                    WHEN ("pr"."return_id" IS NOT NULL) THEN 'purchase_return'::"text"
                    WHEN ("inc"."income_id" IS NOT NULL) THEN 'income'::"text"
                    WHEN ("exp"."expense_id" IS NOT NULL) THEN 'expense'::"text"
                    ELSE 'other'::"text"
                END AS "transaction_category"
           FROM ((((((((((((((("public"."payments" "p"
             JOIN "public"."transactions" "t" ON (("t"."transaction_id" = "p"."transaction_id")))
             LEFT JOIN "public"."sales" "s" ON (("s"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."business_customers" "bc" ON ((("bc"."customer_id" = "s"."customer_id") AND ("bc"."business_id" = "s"."business_id"))))
             LEFT JOIN "public"."sale_returns" "sr" ON (("sr"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."sales" "s_return" ON (("s_return"."sale_id" = "sr"."sale_id")))
             LEFT JOIN "public"."business_customers" "bc_return" ON ((("bc_return"."customer_id" = "s_return"."customer_id") AND ("bc_return"."business_id" = "sr"."business_id"))))
             LEFT JOIN "public"."purchases" "pur" ON (("pur"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."suppliers" "sup" ON (("sup"."supplier_id" = "pur"."supplier_id")))
             LEFT JOIN "public"."purchase_returns" "pr" ON (("pr"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."purchases" "p_return" ON (("p_return"."purchase_id" = "pr"."purchase_id")))
             LEFT JOIN "public"."suppliers" "sup_return" ON (("sup_return"."supplier_id" = "p_return"."supplier_id")))
             LEFT JOIN "public"."incomes" "inc" ON (("inc"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."income_categories" "ic" ON (("ic"."category_id" = "inc"."income_category_id")))
             LEFT JOIN "public"."expenses" "exp" ON (("exp"."transaction_id" = "t"."transaction_id")))
             LEFT JOIN "public"."expense_categories" "ec" ON (("ec"."category_id" = "exp"."expense_category_id")))
          WHERE ("p"."payment_date" IS NOT NULL)
        ), "running_balance" AS (
         SELECT "dp"."date",
            "dp"."name",
            "dp"."type",
            "dp"."total",
            "dp"."payment_in",
            "dp"."payment_out",
            "dp"."payment_method",
            "dp"."reference_no",
            "dp"."transaction_category",
            "dp"."business_id",
            "dp"."payment_id",
            "dp"."transaction_id",
            "sum"((COALESCE("dp"."payment_in", (0)::numeric) - COALESCE("dp"."payment_out", (0)::numeric))) OVER (PARTITION BY "dp"."business_id" ORDER BY "dp"."date", "dp"."payment_id") AS "balance"
           FROM "daily_payments" "dp"
          WHERE ("dp"."date" IS NOT NULL)
        )
 SELECT "running_balance"."date",
    "running_balance"."name",
    "running_balance"."type",
    "running_balance"."total",
    "running_balance"."payment_in",
    "running_balance"."payment_out",
    "running_balance"."payment_method",
    "running_balance"."reference_no",
    "running_balance"."transaction_category",
    "running_balance"."business_id",
    "running_balance"."payment_id",
    "running_balance"."transaction_id",
    "running_balance"."balance"
   FROM "running_balance"
  WHERE ("running_balance"."business_id" IS NOT NULL)
  ORDER BY "running_balance"."date", "running_balance"."transaction_id", "running_balance"."payment_id";


ALTER TABLE "public"."daily_transactions_report" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employee_branch_access" (
    "employee_id" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."employee_branch_access" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."employee_branches_view" AS
 SELECT "e"."employee_id",
    "e"."business_id",
    "b"."name"
   FROM ("public"."employee_branch_access" "e"
     JOIN "public"."businesses" "b" ON (("e"."business_id" = "b"."business_id")));


ALTER TABLE "public"."employee_branches_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employee_roles" (
    "employee_role_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "business_id" "uuid",
    "name" "text" NOT NULL,
    "description" "text",
    "editable" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."employee_roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employees" (
    "employee_id" "uuid" NOT NULL,
    "code" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "org_id" "uuid" NOT NULL,
    "role" "public"."employee_type" DEFAULT 'admin'::"public"."employee_type" NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "image" "text"
);


ALTER TABLE "public"."employees" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."expense_view" WITH ("security_invoker"='on') AS
 SELECT "i"."expense_id",
    "i"."date",
    "i"."payment_type",
    "i"."expense_for",
    "i"."amount",
    "i"."note",
    "i"."reference_number",
    "i"."business_id",
    "i"."created_at",
    "i"."expense_category_id",
    "i"."transaction_id",
    "i"."status",
    ( SELECT "row_to_json"("ic".*) AS "row_to_json"
           FROM "public"."expense_categories" "ic"
          WHERE ("ic"."category_id" = "i"."expense_category_id")) AS "category"
   FROM "public"."expenses" "i";


ALTER TABLE "public"."expense_view" OWNER TO "postgres";



CREATE TABLE IF NOT EXISTS "public"."features" (
    "feature_id" integer NOT NULL,
    "name" character varying(255) NOT NULL,
    "slug" character varying(255) NOT NULL,
    "description" "text",
    "feature_type" "public"."feature_type_enum" DEFAULT 'boolean'::"public"."feature_type_enum" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."features" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."features_feature_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."features_feature_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."features_feature_id_seq" OWNED BY "public"."features"."feature_id";



CREATE TABLE IF NOT EXISTS "public"."fiscal_years" (
    "fiscal_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "start_month" integer NOT NULL,
    "end_month" integer NOT NULL
);


ALTER TABLE "public"."fiscal_years" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."floor" (
    "floor_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."floor" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."income_view" WITH ("security_invoker"='on') AS
 SELECT "i"."income_id",
    "i"."date",
    "i"."payment_type",
    "i"."income_for",
    "i"."amount",
    "i"."note",
    "i"."reference_number",
    "i"."business_id",
    "i"."created_at",
    "i"."income_category_id",
    "i"."transaction_id",
    "i"."status",
    ( SELECT "row_to_json"("ic".*) AS "row_to_json"
           FROM "public"."income_categories" "ic"
          WHERE ("ic"."category_id" = "i"."income_category_id")) AS "category"
   FROM "public"."incomes" "i";


ALTER TABLE "public"."income_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."invoice_view" AS
 SELECT "i"."invoice_id",
    "i"."business_id",
    "i"."customer_id",
    "i"."invoice_code",
    COALESCE("bcv"."name", 'N/A'::"text") AS "customer_name",
    "i"."status" AS "invoice_status",
    "i"."grand_total" AS "amount",
    "i"."invoice_date",
    "i"."due_date",
    "i"."created_at"
   FROM ("public"."invoices" "i"
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("i"."customer_id" = "bcv"."customer_id") AND ("i"."business_id" = "bcv"."business_id"))));


ALTER TABLE "public"."invoice_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."ledger_parties" AS
 WITH "customer_transactions" AS (
         SELECT "bc"."customer_id" AS "id",
            "bc"."business_id",
            "sum"("s"."total_amount") AS "total_amount",
            "bc"."customer_balance" AS "due_amount"
           FROM ("public"."business_customers" "bc"
             LEFT JOIN "public"."sales" "s" ON ((("s"."customer_id" = "bc"."customer_id") AND ("s"."business_id" = "bc"."business_id"))))
          GROUP BY "bc"."customer_id", "bc"."business_id", "bc"."customer_balance"
        ), "supplier_transactions" AS (
         SELECT "s"."supplier_id" AS "id",
            "s"."business_id",
            "sum"("p"."total_amount") AS "total_amount",
            "s"."supplier_balance" AS "due_amount"
           FROM ("public"."suppliers" "s"
             LEFT JOIN "public"."purchases" "p" ON ((("p"."supplier_id" = "s"."supplier_id") AND ("p"."business_id" = "s"."business_id"))))
          GROUP BY "s"."supplier_id", "s"."business_id", "s"."supplier_balance"
        )
 SELECT "bc"."customer_id" AS "id",
    "bc"."business_id",
    'customer'::"text" AS "type",
    COALESCE("ct"."total_amount", (0)::numeric) AS "amount",
    "bc"."name",
    COALESCE("bc"."customer_balance", (0)::numeric) AS "due_amount"
   FROM ("public"."business_customers" "bc"
     LEFT JOIN "customer_transactions" "ct" ON ((("ct"."id" = "bc"."customer_id") AND ("ct"."business_id" = "bc"."business_id"))))
UNION ALL
 SELECT "s"."supplier_id" AS "id",
    "s"."business_id",
    'supplier'::"text" AS "type",
    COALESCE("st"."total_amount", (0)::numeric) AS "amount",
    "s"."name",
    COALESCE("s"."supplier_balance", (0)::numeric) AS "due_amount"
   FROM ("public"."suppliers" "s"
     LEFT JOIN "supplier_transactions" "st" ON ((("st"."id" = "s"."supplier_id") AND ("st"."business_id" = "s"."business_id"))));


ALTER TABLE "public"."ledger_parties" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."links" (
    "link_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "url" "text" NOT NULL,
    "module_id" bigint NOT NULL,
    "visibility" boolean DEFAULT true NOT NULL,
    "sort_order" smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE "public"."links" OWNER TO "postgres";


ALTER TABLE "public"."links" ALTER COLUMN "link_id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."links_link_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."modules" (
    "module_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "url" "text" NOT NULL,
    "sort_order" smallint DEFAULT '0'::smallint NOT NULL
);


ALTER TABLE "public"."modules" OWNER TO "postgres";


ALTER TABLE "public"."modules" ALTER COLUMN "module_id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."modules_module_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."organizations" (
    "org_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trial_activated" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."organizations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."plans" (
    "plan_id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "slug" character varying(100) NOT NULL,
    "description" "text",
    "default_price_monthly" numeric(10,2),
    "default_price_annual" numeric(10,2),
    "default_currency" character varying(3) DEFAULT 'INR'::character varying,
    "trial_period_days" integer,
    "is_active" boolean DEFAULT true NOT NULL,
    "display_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscriptions" (
    "subscription_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "org_id" "uuid" NOT NULL,
    "plan_id" integer,
    "status" "public"."subscription_status_enum" NOT NULL,
    "start_date" "date",
    "end_date" "date",
    "trial_end_date" "date",
    "cancel_at_period_end" boolean DEFAULT false NOT NULL,
    "canceled_at" timestamp with time zone,
    "payment_provider_subscription_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "addon_id" integer,
    "payment_provider_customer_id" "text",
    "payment_provider" "text",
    "payment_provider_plan_id" "text",
    "billing_cycle" "public"."billing_cycle_enum" DEFAULT 'annually'::"public"."billing_cycle_enum" NOT NULL,
    "currency" "text",
    "current_end" "date",
    "current_start" "date",
    "metadata" "jsonb",
    "payment_url" "text",
    "plan_amount" numeric,
    "quantity" integer DEFAULT 1 NOT NULL,
    "tax_amount" numeric,
    "total_invoice_amount" numeric,
    CONSTRAINT "plan_or_addon_required" CHECK ((("plan_id" IS NOT NULL) OR ("addon_id" IS NOT NULL)))
);


ALTER TABLE "public"."subscriptions" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."org_details_view" AS
 WITH "ranked_subscriptions" AS (
         SELECT "s"."org_id",
            "s"."subscription_id",
            "s"."plan_id",
            "s"."status",
            "s"."start_date",
            "s"."end_date",
            "s"."trial_end_date",
            "s"."cancel_at_period_end",
            "s"."canceled_at",
            "s"."payment_provider_subscription_id",
            "s"."created_at",
            "s"."updated_at",
            "s"."addon_id",
            "s"."payment_provider_customer_id",
            "s"."payment_provider",
            "s"."payment_provider_plan_id",
            "s"."current_start",
            "s"."current_end",
            "s"."payment_url",
            "s"."currency",
            "s"."plan_amount",
            "s"."total_invoice_amount",
            "s"."metadata",
            "s"."billing_cycle",
            "s"."tax_amount",
            "row_number"() OVER (PARTITION BY "s"."org_id" ORDER BY
                CASE "s"."status"
                    WHEN 'active'::"public"."subscription_status_enum" THEN 1
                    WHEN 'trialing'::"public"."subscription_status_enum" THEN 2
                    WHEN 'past_due'::"public"."subscription_status_enum" THEN 3
                    ELSE 4
                END, "s"."start_date" DESC, "s"."created_at" DESC) AS "rn"
           FROM "public"."subscriptions" "s"
          WHERE (("s"."status" = ANY (ARRAY['trialing'::"public"."subscription_status_enum", 'active'::"public"."subscription_status_enum", 'past_due'::"public"."subscription_status_enum"])) AND ("s"."plan_id" IS NOT NULL))
        )
 SELECT "o"."org_id",
    "o"."name",
    "o"."created_by",
    "o"."created_at",
    "sub"."active_subscription_details",
    "active_addons"."active_addons_list",
    "biz"."businesses_list",
    "o"."trial_activated"
   FROM ((("public"."organizations" "o"
     LEFT JOIN LATERAL ( SELECT "jsonb_build_object"('subscription_id', "rs"."subscription_id", 'plan_id', "rs"."plan_id", 'addon_id', "rs"."addon_id", 'status', "rs"."status", 'start_date', "rs"."start_date", 'end_date', "rs"."end_date", 'trial_end_date', "rs"."trial_end_date", 'cancel_at_period_end', "rs"."cancel_at_period_end", 'canceled_at', "rs"."canceled_at", 'payment_provider_subscription_id', "rs"."payment_provider_subscription_id", 'created_at', "rs"."created_at", 'updated_at', "rs"."updated_at", 'payment_provider_customer_id', "rs"."payment_provider_customer_id", 'payment_provider', "rs"."payment_provider", 'payment_provider_plan_id', "rs"."payment_provider_plan_id", 'current_start', "rs"."current_start", 'current_end', "rs"."current_end", 'payment_url', "rs"."payment_url", 'currency', "rs"."currency", 'plan_amount', "rs"."plan_amount", 'total_invoice_amount', "rs"."total_invoice_amount", 'tax_amount', "rs"."tax_amount", 'billing_cycle', "rs"."billing_cycle", 'metadata', "rs"."metadata", 'plan_details',
                CASE
                    WHEN ("p"."plan_id" IS NOT NULL) THEN "to_jsonb"("p".*)
                    ELSE NULL::"jsonb"
                END, 'addon_details_on_plan_sub',
                CASE
                    WHEN ("a"."addon_id" IS NOT NULL) THEN "to_jsonb"("a".*)
                    ELSE NULL::"jsonb"
                END) AS "active_subscription_details"
           FROM (("ranked_subscriptions" "rs"
             LEFT JOIN "public"."plans" "p" ON (("rs"."plan_id" = "p"."plan_id")))
             LEFT JOIN "public"."addons" "a" ON (("rs"."addon_id" = "a"."addon_id")))
          WHERE (("rs"."org_id" = "o"."org_id") AND ("rs"."rn" = 1))) "sub" ON (true))
     LEFT JOIN LATERAL ( SELECT COALESCE("jsonb_agg"("jsonb_build_object"('subscription_id', "s_addon"."subscription_id", 'addon_id', "s_addon"."addon_id", 'status', "s_addon"."status", 'start_date', "s_addon"."start_date", 'end_date', "s_addon"."end_date", 'trial_end_date', "s_addon"."trial_end_date", 'cancel_at_period_end', "s_addon"."cancel_at_period_end", 'canceled_at', "s_addon"."canceled_at", 'payment_provider_subscription_id', "s_addon"."payment_provider_subscription_id", 'payment_provider_customer_id', "s_addon"."payment_provider_customer_id", 'payment_provider', "s_addon"."payment_provider", 'payment_provider_plan_id', "s_addon"."payment_provider_plan_id", 'current_start', "s_addon"."current_start", 'current_end', "s_addon"."current_end", 'payment_url', "s_addon"."payment_url", 'currency', "s_addon"."currency", 'subscribed_amount', "s_addon"."plan_amount", 'total_invoice_amount', "s_addon"."total_invoice_amount", 'tax_amount', "s_addon"."tax_amount", 'billing_cycle', "s_addon"."billing_cycle", 'metadata', "s_addon"."metadata", 'created_at', "s_addon"."created_at", 'updated_at', "s_addon"."updated_at", 'addon_details', "to_jsonb"("a".*)) ORDER BY "s_addon"."created_at" DESC), '[]'::"jsonb") AS "active_addons_list"
           FROM ("public"."subscriptions" "s_addon"
             JOIN "public"."addons" "a" ON (("s_addon"."addon_id" = "a"."addon_id")))
          WHERE (("s_addon"."org_id" = "o"."org_id") AND ("s_addon"."addon_id" IS NOT NULL) AND ("s_addon"."plan_id" IS NULL) AND ("s_addon"."status" = ANY (ARRAY['trialing'::"public"."subscription_status_enum", 'active'::"public"."subscription_status_enum", 'past_due'::"public"."subscription_status_enum"])))) "active_addons" ON (true))
     LEFT JOIN LATERAL ( SELECT COALESCE("jsonb_agg"("to_jsonb"("b_details".*) ORDER BY "b_details"."created_at"), '[]'::"jsonb") AS "businesses_list"
           FROM ( SELECT "b"."business_id",
                    "b"."name",
                    "b"."org_id",
                    "b"."created_at",
                    "b"."created_by",
                    "b"."subscription_status",
                    "b"."last_active_at",
                    "b"."contact_email",
                    "b"."contact_phone",
                    "b"."contact_address",
                    "b"."currency",
                    "b"."logo",
                    "b"."images",
                    "b"."store_name",
                    "b"."gst_in",
                    "b"."state",
                    "b"."country",
                    "b"."time_zone",
                    "b"."fiscal_id",
                    "b"."is_gst_registered",
                    "b"."legal_business_name",
                    "b"."gst_registered_date",
                    "b"."trade_name",
                    "b"."print_on_sale",
                    "b"."print_on_purchase",
                    "b"."allow_walkin_customer",
                    "b"."allow_sales_when_outofstock",
                    "b"."business_type",
                    "b"."print_barcode_on_purchase",
                    "b"."format"
                   FROM "public"."businesses" "b"
                  WHERE ("b"."org_id" = "o"."org_id")) "b_details") "biz" ON (true));


ALTER TABLE "public"."org_details_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."payments_received" (
    "payment_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "invoice_id" "uuid",
    "payment_code" "text" NOT NULL,
    "amount_received" numeric NOT NULL,
    "payment_date" "date" NOT NULL,
    "payment_mode" "public"."payment_type" NOT NULL,
    "deposited_to" "text" NOT NULL,
    "reference_number" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "payment_status" "public"."payment_recieved",
    "amount_refunded" numeric DEFAULT 0 NOT NULL,
    CONSTRAINT "chk_payments_received_amount_positive" CHECK (("amount_received" >= (0)::numeric))
);


ALTER TABLE "public"."payments_received" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."payment_details_view" AS
 SELECT DISTINCT ON ("p"."payment_id") "p"."payment_id",
    "p"."business_id",
    "p"."customer_id",
    "p"."invoice_id",
    "p"."payment_code",
    "p"."amount_received",
    "p"."payment_date",
    "p"."payment_mode",
    "p"."deposited_to",
    "p"."reference_number",
    "p"."notes" AS "payment_notes",
    "p"."created_at" AS "payment_created_at",
    "p"."created_by",
    ("row_to_json"("b".*))::"jsonb" AS "business",
    ("row_to_json"("bcv".*))::"jsonb" AS "customer",
    ("row_to_json"("emp".*))::"jsonb" AS "employee",
    ("row_to_json"("idv".*))::"jsonb" AS "invoice_details",
    "p"."payment_status"
   FROM (((("public"."payments_received" "p"
     LEFT JOIN "public"."businesses" "b" ON (("p"."business_id" = "b"."business_id")))
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("p"."customer_id" = "bcv"."customer_id") AND ("p"."business_id" = "bcv"."business_id"))))
     LEFT JOIN "public"."employee_view" "emp" ON (("p"."created_by" = "emp"."employee_id")))
     LEFT JOIN "public"."invoice_details_view" "idv" ON (("p"."invoice_id" = "idv"."invoice_id")))
  ORDER BY "p"."payment_id", "p"."created_at" DESC;


ALTER TABLE "public"."payment_details_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."permissions" (
    "permission_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "employee_role_id" "uuid" NOT NULL,
    "module_id" bigint,
    "link_id" bigint,
    "view" boolean DEFAULT false NOT NULL,
    "create" boolean DEFAULT false NOT NULL,
    "edit" boolean DEFAULT false NOT NULL,
    "delete" boolean DEFAULT false NOT NULL,
    "print" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."plan_features" (
    "plan_feature_id" integer NOT NULL,
    "plan_id" integer NOT NULL,
    "feature_id" integer NOT NULL,
    "is_enabled" boolean DEFAULT false NOT NULL,
    "limit_value" bigint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."plan_features" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."plan_features_plan_feature_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."plan_features_plan_feature_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."plan_features_plan_feature_id_seq" OWNED BY "public"."plan_features"."plan_feature_id";



CREATE TABLE IF NOT EXISTS "public"."plan_prices" (
    "plan_price_id" integer NOT NULL,
    "plan_id" integer NOT NULL,
    "country_code" character varying(2) NOT NULL,
    "currency_code" character varying(3) NOT NULL,
    "price_monthly" numeric(10,2) NOT NULL,
    "price_annual" numeric(10,2) NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."plan_prices" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."plan_prices_plan_price_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."plan_prices_plan_price_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."plan_prices_plan_price_id_seq" OWNED BY "public"."plan_prices"."plan_price_id";



CREATE SEQUENCE IF NOT EXISTS "public"."plans_plan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."plans_plan_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."plans_plan_id_seq" OWNED BY "public"."plans"."plan_id";



CREATE TABLE IF NOT EXISTS "public"."processed_webhook_events" (
    "event_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."processed_webhook_events" OWNER TO "postgres";


COMMENT ON TABLE "public"."processed_webhook_events" IS 'Stores Razorpay webhook event IDs to prevent duplicate processing.';



CREATE TABLE IF NOT EXISTS "public"."purchase_audits" (
    "audit_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "purchase_id" "uuid" NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "action_type" "public"."purchase_audit_action" NOT NULL,
    "action_timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "performed_by" "uuid" NOT NULL,
    "old_data" "jsonb",
    "new_data" "jsonb",
    "change_details" "text",
    "ip_address" "text",
    "user_agent" "text"
);


ALTER TABLE "public"."purchase_audits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchase_custom_field_definitions" (
    "field_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "field_name" "text" NOT NULL,
    "field_type" "public"."custom_field_type" NOT NULL,
    "is_required" boolean DEFAULT false NOT NULL,
    "default_value" "text",
    "validation_rules" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."purchase_custom_field_definitions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchase_custom_field_values" (
    "purchase_id" "uuid" NOT NULL,
    "field_id" "uuid" NOT NULL,
    "field_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."purchase_custom_field_values" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchase_items" (
    "purchase_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "purchase_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "public"."purchase_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."purchase_return_items" (
    "return_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "return_id" "uuid" NOT NULL,
    "purchase_item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_return_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_return_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."purchase_return_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transaction_entries" (
    "entry_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "account_id" "uuid" NOT NULL,
    "entry_type" "public"."entry_type" NOT NULL,
    "amount" numeric NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    "updated_at" timestamp with time zone DEFAULT ("now"() AT TIME ZONE 'utc'::"text")
);


ALTER TABLE "public"."transaction_entries" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."purchase_view" AS
 SELECT "p"."purchase_id",
    "p"."purchase_invoice",
    "p"."invoice_no",
    "p"."supplier_id",
    "p"."purchase_date",
    "p"."transaction_id",
    "p"."subtotal",
    "p"."discount_amount",
    "p"."tax_amount",
    "p"."shipping_charge",
    "p"."total_amount",
    "p"."paid_amount",
    "p"."due_amount",
    "p"."business_id",
    "p"."created_by",
    "p"."notes",
    "p"."attachment_url",
    "p"."metadata",
    "p"."created_at",
    "p"."updated_at",
    ("row_to_json"("s".*))::"jsonb" AS "supplier",
    ("row_to_json"("t".*))::"jsonb" AS "transaction",
    (( SELECT "json_agg"("json_build_object"('entry', "row_to_json"("te".*), 'account', "row_to_json"("a".*))) AS "json_agg"
           FROM ("public"."transaction_entries" "te"
             LEFT JOIN "public"."accounts" "a" ON (("te"."account_id" = "a"."account_id")))
          WHERE ("te"."transaction_id" = "t"."transaction_id")))::"jsonb" AS "transaction_entries",
    (( SELECT "json_agg"("row_to_json"("pe".*)) AS "json_agg"
           FROM "public"."payments" "pe"
          WHERE ("pe"."transaction_id" = "t"."transaction_id")))::"jsonb" AS "payments",
    (( SELECT "json_agg"((("row_to_json"("pi".*))::"jsonb" || "jsonb_build_object"('item', "row_to_json"("i".*)))) AS "json_agg"
           FROM ("public"."purchase_items" "pi"
             JOIN "public"."vw_items" "i" ON (("pi"."item_id" = "i"."item_id")))
          WHERE ("pi"."purchase_id" = "p"."purchase_id")))::"jsonb" AS "purchase_items",
    ("row_to_json"("emp".*))::"jsonb" AS "employee"
   FROM ((("public"."purchases" "p"
     LEFT JOIN "public"."transactions" "t" ON (("p"."transaction_id" = "t"."transaction_id")))
     LEFT JOIN "public"."suppliers" "s" ON (("p"."supplier_id" = "s"."supplier_id")))
     LEFT JOIN "public"."employee_view" "emp" ON (("p"."created_by" = "emp"."employee_id")));


ALTER TABLE "public"."purchase_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."quote_items" (
    "quote_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "quote_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_quote_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_quote_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."quote_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."quotes" (
    "business_id" "uuid" NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "quote_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "billing_address" "uuid" DEFAULT "gen_random_uuid"(),
    "shipping_address" "uuid" DEFAULT "gen_random_uuid"(),
    "quote_date" "date",
    "valid_until_date" "date",
    "notes" "text",
    "terms_and_conditions" "text",
    "tax_total" numeric,
    "sub_total" numeric,
    "discount_amount" numeric,
    "shipping_charges" numeric,
    "grand_total" numeric,
    "status" "text",
    "quote_code" "text" NOT NULL
);


ALTER TABLE "public"."quotes" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."quote_details_view" AS
 SELECT DISTINCT ON ("q"."quote_id") "q"."quote_id",
    "q"."business_id",
    "q"."customer_id",
    "q"."created_at" AS "quote_created_at",
    "q"."created_by",
    "q"."billing_address" AS "billing_address_id",
    "q"."shipping_address" AS "shipping_address_id",
    "q"."quote_date",
    "q"."valid_until_date",
    "q"."notes" AS "quote_notes",
    "q"."terms_and_conditions" AS "quote_terms_and_conditions",
    "q"."tax_total",
    "q"."sub_total",
    "q"."discount_amount",
    "q"."shipping_charges",
    "q"."grand_total",
    "q"."status" AS "quote_status",
    "q"."quote_code",
    ("row_to_json"("b".*))::"jsonb" AS "business",
    ("row_to_json"("bcv".*))::"jsonb" AS "customer",
    ("row_to_json"("emp".*))::"jsonb" AS "employee",
    ("row_to_json"("ba".*))::"jsonb" AS "billing_address_details",
    ("row_to_json"("sa".*))::"jsonb" AS "shipping_address_details",
    ( SELECT COALESCE("jsonb_agg"("jsonb_build_object"('quote_item_id', "qi"."quote_item_id", 'item_id', "qi"."item_id", 'quantity', "qi"."quantity", 'unit_price', "qi"."unit_price", 'total_price', "qi"."total_price", 'created_at', "qi"."created_at", 'updated_at', "qi"."updated_at", 'item', ("row_to_json"("i".*))::"jsonb") ORDER BY "qi"."created_at"), '[]'::"jsonb") AS "coalesce"
           FROM ("public"."quote_items" "qi"
             JOIN "public"."vw_items" "i" ON (("qi"."item_id" = "i"."item_id")))
          WHERE (("qi"."business_id" = "q"."business_id") AND ("qi"."customer_id" = "q"."customer_id") AND ("qi"."quote_id" = "q"."quote_id"))) AS "quote_items"
   FROM ((((("public"."quotes" "q"
     LEFT JOIN "public"."businesses" "b" ON (("q"."business_id" = "b"."business_id")))
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("q"."customer_id" = "bcv"."customer_id") AND ("q"."business_id" = "bcv"."business_id"))))
     LEFT JOIN "public"."employee_view" "emp" ON (("q"."created_by" = "emp"."employee_id")))
     LEFT JOIN "public"."customer_addresses" "ba" ON (("q"."billing_address" = "ba"."customer_addresses_id")))
     LEFT JOIN "public"."customer_addresses" "sa" ON (("q"."shipping_address" = "sa"."customer_addresses_id")))
  ORDER BY "q"."quote_id", "q"."created_at" DESC;


ALTER TABLE "public"."quote_details_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."quote_view" AS
 SELECT "q"."quote_id",
    "q"."business_id",
    "q"."customer_id",
    "q"."quote_code",
    COALESCE("bcv"."name", 'N/A'::"text") AS "customer_name",
    "q"."status" AS "quote_status",
    "q"."grand_total" AS "amount",
    "q"."quote_date",
    "q"."valid_until_date",
    "q"."created_at"
   FROM ("public"."quotes" "q"
     LEFT JOIN "public"."business_customer_view" "bcv" ON ((("q"."customer_id" = "bcv"."customer_id") AND ("q"."business_id" = "bcv"."business_id"))));


ALTER TABLE "public"."quote_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."razorpay_addons" (
    "razorpay_addon_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "addon_id" integer NOT NULL,
    "billing_cycle" "public"."billing_cycle_enum" NOT NULL
);


ALTER TABLE "public"."razorpay_addons" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."razorpay_plans" (
    "razorpay_plan_id" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "plan_id" integer NOT NULL,
    "billing_cycle" "public"."billing_cycle_enum" NOT NULL
);


ALTER TABLE "public"."razorpay_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."referrals" (
    "referral_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reseller_id" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "referred_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."referrals" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."reseller_referred_businesses" AS
 SELECT "r"."reseller_id",
    "b"."business_id",
    "b"."name",
    "b"."contact_email",
    "b"."contact_phone",
    "b"."contact_address",
    "b"."subscription_status",
    "b"."last_active_at"
   FROM ("public"."referrals" "r"
     JOIN "public"."businesses" "b" ON (("r"."business_id" = "b"."business_id")));


ALTER TABLE "public"."reseller_referred_businesses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."resellers" (
    "reseller_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "email" "text" NOT NULL,
    "phone" "text" NOT NULL,
    "address" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."resellers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles_of_employees" (
    "employee_role_id" "uuid" NOT NULL,
    "employee_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."roles_of_employees" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_audits" (
    "audit_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sale_id" "uuid" NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "action_type" "public"."sale_audit_action" NOT NULL,
    "action_timestamp" timestamp with time zone DEFAULT "now"() NOT NULL,
    "performed_by" "uuid" NOT NULL,
    "old_data" "jsonb",
    "new_data" "jsonb",
    "change_details" "text",
    "ip_address" "text",
    "user_agent" "text"
);


ALTER TABLE "public"."sale_audits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_custom_field_definitions" (
    "field_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "field_name" "text" NOT NULL,
    "field_type" "public"."custom_field_type" NOT NULL,
    "is_required" boolean DEFAULT false NOT NULL,
    "default_value" "text",
    "validation_rules" "jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sale_custom_field_definitions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_custom_field_values" (
    "sale_id" "uuid" NOT NULL,
    "field_id" "uuid" NOT NULL,
    "field_value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sale_custom_field_values" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_item_subservices" (
    "sale_item_subservice_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sale_item_id" "uuid" NOT NULL,
    "sub_service_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 1 NOT NULL,
    "additional_price" numeric DEFAULT 0 NOT NULL,
    "total_additional_price" numeric GENERATED ALWAYS AS (("quantity" * "additional_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "chk_sale_item_subservices_additional_price_positive" CHECK (("additional_price" >= (0)::numeric)),
    CONSTRAINT "chk_sale_item_subservices_quantity_positive" CHECK (("quantity" >= (0)::numeric))
);


ALTER TABLE "public"."sale_item_subservices" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_items" (
    "sale_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "sale_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "chk_sale_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_sale_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."sale_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sale_return_items" (
    "return_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "return_id" "uuid" NOT NULL,
    "sale_item_id" "uuid" NOT NULL,
    "quantity" numeric DEFAULT 0 NOT NULL,
    "unit_price" numeric DEFAULT 0 NOT NULL,
    "total_price" numeric GENERATED ALWAYS AS (("quantity" * "unit_price")) STORED,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chk_return_items_quantity_positive" CHECK (("quantity" >= (0)::numeric)),
    CONSTRAINT "chk_return_items_unit_price_positive" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."sale_return_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."statuses" (
    "status_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "sequence_order" integer NOT NULL,
    "moving_order" integer,
    "is_default" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "type" "public"."status_type" NOT NULL,
    "is_editable" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."statuses" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."sale_view" AS
 SELECT DISTINCT ON ("s"."sale_id") "s"."sale_id",
    "s"."sale_invoice",
    "s"."customer_id",
    "s"."sale_date",
    "s"."transaction_id",
    "s"."subtotal",
    "s"."discount_amount",
    "s"."tax_amount",
    "s"."shipping_charge",
    "s"."total_amount",
    "s"."paid_amount",
    "s"."due_amount",
    "s"."business_id",
    "s"."created_by",
    "s"."notes",
    "s"."attachment_url",
    "s"."metadata",
    "s"."created_at",
    "s"."updated_at",
    ("row_to_json"("c".*))::"jsonb" AS "customer",
    ("row_to_json"("t".*))::"jsonb" AS "transaction",
    ( SELECT ("json_agg"("json_build_object"('entry', "row_to_json"("te".*), 'account', "row_to_json"("a".*))))::"jsonb" AS "json_agg"
           FROM ("public"."transaction_entries" "te"
             LEFT JOIN "public"."accounts" "a" ON (("te"."account_id" = "a"."account_id")))
          WHERE ("te"."transaction_id" = "t"."transaction_id")) AS "transaction_entries",
    ( SELECT (COALESCE("json_agg"("row_to_json"("pe".*)), '[]'::"json"))::"jsonb" AS "coalesce"
           FROM "public"."payments" "pe"
          WHERE ("pe"."transaction_id" = "t"."transaction_id")) AS "payments",
    ( SELECT ("json_agg"("json_build_object"('sale_item_id', "si"."sale_item_id", 'item_id', "si"."item_id", 'quantity', "si"."quantity", 'unit_price', "si"."unit_price", 'total_price', "si"."total_price", 'subservices', ( SELECT COALESCE("json_agg"("json_build_object"('sale_item_subservice_id', "sis"."sale_item_subservice_id", 'sub_service_id', "sis"."sub_service_id", 'quantity', "sis"."quantity", 'additional_price', "sis"."additional_price", 'total_additional_price', "sis"."total_additional_price", 'name', "ss"."name")), '[]'::"json") AS "coalesce"
                   FROM ("public"."sale_item_subservices" "sis"
                     JOIN "public"."subservices" "ss" ON (("sis"."sub_service_id" = "ss"."sub_service_id")))
                  WHERE ("sis"."sale_item_id" = "si"."sale_item_id")), 'item', "row_to_json"("i".*))))::"jsonb" AS "json_agg"
           FROM ("public"."sale_items" "si"
             JOIN "public"."vw_items" "i" ON (("si"."item_id" = "i"."item_id")))
          WHERE ("si"."sale_id" = "s"."sale_id")) AS "sale_items",
    ("row_to_json"("emp".*))::"jsonb" AS "employee",
    "s"."order_mode",
    "s"."status_id",
    ("row_to_json"("st".*))::"jsonb" AS "status",
    ("row_to_json"("b".*))::"jsonb" AS "business",
    "s"."platform",
    "s"."billing_address",
    "s"."shipping_address"
   FROM ((((("public"."sales" "s"
     LEFT JOIN "public"."transactions" "t" ON (("s"."transaction_id" = "t"."transaction_id")))
     LEFT JOIN "public"."statuses" "st" ON (("s"."status_id" = "st"."status_id")))
     LEFT JOIN "public"."businesses" "b" ON (("b"."business_id" = "s"."business_id")))
     LEFT JOIN "public"."business_customer_view" "c" ON (("s"."customer_id" = "c"."customer_id")))
     LEFT JOIN "public"."employee_view" "emp" ON (("s"."created_by" = "emp"."employee_id")))
  ORDER BY "s"."sale_id";


ALTER TABLE "public"."sale_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."sales_purchases_due_report" AS
 WITH "sales_dues" AS (
         SELECT "s"."sale_date" AS "date",
            COALESCE("s"."sale_invoice", ''::"text") AS "invoice_no",
            "s"."payments",
            "s"."total_amount",
            "s"."due_amount",
            "s"."transaction_id",
            'sale'::"text" AS "transaction_type",
            "s"."business_id",
            "bc"."name" AS "party_name"
           FROM ("public"."sale_view" "s"
             LEFT JOIN "public"."business_customers" "bc" ON ((("bc"."customer_id" = "s"."customer_id") AND ("bc"."business_id" = "s"."business_id"))))
          WHERE (("s"."due_amount" > (0)::numeric) AND (NOT ("s"."status_id" IN ( SELECT "statuses"."status_id"
                   FROM "public"."statuses"
                  WHERE ("statuses"."name" = ANY (ARRAY['VOID'::"text", 'CANCELLED'::"text"]))))))
        ), "purchase_dues" AS (
         SELECT "p"."purchase_date" AS "date",
            COALESCE("p"."purchase_invoice", ''::"text") AS "invoice_no",
            "p"."payments",
            "p"."total_amount",
            "p"."due_amount",
            "p"."transaction_id",
            'purchase'::"text" AS "transaction_type",
            "p"."business_id",
            "s"."name" AS "party_name"
           FROM ("public"."purchase_view" "p"
             LEFT JOIN "public"."suppliers" "s" ON (("s"."supplier_id" = "p"."supplier_id")))
          WHERE ("p"."due_amount" > (0)::numeric)
        )
 SELECT "sales_dues"."date",
    "sales_dues"."invoice_no",
    "sales_dues"."payments",
    "sales_dues"."total_amount",
    "sales_dues"."due_amount",
    "sales_dues"."transaction_id",
    "sales_dues"."transaction_type",
    "sales_dues"."business_id",
    "sales_dues"."party_name"
   FROM "sales_dues"
UNION ALL
 SELECT "purchase_dues"."date",
    "purchase_dues"."invoice_no",
    "purchase_dues"."payments",
    "purchase_dues"."total_amount",
    "purchase_dues"."due_amount",
    "purchase_dues"."transaction_id",
    "purchase_dues"."transaction_type",
    "purchase_dues"."business_id",
    "purchase_dues"."party_name"
   FROM "purchase_dues";


ALTER TABLE "public"."sales_purchases_due_report" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."states" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "country_id" integer NOT NULL
);


ALTER TABLE "public"."states" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."states_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."states_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."states_id_seq" OWNED BY "public"."states"."id";



CREATE TABLE IF NOT EXISTS "public"."stock_adjustment_items" (
    "adjustment_item_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "adjustment_id" "uuid" NOT NULL,
    "item_id" "uuid" NOT NULL,
    "quantity_adjusted" numeric(10,2) NOT NULL,
    "previous_quantity" numeric(10,2) NOT NULL,
    "new_quantity" numeric(10,2) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" DEFAULT "auth"."uid"(),
    "updated_by" "uuid"
);


ALTER TABLE "public"."stock_adjustment_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."stock_adjustments" (
    "adjustment_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "reason" "text" NOT NULL,
    "reference" character varying(255) NOT NULL,
    "performed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "performed_by" "uuid" NOT NULL,
    "business_id" "uuid" NOT NULL,
    "org_id" "uuid" NOT NULL,
    "transaction_id" "uuid" NOT NULL,
    "updated_by" "uuid"
);


ALTER TABLE "public"."stock_adjustments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."subscription_invoices" (
    "subscription_invoice_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "org_id" "uuid" NOT NULL,
    "subscription_id" "uuid",
    "payment_provider_subscription_id" "text",
    "payment_provider_invoice_id" "text" NOT NULL,
    "payment_provider_order_id" "text",
    "payment_provider_payment_id" "text",
    "payment_provider" "text" DEFAULT 'razorpay'::"text" NOT NULL,
    "status" "public"."invoice_status_enum" DEFAULT 'issued'::"public"."invoice_status_enum" NOT NULL,
    "amount" numeric(12,2) NOT NULL,
    "amount_paid" numeric(12,2),
    "amount_due" numeric(12,2),
    "currency" character varying(3) NOT NULL,
    "due_date" timestamp with time zone,
    "paid_at" timestamp with time zone,
    "issued_at" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "line_items" "jsonb",
    "notes" "text",
    "pdf_url" "text",
    "metadata" "jsonb",
    "payment_url" "text"
);


ALTER TABLE "public"."subscription_invoices" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."subscriptions_subscription_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."subscriptions_subscription_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."subscriptions_subscription_id_seq" OWNED BY "public"."subscriptions"."subscription_id";



CREATE TABLE IF NOT EXISTS "public"."table" (
    "table_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "business_id" "uuid" NOT NULL,
    "floor_id" "uuid",
    "name" "text" NOT NULL,
    "no_of_seats" integer DEFAULT 4,
    "x" numeric DEFAULT 0,
    "y" numeric DEFAULT 0,
    "turns" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."table" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_purchase_return_items" AS
 SELECT "pri"."return_item_id",
    "pri"."return_id",
    "pri"."purchase_item_id",
    "pri"."quantity" AS "return_quantity",
    "pri"."unit_price" AS "return_unit_price",
    "pri"."total_price" AS "return_total_price",
    "pi"."item_id",
    "i"."name" AS "item_name",
    "i"."item_code",
    "pi"."quantity" AS "original_quantity",
    "pi"."unit_price" AS "original_unit_price",
    "pi"."total_price" AS "original_total_price",
    "pri"."created_at",
    "pri"."updated_at"
   FROM (("public"."purchase_return_items" "pri"
     JOIN "public"."purchase_items" "pi" ON (("pri"."purchase_item_id" = "pi"."purchase_item_id")))
     JOIN "public"."items" "i" ON (("pi"."item_id" = "i"."item_id")));


ALTER TABLE "public"."v_purchase_return_items" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_purchase_returns" AS
 SELECT "pr"."return_id",
    "pr"."purchase_id",
    "pr"."return_invoice",
    "pr"."return_date",
    "pr"."reason",
    "pr"."notes",
    "pr"."total_amount" AS "return_amount",
    "pr"."transaction_id",
    "pr"."business_id",
    "pr"."created_by",
    "pr"."created_at",
    "pr"."updated_at",
    "p"."invoice_no" AS "purchase_invoice",
    "p"."purchase_date",
    "p"."total_amount" AS "original_purchase_amount",
    ("row_to_json"("s".*))::"jsonb" AS "supplier",
    "t"."reference_no" AS "transaction_reference",
    "t"."status" AS "transaction_status",
    "t"."total_amount" AS "transaction_amount",
    "t"."paid_amount" AS "transaction_paid_amount",
    "t"."due_amount" AS "transaction_due_amount",
    "e"."name" AS "created_by_name",
    ( SELECT "jsonb_agg"("jsonb_build_object"('return_item_id', "pri"."return_item_id", 'item_id', "i"."item_id", 'item_name', "i"."name", 'item_code', "i"."item_code", 'return_quantity', "pri"."quantity", 'return_unit_price', "pri"."unit_price", 'return_total_price', "pri"."total_price", 'original_quantity', "pi"."quantity", 'original_unit_price', "pi"."unit_price", 'original_total_price', "pi"."total_price")) AS "jsonb_agg"
           FROM (("public"."purchase_return_items" "pri"
             JOIN "public"."purchase_items" "pi" ON (("pri"."purchase_item_id" = "pi"."purchase_item_id")))
             JOIN "public"."items" "i" ON (("pi"."item_id" = "i"."item_id")))
          WHERE ("pri"."return_id" = "pr"."return_id")) AS "return_items",
    ( SELECT "jsonb_agg"("jsonb_build_object"('entry_id', "te"."entry_id", 'account_id', "te"."account_id", 'account_name', "a"."name", 'entry_type', "te"."entry_type", 'amount', "te"."amount", 'description', "te"."description")) AS "jsonb_agg"
           FROM ("public"."transaction_entries" "te"
             JOIN "public"."accounts" "a" ON (("te"."account_id" = "a"."account_id")))
          WHERE ("te"."transaction_id" = "pr"."transaction_id")) AS "accounting_entries"
   FROM (((("public"."purchase_returns" "pr"
     JOIN "public"."purchases" "p" ON (("pr"."purchase_id" = "p"."purchase_id")))
     JOIN "public"."transactions" "t" ON (("pr"."transaction_id" = "t"."transaction_id")))
     JOIN "public"."employees" "e" ON (("pr"."created_by" = "e"."employee_id")))
     LEFT JOIN "public"."suppliers" "s" ON (("p"."supplier_id" = "s"."supplier_id")));


ALTER TABLE "public"."v_purchase_returns" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_purchase_returns_summary" AS
 SELECT "pr"."business_id",
    "date_trunc"('day'::"text", "pr"."return_date") AS "return_date",
    "count"(*) AS "total_returns",
    "sum"("pr"."total_amount") AS "total_return_amount",
    "count"(DISTINCT "p"."supplier_id") AS "unique_suppliers",
    "jsonb_agg"("jsonb_build_object"('return_invoice', "pr"."return_invoice", 'amount', "pr"."total_amount", 'supplier', "s"."name", 'reason', "pr"."reason")) AS "returns_list"
   FROM (("public"."purchase_returns" "pr"
     JOIN "public"."purchases" "p" ON (("pr"."purchase_id" = "p"."purchase_id")))
     LEFT JOIN "public"."suppliers" "s" ON (("p"."supplier_id" = "s"."supplier_id")))
  GROUP BY "pr"."business_id", ("date_trunc"('day'::"text", "pr"."return_date"));


ALTER TABLE "public"."v_purchase_returns_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_sale_return_items" AS
 SELECT "sri"."return_item_id",
    "sri"."return_id",
    "sri"."sale_item_id",
    "sri"."quantity" AS "return_quantity",
    "sri"."unit_price" AS "return_unit_price",
    "sri"."total_price" AS "return_total_price",
    "si"."item_id",
    "i"."name" AS "item_name",
    "i"."item_code",
    "si"."quantity" AS "original_quantity",
    "si"."unit_price" AS "original_unit_price",
    "si"."total_price" AS "original_total_price",
    "sri"."created_at",
    "sri"."updated_at"
   FROM (("public"."sale_return_items" "sri"
     JOIN "public"."sale_items" "si" ON (("sri"."sale_item_id" = "si"."sale_item_id")))
     JOIN "public"."items" "i" ON (("si"."item_id" = "i"."item_id")));


ALTER TABLE "public"."v_sale_return_items" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_sale_returns" AS
 SELECT "sr"."return_id",
    "sr"."sale_id",
    "sr"."return_invoice",
    "sr"."return_date",
    "sr"."reason",
    "sr"."notes",
    "sr"."total_amount" AS "return_amount",
    "sr"."transaction_id",
    "sr"."business_id",
    "sr"."created_by",
    "sr"."created_at",
    "sr"."updated_at",
    "s"."sale_invoice",
    "s"."sale_date",
    "s"."total_amount" AS "original_sale_amount",
    ("row_to_json"("c".*))::"jsonb" AS "customer",
    "t"."reference_no" AS "transaction_reference",
    "t"."status" AS "transaction_status",
    "t"."total_amount" AS "transaction_amount",
    "t"."paid_amount" AS "transaction_paid_amount",
    "t"."due_amount" AS "transaction_due_amount",
    "e"."name" AS "created_by_name",
    ( SELECT "jsonb_agg"("jsonb_build_object"('return_item_id', "sri"."return_item_id", 'item_id', "i"."item_id", 'item_name', "i"."name", 'item_code', "i"."item_code", 'return_quantity', "sri"."quantity", 'return_unit_price', "sri"."unit_price", 'return_total_price', "sri"."total_price", 'original_quantity', "si"."quantity", 'original_unit_price', "si"."unit_price", 'original_total_price', "si"."total_price")) AS "jsonb_agg"
           FROM (("public"."sale_return_items" "sri"
             JOIN "public"."sale_items" "si" ON (("sri"."sale_item_id" = "si"."sale_item_id")))
             JOIN "public"."items" "i" ON (("si"."item_id" = "i"."item_id")))
          WHERE ("sri"."return_id" = "sr"."return_id")) AS "return_items",
    ( SELECT "jsonb_agg"("jsonb_build_object"('entry_id', "te"."entry_id", 'account_id', "te"."account_id", 'account_name', "a"."name", 'entry_type', "te"."entry_type", 'amount', "te"."amount", 'description', "te"."description")) AS "jsonb_agg"
           FROM ("public"."transaction_entries" "te"
             JOIN "public"."accounts" "a" ON (("te"."account_id" = "a"."account_id")))
          WHERE ("te"."transaction_id" = "sr"."transaction_id")) AS "accounting_entries"
   FROM (((("public"."sale_returns" "sr"
     JOIN "public"."sales" "s" ON (("sr"."sale_id" = "s"."sale_id")))
     JOIN "public"."transactions" "t" ON (("sr"."transaction_id" = "t"."transaction_id")))
     JOIN "public"."employees" "e" ON (("sr"."created_by" = "e"."employee_id")))
     LEFT JOIN "public"."business_customer_view" "c" ON (("s"."customer_id" = "c"."customer_id")));


ALTER TABLE "public"."v_sale_returns" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_sale_returns_summary" AS
 SELECT "sr"."business_id",
    "date_trunc"('day'::"text", "sr"."return_date") AS "return_date",
    "count"(*) AS "total_returns",
    "sum"("sr"."total_amount") AS "total_return_amount",
    "count"(DISTINCT "s"."customer_id") AS "unique_customers",
    "jsonb_agg"("jsonb_build_object"('return_invoice', "sr"."return_invoice", 'amount', "sr"."total_amount", 'customer', "c"."name", 'reason', "sr"."reason")) AS "returns_list"
   FROM (("public"."sale_returns" "sr"
     JOIN "public"."sales" "s" ON (("sr"."sale_id" = "s"."sale_id")))
     LEFT JOIN "public"."customers" "c" ON (("s"."customer_id" = "c"."customer_id")))
  GROUP BY "sr"."business_id", ("date_trunc"('day'::"text", "sr"."return_date"));


ALTER TABLE "public"."v_sale_returns_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_daily_transactions_report_v2" AS
 WITH "transaction_details" AS (
         SELECT "t"."transaction_id",
            "t"."transaction_date",
            "t"."transaction_type",
            "t"."total_amount",
            "t"."business_id",
            "t"."reference_no" AS "transaction_ref_no",
            COALESCE(
                CASE
                    WHEN ("t"."transaction_type" = 'SALE'::"public"."transaction_type") THEN "bc"."name"
                    WHEN ("t"."transaction_type" = 'SALE_RETURN'::"public"."transaction_type") THEN "bc_return"."name"
                    WHEN ("t"."transaction_type" = 'PURCHASE'::"public"."transaction_type") THEN "sup"."name"
                    WHEN ("t"."transaction_type" = 'PURCHASE_RETURN'::"public"."transaction_type") THEN "sup_return"."name"
                    WHEN ("t"."transaction_type" = 'INCOME'::"public"."transaction_type") THEN COALESCE("inc"."income_for", 'Income'::"text")
                    WHEN ("t"."transaction_type" = 'EXPENSE'::"public"."transaction_type") THEN COALESCE("exp"."expense_for", 'Expense'::"text")
                    WHEN ("t"."transaction_type" = 'STOCK_ADJUSTMENT'::"public"."transaction_type") THEN 'Stock Adjustment'::"text"
                    WHEN ("t"."transaction_type" = 'CUSTOMER_OPENING_BALANCE'::"public"."transaction_type") THEN 'Opening Balance - Customer'::"text"
                    WHEN ("t"."transaction_type" = 'SUPPLIER_OPENING_BALANCE'::"public"."transaction_type") THEN 'Opening Balance - Supplier'::"text"
                    WHEN ("t"."transaction_type" = 'OPENING_STOCK'::"public"."transaction_type") THEN 'Opening Balance - Item Stock'::"text"
                    ELSE 'Other Transaction'::"text"
                END, 'Walk-in'::"text") AS "name",
                CASE
                    WHEN ("t"."transaction_type" = 'SALE'::"public"."transaction_type") THEN 'Sale'::"text"
                    WHEN ("t"."transaction_type" = 'SALE_RETURN'::"public"."transaction_type") THEN 'Sale Return'::"text"
                    WHEN ("t"."transaction_type" = 'PURCHASE'::"public"."transaction_type") THEN 'Purchase'::"text"
                    WHEN ("t"."transaction_type" = 'PURCHASE_RETURN'::"public"."transaction_type") THEN 'Purchase Return'::"text"
                    WHEN ("t"."transaction_type" = 'INCOME'::"public"."transaction_type") THEN ('Income - '::"text" || COALESCE("ic"."name", "inc"."income_for", 'Other'::"text"))
                    WHEN ("t"."transaction_type" = 'EXPENSE'::"public"."transaction_type") THEN ('Expense - '::"text" || COALESCE("ec"."name", "exp"."expense_for", 'Other'::"text"))
                    WHEN ("t"."transaction_type" = 'STOCK_ADJUSTMENT'::"public"."transaction_type") THEN 'Stock Adjustment'::"text"
                    WHEN ("t"."transaction_type" = ANY (ARRAY['CUSTOMER_OPENING_BALANCE'::"public"."transaction_type", 'SUPPLIER_OPENING_BALANCE'::"public"."transaction_type", 'OPENING_STOCK'::"public"."transaction_type"])) THEN 'Opening Balance Setup'::"text"
                    ELSE "initcap"("replace"(("t"."transaction_type")::"text", '_'::"text", ' '::"text"))
                END AS "type",
            "lower"(("t"."transaction_type")::"text") AS "transaction_category",
            "p"."payment_id",
            "p"."payment_date",
            "p"."amount" AS "payment_amount",
            "p"."payment_method",
            "p"."reference_no" AS "payment_ref_no"
           FROM ((((((((((((((("public"."transactions" "t"
             LEFT JOIN "public"."payments" "p" ON (("t"."transaction_id" = "p"."transaction_id")))
             LEFT JOIN "public"."sales" "s" ON ((("s"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'SALE'::"public"."transaction_type"))))
             LEFT JOIN "public"."business_customers" "bc" ON ((("bc"."customer_id" = "s"."customer_id") AND ("bc"."business_id" = "t"."business_id"))))
             LEFT JOIN "public"."sale_returns" "sr" ON ((("sr"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'SALE_RETURN'::"public"."transaction_type"))))
             LEFT JOIN "public"."sales" "s_return" ON (("s_return"."sale_id" = "sr"."sale_id")))
             LEFT JOIN "public"."business_customers" "bc_return" ON ((("bc_return"."customer_id" = "s_return"."customer_id") AND ("bc_return"."business_id" = "t"."business_id"))))
             LEFT JOIN "public"."purchases" "pur" ON ((("pur"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'PURCHASE'::"public"."transaction_type"))))
             LEFT JOIN "public"."suppliers" "sup" ON (("sup"."supplier_id" = "pur"."supplier_id")))
             LEFT JOIN "public"."purchase_returns" "pr" ON ((("pr"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'PURCHASE_RETURN'::"public"."transaction_type"))))
             LEFT JOIN "public"."purchases" "p_return" ON (("p_return"."purchase_id" = "pr"."purchase_id")))
             LEFT JOIN "public"."suppliers" "sup_return" ON (("sup_return"."supplier_id" = "p_return"."supplier_id")))
             LEFT JOIN "public"."incomes" "inc" ON ((("inc"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'INCOME'::"public"."transaction_type"))))
             LEFT JOIN "public"."income_categories" "ic" ON (("ic"."category_id" = "inc"."income_category_id")))
             LEFT JOIN "public"."expenses" "exp" ON ((("exp"."transaction_id" = "t"."transaction_id") AND ("t"."transaction_type" = 'EXPENSE'::"public"."transaction_type"))))
             LEFT JOIN "public"."expense_categories" "ec" ON (("ec"."category_id" = "exp"."expense_category_id")))
          WHERE (("t"."status" IS DISTINCT FROM 'REVERSED'::"public"."transaction_status") AND ("t"."status" IS DISTINCT FROM 'CANCELLED'::"public"."transaction_status"))
        ), "daily_movements" AS (
         SELECT COALESCE("td"."payment_date", "td"."transaction_date") AS "date",
            "td"."name",
            "td"."type",
            "td"."total_amount" AS "transaction_total",
                CASE
                    WHEN (("td"."payment_id" IS NOT NULL) AND ("td"."transaction_category" = ANY (ARRAY['sale'::"text", 'income'::"text", 'purchase_return'::"text"]))) THEN "td"."payment_amount"
                    ELSE NULL::numeric
                END AS "payment_in",
                CASE
                    WHEN (("td"."payment_id" IS NOT NULL) AND ("td"."transaction_category" = ANY (ARRAY['purchase'::"text", 'expense'::"text", 'sale_return'::"text"]))) THEN "td"."payment_amount"
                    ELSE NULL::numeric
                END AS "payment_out",
            "td"."payment_method",
            "td"."payment_id",
            "td"."transaction_id",
            COALESCE("td"."payment_ref_no", "td"."transaction_ref_no") AS "reference_no",
            "td"."transaction_category",
            "td"."business_id"
           FROM "transaction_details" "td"
        ), "running_balance" AS (
         SELECT "dm"."date",
            "dm"."name",
            "dm"."type",
            "dm"."transaction_total",
            "dm"."payment_in",
            "dm"."payment_out",
            "dm"."payment_method",
            "dm"."reference_no",
            "dm"."transaction_category",
            "dm"."business_id",
            "dm"."payment_id",
            "dm"."transaction_id",
            "sum"((COALESCE("dm"."payment_in", (0)::numeric) - COALESCE("dm"."payment_out", (0)::numeric))) OVER (PARTITION BY "dm"."business_id" ORDER BY "dm"."date", "dm"."transaction_id", "dm"."payment_id") AS "balance"
           FROM "daily_movements" "dm"
        )
 SELECT "rb"."date",
    "rb"."name",
    "rb"."type",
    "rb"."transaction_total",
    "rb"."payment_in",
    "rb"."payment_out",
    "rb"."payment_method",
    "rb"."reference_no",
    "rb"."transaction_category",
    "rb"."business_id",
    "rb"."payment_id",
    "rb"."transaction_id",
    "rb"."balance"
   FROM "running_balance" "rb"
  WHERE ("rb"."business_id" IS NOT NULL)
  ORDER BY "rb"."date", "rb"."transaction_id", "rb"."payment_id";


ALTER TABLE "public"."vw_daily_transactions_report_v2" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_stock_adjustments" AS
 WITH "adjustment_items_agg" AS (
         SELECT "sai"."adjustment_id",
            "jsonb_agg"("jsonb_build_object"('adjustment_item_id', "sai"."adjustment_item_id", 'item_id', "sai"."item_id", 'item', "to_jsonb"("vw_i".*), 'quantity_adjusted', "sai"."quantity_adjusted", 'previous_quantity', "sai"."previous_quantity", 'new_quantity', "sai"."new_quantity", 'created_at', "sai"."created_at")) AS "adjusted_items"
           FROM ("public"."stock_adjustment_items" "sai"
             JOIN "public"."vw_items" "vw_i" ON (("sai"."item_id" = "vw_i"."item_id")))
          GROUP BY "sai"."adjustment_id"
        )
 SELECT "sa"."adjustment_id",
    "sa"."reason",
    "sa"."reference",
    "sa"."performed_at",
    "sa"."performed_by",
    "emp"."name" AS "performed_user",
    "sa"."business_id",
    "sa"."org_id",
    "adjustment_items_agg"."adjusted_items"
   FROM ((("public"."stock_adjustments" "sa"
     JOIN "public"."transactions" "t" ON (("sa"."transaction_id" = "t"."transaction_id")))
     LEFT JOIN "adjustment_items_agg" ON (("sa"."adjustment_id" = "adjustment_items_agg"."adjustment_id")))
     LEFT JOIN "public"."employee_view" "emp" ON (("sa"."performed_by" = "emp"."employee_id")))
  WHERE ("t"."status" IS DISTINCT FROM 'REVERSED'::"public"."transaction_status")
  ORDER BY "sa"."performed_at" DESC;


ALTER TABLE "public"."vw_stock_adjustments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."whatsapp_integration" (
    "whatsapp_integration_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "whatsapp_number_id" character varying(255),
    "whatsapp_token" character varying(255),
    "customer_sale_invoice" boolean DEFAULT false,
    "customer_payment_receipt" boolean DEFAULT false,
    "admin_order_assigned_alert" boolean DEFAULT false,
    "admin_stock_alert" boolean DEFAULT false,
    "payment_overdue_alert" character varying(50) DEFAULT 'None'::character varying,
    "business_id" "uuid" NOT NULL,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."whatsapp_integration" OWNER TO "postgres";


ALTER TABLE ONLY "public"."addon_prices" ALTER COLUMN "addon_price_id" SET DEFAULT "nextval"('"public"."addon_prices_addon_price_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."addons" ALTER COLUMN "addon_id" SET DEFAULT "nextval"('"public"."addons_addon_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."cities" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."cities_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."countries" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."countries_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."features" ALTER COLUMN "feature_id" SET DEFAULT "nextval"('"public"."features_feature_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."plan_features" ALTER COLUMN "plan_feature_id" SET DEFAULT "nextval"('"public"."plan_features_plan_feature_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."plan_prices" ALTER COLUMN "plan_price_id" SET DEFAULT "nextval"('"public"."plan_prices_plan_price_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."plans" ALTER COLUMN "plan_id" SET DEFAULT "nextval"('"public"."plans_plan_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."account_categories"
    ADD CONSTRAINT "account_categories_business_id_code_key" UNIQUE ("business_id", "code");



ALTER TABLE ONLY "public"."account_categories"
    ADD CONSTRAINT "account_categories_pkey" PRIMARY KEY ("category_id");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_business_id_code_key" UNIQUE ("business_id", "code");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_pkey" PRIMARY KEY ("account_id");



ALTER TABLE ONLY "public"."addon_prices"
    ADD CONSTRAINT "addon_prices_pkey" PRIMARY KEY ("addon_price_id");



ALTER TABLE ONLY "public"."addons"
    ADD CONSTRAINT "addons_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."addons"
    ADD CONSTRAINT "addons_pkey" PRIMARY KEY ("addon_id");



ALTER TABLE ONLY "public"."addons"
    ADD CONSTRAINT "addons_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_pkey" PRIMARY KEY ("brand_id");



ALTER TABLE ONLY "public"."business_customers"
    ADD CONSTRAINT "business_customers_pkey" PRIMARY KEY ("business_id", "customer_id");



ALTER TABLE ONLY "public"."businesses"
    ADD CONSTRAINT "businesses_pkey" PRIMARY KEY ("business_id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_iso_code_unique" UNIQUE ("iso_code");



ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."credit_note_items"
    ADD CONSTRAINT "credit_note_items_item_unique" UNIQUE ("business_id", "customer_id", "credit_note_id", "item_id");



ALTER TABLE ONLY "public"."credit_note_items"
    ADD CONSTRAINT "credit_note_items_pkey" PRIMARY KEY ("credit_note_item_id");



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "credit_notes_credit_note_code_key" UNIQUE ("credit_note_code");



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "credit_notes_pkey" PRIMARY KEY ("business_id", "customer_id", "credit_note_id");



ALTER TABLE ONLY "public"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_pkey" PRIMARY KEY ("customer_addresses_id");



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_pkey" PRIMARY KEY ("customer_id");



ALTER TABLE ONLY "public"."employee_branch_access"
    ADD CONSTRAINT "employee_branch_access_pkey" PRIMARY KEY ("employee_id", "business_id");



ALTER TABLE ONLY "public"."employee_roles"
    ADD CONSTRAINT "employee_roles_pkey" PRIMARY KEY ("employee_role_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("employee_id");



ALTER TABLE ONLY "public"."expense_categories"
    ADD CONSTRAINT "expense_categories_pkey" PRIMARY KEY ("category_id");



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_pkey" PRIMARY KEY ("expense_id");



ALTER TABLE ONLY "public"."features"
    ADD CONSTRAINT "features_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."features"
    ADD CONSTRAINT "features_pkey" PRIMARY KEY ("feature_id");



ALTER TABLE ONLY "public"."features"
    ADD CONSTRAINT "features_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."fiscal_years"
    ADD CONSTRAINT "fiscal_years_pkey" PRIMARY KEY ("fiscal_id");



ALTER TABLE ONLY "public"."floor"
    ADD CONSTRAINT "floor_pkey" PRIMARY KEY ("floor_id");



ALTER TABLE ONLY "public"."income_categories"
    ADD CONSTRAINT "income_categories_pkey" PRIMARY KEY ("category_id");



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_pkey" PRIMARY KEY ("income_id");



ALTER TABLE ONLY "public"."invoice_items"
    ADD CONSTRAINT "invoice_items_invoice_item_unique" UNIQUE ("business_id", "customer_id", "invoice_id", "item_id");



ALTER TABLE ONLY "public"."invoice_items"
    ADD CONSTRAINT "invoice_items_pkey" PRIMARY KEY ("invoice_item_id");



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_invoice_code_key" UNIQUE ("invoice_code");



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_pkey" PRIMARY KEY ("business_id", "customer_id", "invoice_id");



ALTER TABLE ONLY "public"."item_categories"
    ADD CONSTRAINT "item_categories_pkey" PRIMARY KEY ("item_category_id");



ALTER TABLE ONLY "public"."item_custom_field_definitions"
    ADD CONSTRAINT "item_custom_field_definitions_pkey" PRIMARY KEY ("field_id");



ALTER TABLE ONLY "public"."item_custom_field_values"
    ADD CONSTRAINT "item_custom_field_values_pkey" PRIMARY KEY ("item_id", "field_id");



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_pkey" PRIMARY KEY ("item_id");



ALTER TABLE ONLY "public"."links"
    ADD CONSTRAINT "links_pkey" PRIMARY KEY ("link_id");



ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("module_id");



ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_url_key" UNIQUE ("url");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_created_by_key" UNIQUE ("created_by");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_pkey" PRIMARY KEY ("org_id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("payment_id");



ALTER TABLE ONLY "public"."payments_received"
    ADD CONSTRAINT "payments_received_business_id_payment_code_key" UNIQUE ("business_id", "payment_code");



ALTER TABLE ONLY "public"."payments_received"
    ADD CONSTRAINT "payments_received_pkey" PRIMARY KEY ("payment_id");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("permission_id");



ALTER TABLE ONLY "public"."plan_features"
    ADD CONSTRAINT "plan_features_pkey" PRIMARY KEY ("plan_feature_id");



ALTER TABLE ONLY "public"."plan_prices"
    ADD CONSTRAINT "plan_prices_pkey" PRIMARY KEY ("plan_price_id");



ALTER TABLE ONLY "public"."plans"
    ADD CONSTRAINT "plans_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."plans"
    ADD CONSTRAINT "plans_pkey" PRIMARY KEY ("plan_id");



ALTER TABLE ONLY "public"."plans"
    ADD CONSTRAINT "plans_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."processed_webhook_events"
    ADD CONSTRAINT "processed_webhook_events_pkey" PRIMARY KEY ("event_id");



ALTER TABLE ONLY "public"."purchase_audits"
    ADD CONSTRAINT "purchase_audits_pkey" PRIMARY KEY ("audit_id");



ALTER TABLE ONLY "public"."purchase_custom_field_definitions"
    ADD CONSTRAINT "purchase_custom_field_definitions_pkey" PRIMARY KEY ("field_id");



ALTER TABLE ONLY "public"."purchase_custom_field_definitions"
    ADD CONSTRAINT "purchase_custom_field_definitions_unique_field_name_per_busines" UNIQUE ("business_id", "field_name");



ALTER TABLE ONLY "public"."purchase_custom_field_values"
    ADD CONSTRAINT "purchase_custom_field_values_pkey" PRIMARY KEY ("purchase_id", "field_id");



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_pkey" PRIMARY KEY ("purchase_item_id");



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_purchase_id_item_id_key" UNIQUE ("purchase_id", "item_id");



ALTER TABLE ONLY "public"."purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_pkey" PRIMARY KEY ("return_item_id");



ALTER TABLE ONLY "public"."purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_return_id_purchase_item_id_unique" UNIQUE ("return_id", "purchase_item_id");



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "purchase_returns_pkey" PRIMARY KEY ("return_id");



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_pkey" PRIMARY KEY ("purchase_id");



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_transaction_id_key" UNIQUE ("transaction_id");



ALTER TABLE ONLY "public"."quote_items"
    ADD CONSTRAINT "quote_items_pkey" PRIMARY KEY ("quote_item_id");



ALTER TABLE ONLY "public"."quote_items"
    ADD CONSTRAINT "quote_items_quote_item_unique" UNIQUE ("business_id", "customer_id", "quote_id", "item_id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_pkey" PRIMARY KEY ("business_id", "customer_id", "quote_id");



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_quote_code_key" UNIQUE ("quote_code");



ALTER TABLE ONLY "public"."razorpay_addons"
    ADD CONSTRAINT "razorpay_addons_pkey" PRIMARY KEY ("razorpay_addon_id");



ALTER TABLE ONLY "public"."razorpay_plans"
    ADD CONSTRAINT "razorpay_plans_pkey" PRIMARY KEY ("razorpay_plan_id");



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_pkey" PRIMARY KEY ("referral_id");



ALTER TABLE ONLY "public"."refund_payments"
    ADD CONSTRAINT "refund_payments_pkey" PRIMARY KEY ("refund_id");



ALTER TABLE ONLY "public"."resellers"
    ADD CONSTRAINT "resellers_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."resellers"
    ADD CONSTRAINT "resellers_pkey" PRIMARY KEY ("reseller_id");



ALTER TABLE ONLY "public"."roles_of_employees"
    ADD CONSTRAINT "roles_of_employees_pkey" PRIMARY KEY ("employee_role_id", "employee_id");



ALTER TABLE ONLY "public"."sale_audits"
    ADD CONSTRAINT "sale_audits_pkey" PRIMARY KEY ("audit_id");



ALTER TABLE ONLY "public"."sale_custom_field_definitions"
    ADD CONSTRAINT "sale_custom_field_definitions_pkey" PRIMARY KEY ("field_id");



ALTER TABLE ONLY "public"."sale_custom_field_definitions"
    ADD CONSTRAINT "sale_custom_field_definitions_unique_field_name_per_business" UNIQUE ("business_id", "field_name");



ALTER TABLE ONLY "public"."sale_custom_field_values"
    ADD CONSTRAINT "sale_custom_field_values_pkey" PRIMARY KEY ("sale_id", "field_id");



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_pkey" PRIMARY KEY ("sale_item_subservice_id");



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_sale_item_id_sub_service_id_unique" UNIQUE ("sale_item_id", "sub_service_id");



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_pkey" PRIMARY KEY ("sale_item_id");



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_sale_id_item_id_unique" UNIQUE ("sale_id", "item_id");



ALTER TABLE ONLY "public"."sale_return_items"
    ADD CONSTRAINT "sale_return_items_pkey" PRIMARY KEY ("return_item_id");



ALTER TABLE ONLY "public"."sale_return_items"
    ADD CONSTRAINT "sale_return_items_return_id_sale_item_id_unique" UNIQUE ("return_id", "sale_item_id");



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "sale_returns_pkey" PRIMARY KEY ("return_id");



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("sale_id");



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_transaction_id_key" UNIQUE ("transaction_id");



ALTER TABLE ONLY "public"."states"
    ADD CONSTRAINT "states_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_pkey" PRIMARY KEY ("status_id");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_unique_business_name" UNIQUE ("business_id", "name");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_unique_business_sequence" UNIQUE ("business_id", "sequence_order");



ALTER TABLE ONLY "public"."stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_pkey" PRIMARY KEY ("adjustment_item_id");



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_pkey" PRIMARY KEY ("adjustment_id");



ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_payment_provider_invoice_id_unique" UNIQUE ("payment_provider", "payment_provider_invoice_id");



ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_pkey" PRIMARY KEY ("subscription_invoice_id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_payment_provider_subscription_id_key" UNIQUE ("payment_provider_subscription_id");



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("subscription_id");



ALTER TABLE ONLY "public"."subservices"
    ADD CONSTRAINT "subservices_pkey" PRIMARY KEY ("sub_service_id");



ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_pkey" PRIMARY KEY ("supplier_id");



ALTER TABLE ONLY "public"."table"
    ADD CONSTRAINT "table_pkey" PRIMARY KEY ("table_id");



ALTER TABLE ONLY "public"."taxes"
    ADD CONSTRAINT "taxes_pkey" PRIMARY KEY ("tax_id");



ALTER TABLE ONLY "public"."transaction_entries"
    ADD CONSTRAINT "transaction_entries_pkey" PRIMARY KEY ("entry_id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_business_id_reference_no_key" UNIQUE ("business_id", "reference_no");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("transaction_id");



ALTER TABLE ONLY "public"."addon_prices"
    ADD CONSTRAINT "unique_addon_country_price" UNIQUE ("addon_id", "country_code");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "unique_business_accounts_code" UNIQUE ("business_id", "code");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "unique_business_accounts_name" UNIQUE ("business_id", "name");



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "unique_business_item_code" UNIQUE ("business_id", "item_code");



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "unique_business_purchase_invoice" UNIQUE ("business_id", "invoice_no");



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "unique_business_purchsase_return_invoice" UNIQUE ("business_id", "return_invoice");



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "unique_business_return_invoice" UNIQUE ("business_id", "return_invoice");



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "unique_business_sale_invoice" UNIQUE ("business_id", "sale_invoice");



ALTER TABLE ONLY "public"."item_custom_field_definitions"
    ADD CONSTRAINT "unique_field_name_per_business" UNIQUE ("business_id", "field_name");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "unique_permissions_role_link" UNIQUE ("employee_role_id", "link_id");



ALTER TABLE ONLY "public"."plan_prices"
    ADD CONSTRAINT "unique_plan_country_price" UNIQUE ("plan_id", "country_code");



ALTER TABLE ONLY "public"."plan_features"
    ADD CONSTRAINT "unique_plan_feature" UNIQUE ("plan_id", "feature_id");



ALTER TABLE ONLY "public"."units"
    ADD CONSTRAINT "units_pkey" PRIMARY KEY ("unit_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."whatsapp_integration"
    ADD CONSTRAINT "whatsapp_integration_business_id_key" UNIQUE ("business_id");



ALTER TABLE ONLY "public"."whatsapp_integration"
    ADD CONSTRAINT "whatsapp_integration_pkey" PRIMARY KEY ("whatsapp_integration_id");



CREATE INDEX "idx_accounts_parent_account_id" ON "public"."accounts" USING "btree" ("parent_account_id");



CREATE INDEX "idx_addon_prices_addon_country" ON "public"."addon_prices" USING "btree" ("addon_id", "country_code");



CREATE INDEX "idx_addons_slug" ON "public"."addons" USING "btree" ("slug");



CREATE INDEX "idx_business_customers_is_active" ON "public"."business_customers" USING "btree" ("is_active");



CREATE INDEX "idx_credit_note_items_credit_note_id" ON "public"."credit_note_items" USING "btree" ("business_id", "customer_id", "credit_note_id");



CREATE INDEX "idx_credit_note_items_item_id" ON "public"."credit_note_items" USING "btree" ("item_id");



CREATE INDEX "idx_credit_notes_created_by" ON "public"."credit_notes" USING "btree" ("created_by");



CREATE INDEX "idx_credit_notes_date" ON "public"."credit_notes" USING "btree" ("credit_note_date");



CREATE INDEX "idx_credit_notes_invoice_id" ON "public"."credit_notes" USING "btree" ("invoice_id");



CREATE INDEX "idx_credit_notes_status" ON "public"."credit_notes" USING "btree" ("status");



CREATE INDEX "idx_expenses_transaction" ON "public"."expenses" USING "btree" ("transaction_id");



CREATE INDEX "idx_features_slug" ON "public"."features" USING "btree" ("slug");



CREATE INDEX "idx_incomes_transaction" ON "public"."incomes" USING "btree" ("transaction_id");



CREATE INDEX "idx_invoice_items_invoice_id" ON "public"."invoice_items" USING "btree" ("business_id", "customer_id", "invoice_id");



CREATE INDEX "idx_invoice_items_item_id" ON "public"."invoice_items" USING "btree" ("item_id");



CREATE INDEX "idx_invoices_created_by" ON "public"."invoices" USING "btree" ("created_by");



CREATE INDEX "idx_invoices_invoice_date" ON "public"."invoices" USING "btree" ("invoice_date");



CREATE INDEX "idx_invoices_status" ON "public"."invoices" USING "btree" ("status");



CREATE INDEX "idx_items_is_active" ON "public"."items" USING "btree" ("is_active");



CREATE INDEX "idx_ledger_parties_business_id" ON "public"."business_customers" USING "btree" ("business_id");



CREATE INDEX "idx_ledger_parties_name" ON "public"."business_customers" USING "btree" ("name");



CREATE INDEX "idx_ledger_parties_supplier_business_id" ON "public"."suppliers" USING "btree" ("business_id");



CREATE INDEX "idx_ledger_parties_supplier_name" ON "public"."suppliers" USING "btree" ("name");



CREATE INDEX "idx_payments_date" ON "public"."payments" USING "btree" ("payment_date");



CREATE INDEX "idx_payments_received_customer_id" ON "public"."payments_received" USING "btree" ("business_id", "customer_id");



CREATE INDEX "idx_payments_received_invoice_id" ON "public"."payments_received" USING "btree" ("business_id", "customer_id", "invoice_id");



CREATE INDEX "idx_payments_received_payment_date" ON "public"."payments_received" USING "btree" ("payment_date");



CREATE INDEX "idx_payments_transaction" ON "public"."payments" USING "btree" ("transaction_id");



CREATE INDEX "idx_plan_features_feature" ON "public"."plan_features" USING "btree" ("feature_id");



CREATE INDEX "idx_plan_features_plan" ON "public"."plan_features" USING "btree" ("plan_id");



CREATE INDEX "idx_plan_prices_plan_country" ON "public"."plan_prices" USING "btree" ("plan_id", "country_code");



CREATE INDEX "idx_plans_slug" ON "public"."plans" USING "btree" ("slug");



CREATE INDEX "idx_purchase_audits_action_timestamp" ON "public"."purchase_audits" USING "btree" ("action_timestamp");



CREATE INDEX "idx_purchase_audits_purchase_id" ON "public"."purchase_audits" USING "btree" ("purchase_id");



CREATE INDEX "idx_purchase_audits_transaction_id" ON "public"."purchase_audits" USING "btree" ("transaction_id");



CREATE INDEX "idx_purchase_returns_business" ON "public"."purchase_returns" USING "btree" ("business_id");



CREATE INDEX "idx_purchase_returns_date" ON "public"."purchase_returns" USING "btree" ("return_date");



CREATE INDEX "idx_purchases_business" ON "public"."purchases" USING "btree" ("business_id");



CREATE INDEX "idx_purchases_due_report_business_id" ON "public"."purchases" USING "btree" ("business_id");



CREATE INDEX "idx_purchases_due_report_invoice" ON "public"."purchases" USING "btree" ("purchase_invoice");



CREATE INDEX "idx_quote_items_item_id" ON "public"."quote_items" USING "btree" ("item_id");



CREATE INDEX "idx_quote_items_quote_id" ON "public"."quote_items" USING "btree" ("business_id", "customer_id", "quote_id");



CREATE INDEX "idx_quotes_created_by" ON "public"."quotes" USING "btree" ("created_by");



CREATE INDEX "idx_quotes_quote_date" ON "public"."quotes" USING "btree" ("quote_date");



CREATE INDEX "idx_quotes_status" ON "public"."quotes" USING "btree" ("status");



CREATE INDEX "idx_quotes_valid_until_date" ON "public"."quotes" USING "btree" ("valid_until_date");



CREATE INDEX "idx_refund_payments_customer_id" ON "public"."refund_payments" USING "btree" ("business_id", "customer_id");



CREATE INDEX "idx_refund_payments_invoice_id" ON "public"."refund_payments" USING "btree" ("business_id", "customer_id", "invoice_id");



CREATE INDEX "idx_refund_payments_refund_date" ON "public"."refund_payments" USING "btree" ("refund_date");



CREATE INDEX "idx_sale_audits_action_timestamp" ON "public"."sale_audits" USING "btree" ("action_timestamp");



CREATE INDEX "idx_sale_audits_action_type" ON "public"."sale_audits" USING "btree" ("action_type");



CREATE INDEX "idx_sale_audits_performed_by" ON "public"."sale_audits" USING "btree" ("performed_by");



CREATE INDEX "idx_sale_audits_sale_id" ON "public"."sale_audits" USING "btree" ("sale_id");



CREATE INDEX "idx_sale_audits_transaction_id" ON "public"."sale_audits" USING "btree" ("transaction_id");



CREATE INDEX "idx_sale_returns_business" ON "public"."sale_returns" USING "btree" ("business_id");



CREATE INDEX "idx_sale_returns_date" ON "public"."sale_returns" USING "btree" ("return_date");



CREATE INDEX "idx_sales_business" ON "public"."sales" USING "btree" ("business_id");



CREATE INDEX "idx_sales_purchases_due_report_business_id" ON "public"."sales" USING "btree" ("business_id");



CREATE INDEX "idx_sales_purchases_due_report_invoice" ON "public"."sales" USING "btree" ("sale_invoice");



CREATE INDEX "idx_subscription_invoices_org_id" ON "public"."subscription_invoices" USING "btree" ("org_id");



CREATE INDEX "idx_subscription_invoices_payment_provider_ids" ON "public"."subscription_invoices" USING "btree" ("payment_provider_invoice_id", "payment_provider_subscription_id");



CREATE INDEX "idx_subscription_invoices_status" ON "public"."subscription_invoices" USING "btree" ("status");



CREATE INDEX "idx_subscriptions_business_status" ON "public"."subscriptions" USING "btree" ("org_id", "status");



CREATE INDEX "idx_subscriptions_end_date" ON "public"."subscriptions" USING "btree" ("end_date");



CREATE INDEX "idx_subscriptions_payment_provider" ON "public"."subscriptions" USING "btree" ("payment_provider_subscription_id");



CREATE INDEX "idx_subscriptions_plan" ON "public"."subscriptions" USING "btree" ("plan_id");



CREATE INDEX "idx_subscriptions_status" ON "public"."subscriptions" USING "btree" ("status");



CREATE INDEX "idx_suppliers_is_active" ON "public"."suppliers" USING "btree" ("is_active");



CREATE INDEX "idx_transaction_entries_account" ON "public"."transaction_entries" USING "btree" ("account_id");



CREATE INDEX "idx_transaction_entries_business" ON "public"."transactions" USING "btree" ("business_id");



CREATE INDEX "idx_transaction_entries_date" ON "public"."transactions" USING "btree" ("transaction_date");



CREATE INDEX "idx_transactions_customer_id" ON "public"."transactions" USING "btree" ("customer_id");



CREATE INDEX "idx_transactions_item_id" ON "public"."transactions" USING "btree" ("item_id");



CREATE INDEX "idx_transactions_supplier_id" ON "public"."transactions" USING "btree" ("supplier_id");



CREATE UNIQUE INDEX "one_active_plan_per_org_idx" ON "public"."subscriptions" USING "btree" ("org_id") WHERE (("status" = ANY (ARRAY['trialing'::"public"."subscription_status_enum", 'active'::"public"."subscription_status_enum", 'past_due'::"public"."subscription_status_enum"])) AND ("plan_id" IS NOT NULL));



CREATE OR REPLACE VIEW "public"."employee_view" AS
 WITH "user_props" AS (
         SELECT ("replace"(((("auth"."jwt"() -> 'user_metadata'::"text") -> 'business_id'::"text"))::"text", '"'::"text", ''::"text"))::"uuid" AS "business_id"
        )
 SELECT "e"."employee_id",
    "e"."code",
    "e"."org_id",
    COALESCE(NULLIF(TRIM(BOTH FROM "e"."name"), ''::"text"), "u"."name") AS "name",
    "u"."email",
    "u"."phone",
    "e"."role",
    "e"."image",
    "e"."created_at",
    COALESCE("array_agg"(DISTINCT "eba"."business_id") FILTER (WHERE ("eba"."business_id" IS NOT NULL)), ARRAY[]::"uuid"[]) AS "business_ids",
    COALESCE("array_agg"(DISTINCT "roe"."employee_role_id") FILTER (WHERE ("roe"."employee_role_id" IS NOT NULL)), ARRAY[]::"uuid"[]) AS "employee_role_ids",
    COALESCE(( SELECT "json_agg"("t"."distinct_roles") AS "json_agg"
           FROM ( SELECT "json_build_object"('role_id', "er_1"."employee_role_id", 'role_name', "er_1"."name", 'business_id', "er_1"."business_id") AS "distinct_roles"
                   FROM ( SELECT DISTINCT "employee_roles"."employee_role_id",
                            "employee_roles"."name",
                            "employee_roles"."business_id"
                           FROM "public"."employee_roles"
                          WHERE (("employee_roles"."business_id" = "up"."business_id") AND ("employee_roles"."employee_role_id" = ANY ("array_agg"("roe"."employee_role_id"))))) "er_1") "t"), '[]'::"json") AS "employee_roles",
    "up"."business_id"
   FROM ((((("public"."employees" "e"
     JOIN "public"."users" "u" ON (("e"."employee_id" = "u"."user_id")))
     LEFT JOIN "public"."employee_branch_access" "eba" ON (("e"."employee_id" = "eba"."employee_id")))
     LEFT JOIN "public"."roles_of_employees" "roe" ON (("e"."employee_id" = "roe"."employee_id")))
     LEFT JOIN "public"."employee_roles" "er" ON (("roe"."employee_role_id" = "er"."employee_role_id")))
     CROSS JOIN "user_props" "up")
  GROUP BY "e"."employee_id", "e"."code", "e"."org_id", "u"."name", "u"."email", "u"."phone", "e"."role", "u"."image", "e"."created_at", "up"."business_id";



CREATE OR REPLACE TRIGGER "clear_sequences_on_delete" BEFORE DELETE ON "public"."businesses" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_clear_sequences"();



CREATE OR REPLACE TRIGGER "create_sequences_on_insert" AFTER INSERT ON "public"."businesses" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_create_sequences"();



CREATE OR REPLACE TRIGGER "customer_sale_invoice" AFTER INSERT OR UPDATE ON "public"."sales" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://awfbsiftpwpiczdxlmig.supabase.co/functions/v1/notification_service', 'POST', '{"Content-type":"application/json"}', '{}', '5000');



CREATE OR REPLACE TRIGGER "purchase_returns_audit_trigger" AFTER INSERT ON "public"."purchase_returns" FOR EACH ROW EXECUTE FUNCTION "public"."handle_purchase_audit"();



CREATE OR REPLACE TRIGGER "purchases_audit_trigger" AFTER INSERT OR UPDATE ON "public"."purchases" FOR EACH ROW EXECUTE FUNCTION "public"."handle_purchase_audit"();



CREATE OR REPLACE TRIGGER "sale_returns_audit_trigger" AFTER INSERT ON "public"."sale_returns" FOR EACH ROW EXECUTE FUNCTION "public"."handle_sale_audit"();



CREATE OR REPLACE TRIGGER "sales_audit_trigger" AFTER INSERT OR UPDATE ON "public"."sales" FOR EACH ROW EXECUTE FUNCTION "public"."handle_sale_audit"();



CREATE OR REPLACE TRIGGER "set_credit_notes_updated_at" BEFORE UPDATE ON "public"."credit_notes" FOR EACH ROW EXECUTE FUNCTION "public"."set_current_timestamp_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_customer_balance" AFTER INSERT OR DELETE OR UPDATE ON "public"."transaction_entries" FOR EACH ROW EXECUTE FUNCTION "public"."update_customer_balance_from_entry"();



CREATE OR REPLACE TRIGGER "trigger_update_supplier_balance" AFTER INSERT OR DELETE OR UPDATE ON "public"."transaction_entries" FOR EACH ROW EXECUTE FUNCTION "public"."update_supplier_balance_from_entry"();



CREATE OR REPLACE TRIGGER "update_account_balance_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."transaction_entries" FOR EACH ROW EXECUTE FUNCTION "public"."update_account_balance"();



ALTER TABLE ONLY "public"."account_categories"
    ADD CONSTRAINT "account_categories_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."account_categories"("category_id");



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."accounts"
    ADD CONSTRAINT "accounts_parent_account_id_fkey" FOREIGN KEY ("parent_account_id") REFERENCES "public"."accounts"("account_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."addon_prices"
    ADD CONSTRAINT "addon_prices_addon_id_fkey" FOREIGN KEY ("addon_id") REFERENCES "public"."addons"("addon_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."addons"
    ADD CONSTRAINT "addons_linked_feature_id_fkey" FOREIGN KEY ("linked_feature_id") REFERENCES "public"."features"("feature_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."business_customers"
    ADD CONSTRAINT "business_customers_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."business_customers"
    ADD CONSTRAINT "business_customers_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("customer_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."business_customers"
    ADD CONSTRAINT "business_customers_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."businesses"
    ADD CONSTRAINT "businesses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."businesses"
    ADD CONSTRAINT "businesses_fiscal_id_fkey" FOREIGN KEY ("fiscal_id") REFERENCES "public"."fiscal_years"("fiscal_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."businesses"
    ADD CONSTRAINT "businesses_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_state_id_fkey" FOREIGN KEY ("state_id") REFERENCES "public"."states"("id");



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "credit_notes_billing_address_fkey" FOREIGN KEY ("billing_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "credit_notes_shipping_address_fkey" FOREIGN KEY ("shipping_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."customer_addresses"
    ADD CONSTRAINT "customer_addresses_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("customer_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."customers"
    ADD CONSTRAINT "customers_user_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_branch_access"
    ADD CONSTRAINT "employee_branch_access_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_branch_access"
    ADD CONSTRAINT "employee_branch_access_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_roles"
    ADD CONSTRAINT "employee_roles_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expense_categories"
    ADD CONSTRAINT "expense_category_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_expense_category_id_fkey" FOREIGN KEY ("expense_category_id") REFERENCES "public"."expense_categories"("category_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."credit_note_items"
    ADD CONSTRAINT "fk_credit_note_items_item_id" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."credit_note_items"
    ADD CONSTRAINT "fk_credit_note_items_to_credit_note" FOREIGN KEY ("business_id", "customer_id", "credit_note_id") REFERENCES "public"."credit_notes"("business_id", "customer_id", "credit_note_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "fk_credit_notes_created_by_employee" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "fk_credit_notes_to_business_customer" FOREIGN KEY ("business_id", "customer_id") REFERENCES "public"."business_customers"("business_id", "customer_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."credit_notes"
    ADD CONSTRAINT "fk_credit_notes_to_invoice" FOREIGN KEY ("business_id", "customer_id", "invoice_id") REFERENCES "public"."invoices"("business_id", "customer_id", "invoice_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."invoice_items"
    ADD CONSTRAINT "fk_invoice_items_item_id" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."invoice_items"
    ADD CONSTRAINT "fk_invoice_items_to_invoice" FOREIGN KEY ("business_id", "customer_id", "invoice_id") REFERENCES "public"."invoices"("business_id", "customer_id", "invoice_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "fk_invoices_created_by_employee" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "fk_invoices_to_business_customer" FOREIGN KEY ("business_id", "customer_id") REFERENCES "public"."business_customers"("business_id", "customer_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."payments_received"
    ADD CONSTRAINT "fk_payments_created_by_employee" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."payments_received"
    ADD CONSTRAINT "fk_payments_to_business_customer" FOREIGN KEY ("business_id", "customer_id") REFERENCES "public"."business_customers"("business_id", "customer_id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."payments_received"
    ADD CONSTRAINT "fk_payments_to_invoice" FOREIGN KEY ("business_id", "customer_id", "invoice_id") REFERENCES "public"."invoices"("business_id", "customer_id", "invoice_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."quote_items"
    ADD CONSTRAINT "fk_quote_items_item_id" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."quote_items"
    ADD CONSTRAINT "fk_quote_items_to_quote" FOREIGN KEY ("business_id", "customer_id", "quote_id") REFERENCES "public"."quotes"("business_id", "customer_id", "quote_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "fk_quotes_created_by_employee" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "fk_quotes_to_business_customer" FOREIGN KEY ("business_id", "customer_id") REFERENCES "public"."business_customers"("business_id", "customer_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."refund_payments"
    ADD CONSTRAINT "fk_refund_created_by_employee" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."refund_payments"
    ADD CONSTRAINT "fk_refund_to_business_customer" FOREIGN KEY ("business_id", "customer_id") REFERENCES "public"."business_customers"("business_id", "customer_id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."refund_payments"
    ADD CONSTRAINT "fk_refund_to_invoice" FOREIGN KEY ("business_id", "customer_id", "invoice_id") REFERENCES "public"."invoices"("business_id", "customer_id", "invoice_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."refund_payments"
    ADD CONSTRAINT "fk_refund_to_source_payment" FOREIGN KEY ("source_payment_id") REFERENCES "public"."payments_received"("payment_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "fk_reverses_transaction" FOREIGN KEY ("reverses_transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "fk_transactions_item_id" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."floor"
    ADD CONSTRAINT "floor_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."income_categories"
    ADD CONSTRAINT "income_category_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_income_category_id_fkey" FOREIGN KEY ("income_category_id") REFERENCES "public"."income_categories"("category_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."incomes"
    ADD CONSTRAINT "incomes_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_billing_address_fkey" FOREIGN KEY ("billing_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_shipping_address_fkey" FOREIGN KEY ("shipping_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."item_categories"
    ADD CONSTRAINT "item_categories_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."item_categories"
    ADD CONSTRAINT "item_categories_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."item_custom_field_definitions"
    ADD CONSTRAINT "item_custom_field_definitions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."item_custom_field_values"
    ADD CONSTRAINT "item_custom_field_values_field_id_fkey" FOREIGN KEY ("field_id") REFERENCES "public"."item_custom_field_definitions"("field_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."item_custom_field_values"
    ADD CONSTRAINT "item_custom_field_values_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("brand_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_item_category_id_fkey" FOREIGN KEY ("item_category_id") REFERENCES "public"."item_categories"("item_category_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_preferred_vendor_id_fkey" FOREIGN KEY ("preferred_vendor_id") REFERENCES "public"."suppliers"("supplier_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_tax_id_fkey" FOREIGN KEY ("tax_id") REFERENCES "public"."taxes"("tax_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "public"."units"("unit_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_link_id_fkey" FOREIGN KEY ("link_id") REFERENCES "public"."links"("link_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "permissions_role_id_fkey" FOREIGN KEY ("employee_role_id") REFERENCES "public"."employee_roles"("employee_role_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."plan_features"
    ADD CONSTRAINT "plan_features_feature_id_fkey" FOREIGN KEY ("feature_id") REFERENCES "public"."features"("feature_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."plan_features"
    ADD CONSTRAINT "plan_features_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."plan_prices"
    ADD CONSTRAINT "plan_prices_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."links"
    ADD CONSTRAINT "public_links_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "public"."modules"("module_id");



ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "public_permissions_module_id_fkey" FOREIGN KEY ("module_id") REFERENCES "public"."modules"("module_id");



ALTER TABLE ONLY "public"."purchase_audits"
    ADD CONSTRAINT "purchase_audits_performed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."purchase_audits"
    ADD CONSTRAINT "purchase_audits_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "public"."purchases"("purchase_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_audits"
    ADD CONSTRAINT "purchase_audits_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_custom_field_definitions"
    ADD CONSTRAINT "purchase_custom_field_definitions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_custom_field_values"
    ADD CONSTRAINT "purchase_custom_field_values_field_id_fkey" FOREIGN KEY ("field_id") REFERENCES "public"."purchase_custom_field_definitions"("field_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_custom_field_values"
    ADD CONSTRAINT "purchase_custom_field_values_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "public"."purchases"("purchase_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "public"."purchases"("purchase_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_items"
    ADD CONSTRAINT "purchase_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_purchase_item_id_fkey" FOREIGN KEY ("purchase_item_id") REFERENCES "public"."purchase_items"("purchase_item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchase_return_items"
    ADD CONSTRAINT "purchase_return_items_return_id_fkey" FOREIGN KEY ("return_id") REFERENCES "public"."purchase_returns"("return_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "purchase_returns_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "purchase_returns_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "purchase_returns_purchase_id_fkey" FOREIGN KEY ("purchase_id") REFERENCES "public"."purchases"("purchase_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchase_returns"
    ADD CONSTRAINT "purchase_returns_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("supplier_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."purchases"
    ADD CONSTRAINT "purchases_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_billing_address_fkey" FOREIGN KEY ("billing_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."quotes"
    ADD CONSTRAINT "quotes_shipping_address_fkey" FOREIGN KEY ("shipping_address") REFERENCES "public"."customer_addresses"("customer_addresses_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."razorpay_addons"
    ADD CONSTRAINT "razorpay_addons_addon_id_fkey" FOREIGN KEY ("addon_id") REFERENCES "public"."addons"("addon_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."razorpay_plans"
    ADD CONSTRAINT "razorpay_plans_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id");



ALTER TABLE ONLY "public"."referrals"
    ADD CONSTRAINT "referrals_reseller_id_fkey" FOREIGN KEY ("reseller_id") REFERENCES "public"."resellers"("reseller_id");



ALTER TABLE ONLY "public"."roles_of_employees"
    ADD CONSTRAINT "roles_of_employees_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roles_of_employees"
    ADD CONSTRAINT "roles_of_employees_employee_role_id_fkey" FOREIGN KEY ("employee_role_id") REFERENCES "public"."employee_roles"("employee_role_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_audits"
    ADD CONSTRAINT "sale_audits_performed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."sale_audits"
    ADD CONSTRAINT "sale_audits_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "public"."sales"("sale_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_audits"
    ADD CONSTRAINT "sale_audits_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_custom_field_definitions"
    ADD CONSTRAINT "sale_custom_field_definitions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_custom_field_values"
    ADD CONSTRAINT "sale_custom_field_values_field_id_fkey" FOREIGN KEY ("field_id") REFERENCES "public"."sale_custom_field_definitions"("field_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_custom_field_values"
    ADD CONSTRAINT "sale_custom_field_values_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "public"."sales"("sale_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_sale_item_id_fkey" FOREIGN KEY ("sale_item_id") REFERENCES "public"."sale_items"("sale_item_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_sub_service_id_fkey" FOREIGN KEY ("sub_service_id") REFERENCES "public"."subservices"("sub_service_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sale_item_subservices"
    ADD CONSTRAINT "sale_item_subservices_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "public"."sales"("sale_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_items"
    ADD CONSTRAINT "sale_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sale_return_items"
    ADD CONSTRAINT "sale_return_items_return_id_fkey" FOREIGN KEY ("return_id") REFERENCES "public"."sale_returns"("return_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_return_items"
    ADD CONSTRAINT "sale_return_items_sale_item_id_fkey" FOREIGN KEY ("sale_item_id") REFERENCES "public"."sale_items"("sale_item_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "sale_returns_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "sale_returns_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "sale_returns_sale_id_fkey" FOREIGN KEY ("sale_id") REFERENCES "public"."sales"("sale_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sale_returns"
    ADD CONSTRAINT "sale_returns_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("customer_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_status_id_fkey" FOREIGN KEY ("status_id") REFERENCES "public"."statuses"("status_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "public"."table"("table_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."states"
    ADD CONSTRAINT "states_country_id_fkey" FOREIGN KEY ("country_id") REFERENCES "public"."countries"("id");



ALTER TABLE ONLY "public"."statuses"
    ADD CONSTRAINT "statuses_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_adjustment_id_fkey" FOREIGN KEY ("adjustment_id") REFERENCES "public"."stock_adjustments"("adjustment_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustment_items"
    ADD CONSTRAINT "stock_adjustment_items_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_performed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."stock_adjustments"
    ADD CONSTRAINT "stock_adjustments_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscription_invoices"
    ADD CONSTRAINT "subscription_invoices_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "public"."subscriptions"("subscription_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_addon_id_fkey" FOREIGN KEY ("addon_id") REFERENCES "public"."addons"("addon_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subscriptions"
    ADD CONSTRAINT "subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."subservices"
    ADD CONSTRAINT "subservices_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."subservices"
    ADD CONSTRAINT "subservices_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "public"."items"("item_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."subservices"
    ADD CONSTRAINT "subservices_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."suppliers"
    ADD CONSTRAINT "suppliers_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."employees"("employee_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."table"
    ADD CONSTRAINT "table_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."table"
    ADD CONSTRAINT "table_floor_id_fkey" FOREIGN KEY ("floor_id") REFERENCES "public"."floor"("floor_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."taxes"
    ADD CONSTRAINT "taxes_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."taxes"
    ADD CONSTRAINT "taxes_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transaction_entries"
    ADD CONSTRAINT "transaction_entries_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "public"."accounts"("account_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transaction_entries"
    ADD CONSTRAINT "transaction_entries_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transaction_entries"
    ADD CONSTRAINT "transaction_entries_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("transaction_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transaction_entries"
    ADD CONSTRAINT "transaction_entries_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("supplier_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions"
    ADD CONSTRAINT "transactions_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."units"
    ADD CONSTRAINT "units_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."units"
    ADD CONSTRAINT "units_org_id_fkey" FOREIGN KEY ("org_id") REFERENCES "public"."organizations"("org_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_roles"
    ADD CONSTRAINT "user_roles_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."whatsapp_integration"
    ADD CONSTRAINT "whatsapp_integration_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "public"."businesses"("business_id") ON UPDATE CASCADE ON DELETE CASCADE;





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."businesses";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."organizations";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."sales";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."subscriptions";






REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT ALL ON SCHEMA "public" TO PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."adjust_stock"("p_adjustment_json" "jsonb", "p_business_id" "uuid", "p_org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."adjust_stock"("p_adjustment_json" "jsonb", "p_business_id" "uuid", "p_org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."adjust_stock"("p_adjustment_json" "jsonb", "p_business_id" "uuid", "p_org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."archive_customer"("p_customer_id" "uuid", "p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."archive_customer"("p_customer_id" "uuid", "p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_customer"("p_customer_id" "uuid", "p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."archive_item"("p_item_id" "uuid", "p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."archive_item"("p_item_id" "uuid", "p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_item"("p_item_id" "uuid", "p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."archive_supplier"("p_supplier_id" "uuid", "p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."archive_supplier"("p_supplier_id" "uuid", "p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_supplier"("p_supplier_id" "uuid", "p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."build_account_node"("_account_id" "uuid", "_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."build_account_node"("_account_id" "uuid", "_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."build_account_node"("_account_id" "uuid", "_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."bulk_import_items"("p_import_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."bulk_import_items"("p_import_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."bulk_import_items"("p_import_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_expired_trials"() TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_expired_trials"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_expired_trials"() TO "service_role";



GRANT ALL ON FUNCTION "public"."change_phone_or_email"() TO "anon";
GRANT ALL ON FUNCTION "public"."change_phone_or_email"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."change_phone_or_email"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_user_exists"("p_email" "text", "p_phone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_user_exists"("p_email" "text", "p_phone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_user_exists"("p_email" "text", "p_phone" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."clear_sequences"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."clear_sequences"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."clear_sequences"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_addon_subscription_package"("p_org_id" "uuid", "p_addon_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_item_id" "text", "p_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_quantity" integer, "p_billing_cycle" "public"."billing_cycle_enum", "p_country_code" character varying, "p_currency_code" character varying, "p_trial_end_date" timestamp with time zone, "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."create_addon_subscription_package"("p_org_id" "uuid", "p_addon_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_item_id" "text", "p_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_quantity" integer, "p_billing_cycle" "public"."billing_cycle_enum", "p_country_code" character varying, "p_currency_code" character varying, "p_trial_end_date" timestamp with time zone, "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_addon_subscription_package"("p_org_id" "uuid", "p_addon_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_item_id" "text", "p_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_quantity" integer, "p_billing_cycle" "public"."billing_cycle_enum", "p_country_code" character varying, "p_currency_code" character varying, "p_trial_end_date" timestamp with time zone, "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_credit_note"("p_credit_note_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_credit_note"("p_credit_note_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_credit_note"("p_credit_note_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_default_chart_of_accounts"("p_business_id" "uuid", "p_org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_default_chart_of_accounts"("p_business_id" "uuid", "p_org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_default_chart_of_accounts"("p_business_id" "uuid", "p_org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_invoice"("p_invoice_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_invoice"("p_invoice_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_invoice"("p_invoice_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_paid_subscription_package"("p_org_id" "uuid", "p_plan_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_plan_id" "text", "p_end_date" timestamp with time zone, "p_trial_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_billing_cycle" "public"."billing_cycle_enum", "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."create_paid_subscription_package"("p_org_id" "uuid", "p_plan_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_plan_id" "text", "p_end_date" timestamp with time zone, "p_trial_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_billing_cycle" "public"."billing_cycle_enum", "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_paid_subscription_package"("p_org_id" "uuid", "p_plan_id" integer, "p_payment_provider_subscription_id" "text", "p_initial_status" "public"."subscription_status_enum", "p_start_date" timestamp with time zone, "p_payment_provider" "text", "p_payment_provider_plan_id" "text", "p_end_date" timestamp with time zone, "p_trial_end_date" timestamp with time zone, "p_invoices" "jsonb", "p_payment_url" "text", "p_metadata" "jsonb", "p_billing_cycle" "public"."billing_cycle_enum", "p_current_start" timestamp with time zone, "p_current_end" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_payment"("p_payment_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_payment"("p_payment_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_payment"("p_payment_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_payment_and_update_invoice"("p_payment_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_payment_and_update_invoice"("p_payment_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_payment_and_update_invoice"("p_payment_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_payment_received"("p_payment_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_payment_received"("p_payment_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_payment_received"("p_payment_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_purchase"("p_purchase_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_purchase"("p_purchase_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_purchase"("p_purchase_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_purchase_return"("p_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_purchase_return"("p_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_purchase_return"("p_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_quote"("p_quote_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_quote"("p_quote_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_quote"("p_quote_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_refund"("p_refund_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_refund"("p_refund_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_refund"("p_refund_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_sale"("p_sale_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_sale"("p_sale_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_sale"("p_sale_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_sale_return"("p_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_sale_return"("p_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_sale_return"("p_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_sequences"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_sequences"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_sequences"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_credit_note"("p_credit_note_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_credit_note"("p_credit_note_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_credit_note"("p_credit_note_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_invoice"("p_invoice_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_invoice"("p_invoice_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_invoice"("p_invoice_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_payment_received"("p_payment_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_payment_received"("p_payment_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_payment_received"("p_payment_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_refund"("p_refund_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_refund"("p_refund_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_refund"("p_refund_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."edit_credit_note"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."edit_credit_note"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_credit_note"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."edit_credit_note_after_application"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."edit_credit_note_after_application"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_credit_note_after_application"("p_credit_note_id" "uuid", "p_update_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."edit_invoice"("p_invoice_id" "uuid", "p_update_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."edit_invoice"("p_invoice_id" "uuid", "p_update_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_invoice"("p_invoice_id" "uuid", "p_update_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."edit_payment_received"("p_payment_id" "uuid", "p_update_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."edit_payment_received"("p_payment_id" "uuid", "p_update_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."edit_payment_received"("p_payment_id" "uuid", "p_update_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."ensure_credit_note_sequence"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."ensure_credit_note_sequence"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."ensure_credit_note_sequence"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."find_missing_default_accounts"() TO "anon";
GRANT ALL ON FUNCTION "public"."find_missing_default_accounts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."find_missing_default_accounts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."format_invoice_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."format_invoice_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."format_invoice_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."format_payment_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."format_payment_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."format_payment_code"("p_business_id" "uuid", "p_sequence_number" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_business_dependencies"("business_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_business_dependencies"("business_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_business_dependencies"("business_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_short_id"("p_length" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."generate_short_id"("p_length" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_short_id"("p_length" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid", "p_org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid", "p_org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_business_summaries"("p_business_id" "uuid", "p_org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_chart_of_accounts_tree"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_chart_of_accounts_tree"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_chart_of_accounts_tree"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_fiscal_period"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_fiscal_period"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_fiscal_period"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_daily_transactions_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_daily_transactions_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_daily_transactions_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_dashboard_data"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_dashboard_data"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_dashboard_data"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_employee_sales_report"("start_date" timestamp with time zone, "end_date" timestamp with time zone, "page_number" integer, "page_size" integer, "p_business_id" "uuid", "employee_name_filter" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_employee_sales_report"("start_date" timestamp with time zone, "end_date" timestamp with time zone, "page_number" integer, "page_size" integer, "p_business_id" "uuid", "employee_name_filter" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employee_sales_report"("start_date" timestamp with time zone, "end_date" timestamp with time zone, "page_number" integer, "page_size" integer, "p_business_id" "uuid", "employee_name_filter" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_employee_sales_summary_total"("page_number" integer, "page_size" integer, "p_business_id" "uuid", "start_date" "date", "end_date" "date", "employee_name_filter" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_employee_sales_summary_total"("page_number" integer, "page_size" integer, "p_business_id" "uuid", "start_date" "date", "end_date" "date", "employee_name_filter" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_employee_sales_summary_total"("page_number" integer, "page_size" integer, "p_business_id" "uuid", "start_date" "date", "end_date" "date", "employee_name_filter" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_claim"("claim" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_current_org_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_current_org_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_current_org_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_user_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_user_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_user_type"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_credit_note_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_credit_note_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_credit_note_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_invoice_code"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_invoice_code"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_invoice_code"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_item_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_item_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_item_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_payment_code_preview"("p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_payment_code_preview"("p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_payment_code_preview"("p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_purchase_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_purchase_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_purchase_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_purchase_return_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_purchase_return_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_purchase_return_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_quote_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_quote_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_quote_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_sale_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_sale_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_sale_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_next_sale_return_code"("business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_next_sale_return_code"("business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_next_sale_return_code"("business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_brand"("p_business_id" "uuid", "p_brand_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_brand"("p_business_id" "uuid", "p_brand_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_brand"("p_business_id" "uuid", "p_brand_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_item_category"("p_business_id" "uuid", "p_category_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_item_category"("p_business_id" "uuid", "p_category_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_item_category"("p_business_id" "uuid", "p_category_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_unit"("p_business_id" "uuid", "p_unit_name" "text", "p_unit_short_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_unit"("p_business_id" "uuid", "p_unit_name" "text", "p_unit_short_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_unit"("p_business_id" "uuid", "p_unit_name" "text", "p_unit_short_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_party_transaction_summary"("party_type" "text", "party_id" "uuid", "p_business_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_party_transaction_summary"("party_type" "text", "party_id" "uuid", "p_business_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_party_transaction_summary"("party_type" "text", "party_id" "uuid", "p_business_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_profit_and_loss"("p_business_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."get_profit_and_loss"("p_business_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_profit_and_loss"("p_business_id" "uuid", "p_start_date" "date", "p_end_date" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_promotional_addon_details"("p_country_code" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_promotional_addon_details"("p_country_code" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_promotional_addon_details"("p_country_code" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_promotional_plan_details"("p_country_code" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_promotional_plan_details"("p_country_code" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_promotional_plan_details"("p_country_code" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_purchase_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_role_permissions"("role_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_role_permissions"("role_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_role_permissions"("role_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sales_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sidebar"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_sidebar"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sidebar"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_total_dues_summary"("p_business_id" "uuid", "p_org_id" "uuid", "p_start_date" timestamp with time zone, "p_end_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_existing_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_existing_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_existing_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_free_plan_switch"("p_org_id" "uuid", "p_start_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."handle_free_plan_switch"("p_org_id" "uuid", "p_start_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_free_plan_switch"("p_org_id" "uuid", "p_start_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_employee"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_employee"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_employee"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_purchase_audit"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_purchase_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_purchase_audit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_sale_audit"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_sale_audit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_sale_audit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_employee_of_any_org"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_employee_of_any_org"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_employee_of_any_org"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_employee_of_org"("p_user_id" "uuid", "p_org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_employee_of_org"("p_user_id" "uuid", "p_org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_employee_of_org"("p_user_id" "uuid", "p_org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."register_business"("business_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."register_business"("business_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."register_business"("business_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."reverse_stock_adjustment"("p_original_adjustment_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."reverse_stock_adjustment"("p_original_adjustment_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reverse_stock_adjustment"("p_original_adjustment_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."reverse_transaction"("p_original_transaction_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."reverse_transaction"("p_original_transaction_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reverse_transaction"("p_original_transaction_id" "uuid", "p_reversal_date" timestamp with time zone, "p_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_current_timestamp_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."settle_purchase_payment"("p_purchase_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."settle_purchase_payment"("p_purchase_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."settle_purchase_payment"("p_purchase_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."settle_sale_payment"("p_sale_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."settle_sale_payment"("p_sale_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."settle_sale_payment"("p_sale_id" "uuid", "p_amount" numeric, "p_payment_mode" "text", "p_payment_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_customer_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_customer_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_customer_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_clear_sequences"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_clear_sequences"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_clear_sequences"() TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_create_sequences"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_create_sequences"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_create_sequences"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_account_balance"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_account_balance"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_account_balance"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_credit_note_status"("p_credit_note_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_credit_note_status"("p_credit_note_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_credit_note_status"("p_credit_note_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_customer_balance_from_entry"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_customer_balance_from_entry"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_customer_balance_from_entry"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_invoice_status"("p_invoice_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_invoice_status"("p_invoice_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_invoice_status"("p_invoice_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_quote"("p_quote_id_to_update" "uuid", "p_update_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_quote"("p_quote_id_to_update" "uuid", "p_update_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_quote"("p_quote_id_to_update" "uuid", "p_update_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_sale"("p_sale_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_sale"("p_sale_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_sale"("p_sale_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_supplier_balance_from_entry"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_supplier_balance_from_entry"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_supplier_balance_from_entry"() TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_business_customer"("p_customer_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_business_customer"("p_customer_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_business_customer"("p_customer_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_employee_role"("employee_role_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_employee_role"("employee_role_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_employee_role"("employee_role_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_expense"("p_expense_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_expense"("p_expense_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_expense"("p_expense_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_income"("p_income_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_income"("p_income_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_income"("p_income_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_item"("item_json" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_item"("item_json" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_item"("item_json" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_supplier"("p_supplier_data" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_supplier"("p_supplier_data" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_supplier"("p_supplier_data" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_transaction_balance"("p_transaction_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."verify_transaction_balance"("p_transaction_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_transaction_balance"("p_transaction_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_user_password"("password" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."verify_user_password"("password" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_user_password"("password" "text") TO "service_role";



GRANT ALL ON TABLE "public"."account_categories" TO "anon";
GRANT ALL ON TABLE "public"."account_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."account_categories" TO "service_role";
GRANT ALL ON TABLE "public"."account_categories" TO "supabase_admin";



GRANT ALL ON TABLE "public"."accounts" TO "anon";
GRANT ALL ON TABLE "public"."accounts" TO "authenticated";
GRANT ALL ON TABLE "public"."accounts" TO "service_role";
GRANT ALL ON TABLE "public"."accounts" TO "supabase_admin";



GRANT ALL ON TABLE "public"."addon_prices" TO "anon";
GRANT ALL ON TABLE "public"."addon_prices" TO "authenticated";
GRANT ALL ON TABLE "public"."addon_prices" TO "service_role";



GRANT ALL ON SEQUENCE "public"."addon_prices_addon_price_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."addon_prices_addon_price_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."addon_prices_addon_price_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."addons" TO "anon";
GRANT ALL ON TABLE "public"."addons" TO "authenticated";
GRANT ALL ON TABLE "public"."addons" TO "service_role";



GRANT ALL ON SEQUENCE "public"."addons_addon_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."addons_addon_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."addons_addon_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."brands" TO "anon";
GRANT ALL ON TABLE "public"."brands" TO "authenticated";
GRANT ALL ON TABLE "public"."brands" TO "service_role";
GRANT ALL ON TABLE "public"."brands" TO "supabase_admin";



GRANT ALL ON TABLE "public"."business_customers" TO "anon";
GRANT ALL ON TABLE "public"."business_customers" TO "authenticated";
GRANT ALL ON TABLE "public"."business_customers" TO "service_role";



GRANT ALL ON TABLE "public"."customers" TO "anon";
GRANT ALL ON TABLE "public"."customers" TO "authenticated";
GRANT ALL ON TABLE "public"."customers" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";
GRANT ALL ON TABLE "public"."users" TO "supabase_admin";



GRANT ALL ON TABLE "public"."business_customer_view" TO "anon";
GRANT ALL ON TABLE "public"."business_customer_view" TO "authenticated";
GRANT ALL ON TABLE "public"."business_customer_view" TO "service_role";



GRANT ALL ON TABLE "public"."businesses" TO "anon";
GRANT ALL ON TABLE "public"."businesses" TO "authenticated";
GRANT ALL ON TABLE "public"."businesses" TO "service_role";
GRANT ALL ON TABLE "public"."businesses" TO "supabase_admin";



GRANT ALL ON TABLE "public"."cities" TO "anon";
GRANT ALL ON TABLE "public"."cities" TO "authenticated";
GRANT ALL ON TABLE "public"."cities" TO "service_role";



GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."cities_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticated";
GRANT ALL ON TABLE "public"."countries" TO "service_role";



GRANT ALL ON SEQUENCE "public"."countries_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."countries_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."countries_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."credit_note_items" TO "anon";
GRANT ALL ON TABLE "public"."credit_note_items" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_note_items" TO "service_role";



GRANT ALL ON TABLE "public"."credit_notes" TO "anon";
GRANT ALL ON TABLE "public"."credit_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_notes" TO "service_role";



GRANT ALL ON TABLE "public"."customer_addresses" TO "anon";
GRANT ALL ON TABLE "public"."customer_addresses" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_addresses" TO "service_role";



GRANT ALL ON TABLE "public"."employee_view" TO "anon";
GRANT ALL ON TABLE "public"."employee_view" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_view" TO "service_role";



GRANT ALL ON TABLE "public"."invoice_items" TO "anon";
GRANT ALL ON TABLE "public"."invoice_items" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice_items" TO "service_role";



GRANT ALL ON TABLE "public"."invoices" TO "anon";
GRANT ALL ON TABLE "public"."invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."invoices" TO "service_role";



GRANT ALL ON TABLE "public"."item_categories" TO "anon";
GRANT ALL ON TABLE "public"."item_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."item_categories" TO "service_role";
GRANT ALL ON TABLE "public"."item_categories" TO "supabase_admin";



GRANT ALL ON TABLE "public"."item_custom_field_definitions" TO "anon";
GRANT ALL ON TABLE "public"."item_custom_field_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."item_custom_field_definitions" TO "service_role";
GRANT ALL ON TABLE "public"."item_custom_field_definitions" TO "supabase_admin";



GRANT ALL ON TABLE "public"."item_custom_field_values" TO "anon";
GRANT ALL ON TABLE "public"."item_custom_field_values" TO "authenticated";
GRANT ALL ON TABLE "public"."item_custom_field_values" TO "service_role";
GRANT ALL ON TABLE "public"."item_custom_field_values" TO "supabase_admin";



GRANT ALL ON TABLE "public"."items" TO "anon";
GRANT ALL ON TABLE "public"."items" TO "authenticated";
GRANT ALL ON TABLE "public"."items" TO "service_role";
GRANT ALL ON TABLE "public"."items" TO "supabase_admin";



GRANT ALL ON TABLE "public"."subservices" TO "anon";
GRANT ALL ON TABLE "public"."subservices" TO "authenticated";
GRANT ALL ON TABLE "public"."subservices" TO "service_role";
GRANT ALL ON TABLE "public"."subservices" TO "supabase_admin";



GRANT ALL ON TABLE "public"."suppliers" TO "anon";
GRANT ALL ON TABLE "public"."suppliers" TO "authenticated";
GRANT ALL ON TABLE "public"."suppliers" TO "service_role";
GRANT ALL ON TABLE "public"."suppliers" TO "supabase_admin";



GRANT ALL ON TABLE "public"."taxes" TO "anon";
GRANT ALL ON TABLE "public"."taxes" TO "authenticated";
GRANT ALL ON TABLE "public"."taxes" TO "service_role";
GRANT ALL ON TABLE "public"."taxes" TO "supabase_admin";



GRANT ALL ON TABLE "public"."units" TO "anon";
GRANT ALL ON TABLE "public"."units" TO "authenticated";
GRANT ALL ON TABLE "public"."units" TO "service_role";
GRANT ALL ON TABLE "public"."units" TO "supabase_admin";



GRANT ALL ON TABLE "public"."vw_items" TO "anon";
GRANT ALL ON TABLE "public"."vw_items" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_items" TO "service_role";



GRANT ALL ON TABLE "public"."invoice_details_view" TO "anon";
GRANT ALL ON TABLE "public"."invoice_details_view" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice_details_view" TO "service_role";



GRANT ALL ON TABLE "public"."refund_payments" TO "anon";
GRANT ALL ON TABLE "public"."refund_payments" TO "authenticated";
GRANT ALL ON TABLE "public"."refund_payments" TO "service_role";



GRANT ALL ON TABLE "public"."credit_note_details_view" TO "anon";
GRANT ALL ON TABLE "public"."credit_note_details_view" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_note_details_view" TO "service_role";



GRANT ALL ON TABLE "public"."credit_notes_list_view" TO "anon";
GRANT ALL ON TABLE "public"."credit_notes_list_view" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_notes_list_view" TO "service_role";



GRANT ALL ON TABLE "public"."customer_view" TO "anon";
GRANT ALL ON TABLE "public"."customer_view" TO "authenticated";
GRANT ALL ON TABLE "public"."customer_view" TO "service_role";



GRANT ALL ON TABLE "public"."expense_categories" TO "anon";
GRANT ALL ON TABLE "public"."expense_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."expense_categories" TO "service_role";



GRANT ALL ON TABLE "public"."expenses" TO "anon";
GRANT ALL ON TABLE "public"."expenses" TO "authenticated";
GRANT ALL ON TABLE "public"."expenses" TO "service_role";



GRANT ALL ON TABLE "public"."income_categories" TO "anon";
GRANT ALL ON TABLE "public"."income_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."income_categories" TO "service_role";



GRANT ALL ON TABLE "public"."incomes" TO "anon";
GRANT ALL ON TABLE "public"."incomes" TO "authenticated";
GRANT ALL ON TABLE "public"."incomes" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";
GRANT ALL ON TABLE "public"."payments" TO "supabase_admin";



GRANT ALL ON TABLE "public"."purchase_returns" TO "anon";
GRANT ALL ON TABLE "public"."purchase_returns" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_returns" TO "service_role";



GRANT ALL ON TABLE "public"."purchases" TO "anon";
GRANT ALL ON TABLE "public"."purchases" TO "authenticated";
GRANT ALL ON TABLE "public"."purchases" TO "service_role";



GRANT ALL ON TABLE "public"."sale_returns" TO "anon";
GRANT ALL ON TABLE "public"."sale_returns" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_returns" TO "service_role";



GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";



GRANT ALL ON TABLE "public"."transactions" TO "anon";
GRANT ALL ON TABLE "public"."transactions" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions" TO "service_role";
GRANT ALL ON TABLE "public"."transactions" TO "supabase_admin";



GRANT ALL ON TABLE "public"."daily_transactions_report" TO "anon";
GRANT ALL ON TABLE "public"."daily_transactions_report" TO "authenticated";
GRANT ALL ON TABLE "public"."daily_transactions_report" TO "service_role";



GRANT ALL ON TABLE "public"."employee_branch_access" TO "anon";
GRANT ALL ON TABLE "public"."employee_branch_access" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_branch_access" TO "service_role";
GRANT ALL ON TABLE "public"."employee_branch_access" TO "supabase_admin";



GRANT ALL ON TABLE "public"."employee_branches_view" TO "anon";
GRANT ALL ON TABLE "public"."employee_branches_view" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_branches_view" TO "service_role";



GRANT ALL ON TABLE "public"."employee_roles" TO "anon";
GRANT ALL ON TABLE "public"."employee_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_roles" TO "service_role";
GRANT ALL ON TABLE "public"."employee_roles" TO "supabase_admin";



GRANT ALL ON TABLE "public"."employees" TO "anon";
GRANT ALL ON TABLE "public"."employees" TO "authenticated";
GRANT ALL ON TABLE "public"."employees" TO "service_role";
GRANT ALL ON TABLE "public"."employees" TO "supabase_admin";



GRANT ALL ON TABLE "public"."expense_view" TO "anon";
GRANT ALL ON TABLE "public"."expense_view" TO "authenticated";
GRANT ALL ON TABLE "public"."expense_view" TO "service_role";


GRANT ALL ON TABLE "public"."features" TO "anon";
GRANT ALL ON TABLE "public"."features" TO "authenticated";
GRANT ALL ON TABLE "public"."features" TO "service_role";



GRANT ALL ON SEQUENCE "public"."features_feature_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."features_feature_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."features_feature_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."fiscal_years" TO "anon";
GRANT ALL ON TABLE "public"."fiscal_years" TO "authenticated";
GRANT ALL ON TABLE "public"."fiscal_years" TO "service_role";



GRANT ALL ON TABLE "public"."floor" TO "anon";
GRANT ALL ON TABLE "public"."floor" TO "authenticated";
GRANT ALL ON TABLE "public"."floor" TO "service_role";



GRANT ALL ON TABLE "public"."income_view" TO "anon";
GRANT ALL ON TABLE "public"."income_view" TO "authenticated";
GRANT ALL ON TABLE "public"."income_view" TO "service_role";



GRANT ALL ON TABLE "public"."invoice_view" TO "anon";
GRANT ALL ON TABLE "public"."invoice_view" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice_view" TO "service_role";



GRANT ALL ON TABLE "public"."ledger_parties" TO "anon";
GRANT ALL ON TABLE "public"."ledger_parties" TO "authenticated";
GRANT ALL ON TABLE "public"."ledger_parties" TO "service_role";



GRANT ALL ON TABLE "public"."links" TO "anon";
GRANT ALL ON TABLE "public"."links" TO "authenticated";
GRANT ALL ON TABLE "public"."links" TO "service_role";
GRANT ALL ON TABLE "public"."links" TO "supabase_admin";



GRANT ALL ON SEQUENCE "public"."links_link_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."links_link_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."links_link_id_seq" TO "service_role";
GRANT ALL ON SEQUENCE "public"."links_link_id_seq" TO "supabase_admin";



GRANT ALL ON TABLE "public"."modules" TO "anon";
GRANT ALL ON TABLE "public"."modules" TO "authenticated";
GRANT ALL ON TABLE "public"."modules" TO "service_role";
GRANT ALL ON TABLE "public"."modules" TO "supabase_admin";



GRANT ALL ON SEQUENCE "public"."modules_module_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."modules_module_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."modules_module_id_seq" TO "service_role";
GRANT ALL ON SEQUENCE "public"."modules_module_id_seq" TO "supabase_admin";



GRANT ALL ON TABLE "public"."organizations" TO "anon";
GRANT ALL ON TABLE "public"."organizations" TO "authenticated";
GRANT ALL ON TABLE "public"."organizations" TO "service_role";
GRANT ALL ON TABLE "public"."organizations" TO "supabase_admin";



GRANT ALL ON TABLE "public"."plans" TO "anon";
GRANT ALL ON TABLE "public"."plans" TO "authenticated";
GRANT ALL ON TABLE "public"."plans" TO "service_role";



GRANT ALL ON TABLE "public"."subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."org_details_view" TO "anon";
GRANT ALL ON TABLE "public"."org_details_view" TO "authenticated";
GRANT ALL ON TABLE "public"."org_details_view" TO "service_role";



GRANT ALL ON TABLE "public"."payments_received" TO "anon";
GRANT ALL ON TABLE "public"."payments_received" TO "authenticated";
GRANT ALL ON TABLE "public"."payments_received" TO "service_role";



GRANT ALL ON TABLE "public"."payment_details_view" TO "anon";
GRANT ALL ON TABLE "public"."payment_details_view" TO "authenticated";
GRANT ALL ON TABLE "public"."payment_details_view" TO "service_role";



GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";
GRANT ALL ON TABLE "public"."permissions" TO "supabase_admin";



GRANT ALL ON TABLE "public"."plan_features" TO "anon";
GRANT ALL ON TABLE "public"."plan_features" TO "authenticated";
GRANT ALL ON TABLE "public"."plan_features" TO "service_role";



GRANT ALL ON SEQUENCE "public"."plan_features_plan_feature_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."plan_features_plan_feature_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."plan_features_plan_feature_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."plan_prices" TO "anon";
GRANT ALL ON TABLE "public"."plan_prices" TO "authenticated";
GRANT ALL ON TABLE "public"."plan_prices" TO "service_role";



GRANT ALL ON SEQUENCE "public"."plan_prices_plan_price_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."plan_prices_plan_price_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."plan_prices_plan_price_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."plans_plan_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."plans_plan_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."plans_plan_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."processed_webhook_events" TO "anon";
GRANT ALL ON TABLE "public"."processed_webhook_events" TO "authenticated";
GRANT ALL ON TABLE "public"."processed_webhook_events" TO "service_role";



GRANT ALL ON TABLE "public"."purchase_audits" TO "anon";
GRANT ALL ON TABLE "public"."purchase_audits" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_audits" TO "service_role";



GRANT ALL ON TABLE "public"."purchase_custom_field_definitions" TO "anon";
GRANT ALL ON TABLE "public"."purchase_custom_field_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_custom_field_definitions" TO "service_role";



GRANT ALL ON TABLE "public"."purchase_custom_field_values" TO "anon";
GRANT ALL ON TABLE "public"."purchase_custom_field_values" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_custom_field_values" TO "service_role";



GRANT ALL ON TABLE "public"."purchase_items" TO "anon";
GRANT ALL ON TABLE "public"."purchase_items" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_items" TO "service_role";



GRANT ALL ON TABLE "public"."purchase_return_items" TO "anon";
GRANT ALL ON TABLE "public"."purchase_return_items" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_return_items" TO "service_role";



GRANT ALL ON TABLE "public"."transaction_entries" TO "anon";
GRANT ALL ON TABLE "public"."transaction_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."transaction_entries" TO "service_role";
GRANT ALL ON TABLE "public"."transaction_entries" TO "supabase_admin";



GRANT ALL ON TABLE "public"."purchase_view" TO "anon";
GRANT ALL ON TABLE "public"."purchase_view" TO "authenticated";
GRANT ALL ON TABLE "public"."purchase_view" TO "service_role";



GRANT ALL ON TABLE "public"."quote_items" TO "anon";
GRANT ALL ON TABLE "public"."quote_items" TO "authenticated";
GRANT ALL ON TABLE "public"."quote_items" TO "service_role";



GRANT ALL ON TABLE "public"."quotes" TO "anon";
GRANT ALL ON TABLE "public"."quotes" TO "authenticated";
GRANT ALL ON TABLE "public"."quotes" TO "service_role";



GRANT ALL ON TABLE "public"."quote_details_view" TO "anon";
GRANT ALL ON TABLE "public"."quote_details_view" TO "authenticated";
GRANT ALL ON TABLE "public"."quote_details_view" TO "service_role";



GRANT ALL ON TABLE "public"."quote_view" TO "anon";
GRANT ALL ON TABLE "public"."quote_view" TO "authenticated";
GRANT ALL ON TABLE "public"."quote_view" TO "service_role";



GRANT ALL ON TABLE "public"."razorpay_addons" TO "anon";
GRANT ALL ON TABLE "public"."razorpay_addons" TO "authenticated";
GRANT ALL ON TABLE "public"."razorpay_addons" TO "service_role";



GRANT ALL ON TABLE "public"."razorpay_plans" TO "anon";
GRANT ALL ON TABLE "public"."razorpay_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."razorpay_plans" TO "service_role";



GRANT ALL ON TABLE "public"."referrals" TO "anon";
GRANT ALL ON TABLE "public"."referrals" TO "authenticated";
GRANT ALL ON TABLE "public"."referrals" TO "service_role";
GRANT ALL ON TABLE "public"."referrals" TO "supabase_admin";



GRANT ALL ON TABLE "public"."reseller_referred_businesses" TO "anon";
GRANT ALL ON TABLE "public"."reseller_referred_businesses" TO "authenticated";
GRANT ALL ON TABLE "public"."reseller_referred_businesses" TO "service_role";
GRANT ALL ON TABLE "public"."reseller_referred_businesses" TO "supabase_admin";



GRANT ALL ON TABLE "public"."resellers" TO "anon";
GRANT ALL ON TABLE "public"."resellers" TO "authenticated";
GRANT ALL ON TABLE "public"."resellers" TO "service_role";
GRANT ALL ON TABLE "public"."resellers" TO "supabase_admin";



GRANT ALL ON TABLE "public"."roles_of_employees" TO "anon";
GRANT ALL ON TABLE "public"."roles_of_employees" TO "authenticated";
GRANT ALL ON TABLE "public"."roles_of_employees" TO "service_role";
GRANT ALL ON TABLE "public"."roles_of_employees" TO "supabase_admin";



GRANT ALL ON TABLE "public"."sale_audits" TO "anon";
GRANT ALL ON TABLE "public"."sale_audits" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_audits" TO "service_role";



GRANT ALL ON TABLE "public"."sale_custom_field_definitions" TO "anon";
GRANT ALL ON TABLE "public"."sale_custom_field_definitions" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_custom_field_definitions" TO "service_role";



GRANT ALL ON TABLE "public"."sale_custom_field_values" TO "anon";
GRANT ALL ON TABLE "public"."sale_custom_field_values" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_custom_field_values" TO "service_role";



GRANT ALL ON TABLE "public"."sale_item_subservices" TO "anon";
GRANT ALL ON TABLE "public"."sale_item_subservices" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_item_subservices" TO "service_role";



GRANT ALL ON TABLE "public"."sale_items" TO "anon";
GRANT ALL ON TABLE "public"."sale_items" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_items" TO "service_role";



GRANT ALL ON TABLE "public"."sale_return_items" TO "anon";
GRANT ALL ON TABLE "public"."sale_return_items" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_return_items" TO "service_role";



GRANT ALL ON TABLE "public"."statuses" TO "anon";
GRANT ALL ON TABLE "public"."statuses" TO "authenticated";
GRANT ALL ON TABLE "public"."statuses" TO "service_role";



GRANT ALL ON TABLE "public"."sale_view" TO "anon";
GRANT ALL ON TABLE "public"."sale_view" TO "authenticated";
GRANT ALL ON TABLE "public"."sale_view" TO "service_role";



GRANT ALL ON TABLE "public"."sales_purchases_due_report" TO "anon";
GRANT ALL ON TABLE "public"."sales_purchases_due_report" TO "authenticated";
GRANT ALL ON TABLE "public"."sales_purchases_due_report" TO "service_role";



GRANT ALL ON TABLE "public"."states" TO "anon";
GRANT ALL ON TABLE "public"."states" TO "authenticated";
GRANT ALL ON TABLE "public"."states" TO "service_role";



GRANT ALL ON SEQUENCE "public"."states_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."states_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."states_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."stock_adjustment_items" TO "anon";
GRANT ALL ON TABLE "public"."stock_adjustment_items" TO "authenticated";
GRANT ALL ON TABLE "public"."stock_adjustment_items" TO "service_role";
GRANT ALL ON TABLE "public"."stock_adjustment_items" TO "supabase_admin";



GRANT ALL ON TABLE "public"."stock_adjustments" TO "anon";
GRANT ALL ON TABLE "public"."stock_adjustments" TO "authenticated";
GRANT ALL ON TABLE "public"."stock_adjustments" TO "service_role";
GRANT ALL ON TABLE "public"."stock_adjustments" TO "supabase_admin";



GRANT ALL ON TABLE "public"."subscription_invoices" TO "anon";
GRANT ALL ON TABLE "public"."subscription_invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."subscription_invoices" TO "service_role";



GRANT ALL ON SEQUENCE "public"."subscriptions_subscription_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subscriptions_subscription_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subscriptions_subscription_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."table" TO "anon";
GRANT ALL ON TABLE "public"."table" TO "authenticated";
GRANT ALL ON TABLE "public"."table" TO "service_role";



GRANT ALL ON TABLE "public"."v_purchase_return_items" TO "anon";
GRANT ALL ON TABLE "public"."v_purchase_return_items" TO "authenticated";
GRANT ALL ON TABLE "public"."v_purchase_return_items" TO "service_role";



GRANT ALL ON TABLE "public"."v_purchase_returns" TO "anon";
GRANT ALL ON TABLE "public"."v_purchase_returns" TO "authenticated";
GRANT ALL ON TABLE "public"."v_purchase_returns" TO "service_role";



GRANT ALL ON TABLE "public"."v_purchase_returns_summary" TO "anon";
GRANT ALL ON TABLE "public"."v_purchase_returns_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."v_purchase_returns_summary" TO "service_role";



GRANT ALL ON TABLE "public"."v_sale_return_items" TO "anon";
GRANT ALL ON TABLE "public"."v_sale_return_items" TO "authenticated";
GRANT ALL ON TABLE "public"."v_sale_return_items" TO "service_role";



GRANT ALL ON TABLE "public"."v_sale_returns" TO "anon";
GRANT ALL ON TABLE "public"."v_sale_returns" TO "authenticated";
GRANT ALL ON TABLE "public"."v_sale_returns" TO "service_role";



GRANT ALL ON TABLE "public"."v_sale_returns_summary" TO "anon";
GRANT ALL ON TABLE "public"."v_sale_returns_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."v_sale_returns_summary" TO "service_role";



GRANT ALL ON TABLE "public"."vw_daily_transactions_report_v2" TO "anon";
GRANT ALL ON TABLE "public"."vw_daily_transactions_report_v2" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_daily_transactions_report_v2" TO "service_role";



GRANT ALL ON TABLE "public"."vw_stock_adjustments" TO "anon";
GRANT ALL ON TABLE "public"."vw_stock_adjustments" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_stock_adjustments" TO "service_role";



GRANT ALL ON TABLE "public"."whatsapp_integration" TO "anon";
GRANT ALL ON TABLE "public"."whatsapp_integration" TO "authenticated";
GRANT ALL ON TABLE "public"."whatsapp_integration" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
