// razorpay.ts

// --- Core Entities ---

/**
 * Represents the core structure of a Razorpay Subscription entity.
 * Consolidated from various event examples.
 */
export interface RazorpaySubscriptionEntity {
    id: string;
    entity: "subscription";
    plan_id: string;
    customer_id: string | null;
    status:
        | "created"
        | "authenticated"
        | "active"
        | "pending"
        | "halted"
        | "cancelled"
        | "completed"
        | "expired"
        | "paused";
    current_start: number | null;
    current_end: number | null;
    ended_at: number | null;
    quantity: number;
    notes: Record<string, string> | null; // Typically string key-value pairs from API
    charge_at: number | null;
    start_at: number | null;
    end_at: number | null; // This is when the subscription itself is scheduled to end (e.g., after total_count)
    auth_attempts: number;
    total_count: number;
    paid_count: number;
    customer_notify: boolean;
    created_at: number;
    expire_by: number | null;
    short_url: string | null;
    has_scheduled_changes: boolean;
    change_scheduled_at: number | null;
    source?: string; // e.g., "api", "dashboard" - sometimes present
    offer_id: string | null;
    remaining_count: number;
    cancel_at_period_end?: boolean; // Added this based on common subscription models
    trial_start?: number | null; // If a trial period is involved
    trial_end?: number | null; // If a trial period is involved
    // Optional fields observed in specific events
    type?: number;
    payment_method?: string | null;
    pause_initiated_by?: "customer" | "merchant" | "api" | "self" | null;
    cancel_initiated_by?: "customer" | "merchant" | "api" | "self" | null;
}

/**
 * Represents the core structure of a Razorpay Card entity.
 */
export interface RazorpayCardEntity {
    id: string;
    entity: "card";
    name: string | null;
    last4: string;
    network: string;
    type: string;
    issuer: string | null;
    international: boolean;
    emi: boolean;
    expiry_month: number;
    expiry_year: number;
}

/**
 * Represents the core structure of a Razorpay Payment entity.
 */
export interface RazorpayPaymentEntity {
    id: string;
    entity: "payment";
    amount: number;
    currency: string;
    status: "created" | "authorized" | "captured" | "refunded" | "failed";
    order_id: string | null;
    invoice_id: string | null;
    international: boolean;
    method: string;
    amount_refunded: number;
    amount_transferred: number;
    refund_status: "null" | "partial" | "full" | null; // Ensure null is a valid type if API returns it
    captured: boolean; // Razorpay docs often show this as boolean in webhook payloads
    description: string | null;
    card_id: string | null;
    card: RazorpayCardEntity | null;
    bank: string | null;
    wallet: string | null;
    vpa: string | null;
    email: string;
    contact: string;
    customer_id: string | null;
    token_id: string | null;
    notes: Record<string, string> | null; // Typically string key-value pairs
    fee: number | null; // Can be null if not applicable
    tax: number | null; // Can be null if not applicable
    error_code: string | null;
    error_description: string | null;
    error_source?: string | null;
    error_step?: string | null;
    error_reason?: string | null;
    created_at: number;
}

/**
 * Represents the core structure of a Razorpay Invoice entity.
 */
export interface RazorpayInvoiceEntity {
    id: string;
    entity: "invoice";
    receipt?: string | null;
    invoice_number?: string | null; // If you use custom invoice numbers
    customer_id?: string | null;
    customer_details?: {
        id?: string;
        name?: string;
        email?: string;
        contact?: string;
        // ... other customer details
    } | null;
    order_id?: string; // Order for which invoice was generated
    subscription_id?: string; // If linked to a subscription
    payment_id?: string; // If paid, the ID of the successful payment
    status:
        | "draft"
        | "issued"
        | "partially_paid"
        | "paid"
        | "cancelled"
        | "expired"
        | "void";
    expire_by?: number | null;
    issued_at: number;
    paid_at?: number | null;
    cancelled_at?: number | null;
    expired_at?: number | null;
    sms_status?: "pending" | "sent" | null;
    email_status?: "pending" | "sent" | null;
    date: number; // Issue date timestamp
    terms?: string | null;
    partial_payment?: boolean;
    gross_amount?: number; // Total amount before discounts
    tax_amount?: number; // Total tax amount
    taxable_amount?: number; // Amount on which tax is applied
    amount: number; // Net amount (in paise)
    amount_paid: number; // Amount paid so far (in paise)
    amount_due: number; // Remaining amount due (in paise)
    currency: string; // e.g., "INR"
    description?: string | null;
    notes: Record<string, string> | null; // Custom notes
    comment?: string | null;
    short_url?: string | null; // Payment link for the invoice
    view_less?: boolean;
    billing_start?: number | null; // For subscription invoices
    billing_end?: number | null; // For subscription invoices
    type: "invoice" | "link"; // 'link' if created via Payment Links with invoice enabled
    group_id?: string | null;
    line_items: Array<{
        id?: string;
        item_id?: string | null;
        name: string;
        description?: string | null;
        amount: number; // Amount for this line item (in paise)
        unit_amount?: number; // Unit price (in paise)
        gross_amount?: number;
        tax_amount?: number;
        taxable_amount?: number;
        net_amount?: number;
        currency: string;
        type?: "invoice" | "adhoc";
        quantity?: number;
        // ... other line item fields
    }>;
    created_at: number;
    // pdf_url: string; // This is typically not in the webhook payload directly, fetched via API
}

// --- Base Event Structure ---
interface RazorpayBaseWebhookPayload {
    account_id: string; // Often present at this level too
    // Contains can also be here for some events, but often inside specific payload wrapper
}

interface RazorpayEventPayload<
    T_EntityWrapper,
    C_Contains extends ReadonlyArray<string>,
> extends RazorpayBaseWebhookPayload {
    // entity_wrapper is a placeholder for the actual structure like { subscription: { entity: ... }}
    [key: string]: any; // Allows for dynamic keys like 'subscription', 'payment', 'invoice'
    // contains: C; // 'contains' array is usually directly in the top-level event for webhook
}

// --- Specific Event Types (Discriminated Union) ---

// SUBSCRIPTION EVENTS
interface SubscriptionEventPayload {
    subscription: { entity: RazorpaySubscriptionEntity };
}
interface SubscriptionPaymentEventPayload extends SubscriptionEventPayload {
    payment: { entity: RazorpayPaymentEntity };
}

// INVOICE EVENTS
interface InvoiceEventPayload {
    invoice: { entity: RazorpayInvoiceEntity };
}
interface InvoicePaymentEventPayload extends InvoiceEventPayload {
    payment: { entity: RazorpayPaymentEntity }; // Payment entity included on invoice.paid
}

// ORDER EVENTS (Example, if you handle them)
export interface RazorpayOrderEntity {
    id: string;
    entity: "order";
    amount: number;
    amount_paid: number;
    amount_due: number;
    currency: string;
    receipt: string | null;
    offer_id: string | null;
    status: "created" | "attempted" | "paid";
    attempts: number;
    notes: Record<string, string> | null;
    created_at: number;
}
interface OrderEventPayload {
    order: { entity: RazorpayOrderEntity };
}
interface OrderPaymentEventPayload extends OrderEventPayload {
    payment: { entity: RazorpayPaymentEntity };
}

export type RazorpayWebhookEvent =
    | {
        event: "subscription.created";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.authenticated";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.activated";
        payload: SubscriptionPaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.activated";
        payload: SubscriptionPaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription", "payment"];
        created_at: number;
    }
    | {
        event: "subscription.charged";
        payload: SubscriptionPaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription", "payment"];
        created_at: number;
    }
    | {
        event: "subscription.pending";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.halted";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.updated";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.cancelled";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.completed";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    } // Payment might be optional here
    | {
        event: "subscription.paused";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    | {
        event: "subscription.resumed";
        payload: SubscriptionEventPayload;
        entity: "event";
        account_id: string;
        contains: ["subscription"];
        created_at: number;
    }
    // Invoice Events
    | {
        event: "invoice.created";
        payload: InvoiceEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice"];
        created_at: number;
    }
    | {
        event: "invoice.issued";
        payload: InvoiceEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice"];
        created_at: number;
    } // Often used instead of 'created'
    | {
        event: "invoice.paid";
        payload: InvoicePaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice", "payment"];
        created_at: number;
    }
    | {
        event: "invoice.partially_paid";
        payload: InvoicePaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice", "payment"];
        created_at: number;
    }
    | {
        event: "invoice.expired";
        payload: InvoiceEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice"];
        created_at: number;
    }
    | {
        event: "invoice.cancelled";
        payload: InvoiceEventPayload;
        entity: "event";
        account_id: string;
        contains: ["invoice"];
        created_at: number;
    }
    // Order Events (Example)
    | {
        event: "order.paid";
        payload: OrderPaymentEventPayload;
        entity: "event";
        account_id: string;
        contains: ["order", "payment"];
        created_at: number;
    }
    // Payment Events (Example for direct payments not via sub/invoice flow if needed)
    | {
        event: "payment.captured";
        payload: { payment: { entity: RazorpayPaymentEntity } };
        entity: "event";
        account_id: string;
        contains: ["payment"];
        created_at: number;
    }
    | {
        event: "payment.failed";
        payload: { payment: { entity: RazorpayPaymentEntity } };
        entity: "event";
        account_id: string;
        contains: ["payment"];
        created_at: number;
    }
    // Fallback for unhandled/new events - good for robustness
    | {
        event: string;
        payload: any;
        entity: "event";
        account_id: string;
        contains: string[];
        created_at: number;
    };

export interface RazorpaySubscriptionBaseRequestBody {
    /**
     * The unique identifier of a plan that should be linked to the Subscription.
     * For example, `plan_00000000000001`.
     */
    plan_id: string;
    /**
     * The number of billing cycles for which the customer should be charged.
     */
    total_count: number;
    /**
     * Indicates whether the communication to the customer would be handled by you or us.
     * Possible values:
     *
     * `0`: communication handled by you.
     *
     * `1` (default): communication handled by Razorpay.
     */
    customer_notify?: boolean | 0 | 1;
    /**
     * The number of times the customer should be charged the plan
     * amount per invoice.
     */
    quantity?: number;
    /**
     * The unique identifier of the offer that is linked to the Subscription.
     * You can obtain this from the Dashboard.
     */
    offer_id?: string;
    /**
     * Unix timestamp that indicates from when the Subscription should start.
     * If not passed, the Subscription starts immediately after the authorisation
     * payment.
     */
    start_at?: number;
    /**
     * Unix timestamp that indicates till when the customer can make the
     * authorisation payment.
     */
    expire_by?: number;
    /**
     * This can be used to charge the customer a one-time fee before the
     * start of the Subscription. This can include something like a one-time
     * delivery charge or a security deposit. Know more about
     * [Add-ons](https://razorpay.com/docs/payments/subscriptions/create-add-ons).
     */
    addons?: Pick<RazorpaySubscriptionAddonsBaseRequestBody, "item">[];
    /**
     * Notes you can enter for the contact for future reference. This is a
     * key-value pair.
     */
    notes?: Record<string, string | number>;
    /**
     * Represents when the Subscription should be updated. Possible values:
     *
     * `now` (default value): Updates the Subscription immediately.
     *
     * `cycle_end`: Updates the Subscription at the end of the current billing cycle.
     */
    schedule_change_at?: "now" | "cycle_end";
}

interface RazorpaySubscriptionAddonsBaseRequestBody {
    /**
     * List of invoices generated for the Subscription.
     */
    item: RazorpayItemBaseRequestBody;
    /**
     * The number of units of the item billed in the invoice.
     * For example, `1`.
     */
    quantity?: number;
}

interface RazorpayItemBaseRequestBody {
    /**
     * A name for the item. For example, `Extra appala (papadum)`.
     */
    name: string;
    /**
     * The amount you want to charge the customer for the item, in the currency subunit. For example, `30000`.
     */
    amount: number | string;
    /**
     * The currency in which the customer should be charged for the item. For example, `INR`.
     */
    currency: string;
    /**
     * Description for the item. For example, `1 extra oil fried appala with meals`
     */
    description?: string;
}
