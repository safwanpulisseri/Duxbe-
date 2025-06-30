supabase db diff
create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_employee_code";

create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_item_code";

create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_purchase_invoice";

create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_purchase_return_code";

create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_sale_invoice";

create sequence "public"."5b775c31-9f10-4bb2-bafb-4de48ff88c27_sale_return_code";

drop function if exists "public"."delete_stock_adjustment"(p_adjustment_id uuid);

drop function if exists "public"."find_missing_default_accounts"();

drop function if exists "public"."get_daily_transactions_summary"(p_business_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone);

drop function if exists "public"."get_employee_sales_summary_total"(page_number integer, page_size integer, p_business_id uuid, start_date date, end_date date, employee_name_filter text);

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_employee_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_item_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_return_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_return_code";

CREATE UNIQUE INDEX unique_permissions_role_link ON public.permissions USING btree (employee_role_id, link_id);

alter table "public"."permissions" add constraint "unique_permissions_role_link" UNIQUE using index "unique_permissions_role_link";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_business_summaries(p_business_id uuid, p_org_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_profit_and_loss(p_business_id uuid, p_org_id uuid, p_start_date date, p_end_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'get_profit_and_loss: Fetching for Business: %, Org: %, Period: % to %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Fetch Account IDs
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_products_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_services_code AND is_group=FALSE;
    SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_discount_code AND is_group=FALSE;
    
    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_freight_in_code AND is_group=FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_purchase_discount_code AND is_group=FALSE;

    SELECT account_id INTO v_general_income_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_general_income_code AND is_group=FALSE;
    SELECT account_id INTO v_stock_overage_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_stock_overage_code AND is_group=FALSE;

    SELECT category_id INTO v_opex_category_id FROM public.account_categories WHERE business_id=p_business_id AND code=v_opex_category_code;

    -- 1. Calculate Net Sales Revenue
    -- Revenue accounts have CREDIT normal balance. Sales Discount has DEBIT normal balance.
    -- Sum Credits for revenue accounts, sum Debits for sales discount.
    -- Net Sales = (Credit Sales Product + Credit Sales Service + Credit Shipping Rev) - Debit Sales Discount
    
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_products
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_services
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_services_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_shipping
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_shipping_revenue_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Sales Discount is a contra-revenue, normal balance is DEBIT. So we sum debits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_sales_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_cogs_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_freight_in_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_freight_in_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Purchase Discount is a contra-COGS, normal balance is CREDIT. So we sum credits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_purchase_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_purchase_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_general_income_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_income_stock_overage
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_stock_overage_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND a.category_id = v_opex_category_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_purchase_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_sales_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_total_dues_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.settle_purchase_payment(p_purchase_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_purchase_payment: Start. PurchaseID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_purchase_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE p.purchase_id = p_purchase_id 
      AND p.business_id = v_business_id -- Assuming p_business_id is derived from purchase, but better to pass if available
      AND p.org_id = p_org_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase ID %s not found for Org ID %s.', p_purchase_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ap_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN -- Assuming p_payment_mode is TEXT, not ENUM here.
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ap_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Payable account (%s) not found for Business:%, Org:%', v_ap_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-PUR-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record (linking to the original transaction_id of the purchase)
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_purchase_payment: ERROR for PurchaseID:%, OrgID:%. Error: %', p_purchase_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle purchase payment for PurchaseID %s: %s', p_purchase_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.settle_sale_payment(p_sale_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_sale_payment: Start. SaleID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_sale_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE s.sale_id = p_sale_id
      AND s.org_id = p_org_id; -- Assuming sales table has org_id

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale ID %s not found for Org ID %s.', p_sale_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ar_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ar_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Receivable account (%s) not found for Business:%, Org:%', v_ar_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-SAL-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_sale_payment: ERROR for SaleID:%, OrgID:%. Error: %', p_sale_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle sale payment for SaleID %s: %s', p_sale_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.adjust_stock(p_adjustment_json jsonb, p_business_id uuid, p_org_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
        SELECT COALESCE(i.purchase_price, i.last_cost, 0) INTO v_item_cost -- Prioritize last_cost if available over purchase_price
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
        business_id, org_id, transaction_id, created_by, updated_by
    ) VALUES (
        v_adjustment_id, v_reason, v_reference, v_adjusted_date, v_acting_user_id,
        p_business_id, p_org_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
            SELECT COALESCE(i.purchase_price, i.last_cost, 0), i.name INTO v_item_cost, v_item_name
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
$function$
;

CREATE OR REPLACE FUNCTION public.bulk_import_items(p_import_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_addon_subscription_package(p_org_id uuid, p_addon_id integer, p_payment_provider_subscription_id text, p_initial_status subscription_status_enum, p_start_date timestamp with time zone, p_payment_provider text, p_payment_provider_item_id text, p_end_date timestamp with time zone, p_invoices jsonb, p_payment_url text, p_metadata jsonb, p_quantity integer, p_billing_cycle billing_cycle_enum, p_country_code character varying, p_currency_code character varying, p_trial_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_start timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_chart_of_accounts(p_business_id uuid, p_org_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_purchase(p_purchase_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    SELECT public.get_next_purchase_code(v_business_id, v_org_id) INTO v_gen_reference_no; -- Assuming function might need org_id
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
	    paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes,
	    attachment_url, purchase_invoice, 
	    created_at, updated_at
	) VALUES (
	    gen_random_uuid(), 
        v_gen_reference_no, v_supplier_id, v_purchase_date, v_transaction_id,
	    v_subtotal, v_discount_amount, v_tax_amount, v_shipping_charge, v_grand_total,
	    v_paid_amount, v_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes,
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
                     business_id, org_id, created_by, updated_by
	             ) VALUES (
                     gen_random_uuid(),
	                 v_transaction_id, v_purchase_date, v_payment_amount, v_payment_method, v_gen_reference_no, 
                     v_business_id, v_org_id, v_acting_user_id, v_acting_user_id
	             );
	         END;
	    END LOOP;
	END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_purchase: Completed for Txn ID: %, Purchase ID: %', v_transaction_id, v_purchase_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'purchase_id', v_purchase_id, 'reference_no', v_gen_reference_no);

EXCEPTION
	WHEN unique_violation THEN
	    RAISE EXCEPTION 'Failed to create purchase: Unique constraint violated. Invoice No "%s" or Ref No "%s". Detail: %s', v_user_provided_inv_no, v_gen_reference_no, SQLERRM;
	WHEN others THEN
	    RAISE EXCEPTION 'Failed to create purchase for Business: %s, Org: %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sale(p_sale_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_sale_json->>'business_id')::uuid;
    v_org_id              UUID := (p_sale_json->>'org_id')::uuid; -- Assuming org_id is passed
    v_customer_id         UUID := (p_sale_json->>'customer_id')::uuid;
    v_sale_date           TIMESTAMPTZ := COALESCE((p_sale_json->>'sale_date')::timestamptz, now());
    v_notes               TEXT := p_sale_json->>'notes';
    v_attachment_url      TEXT := p_sale_json->>'attachment';
    v_platform		      TEXT := COALESCE(p_sale_json->>'platform', 'Duxbe');
    v_discount_amount     NUMERIC := COALESCE((p_sale_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_sale_json->>'shipping')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_sale_json->>'paid_amount')::numeric, 0);
    v_sale_items          JSONB := p_sale_json->'sale_items';
    v_payment_details     JSONB := p_sale_json->'payment_details';
    v_order_mode          BOOLEAN := COALESCE((p_sale_json->>'order_mode')::boolean, false);
    v_acting_user_id      UUID := COALESCE((p_sale_json->>'employee_id')::uuid, auth.uid());

    -- Internal Calculated Totals
    v_calc_subtotal_goods   NUMERIC := 0; -- For 4110
    v_calc_subtotal_services NUMERIC := 0; -- For 4120 (including subservices)
    v_calc_tax_total      NUMERIC := 0;
    v_calc_grand_total    NUMERIC := 0;
    v_calculated_due_amount NUMERIC;

    -- Internal Vars
    v_transaction_id      UUID;
    v_sale_id             UUID;
    v_status_id           UUID;
    v_gen_reference_no    TEXT;
    v_status              public.transaction_status;
    v_sale_item_data      RECORD;
    v_subservice_data     RECORD;
    v_payment_method      TEXT;
    v_payment_amount      NUMERIC;
    v_total_cogs_value    NUMERIC := 0; -- Sum of COGS for all goods

    -- Account IDs & Codes (COA v6.4)
    v_ar_acc_id                 UUID; -- Accounts Receivable
    v_sales_products_acc_id     UUID; -- Sales Revenue - Products
    v_sales_services_acc_id     UUID; -- Sales Revenue - Services
    v_sales_tax_payable_acc_id  UUID; -- Sales Tax Payable
    v_shipping_revenue_acc_id   UUID; -- Shipping & Handling Revenue
    v_inventory_acc_id          UUID; -- Inventory
    v_cogs_products_acc_id      UUID; -- COGS - Products
    v_cash_in_bank_acc_id       UUID; -- Cash in Bank - Operating
    v_petty_cash_acc_id         UUID; -- Petty Cash
    v_sales_discount_acc_id     UUID; -- Sales Discounts

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

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_sale_items IS NULL OR jsonb_array_length(v_sale_items) = 0 THEN
        RAISE EXCEPTION 'business_id, org_id, and at least one sale_item are required.';
    END IF;
    IF v_sale_date IS NULL THEN v_sale_date := now(); END IF;

    SELECT s.status_id INTO v_status_id FROM public.statuses s
    WHERE s.business_id = v_business_id AND s.org_id = v_org_id AND s.is_default = true AND s.type = 'SALE'::public.status_type LIMIT 1;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Default sale status not found for Business:%, Org:%', v_business_id, v_org_id;
    END IF;

    -- Fetch Account IDs
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
        RAISE EXCEPTION 'One or more core accounts not found. Biz:%, Org:%', v_business_id, v_org_id;
    END IF;

    SELECT public.get_next_sale_code(v_business_id, v_org_id) INTO v_gen_reference_no;

    -- Loop 1: Calculate all totals (subtotals, tax, COGS)
    FOR v_sale_item_data IN
        SELECT x.item_id, x.quantity, x.unit_price, x.subservices, i.item_type, i.inventory_enabled,
               COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name, i.tax_id
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        DECLARE
            v_line_subtotal_item    NUMERIC := v_sale_item_data.quantity * v_sale_item_data.unit_price;
            v_tax_rate              DOUBLE PRECISION := 0;
            v_line_tax_item         NUMERIC := 0;
            v_line_total_subservices NUMERIC := 0;
            v_line_tax_subservices  NUMERIC := 0;
        BEGIN
            IF v_sale_item_data.tax_id IS NOT NULL THEN
                SELECT COALESCE(t.rate, 0) INTO v_tax_rate FROM public.taxes t
                WHERE t.tax_id = v_sale_item_data.tax_id AND t.business_id = v_business_id AND t.org_id = v_org_id;
            END IF;
            v_line_tax_item := v_line_subtotal_item * (v_tax_rate / 100.0);

            IF v_sale_item_data.item_type = 'GOODS'::public.item_type THEN
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
                IF v_sale_item_data.inventory_enabled THEN
                    v_total_cogs_value := v_total_cogs_value + (v_sale_item_data.quantity * v_sale_item_data.item_cost);
                END IF;
            ELSIF v_sale_item_data.item_type = 'SERVICES'::public.item_type THEN
                v_calc_subtotal_services := v_calc_subtotal_services + v_line_subtotal_item;
            ELSE -- Default to goods if type is unknown/null
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
            END IF;

            v_calc_tax_total := v_calc_tax_total + v_line_tax_item;

            IF v_sale_item_data.item_type = 'SERVICES'::public.item_type AND v_sale_item_data.subservices IS NOT NULL AND jsonb_array_length(v_sale_item_data.subservices) > 0 THEN
                FOR v_subservice_data IN
                    SELECT COALESCE((x->>'quantity')::numeric, 1) as quantity,
                           COALESCE((x->>'additional_price')::numeric, 0) as additional_price
                    FROM jsonb_array_elements(v_sale_item_data.subservices) x
                LOOP
                    v_line_total_subservices := v_subservice_data.quantity * v_subservice_data.additional_price;
                    v_calc_subtotal_services := v_calc_subtotal_services + v_line_total_subservices;
                    v_line_tax_subservices := v_line_total_subservices * (v_tax_rate / 100.0);
                    v_calc_tax_total := v_calc_tax_total + v_line_tax_subservices;
                END LOOP;
            END IF;
        END;
    END LOOP;

    v_calc_grand_total := v_calc_subtotal_goods + v_calc_subtotal_services - v_discount_amount + v_shipping_charge + v_calc_tax_total;
    v_calculated_due_amount := v_calc_grand_total - v_paid_amount;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_calc_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
        IF v_customer_id IS NOT NULL THEN v_calculated_due_amount := 0; END IF; -- For known customer, overpayment is credit
    ELSIF v_paid_amount > 0 THEN
        v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE
        v_status := 'PENDING'::public.transaction_status;
    END IF;

    RAISE LOG 'create_sale: Totals: GoodsSub:%, ServSub:%, Tax:%, Ship:%, Disc:%, Grand:%, Paid:%, Due:% Status:%',
        v_calc_subtotal_goods, v_calc_subtotal_services, v_calc_tax_total, v_shipping_charge, v_discount_amount, v_calc_grand_total, v_paid_amount, v_calculated_due_amount, v_status;

    -- 1. Create Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status, total_amount, paid_amount, due_amount,
        notes, business_id, org_id, created_by, updated_by, customer_id
    ) VALUES (
        v_gen_reference_no, 'SALE'::public.transaction_type, v_sale_date, v_status, v_calc_grand_total, v_paid_amount, v_calculated_due_amount,
        v_notes, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_customer_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- 2. Create Sale Header
    INSERT INTO public.sales (
        sale_id, customer_id, sale_date, transaction_id, subtotal, discount_amount, tax_amount, shipping_charge, total_amount,
        paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes, platform, attachment_url, sale_invoice, status_id, order_mode, metadata
    ) VALUES (
        gen_random_uuid(), v_customer_id, v_sale_date, v_transaction_id, (v_calc_subtotal_goods + v_calc_subtotal_services), v_discount_amount, v_calc_tax_total, v_shipping_charge, v_calc_grand_total,
        v_paid_amount, v_calculated_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes, v_platform, v_attachment_url, v_gen_reference_no, v_status_id, v_order_mode, p_sale_json->'metadata'
    ) RETURNING sales.sale_id INTO v_sale_id;

    -- 3. Insert Sale Items, Subservices, Update Inventory, and Create ALL GL Entries
    -- Credit Revenue Accounts (Goods & Services)
    IF v_calc_subtotal_goods > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_products_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_goods, 'Sales Revenue - Products');
    END IF;
    IF v_calc_subtotal_services > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_services_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_services, 'Sales Revenue - Services');
    END IF;

    -- Other Credits & Debits related to the sale total
    IF v_shipping_charge > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_shipping_revenue_acc_id, 'CREDIT'::public.entry_type, v_shipping_charge, 'Shipping & Handling Revenue');
    END IF;
    IF v_calc_tax_total > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_tax_payable_acc_id, 'CREDIT'::public.entry_type, v_calc_tax_total, 'Sales Tax Payable');
    END IF;
    IF v_discount_amount > 0 THEN
         INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
         VALUES (v_transaction_id, v_sales_discount_acc_id, 'DEBIT'::public.entry_type, v_discount_amount, 'Sales Discount');
    END IF;

    -- Debit Accounts Receivable for the Grand Total (Offset by payments below)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_transaction_id, v_ar_acc_id, 'DEBIT'::public.entry_type, v_calc_grand_total, 'Accounts Receivable for Sale ' || v_gen_reference_no);

    -- COGS and Inventory Entries (Loop again to get item-specific COGS)
    FOR v_sale_item_data IN
       SELECT x.item_id, x.quantity, i.item_type, i.inventory_enabled, COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        IF v_sale_item_data.item_type = 'GOODS'::public.item_type AND v_sale_item_data.inventory_enabled THEN
            DECLARE v_cogs_for_item NUMERIC := v_sale_item_data.quantity * v_sale_item_data.item_cost;
            BEGIN
                IF v_cogs_for_item > 0 THEN
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_cogs_products_acc_id, 'DEBIT'::public.entry_type, v_cogs_for_item, 'COGS: ' || v_sale_item_data.item_name);
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_inventory_acc_id, 'CREDIT'::public.entry_type, v_cogs_for_item, 'Inventory Sold: ' || v_sale_item_data.item_name);
                END IF;
                -- Update stock quantity
                UPDATE public.items SET stock_quantity = items.stock_quantity - v_sale_item_data.quantity, updated_at = now(), updated_by = v_acting_user_id
                WHERE items.item_id = v_sale_item_data.item_id;
            END;
        END IF;
        -- Link sale_items and sale_item_subservices (Assuming you have these tables and need to populate them)
        -- This part was simplified to focus on GL; you'd add INSERTs into sale_items and sale_item_subservices here.
    END LOOP;


    -- Process Immediate Payment
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

                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_gen_reference_no);
                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_gen_reference_no);

                     INSERT INTO public.payments (payment_id, transaction_id, payment_date, amount, payment_method, reference_no, business_id, org_id, created_by, updated_by)
                     VALUES (gen_random_uuid(), v_transaction_id, v_sale_date, v_payment_amount, v_payment_method, v_gen_reference_no, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id);
                 END;
            END LOOP;
            IF abs(v_total_payment_processed - v_paid_amount) > 0.01 THEN
                 RAISE WARNING 'create_sale: Sum of payment_details (%) != input paid_amount (%) for Sale %', v_total_payment_processed, v_paid_amount, v_gen_reference_no;
            END IF;
        END;
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_sale: Completed. TxnID:%, SaleID:%', v_transaction_id, v_sale_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'sale_id', v_sale_id, 'reference_no', v_gen_reference_no);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create sale: Unique constraint violated. Ref No "%s". Detail: %s', v_gen_reference_no, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create sale. Biz:%, Org:%. Error: %s. SQLState: %s', v_business_id, v_org_id, SQLERRM, SQLSTATE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sequences(business_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
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
END;
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_business_customer(p_customer_data jsonb)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data
    v_business_id UUID := p_customer_data->>'business_id';
    v_customer_id UUID := p_customer_data->>'customer_id';
    v_name TEXT := p_customer_data->>'name';
    v_image TEXT := p_customer_data->>'image';
    v_address TEXT := p_customer_data->>'address';
    v_opening_balance NUMERIC := COALESCE((p_customer_data->>'customer_balance')::numeric, 0); -- Default to 0
    v_opening_balance_date TIMESTAMPTZ := now();

    -- Internal Variables
    v_user_id UUID := COALESCE(auth.uid(), v_customer_id); -- Assuming Supabase auth or similar acting user
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
            notes, business_id, created_by, customer_id -- Link to customer
        ) VALUES (
            v_ref_no, 'CUSTOMER_OPENING_BALANCE'::public.transaction_type, v_opening_balance_date, 'PAID'::public.transaction_status, -- Mark as PAID/Complete
            abs(v_opening_balance), abs(v_opening_balance), 0, -- Total/Paid amounts are positive magnitude
            'Opening balance setup for customer ' || v_name, v_business_id, v_user_id, v_customer_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_expense(p_expense_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE expense_id = v_expense_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, expense_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_expense_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_expense_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_income(p_income_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE income_id = v_income_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, income_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_income_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_income_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_item(item_json jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
            created_at, updated_at, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_name, v_item_type, v_item_code, v_item_category_id, v_brand_id, v_unit_id,
            v_sales_enabled, v_purchase_enabled, v_inventory_enabled, v_is_returnable,
            v_sale_price, v_retail_price, v_purchase_price, v_alert_quantity, v_preferred_vendor_id,
            v_tax_id, v_images, v_serial_nos, v_rich_text, v_opening_stock_qty, -- Initial quantity is opening stock qty
            v_business_id, v_org_id,
            v_opening_stock_qty, v_opening_stock_value, -- Initial stock quantity & value
            v_opening_stock_qty, v_opening_stock_value, -- Explicitly store OB values
            now(), now(), v_acting_user_id, v_acting_user_id
        )
        RETURNING items.item_id INTO v_item_id_out;

        -- Handle subservices on insert
        IF v_item_type = 'SERVICES' AND item_json->'sub_services' IS NOT NULL THEN -- Assuming item_type is uppercase in ENUM
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
    ELSE
        -- ======== UPDATE PATH ========
        v_item_id_out := v_item_id_in;
        v_is_insert := FALSE;

        UPDATE public.items SET
            name = v_name,
            item_code = v_item_code,
            item_type = v_item_type, -- Allow item_type update?
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
            -- quantity = v_quantity, -- Generally, 'quantity' (current stock) should only be updated by stock transactions, not directly here on item update.
            preferred_vendor_id = v_preferred_vendor_id,
            tax_id = v_tax_id,
            images = v_images,
            serial_nos = v_serial_nos,
            rich_text = v_rich_text,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE items.item_id = v_item_id_out
          AND items.business_id = v_business_id
          AND items.org_id = v_org_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Item ID %s not found for business %s and org %s.', v_item_id_out, v_business_id, v_org_id;
        END IF;

        -- Handle subservice updates
        IF v_item_type = 'SERVICES' AND item_json->'sub_services' IS NOT NULL THEN
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_supplier(p_supplier_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
$function$
;



drop function if exists "public"."delete_stock_adjustment"(p_adjustment_id uuid);

drop function if exists "public"."find_missing_default_accounts"();

drop function if exists "public"."get_daily_transactions_summary"(p_business_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone);

drop function if exists "public"."get_employee_sales_summary_total"(page_number integer, page_size integer, p_business_id uuid, start_date date, end_date date, employee_name_filter text);

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_employee_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_item_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_return_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_return_code";

CREATE UNIQUE INDEX unique_permissions_role_link ON public.permissions USING btree (employee_role_id, link_id);

alter table "public"."permissions" add constraint "unique_permissions_role_link" UNIQUE using index "unique_permissions_role_link";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_user_exists(p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS SETOF auth.users
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM auth.users
    WHERE email = p_email
       OR regexp_replace(phone, '\+', '', 'g') = regexp_replace(p_phone, '\+', '', 'g');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_summaries(p_business_id uuid, p_org_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_profit_and_loss(p_business_id uuid, p_org_id uuid, p_start_date date, p_end_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'get_profit_and_loss: Fetching for Business: %, Org: %, Period: % to %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Fetch Account IDs
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_products_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_services_code AND is_group=FALSE;
    SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_discount_code AND is_group=FALSE;
    
    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_freight_in_code AND is_group=FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_purchase_discount_code AND is_group=FALSE;

    SELECT account_id INTO v_general_income_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_general_income_code AND is_group=FALSE;
    SELECT account_id INTO v_stock_overage_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_stock_overage_code AND is_group=FALSE;

    SELECT category_id INTO v_opex_category_id FROM public.account_categories WHERE business_id=p_business_id AND code=v_opex_category_code;

    -- 1. Calculate Net Sales Revenue
    -- Revenue accounts have CREDIT normal balance. Sales Discount has DEBIT normal balance.
    -- Sum Credits for revenue accounts, sum Debits for sales discount.
    -- Net Sales = (Credit Sales Product + Credit Sales Service + Credit Shipping Rev) - Debit Sales Discount
    
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_products
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_services
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_services_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_shipping
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_shipping_revenue_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Sales Discount is a contra-revenue, normal balance is DEBIT. So we sum debits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_sales_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_cogs_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_freight_in_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_freight_in_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Purchase Discount is a contra-COGS, normal balance is CREDIT. So we sum credits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_purchase_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_purchase_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_general_income_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_income_stock_overage
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_stock_overage_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND a.category_id = v_opex_category_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_purchase_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_sales_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_total_dues_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.settle_purchase_payment(p_purchase_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_purchase_payment: Start. PurchaseID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_purchase_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE p.purchase_id = p_purchase_id 
      AND p.business_id = v_business_id -- Assuming p_business_id is derived from purchase, but better to pass if available
      AND p.org_id = p_org_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase ID %s not found for Org ID %s.', p_purchase_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ap_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN -- Assuming p_payment_mode is TEXT, not ENUM here.
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ap_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Payable account (%s) not found for Business:%, Org:%', v_ap_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-PUR-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record (linking to the original transaction_id of the purchase)
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_purchase_payment: ERROR for PurchaseID:%, OrgID:%. Error: %', p_purchase_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle purchase payment for PurchaseID %s: %s', p_purchase_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.settle_sale_payment(p_sale_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_sale_payment: Start. SaleID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_sale_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE s.sale_id = p_sale_id
      AND s.org_id = p_org_id; -- Assuming sales table has org_id

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale ID %s not found for Org ID %s.', p_sale_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ar_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ar_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Receivable account (%s) not found for Business:%, Org:%', v_ar_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-SAL-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_sale_payment: ERROR for SaleID:%, OrgID:%. Error: %', p_sale_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle sale payment for SaleID %s: %s', p_sale_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.adjust_stock(p_adjustment_json jsonb, p_business_id uuid, p_org_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
        SELECT COALESCE(i.purchase_price, i.last_cost, 0) INTO v_item_cost -- Prioritize last_cost if available over purchase_price
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
        business_id, org_id, transaction_id, created_by, updated_by
    ) VALUES (
        v_adjustment_id, v_reason, v_reference, v_adjusted_date, v_acting_user_id,
        p_business_id, p_org_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
            SELECT COALESCE(i.purchase_price, i.last_cost, 0), i.name INTO v_item_cost, v_item_name
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
$function$
;

CREATE OR REPLACE FUNCTION public.bulk_import_items(p_import_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_addon_subscription_package(p_org_id uuid, p_addon_id integer, p_payment_provider_subscription_id text, p_initial_status subscription_status_enum, p_start_date timestamp with time zone, p_payment_provider text, p_payment_provider_item_id text, p_end_date timestamp with time zone, p_invoices jsonb, p_payment_url text, p_metadata jsonb, p_quantity integer, p_billing_cycle billing_cycle_enum, p_country_code character varying, p_currency_code character varying, p_trial_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_start timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_chart_of_accounts(p_business_id uuid, p_org_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_purchase(p_purchase_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    SELECT public.get_next_purchase_code(v_business_id, v_org_id) INTO v_gen_reference_no; -- Assuming function might need org_id
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
	    paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes,
	    attachment_url, purchase_invoice, 
	    created_at, updated_at
	) VALUES (
	    gen_random_uuid(), 
        v_gen_reference_no, v_supplier_id, v_purchase_date, v_transaction_id,
	    v_subtotal, v_discount_amount, v_tax_amount, v_shipping_charge, v_grand_total,
	    v_paid_amount, v_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes,
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
                     business_id, org_id, created_by, updated_by
	             ) VALUES (
                     gen_random_uuid(),
	                 v_transaction_id, v_purchase_date, v_payment_amount, v_payment_method, v_gen_reference_no, 
                     v_business_id, v_org_id, v_acting_user_id, v_acting_user_id
	             );
	         END;
	    END LOOP;
	END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_purchase: Completed for Txn ID: %, Purchase ID: %', v_transaction_id, v_purchase_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'purchase_id', v_purchase_id, 'reference_no', v_gen_reference_no);

EXCEPTION
	WHEN unique_violation THEN
	    RAISE EXCEPTION 'Failed to create purchase: Unique constraint violated. Invoice No "%s" or Ref No "%s". Detail: %s', v_user_provided_inv_no, v_gen_reference_no, SQLERRM;
	WHEN others THEN
	    RAISE EXCEPTION 'Failed to create purchase for Business: %s, Org: %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sale(p_sale_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_sale_json->>'business_id')::uuid;
    v_org_id              UUID := (p_sale_json->>'org_id')::uuid; -- Assuming org_id is passed
    v_customer_id         UUID := (p_sale_json->>'customer_id')::uuid;
    v_sale_date           TIMESTAMPTZ := COALESCE((p_sale_json->>'sale_date')::timestamptz, now());
    v_notes               TEXT := p_sale_json->>'notes';
    v_attachment_url      TEXT := p_sale_json->>'attachment';
    v_platform		      TEXT := COALESCE(p_sale_json->>'platform', 'Duxbe');
    v_discount_amount     NUMERIC := COALESCE((p_sale_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_sale_json->>'shipping')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_sale_json->>'paid_amount')::numeric, 0);
    v_sale_items          JSONB := p_sale_json->'sale_items';
    v_payment_details     JSONB := p_sale_json->'payment_details';
    v_order_mode          BOOLEAN := COALESCE((p_sale_json->>'order_mode')::boolean, false);
    v_acting_user_id      UUID := COALESCE((p_sale_json->>'employee_id')::uuid, auth.uid());

    -- Internal Calculated Totals
    v_calc_subtotal_goods   NUMERIC := 0; -- For 4110
    v_calc_subtotal_services NUMERIC := 0; -- For 4120 (including subservices)
    v_calc_tax_total      NUMERIC := 0;
    v_calc_grand_total    NUMERIC := 0;
    v_calculated_due_amount NUMERIC;

    -- Internal Vars
    v_transaction_id      UUID;
    v_sale_id             UUID;
    v_status_id           UUID;
    v_gen_reference_no    TEXT;
    v_status              public.transaction_status;
    v_sale_item_data      RECORD;
    v_subservice_data     RECORD;
    v_payment_method      TEXT;
    v_payment_amount      NUMERIC;
    v_total_cogs_value    NUMERIC := 0; -- Sum of COGS for all goods

    -- Account IDs & Codes (COA v6.4)
    v_ar_acc_id                 UUID; -- Accounts Receivable
    v_sales_products_acc_id     UUID; -- Sales Revenue - Products
    v_sales_services_acc_id     UUID; -- Sales Revenue - Services
    v_sales_tax_payable_acc_id  UUID; -- Sales Tax Payable
    v_shipping_revenue_acc_id   UUID; -- Shipping & Handling Revenue
    v_inventory_acc_id          UUID; -- Inventory
    v_cogs_products_acc_id      UUID; -- COGS - Products
    v_cash_in_bank_acc_id       UUID; -- Cash in Bank - Operating
    v_petty_cash_acc_id         UUID; -- Petty Cash
    v_sales_discount_acc_id     UUID; -- Sales Discounts

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

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_sale_items IS NULL OR jsonb_array_length(v_sale_items) = 0 THEN
        RAISE EXCEPTION 'business_id, org_id, and at least one sale_item are required.';
    END IF;
    IF v_sale_date IS NULL THEN v_sale_date := now(); END IF;

    SELECT s.status_id INTO v_status_id FROM public.statuses s
    WHERE s.business_id = v_business_id AND s.org_id = v_org_id AND s.is_default = true AND s.type = 'SALE'::public.status_type LIMIT 1;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Default sale status not found for Business:%, Org:%', v_business_id, v_org_id;
    END IF;

    -- Fetch Account IDs
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
        RAISE EXCEPTION 'One or more core accounts not found. Biz:%, Org:%', v_business_id, v_org_id;
    END IF;

    SELECT public.get_next_sale_code(v_business_id, v_org_id) INTO v_gen_reference_no;

    -- Loop 1: Calculate all totals (subtotals, tax, COGS)
    FOR v_sale_item_data IN
        SELECT x.item_id, x.quantity, x.unit_price, x.subservices, i.item_type, i.inventory_enabled,
               COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name, i.tax_id
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        DECLARE
            v_line_subtotal_item    NUMERIC := v_sale_item_data.quantity * v_sale_item_data.unit_price;
            v_tax_rate              DOUBLE PRECISION := 0;
            v_line_tax_item         NUMERIC := 0;
            v_line_total_subservices NUMERIC := 0;
            v_line_tax_subservices  NUMERIC := 0;
        BEGIN
            IF v_sale_item_data.tax_id IS NOT NULL THEN
                SELECT COALESCE(t.rate, 0) INTO v_tax_rate FROM public.taxes t
                WHERE t.tax_id = v_sale_item_data.tax_id AND t.business_id = v_business_id AND t.org_id = v_org_id;
            END IF;
            v_line_tax_item := v_line_subtotal_item * (v_tax_rate / 100.0);

            IF v_sale_item_data.item_type = 'GOODS'::public.item_type THEN
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
                IF v_sale_item_data.inventory_enabled THEN
                    v_total_cogs_value := v_total_cogs_value + (v_sale_item_data.quantity * v_sale_item_data.item_cost);
                END IF;
            ELSIF v_sale_item_data.item_type = 'SERVICES'::public.item_type THEN
                v_calc_subtotal_services := v_calc_subtotal_services + v_line_subtotal_item;
            ELSE -- Default to goods if type is unknown/null
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
            END IF;

            v_calc_tax_total := v_calc_tax_total + v_line_tax_item;

            IF v_sale_item_data.item_type = 'SERVICES'::public.item_type AND v_sale_item_data.subservices IS NOT NULL AND jsonb_array_length(v_sale_item_data.subservices) > 0 THEN
                FOR v_subservice_data IN
                    SELECT COALESCE((x->>'quantity')::numeric, 1) as quantity,
                           COALESCE((x->>'additional_price')::numeric, 0) as additional_price
                    FROM jsonb_array_elements(v_sale_item_data.subservices) x
                LOOP
                    v_line_total_subservices := v_subservice_data.quantity * v_subservice_data.additional_price;
                    v_calc_subtotal_services := v_calc_subtotal_services + v_line_total_subservices;
                    v_line_tax_subservices := v_line_total_subservices * (v_tax_rate / 100.0);
                    v_calc_tax_total := v_calc_tax_total + v_line_tax_subservices;
                END LOOP;
            END IF;
        END;
    END LOOP;

    v_calc_grand_total := v_calc_subtotal_goods + v_calc_subtotal_services - v_discount_amount + v_shipping_charge + v_calc_tax_total;
    v_calculated_due_amount := v_calc_grand_total - v_paid_amount;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_calc_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
        IF v_customer_id IS NOT NULL THEN v_calculated_due_amount := 0; END IF; -- For known customer, overpayment is credit
    ELSIF v_paid_amount > 0 THEN
        v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE
        v_status := 'PENDING'::public.transaction_status;
    END IF;

    RAISE LOG 'create_sale: Totals: GoodsSub:%, ServSub:%, Tax:%, Ship:%, Disc:%, Grand:%, Paid:%, Due:% Status:%',
        v_calc_subtotal_goods, v_calc_subtotal_services, v_calc_tax_total, v_shipping_charge, v_discount_amount, v_calc_grand_total, v_paid_amount, v_calculated_due_amount, v_status;

    -- 1. Create Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status, total_amount, paid_amount, due_amount,
        notes, business_id, org_id, created_by, updated_by, customer_id
    ) VALUES (
        v_gen_reference_no, 'SALE'::public.transaction_type, v_sale_date, v_status, v_calc_grand_total, v_paid_amount, v_calculated_due_amount,
        v_notes, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_customer_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- 2. Create Sale Header
    INSERT INTO public.sales (
        sale_id, customer_id, sale_date, transaction_id, subtotal, discount_amount, tax_amount, shipping_charge, total_amount,
        paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes, platform, attachment_url, sale_invoice, status_id, order_mode, metadata
    ) VALUES (
        gen_random_uuid(), v_customer_id, v_sale_date, v_transaction_id, (v_calc_subtotal_goods + v_calc_subtotal_services), v_discount_amount, v_calc_tax_total, v_shipping_charge, v_calc_grand_total,
        v_paid_amount, v_calculated_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes, v_platform, v_attachment_url, v_gen_reference_no, v_status_id, v_order_mode, p_sale_json->'metadata'
    ) RETURNING sales.sale_id INTO v_sale_id;

    -- 3. Insert Sale Items, Subservices, Update Inventory, and Create ALL GL Entries
    -- Credit Revenue Accounts (Goods & Services)
    IF v_calc_subtotal_goods > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_products_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_goods, 'Sales Revenue - Products');
    END IF;
    IF v_calc_subtotal_services > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_services_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_services, 'Sales Revenue - Services');
    END IF;

    -- Other Credits & Debits related to the sale total
    IF v_shipping_charge > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_shipping_revenue_acc_id, 'CREDIT'::public.entry_type, v_shipping_charge, 'Shipping & Handling Revenue');
    END IF;
    IF v_calc_tax_total > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_tax_payable_acc_id, 'CREDIT'::public.entry_type, v_calc_tax_total, 'Sales Tax Payable');
    END IF;
    IF v_discount_amount > 0 THEN
         INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
         VALUES (v_transaction_id, v_sales_discount_acc_id, 'DEBIT'::public.entry_type, v_discount_amount, 'Sales Discount');
    END IF;

    -- Debit Accounts Receivable for the Grand Total (Offset by payments below)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_transaction_id, v_ar_acc_id, 'DEBIT'::public.entry_type, v_calc_grand_total, 'Accounts Receivable for Sale ' || v_gen_reference_no);

    -- COGS and Inventory Entries (Loop again to get item-specific COGS)
    FOR v_sale_item_data IN
       SELECT x.item_id, x.quantity, i.item_type, i.inventory_enabled, COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        IF v_sale_item_data.item_type = 'GOODS'::public.item_type AND v_sale_item_data.inventory_enabled THEN
            DECLARE v_cogs_for_item NUMERIC := v_sale_item_data.quantity * v_sale_item_data.item_cost;
            BEGIN
                IF v_cogs_for_item > 0 THEN
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_cogs_products_acc_id, 'DEBIT'::public.entry_type, v_cogs_for_item, 'COGS: ' || v_sale_item_data.item_name);
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_inventory_acc_id, 'CREDIT'::public.entry_type, v_cogs_for_item, 'Inventory Sold: ' || v_sale_item_data.item_name);
                END IF;
                -- Update stock quantity
                UPDATE public.items SET stock_quantity = items.stock_quantity - v_sale_item_data.quantity, updated_at = now(), updated_by = v_acting_user_id
                WHERE items.item_id = v_sale_item_data.item_id;
            END;
        END IF;
        -- Link sale_items and sale_item_subservices (Assuming you have these tables and need to populate them)
        -- This part was simplified to focus on GL; you'd add INSERTs into sale_items and sale_item_subservices here.
    END LOOP;


    -- Process Immediate Payment
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

                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_gen_reference_no);
                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_gen_reference_no);

                     INSERT INTO public.payments (payment_id, transaction_id, payment_date, amount, payment_method, reference_no, business_id, org_id, created_by, updated_by)
                     VALUES (gen_random_uuid(), v_transaction_id, v_sale_date, v_payment_amount, v_payment_method, v_gen_reference_no, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id);
                 END;
            END LOOP;
            IF abs(v_total_payment_processed - v_paid_amount) > 0.01 THEN
                 RAISE WARNING 'create_sale: Sum of payment_details (%) != input paid_amount (%) for Sale %', v_total_payment_processed, v_paid_amount, v_gen_reference_no;
            END IF;
        END;
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_sale: Completed. TxnID:%, SaleID:%', v_transaction_id, v_sale_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'sale_id', v_sale_id, 'reference_no', v_gen_reference_no);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create sale: Unique constraint violated. Ref No "%s". Detail: %s', v_gen_reference_no, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create sale. Biz:%, Org:%. Error: %s. SQLState: %s', v_business_id, v_org_id, SQLERRM, SQLSTATE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sequences(business_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
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
END;
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_business_customer(p_customer_data jsonb)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data
    v_business_id UUID := p_customer_data->>'business_id';
    v_customer_id UUID := p_customer_data->>'customer_id';
    v_name TEXT := p_customer_data->>'name';
    v_image TEXT := p_customer_data->>'image';
    v_address TEXT := p_customer_data->>'address';
    v_opening_balance NUMERIC := COALESCE((p_customer_data->>'customer_balance')::numeric, 0); -- Default to 0
    v_opening_balance_date TIMESTAMPTZ := now();

    -- Internal Variables
    v_user_id UUID := COALESCE(auth.uid(), v_customer_id); -- Assuming Supabase auth or similar acting user
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
            notes, business_id, created_by, customer_id -- Link to customer
        ) VALUES (
            v_ref_no, 'CUSTOMER_OPENING_BALANCE'::public.transaction_type, v_opening_balance_date, 'PAID'::public.transaction_status, -- Mark as PAID/Complete
            abs(v_opening_balance), abs(v_opening_balance), 0, -- Total/Paid amounts are positive magnitude
            'Opening balance setup for customer ' || v_name, v_business_id, v_user_id, v_customer_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_expense(p_expense_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE expense_id = v_expense_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, expense_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_expense_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_expense_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_income(p_income_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE income_id = v_income_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, income_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_income_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_income_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_item(item_json jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
            created_at, updated_at, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_name, v_item_type, v_item_code, v_item_category_id, v_brand_id, v_unit_id,
            v_sales_enabled, v_purchase_enabled, v_inventory_enabled, v_is_returnable,
            v_sale_price, v_retail_price, v_purchase_price, v_alert_quantity, v_preferred_vendor_id,
            v_tax_id, v_images, v_serial_nos, v_rich_text, v_opening_stock_qty, -- Initial quantity is opening stock qty
            v_business_id, v_org_id,
            v_opening_stock_qty, v_opening_stock_value, -- Initial stock quantity & value
            v_opening_stock_qty, v_opening_stock_value, -- Explicitly store OB values
            now(), now(), v_acting_user_id, v_acting_user_id
        )
        RETURNING items.item_id INTO v_item_id_out;

        -- Handle subservices on insert
        IF v_item_type = 'SERVICES' AND item_json->'sub_services' IS NOT NULL THEN -- Assuming item_type is uppercase in ENUM
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
    ELSE
        -- ======== UPDATE PATH ========
        v_item_id_out := v_item_id_in;
        v_is_insert := FALSE;

        UPDATE public.items SET
            name = v_name,
            item_code = v_item_code,
            item_type = v_item_type, -- Allow item_type update?
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
            -- quantity = v_quantity, -- Generally, 'quantity' (current stock) should only be updated by stock transactions, not directly here on item update.
            preferred_vendor_id = v_preferred_vendor_id,
            tax_id = v_tax_id,
            images = v_images,
            serial_nos = v_serial_nos,
            rich_text = v_rich_text,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE items.item_id = v_item_id_out
          AND items.business_id = v_business_id
          AND items.org_id = v_org_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Item ID %s not found for business %s and org %s.', v_item_id_out, v_business_id, v_org_id;
        END IF;

        -- Handle subservice updates
        IF v_item_type = 'SERVICES' AND item_json->'sub_services' IS NOT NULL THEN
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_supplier(p_supplier_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
$function$
;



create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_employee_code";

create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_item_code";

create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_purchase_invoice";

create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_purchase_return_code";

create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_sale_invoice";

create sequence "public"."61494012-f9c0-45bc-ae7c-c8f4cd468dc8_sale_return_code";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_employee_code";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_item_code";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_purchase_invoice";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_purchase_return_code";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_sale_invoice";

create sequence "public"."a537748d-7ecd-4709-a1a3-1f9f86825f64_sale_return_code";

drop function if exists "public"."delete_stock_adjustment"(p_adjustment_id uuid);

drop function if exists "public"."find_missing_default_accounts"();

drop function if exists "public"."get_daily_transactions_summary"(p_business_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone);

drop function if exists "public"."get_employee_sales_summary_total"(page_number integer, page_size integer, p_business_id uuid, start_date date, end_date date, employee_name_filter text);

alter table "public"."items" add column "created_by" uuid;

alter table "public"."items" add column "updated_by" uuid;

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_employee_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_item_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_purchase_return_code";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_invoice";

drop sequence if exists "public"."7cabe91b-9fb3-4530-b95d-d48566305e08_sale_return_code";

CREATE UNIQUE INDEX unique_permissions_role_link ON public.permissions USING btree (employee_role_id, link_id);

alter table "public"."items" add constraint "items_created_by_fkey" FOREIGN KEY (created_by) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."items" validate constraint "items_created_by_fkey";

alter table "public"."items" add constraint "items_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES employees(employee_id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."items" validate constraint "items_updated_by_fkey";

alter table "public"."permissions" add constraint "unique_permissions_role_link" UNIQUE using index "unique_permissions_role_link";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_user_exists(p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS SETOF auth.users
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        *
    FROM auth.users
    WHERE email = p_email
       OR regexp_replace(phone, '\+', '', 'g') = regexp_replace(p_phone, '\+', '', 'g');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_summaries(p_business_id uuid, p_org_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_profit_and_loss(p_business_id uuid, p_org_id uuid, p_start_date date, p_end_date date)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'get_profit_and_loss: Fetching for Business: %, Org: %, Period: % to %', 
        p_business_id, p_org_id, p_start_date, p_end_date;

    -- Fetch Account IDs
    SELECT account_id INTO v_sales_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_products_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_services_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_services_code AND is_group=FALSE;
    SELECT account_id INTO v_shipping_revenue_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_shipping_revenue_code AND is_group=FALSE;
    SELECT account_id INTO v_sales_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_sales_discount_code AND is_group=FALSE;
    
    SELECT account_id INTO v_cogs_products_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_cogs_products_code AND is_group=FALSE;
    SELECT account_id INTO v_freight_in_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_freight_in_code AND is_group=FALSE;
    SELECT account_id INTO v_purchase_discount_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_purchase_discount_code AND is_group=FALSE;

    SELECT account_id INTO v_general_income_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_general_income_code AND is_group=FALSE;
    SELECT account_id INTO v_stock_overage_acc_id FROM public.accounts WHERE business_id=p_business_id AND org_id=p_org_id AND code=v_stock_overage_code AND is_group=FALSE;

    SELECT category_id INTO v_opex_category_id FROM public.account_categories WHERE business_id=p_business_id AND code=v_opex_category_code;

    -- 1. Calculate Net Sales Revenue
    -- Revenue accounts have CREDIT normal balance. Sales Discount has DEBIT normal balance.
    -- Sum Credits for revenue accounts, sum Debits for sales discount.
    -- Net Sales = (Credit Sales Product + Credit Sales Service + Credit Shipping Rev) - Debit Sales Discount
    
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_products
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_services
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_services_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_revenue_shipping
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_shipping_revenue_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Sales Discount is a contra-revenue, normal balance is DEBIT. So we sum debits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_sales_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_sales_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_cogs_products_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'DEBIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_freight_in_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_freight_in_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    -- Purchase Discount is a contra-COGS, normal balance is CREDIT. So we sum credits.
    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_purchase_discounts_total
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_purchase_discount_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_general_income_acc_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date;

    SELECT COALESCE(SUM(CASE WHEN te.entry_type = 'CREDIT' THEN te.amount ELSE -te.amount END), 0)
    INTO v_income_stock_overage
    FROM public.transaction_entries te JOIN public.transactions t ON te.transaction_id = t.transaction_id
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND te.account_id = v_stock_overage_acc_id
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
    WHERE t.business_id = p_business_id AND t.org_id = p_org_id AND a.category_id = v_opex_category_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_purchase_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_sales_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_total_dues_summary(p_business_id uuid, p_org_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.settle_purchase_payment(p_purchase_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_purchase_payment: Start. PurchaseID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_purchase_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE p.purchase_id = p_purchase_id 
      AND p.business_id = v_business_id -- Assuming p_business_id is derived from purchase, but better to pass if available
      AND p.org_id = p_org_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Purchase ID %s not found for Org ID %s.', p_purchase_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ap_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN -- Assuming p_payment_mode is TEXT, not ENUM here.
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ap_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Payable account (%s) not found for Business:%, Org:%', v_ap_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-PUR-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record (linking to the original transaction_id of the purchase)
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_purchase_payment: ERROR for PurchaseID:%, OrgID:%. Error: %', p_purchase_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle purchase payment for PurchaseID %s: %s', p_purchase_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.settle_sale_payment(p_sale_id uuid, p_org_id uuid, p_amount numeric, p_payment_mode text, p_payment_date timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    RAISE LOG 'settle_sale_payment: Start. SaleID:%, OrgID:%, Amount:%, Mode:%, Date:%', 
        p_sale_id, p_org_id, p_amount, p_payment_mode, p_payment_date;

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
    WHERE s.sale_id = p_sale_id
      AND s.org_id = p_org_id; -- Assuming sales table has org_id

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale ID %s not found for Org ID %s.', p_sale_id, p_org_id;
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
        WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_ar_code AND is_group = FALSE;

    IF lower(p_payment_mode) = 'cash' THEN
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_petty_cash_code AND is_group = FALSE;
    ELSE 
        SELECT account_id INTO v_payment_asset_account_id FROM public.accounts 
            WHERE business_id = v_business_id AND org_id = p_org_id AND code = v_cash_in_bank_code AND is_group = FALSE;
    END IF;

    IF v_ar_account_id IS NULL THEN
        RAISE EXCEPTION 'Accounts Receivable account (%s) not found for Business:%, Org:%', v_ar_code, v_business_id, p_org_id;
    END IF;
    IF v_payment_asset_account_id IS NULL THEN
        RAISE EXCEPTION 'Payment asset account (Cash %s or Bank %s) not found for Business:%, Org:%', v_petty_cash_code, v_cash_in_bank_code, v_business_id, p_org_id;
    END IF;

    -- 4. Generate Payment Reference Number
    v_payment_ref_no := 'PAY-SAL-' || public.generate_short_id() || '-' || to_char(p_payment_date, 'YYYYMMDD');

    -- 5. Create Payment Record
    INSERT INTO public.payments (
        payment_id, -- generate new
        transaction_id, payment_date, amount, payment_method, reference_no, 
        business_id, org_id, created_by, updated_by
    ) VALUES (
        gen_random_uuid(),
        v_existing_transaction_id, p_payment_date, p_amount, p_payment_mode, v_payment_ref_no, 
        v_business_id, p_org_id, v_acting_user_id, v_acting_user_id
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
        RAISE LOG 'settle_sale_payment: ERROR for SaleID:%, OrgID:%. Error: %', p_sale_id, p_org_id, SQLERRM;
        RAISE EXCEPTION 'Failed to settle sale payment for SaleID %s: %s', p_sale_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.adjust_stock(p_adjustment_json jsonb, p_business_id uuid, p_org_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
        SELECT COALESCE(i.purchase_price, i.last_cost, 0) INTO v_item_cost -- Prioritize last_cost if available over purchase_price
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
        business_id, org_id, transaction_id, created_by, updated_by
    ) VALUES (
        v_adjustment_id, v_reason, v_reference, v_adjusted_date, v_acting_user_id,
        p_business_id, p_org_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
            SELECT COALESCE(i.purchase_price, i.last_cost, 0), i.name INTO v_item_cost, v_item_name
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
$function$
;

CREATE OR REPLACE FUNCTION public.bulk_import_items(p_import_data jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_addon_subscription_package(p_org_id uuid, p_addon_id integer, p_payment_provider_subscription_id text, p_initial_status subscription_status_enum, p_start_date timestamp with time zone, p_payment_provider text, p_payment_provider_item_id text, p_end_date timestamp with time zone, p_invoices jsonb, p_payment_url text, p_metadata jsonb, p_quantity integer, p_billing_cycle billing_cycle_enum, p_country_code character varying, p_currency_code character varying, p_trial_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_start timestamp with time zone DEFAULT NULL::timestamp with time zone, p_current_end timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_default_chart_of_accounts(p_business_id uuid, p_org_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.create_purchase(p_purchase_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
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
    SELECT public.get_next_purchase_code(v_business_id, v_org_id) INTO v_gen_reference_no; -- Assuming function might need org_id
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
	    paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes,
	    attachment_url, purchase_invoice, 
	    created_at, updated_at
	) VALUES (
	    gen_random_uuid(), 
        v_gen_reference_no, v_supplier_id, v_purchase_date, v_transaction_id,
	    v_subtotal, v_discount_amount, v_tax_amount, v_shipping_charge, v_grand_total,
	    v_paid_amount, v_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes,
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
                     business_id, org_id, created_by, updated_by
	             ) VALUES (
                     gen_random_uuid(),
	                 v_transaction_id, v_purchase_date, v_payment_amount, v_payment_method, v_gen_reference_no, 
                     v_business_id, v_org_id, v_acting_user_id, v_acting_user_id
	             );
	         END;
	    END LOOP;
	END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_purchase: Completed for Txn ID: %, Purchase ID: %', v_transaction_id, v_purchase_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'purchase_id', v_purchase_id, 'reference_no', v_gen_reference_no);

EXCEPTION
	WHEN unique_violation THEN
	    RAISE EXCEPTION 'Failed to create purchase: Unique constraint violated. Invoice No "%s" or Ref No "%s". Detail: %s', v_user_provided_inv_no, v_gen_reference_no, SQLERRM;
	WHEN others THEN
	    RAISE EXCEPTION 'Failed to create purchase for Business: %s, Org: %s. Error: %s', v_business_id, v_org_id, SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sale(p_sale_json jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data Parsed
    v_business_id         UUID := (p_sale_json->>'business_id')::uuid;
    v_org_id              UUID := (p_sale_json->>'org_id')::uuid; -- Assuming org_id is passed
    v_customer_id         UUID := (p_sale_json->>'customer_id')::uuid;
    v_sale_date           TIMESTAMPTZ := COALESCE((p_sale_json->>'sale_date')::timestamptz, now());
    v_notes               TEXT := p_sale_json->>'notes';
    v_attachment_url      TEXT := p_sale_json->>'attachment';
    v_platform		      TEXT := COALESCE(p_sale_json->>'platform', 'Duxbe');
    v_discount_amount     NUMERIC := COALESCE((p_sale_json->>'discount_amount')::numeric, 0);
    v_shipping_charge     NUMERIC := COALESCE((p_sale_json->>'shipping')::numeric, 0);
    v_paid_amount         NUMERIC := COALESCE((p_sale_json->>'paid_amount')::numeric, 0);
    v_sale_items          JSONB := p_sale_json->'sale_items';
    v_payment_details     JSONB := p_sale_json->'payment_details';
    v_order_mode          BOOLEAN := COALESCE((p_sale_json->>'order_mode')::boolean, false);
    v_acting_user_id      UUID := COALESCE((p_sale_json->>'employee_id')::uuid, auth.uid());

    -- Internal Calculated Totals
    v_calc_subtotal_goods   NUMERIC := 0; -- For 4110
    v_calc_subtotal_services NUMERIC := 0; -- For 4120 (including subservices)
    v_calc_tax_total      NUMERIC := 0;
    v_calc_grand_total    NUMERIC := 0;
    v_calculated_due_amount NUMERIC;

    -- Internal Vars
    v_transaction_id      UUID;
    v_sale_id             UUID;
    v_status_id           UUID;
    v_gen_reference_no    TEXT;
    v_status              public.transaction_status;
    v_sale_item_data      RECORD;
    v_subservice_data     RECORD;
    v_payment_method      TEXT;
    v_payment_amount      NUMERIC;
    v_total_cogs_value    NUMERIC := 0; -- Sum of COGS for all goods

    -- Account IDs & Codes (COA v6.4)
    v_ar_acc_id                 UUID; -- Accounts Receivable
    v_sales_products_acc_id     UUID; -- Sales Revenue - Products
    v_sales_services_acc_id     UUID; -- Sales Revenue - Services
    v_sales_tax_payable_acc_id  UUID; -- Sales Tax Payable
    v_shipping_revenue_acc_id   UUID; -- Shipping & Handling Revenue
    v_inventory_acc_id          UUID; -- Inventory
    v_cogs_products_acc_id      UUID; -- COGS - Products
    v_cash_in_bank_acc_id       UUID; -- Cash in Bank - Operating
    v_petty_cash_acc_id         UUID; -- Petty Cash
    v_sales_discount_acc_id     UUID; -- Sales Discounts

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

    IF v_business_id IS NULL OR v_org_id IS NULL OR v_sale_items IS NULL OR jsonb_array_length(v_sale_items) = 0 THEN
        RAISE EXCEPTION 'business_id, org_id, and at least one sale_item are required.';
    END IF;
    IF v_sale_date IS NULL THEN v_sale_date := now(); END IF;

    SELECT s.status_id INTO v_status_id FROM public.statuses s
    WHERE s.business_id = v_business_id AND s.org_id = v_org_id AND s.is_default = true AND s.type = 'SALE'::public.status_type LIMIT 1;
    IF v_status_id IS NULL THEN
        RAISE EXCEPTION 'Default sale status not found for Business:%, Org:%', v_business_id, v_org_id;
    END IF;

    -- Fetch Account IDs
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
        RAISE EXCEPTION 'One or more core accounts not found. Biz:%, Org:%', v_business_id, v_org_id;
    END IF;

    SELECT public.get_next_sale_code(v_business_id, v_org_id) INTO v_gen_reference_no;

    -- Loop 1: Calculate all totals (subtotals, tax, COGS)
    FOR v_sale_item_data IN
        SELECT x.item_id, x.quantity, x.unit_price, x.subservices, i.item_type, i.inventory_enabled,
               COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name, i.tax_id
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric, unit_price numeric, subservices jsonb)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        DECLARE
            v_line_subtotal_item    NUMERIC := v_sale_item_data.quantity * v_sale_item_data.unit_price;
            v_tax_rate              DOUBLE PRECISION := 0;
            v_line_tax_item         NUMERIC := 0;
            v_line_total_subservices NUMERIC := 0;
            v_line_tax_subservices  NUMERIC := 0;
        BEGIN
            IF v_sale_item_data.tax_id IS NOT NULL THEN
                SELECT COALESCE(t.rate, 0) INTO v_tax_rate FROM public.taxes t
                WHERE t.tax_id = v_sale_item_data.tax_id AND t.business_id = v_business_id AND t.org_id = v_org_id;
            END IF;
            v_line_tax_item := v_line_subtotal_item * (v_tax_rate / 100.0);

            IF v_sale_item_data.item_type = 'GOODS'::public.item_type THEN
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
                IF v_sale_item_data.inventory_enabled THEN
                    v_total_cogs_value := v_total_cogs_value + (v_sale_item_data.quantity * v_sale_item_data.item_cost);
                END IF;
            ELSIF v_sale_item_data.item_type = 'SERVICES'::public.item_type THEN
                v_calc_subtotal_services := v_calc_subtotal_services + v_line_subtotal_item;
            ELSE -- Default to goods if type is unknown/null
                v_calc_subtotal_goods := v_calc_subtotal_goods + v_line_subtotal_item;
            END IF;

            v_calc_tax_total := v_calc_tax_total + v_line_tax_item;

            IF v_sale_item_data.item_type = 'SERVICES'::public.item_type AND v_sale_item_data.subservices IS NOT NULL AND jsonb_array_length(v_sale_item_data.subservices) > 0 THEN
                FOR v_subservice_data IN
                    SELECT COALESCE((x->>'quantity')::numeric, 1) as quantity,
                           COALESCE((x->>'additional_price')::numeric, 0) as additional_price
                    FROM jsonb_array_elements(v_sale_item_data.subservices) x
                LOOP
                    v_line_total_subservices := v_subservice_data.quantity * v_subservice_data.additional_price;
                    v_calc_subtotal_services := v_calc_subtotal_services + v_line_total_subservices;
                    v_line_tax_subservices := v_line_total_subservices * (v_tax_rate / 100.0);
                    v_calc_tax_total := v_calc_tax_total + v_line_tax_subservices;
                END LOOP;
            END IF;
        END;
    END LOOP;

    v_calc_grand_total := v_calc_subtotal_goods + v_calc_subtotal_services - v_discount_amount + v_shipping_charge + v_calc_tax_total;
    v_calculated_due_amount := v_calc_grand_total - v_paid_amount;

    IF ROUND(v_paid_amount, 2) >= ROUND(v_calc_grand_total, 2) THEN
        v_status := 'PAID'::public.transaction_status;
        IF v_customer_id IS NOT NULL THEN v_calculated_due_amount := 0; END IF; -- For known customer, overpayment is credit
    ELSIF v_paid_amount > 0 THEN
        v_status := 'PARTIALLY_PAID'::public.transaction_status;
    ELSE
        v_status := 'PENDING'::public.transaction_status;
    END IF;

    RAISE LOG 'create_sale: Totals: GoodsSub:%, ServSub:%, Tax:%, Ship:%, Disc:%, Grand:%, Paid:%, Due:% Status:%',
        v_calc_subtotal_goods, v_calc_subtotal_services, v_calc_tax_total, v_shipping_charge, v_discount_amount, v_calc_grand_total, v_paid_amount, v_calculated_due_amount, v_status;

    -- 1. Create Transaction Header
    INSERT INTO public.transactions (
        reference_no, transaction_type, transaction_date, status, total_amount, paid_amount, due_amount,
        notes, business_id, org_id, created_by, updated_by, customer_id
    ) VALUES (
        v_gen_reference_no, 'SALE'::public.transaction_type, v_sale_date, v_status, v_calc_grand_total, v_paid_amount, v_calculated_due_amount,
        v_notes, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_customer_id
    ) RETURNING transaction_id INTO v_transaction_id;

    -- 2. Create Sale Header
    INSERT INTO public.sales (
        sale_id, customer_id, sale_date, transaction_id, subtotal, discount_amount, tax_amount, shipping_charge, total_amount,
        paid_amount, due_amount, business_id, org_id, created_by, updated_by, notes, platform, attachment_url, sale_invoice, status_id, order_mode, metadata
    ) VALUES (
        gen_random_uuid(), v_customer_id, v_sale_date, v_transaction_id, (v_calc_subtotal_goods + v_calc_subtotal_services), v_discount_amount, v_calc_tax_total, v_shipping_charge, v_calc_grand_total,
        v_paid_amount, v_calculated_due_amount, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id, v_notes, v_platform, v_attachment_url, v_gen_reference_no, v_status_id, v_order_mode, p_sale_json->'metadata'
    ) RETURNING sales.sale_id INTO v_sale_id;

    -- 3. Insert Sale Items, Subservices, Update Inventory, and Create ALL GL Entries
    -- Credit Revenue Accounts (Goods & Services)
    IF v_calc_subtotal_goods > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_products_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_goods, 'Sales Revenue - Products');
    END IF;
    IF v_calc_subtotal_services > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_services_acc_id, 'CREDIT'::public.entry_type, v_calc_subtotal_services, 'Sales Revenue - Services');
    END IF;

    -- Other Credits & Debits related to the sale total
    IF v_shipping_charge > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_shipping_revenue_acc_id, 'CREDIT'::public.entry_type, v_shipping_charge, 'Shipping & Handling Revenue');
    END IF;
    IF v_calc_tax_total > 0 THEN
        INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
        VALUES (v_transaction_id, v_sales_tax_payable_acc_id, 'CREDIT'::public.entry_type, v_calc_tax_total, 'Sales Tax Payable');
    END IF;
    IF v_discount_amount > 0 THEN
         INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
         VALUES (v_transaction_id, v_sales_discount_acc_id, 'DEBIT'::public.entry_type, v_discount_amount, 'Sales Discount');
    END IF;

    -- Debit Accounts Receivable for the Grand Total (Offset by payments below)
    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
    VALUES (v_transaction_id, v_ar_acc_id, 'DEBIT'::public.entry_type, v_calc_grand_total, 'Accounts Receivable for Sale ' || v_gen_reference_no);

    -- COGS and Inventory Entries (Loop again to get item-specific COGS)
    FOR v_sale_item_data IN
       SELECT x.item_id, x.quantity, i.item_type, i.inventory_enabled, COALESCE(i.purchase_price, i.last_cost, 0) as item_cost, i.name as item_name
        FROM jsonb_to_recordset(v_sale_items) AS x(item_id uuid, quantity numeric)
        JOIN public.items i ON i.item_id = x.item_id AND i.business_id = v_business_id AND i.org_id = v_org_id
    LOOP
        IF v_sale_item_data.item_type = 'GOODS'::public.item_type AND v_sale_item_data.inventory_enabled THEN
            DECLARE v_cogs_for_item NUMERIC := v_sale_item_data.quantity * v_sale_item_data.item_cost;
            BEGIN
                IF v_cogs_for_item > 0 THEN
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_cogs_products_acc_id, 'DEBIT'::public.entry_type, v_cogs_for_item, 'COGS: ' || v_sale_item_data.item_name);
                    INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                    VALUES (v_transaction_id, v_inventory_acc_id, 'CREDIT'::public.entry_type, v_cogs_for_item, 'Inventory Sold: ' || v_sale_item_data.item_name);
                END IF;
                -- Update stock quantity
                UPDATE public.items SET stock_quantity = items.stock_quantity - v_sale_item_data.quantity, updated_at = now(), updated_by = v_acting_user_id
                WHERE items.item_id = v_sale_item_data.item_id;
            END;
        END IF;
        -- Link sale_items and sale_item_subservices (Assuming you have these tables and need to populate them)
        -- This part was simplified to focus on GL; you'd add INSERTs into sale_items and sale_item_subservices here.
    END LOOP;


    -- Process Immediate Payment
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

                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_payment_asset_account_id, 'DEBIT'::public.entry_type, v_payment_amount, 'Payment Received (' || v_payment_method || ') for Sale ' || v_gen_reference_no);
                     INSERT INTO public.transaction_entries (transaction_id, account_id, entry_type, amount, description)
                     VALUES (v_transaction_id, v_ar_acc_id, 'CREDIT'::public.entry_type, v_payment_amount, 'Payment Applied to A/R for Sale ' || v_gen_reference_no);

                     INSERT INTO public.payments (payment_id, transaction_id, payment_date, amount, payment_method, reference_no, business_id, org_id, created_by, updated_by)
                     VALUES (gen_random_uuid(), v_transaction_id, v_sale_date, v_payment_amount, v_payment_method, v_gen_reference_no, v_business_id, v_org_id, v_acting_user_id, v_acting_user_id);
                 END;
            END LOOP;
            IF abs(v_total_payment_processed - v_paid_amount) > 0.01 THEN
                 RAISE WARNING 'create_sale: Sum of payment_details (%) != input paid_amount (%) for Sale %', v_total_payment_processed, v_paid_amount, v_gen_reference_no;
            END IF;
        END;
    END IF;

    PERFORM public.verify_transaction_balance(v_transaction_id);
    RAISE LOG 'create_sale: Completed. TxnID:%, SaleID:%', v_transaction_id, v_sale_id;

    RETURN jsonb_build_object('transaction_id', v_transaction_id, 'sale_id', v_sale_id, 'reference_no', v_gen_reference_no);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Failed to create sale: Unique constraint violated. Ref No "%s". Detail: %s', v_gen_reference_no, SQLERRM;
    WHEN others THEN
        RAISE EXCEPTION 'Failed to create sale. Biz:%, Org:%. Error: %s. SQLState: %s', v_business_id, v_org_id, SQLERRM, SQLSTATE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_sequences(business_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
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
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$              DECLARE _PLATFORM TEXT;
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

    RETURN NEW;
END;

$function$
;

CREATE OR REPLACE FUNCTION public.upsert_business_customer(p_customer_data jsonb)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    -- Input Data
    v_business_id UUID := p_customer_data->>'business_id';
    v_customer_id UUID := p_customer_data->>'customer_id';
    v_name TEXT := p_customer_data->>'name';
    v_image TEXT := p_customer_data->>'image';
    v_address TEXT := p_customer_data->>'address';
    v_opening_balance NUMERIC := COALESCE((p_customer_data->>'customer_balance')::numeric, 0); -- Default to 0
    v_opening_balance_date TIMESTAMPTZ := now();

    -- Internal Variables
    v_user_id UUID := COALESCE(auth.uid(), v_customer_id); -- Assuming Supabase auth or similar acting user
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
            notes, business_id, created_by, customer_id -- Link to customer
        ) VALUES (
            v_ref_no, 'CUSTOMER_OPENING_BALANCE'::public.transaction_type, v_opening_balance_date, 'PAID'::public.transaction_status, -- Mark as PAID/Complete
            abs(v_opening_balance), abs(v_opening_balance), 0, -- Total/Paid amounts are positive magnitude
            'Opening balance setup for customer ' || v_name, v_business_id, v_user_id, v_customer_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_expense(p_expense_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE expense_id = v_expense_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, expense_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_expense_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_expense_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_income(p_income_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    IF v_payment_type = 'CASH'::public.payment_type THEN -- Assuming ENUM value is 'CASH'
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
        WHERE income_id = v_income_id AND business_id = v_business_id AND org_id = v_org_id;

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
            business_id, org_id, income_category_id, transaction_id, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_date, v_payment_type, v_income_for, v_amount, v_note, v_ref_no,
            v_business_id, v_org_id, v_income_category_id, v_transaction_id, v_acting_user_id, v_acting_user_id
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_item(item_json jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
            created_at, updated_at, created_by, updated_by
        ) VALUES (
            gen_random_uuid(),
            v_name, v_item_type, v_item_code, v_item_category_id, v_brand_id, v_unit_id,
            v_sales_enabled, v_purchase_enabled, v_inventory_enabled, v_is_returnable,
            v_sale_price, v_retail_price, v_purchase_price, v_alert_quantity, v_preferred_vendor_id,
            v_tax_id, v_images, v_serial_nos, v_rich_text, v_opening_stock_qty, -- Initial quantity is opening stock qty
            v_business_id, v_org_id,
            v_opening_stock_qty, v_opening_stock_value, -- Initial stock quantity & value
            v_opening_stock_qty, v_opening_stock_value, -- Explicitly store OB values
            now(), now(), v_acting_user_id, v_acting_user_id
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
    ELSE
        -- ======== UPDATE PATH ========
        v_item_id_out := v_item_id_in;
        v_is_insert := FALSE;

        UPDATE public.items SET
            name = v_name,
            item_code = v_item_code,
            item_type = v_item_type, -- Allow item_type update?
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
            -- quantity = v_quantity, -- Generally, 'quantity' (current stock) should only be updated by stock transactions, not directly here on item update.
            preferred_vendor_id = v_preferred_vendor_id,
            tax_id = v_tax_id,
            images = v_images,
            serial_nos = v_serial_nos,
            rich_text = v_rich_text,
            updated_at = now(),
            updated_by = v_acting_user_id
        WHERE items.item_id = v_item_id_out
          AND items.business_id = v_business_id
          AND items.org_id = v_org_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Item ID %s not found for business %s and org %s.', v_item_id_out, v_business_id, v_org_id;
        END IF;

        -- Handle subservice updates
        IF v_item_type = 'SERVICES' AND item_json->'sub_services' IS NOT NULL THEN
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
$function$
;

CREATE OR REPLACE FUNCTION public.upsert_supplier(p_supplier_data jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
$function$
;



