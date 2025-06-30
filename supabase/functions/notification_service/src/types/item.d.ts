export enum ItemType {
    goods = "goods",
    services = "services",
}

export type Item = {
    item_type: ItemType;
    item_code: string;
    sales_enabled: boolean;
    purchase_enabled: boolean;
    inventory_enabled: boolean;
    is_returnable: boolean;
    retail_price: number;
    quantity: number;
    sale_price: number;
    stock_value: number;
    opening_stock_value: number;
    stock_quantity: number;
    opening_stock_qty: number;
    branch_variant_id: string;
    stock_status: string;
    name: string;
    purchase_price?: number;
    alert_quantity?: number;
    item_id: string;
    preferred_vendor_id?: string;
    item_category_id?: string;
    brand_id?: string;
    tax_id?: string;
    unit_id?: string;
    rich_text?: string;
    business_id: string;
    org_id: string;
    serial_nos?: string[];
    images?: ItemImage[];
    sub_services?: SubService[];
    custom_fields?: Record<string, Field>;
    selected_sub_services?: SubService[];
};

export type ItemImage = {
    is_thumbnail: boolean;
    url?: string;
    bytes?: Uint8Array;
};

export type SubService = {
    name: string;
    additional_price: number;
    sub_service_id?: string;
    quantity: number;
    service_id?: string;
};

export type Field = {
    type: string;
    required: boolean;
    value?: string;
};
