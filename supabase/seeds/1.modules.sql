INSERT INTO "public"."modules" (
    "module_id",
    "created_at",
    "name",
    "description",
    "url",
    "sort_order"
) VALUES (
    '1',
    '2024-12-23 09:21:35.524119+00',
    'Dashboard',
    NULL,
    'dashboard',
    '1'
),
(
    '2',
    '2024-12-23 09:21:35.524119+00',
    'Sale',
    NULL,
    'sale',
    '2'
),
(
    '3',
    '2024-12-23 09:21:35.524119+00',
    'Purchase',
    NULL,
    'purchase',
    '3'
),
(
    '4',
    '2024-12-23 09:21:35.524119+00',
    'Inventory',
    NULL,
    'inventory',
    '4'
),
(
    '5',
    '2024-12-23 09:21:35.524119+00',
    'Accounting',
    NULL,
    'accounting',
    '5'
),
(
    '6',
    '2024-12-23 09:21:35.524119+00',
    'Reports',
    NULL,
    'reports',
    '6'
),
(
    '7',
    '2024-12-23 09:21:35.524119+00',
    'Users',
    NULL,
    'users',
    '7'
),
(
    '8',
    '2024-12-23 09:21:35.524119+00',
    'Settings',
    NULL,
    'settings',
    '8'
),
(
    '9',
    '2024-12-27 09:48:03.055666+00',
    'Branch',
    NULL,
    'branch',
    '6'
),
(
    '10',
    '2025-05-21 06:53:33.092783+00',
    'Invoice',
    NULL,
    'invoice',
    '7'
) ON CONFLICT (
    MODULE_ID
) DO UPDATE SET CREATED_AT = EXCLUDED.CREATED_AT,
NAME = EXCLUDED.NAME,
DESCRIPTION = EXCLUDED.DESCRIPTION,
URL = EXCLUDED.URL,
SORT_ORDER = EXCLUDED.SORT_ORDER;