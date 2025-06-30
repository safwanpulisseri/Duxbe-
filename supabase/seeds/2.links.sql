INSERT INTO "public"."links" (
    "link_id",
    "created_at",
    "name",
    "description",
    "url",
    "module_id",
    "visibility",
    "sort_order"
) VALUES (
    '1',
    '2024-12-23 09:28:42.722677+00',
    'POS',
    NULL,
    'pos',
    '2',
    'true',
    '1'
),
(
    '2',
    '2024-12-23 09:28:42.722677+00',
    'Sale List',
    NULL,
    'sale_list',
    '2',
    'true',
    '2'
),
(
    '3',
    '2024-12-23 09:28:42.722677+00',
    'Order List',
    NULL,
    'order_list',
    '2',
    'true',
    '3'
),
(
    '4',
    '2024-12-23 09:28:42.722677+00',
    'Sale Return',
    NULL,
    'sale_return',
    '2',
    'true',
    '4'
),
(
    '5',
    '2024-12-23 09:28:42.722677+00',
    'Customer',
    NULL,
    'customer',
    '2',
    'true',
    '5'
),
(
    '6',
    '2024-12-23 09:28:42.722677+00',
    'Purchase',
    NULL,
    'purchasing',
    '3',
    'true',
    '1'
),
(
    '7',
    '2024-12-23 09:28:42.722677+00',
    'Purchase List',
    NULL,
    'purchase_list',
    '3',
    'true',
    '2'
),
(
    '8',
    '2024-12-23 09:28:42.722677+00',
    'Purchase Return',
    NULL,
    'purchase_return',
    '3',
    'true',
    '3'
),
(
    '9',
    '2024-12-23 09:28:42.722677+00',
    'Supplier',
    NULL,
    'supplier',
    '3',
    'true',
    '4'
),
(
    '10',
    '2024-12-23 09:28:42.722677+00',
    'Item List',
    NULL,
    'item_list',
    '4',
    'true',
    '1'
),
(
    '11',
    '2024-12-23 09:28:42.722677+00',
    'Category',
    NULL,
    'category',
    '4',
    'true',
    '2'
),
(
    '12',
    '2024-12-23 09:28:42.722677+00',
    'Units',
    NULL,
    'units',
    '4',
    'true',
    '3'
),
(
    '13',
    '2024-12-23 09:28:42.722677+00',
    'Brands',
    NULL,
    'brands',
    '4',
    'true',
    '4'
),
(
    '14',
    '2024-12-23 09:28:42.722677+00',
    'Manage Stock',
    NULL,
    'manage_stock',
    '4',
    'true',
    '5'
),
(
    '15',
    '2024-12-23 09:28:42.722677+00',
    'Stock Adjustment',
    NULL,
    'stock_adjustment',
    '4',
    'true',
    '6'
),
(
    '16',
    '2024-12-23 09:28:42.722677+00',
    'Expense',
    NULL,
    'expense',
    '5',
    'true',
    '1'
),
(
    '17',
    '2024-12-23 09:28:42.722677+00',
    'Income',
    NULL,
    'income',
    '5',
    'true',
    '2'
),
(
    '18',
    '2024-12-23 09:28:42.722677+00',
    'Ledger',
    NULL,
    'ledger',
    '5',
    'true',
    '3'
),
(
    '19',
    '2024-12-23 09:28:42.722677+00',
    'User List',
    NULL,
    'user_list',
    '7',
    'true',
    '1'
),
(
    '20',
    '2024-12-23 09:28:42.722677+00',
    'User Role',
    NULL,
    'user_role',
    '7',
    'true',
    '2'
),
(
    '21',
    '2025-01-10 11:21:16.074998+00',
    'Print Barcode',
    NULL,
    'print_barcode',
    '4',
    'true',
    '7'
),
(
    '22',
    '2025-04-11 05:11:37.4246+00',
    'Chart of Accounts',
    NULL,
    'chart_of_accounts',
    '5',
    'true',
    '4'
),
(
    '23',
    '2025-04-15 11:38:14.803028+00',
    'Profit and Loss',
    NULL,
    'profit_and_loss',
    '5',
    'true',
    '0'
),
(
    '24',
    '2025-05-21 06:59:50.107138+00',
    'Quote',
    NULL,
    'quote',
    '10',
    'true',
    '1'
),
(
    '25',
    '2025-05-21 07:02:20.10659+00',
    'Invoices',
    NULL,
    'invoices',
    '10',
    'true',
    '2'
),
(
    '26',
    '2025-05-21 07:03:03.972997+00',
    'Payment Received',
    NULL,
    'paymentreceived',
    '10',
    'true',
    '3'
),
(
    '27',
    '2025-05-21 07:02:20.10659+00',
    'Credit Notes',
    NULL,
    'credit_notes',
    '10',
    'true',
    '4'
) ON CONFLICT (
    LINK_ID
) DO UPDATE SET CREATED_AT = EXCLUDED.CREATED_AT,
NAME = EXCLUDED.NAME,
DESCRIPTION = EXCLUDED.DESCRIPTION,
URL = EXCLUDED.URL,
MODULE_ID = EXCLUDED.MODULE_ID,
VISIBILITY = EXCLUDED.VISIBILITY,
SORT_ORDER = EXCLUDED.SORT_ORDER;