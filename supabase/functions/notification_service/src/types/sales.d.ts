import { Employee } from "./employee.d.ts";
import { Item } from "./item.d.ts";

export type Sale = {
    sale_id: string;
    customer_id?: string;
    sale_date: string;
    transaction_id: string;
    subtotal: number;
    discount_amount: number;
    tax_amount: number;
    shipping_charge: number;
    total_amount: number;
    paid_amount: number;
    due_amount: number;
    business_id: string;
    created_by: string;
    notes?: string;
    attachment_url?: string;
    metadata?: Record<string, unknown>;
    created_at: string;
    updated_at: string;
    sale_invoice: string;
    status_id: string;
    order_mode: boolean;
};

export type SaleView = {
    sale_id: string;
    sale_invoice: string;
    customer_id?: string;
    sale_date: string;
    transaction_id: string;
    subtotal: number;
    discount_amount: number;
    tax_amount: number;
    shipping_charge: number;
    total_amount: number;
    paid_amount: number;
    due_amount: number;
    business_id: string;
    created_by: string;
    status_id?: string;
    customer?: Customer;
    status?: Status;
    metadata?: Record<string, unknown>;
    created_at: string;
    updated_at: string;
    employee: Employee;
    business: Business;
    sale_items: SaleItemView[];
    notes?: string;
    attachment_url?: string;
};

export type Status = {
    status_id: string;
    business_id: string;
    name: string;
    sequence_order: number;
    moving_order?: number;
};

export type SaleItemView = {
    sale_item_id: string;
    item_id: string;
    item: Item;
    quantity: number;
    unit_price: number;
    total_price: number;
    subservices?: SaleServiceView[];
};

export type SaleServiceView = {
    sale_item_subservice_id: string;
    sub_service_id: string;
    additional_price: number;
    quantity: number;
    total_additional_price: number;
};

export type Business = {
    business_id: string;
    name: string;
    org_id: string;
    contact_email?: string;
    contact_phone?: string;
    contact_address?: string;
    currency: Currency;
    logo?: string;
    store_name?: string;
    gst_in?: string;
    state?: string;
    country?: string;
    time_zone?: string;
    fiscal_id?: string;
    is_gst_registered?: boolean;
    legal_business_name?: string;
    gst_registered_date?: string;
    trade_name?: string;
    print_on_sale: boolean;
    print_on_purchase: boolean;
    allow_walkin_customer: boolean;
    allow_sales_when_outofstock: boolean;
    business_type: string;
    print_barcode_on_purchase: boolean;
    format: string;
};

export type Customer = {
    customer_id: string;
    name: string;
    email?: string;
    phone?: string;
    image?: string;
};

export type Currency = {
    name: string;
    country_code: string[];
    code?: string;
    symbol?: string;
    flag?: string;
    decimal_digits?: number;
    number?: number;
    name_plural?: string;
};
