DELETE FROM "public"."features";
DELETE FROM "public"."addons";
DELETE FROM "public"."addon_prices";
DELETE FROM "public"."plans";
DELETE FROM "public"."plan_features";
DELETE FROM "public"."plan_prices";



INSERT INTO "public"."features" ("feature_id", "name", "slug", "description", "feature_type", "created_at", "updated_at") VALUES
	(1, 'Users Access', 'users-access', 'Number of users allowed to access the POS system.', 'limit', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(2, 'Sales / Purchase', 'sales-purchase', 'Core functionality for recording sales and purchases.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(3, 'Multi Language', 'multi-language', 'Support for multiple interface languages.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(4, 'Mobile Access', 'mobile-access', 'Ability to access the POS system via a mobile application.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(5, 'Reports', 'reports', 'Access to sales, inventory, and other business reports.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(6, 'Customer Ordering System', 'customer-ordering-system', 'Integration with a customer-facing ordering platform.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(7, 'Barcode Generation', 'barcode-generation', 'Ability to generate and print barcodes for products.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(8, 'WhatsApp Integration', 'whatsapp-integration', 'Integration with WhatsApp for notifications or chat.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(9, 'AI Chat with Whatsapp', 'ai-chat-whatsapp', 'AI-powered chat functionality via WhatsApp.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00'),
	(10, 'AI Dashboard', 'ai-dashboard', 'Access to an AI-powered analytics dashboard.', 'boolean', '2025-04-18 07:19:33.293516+00', '2025-04-18 07:19:33.293516+00');


--
-- Data for Name: addons; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."addons" ("addon_id", "name", "slug", "description", "addon_type", "linked_feature_id", "unit_name", "default_price_monthly", "default_price_annual", "default_currency", "is_active", "created_at", "updated_at", "default_price_one_time") VALUES
	(2, 'Branch + Users', 'additional-branch-user', 'Allows adding one branch and 3 user seat beyond the plan limit.', 'limit_increase', NULL, 'No.s', 199.00, 2388.00, 'INR', true, '2025-05-14 10:58:38.272455+00', '2025-05-14 10:58:38.272455+00', NULL),
	(3, 'Whatsapp Credits', 'whatsapp-credits', 'Purchase whatsapp credit for simple messaging', 'metered_quota', 8, 'Credits', NULL, NULL, 'INR', true, '2025-05-14 11:37:29.753459+00', '2025-05-14 11:37:29.753459+00', 50),
	(1, 'Additional User Seat', 'additional-user', 'Allows adding one extra user seat beyond the plan limit.', 'limit_increase', 1, 'user', 99.00, 999.00, 'INR', true, '2025-04-18 09:16:24.861379+00', '2025-04-18 09:16:24.861379+00', NULL);


--
-- Data for Name: addon_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."addon_prices" ("addon_price_id", "addon_id", "country_code", "currency_code", "price_monthly", "price_annual", "is_active", "created_at", "updated_at", "price_one_time") VALUES
	(1, 1, 'IN', 'INR', 99.00, 999.00, true, '2025-05-14 21:47:18.797987+00', '2025-05-14 21:47:18.797987+00', NULL),
	(2, 2, 'IN', 'INR', 199.00, 2299.00, true, '2025-05-14 21:48:30.584657+00', '2025-05-14 21:48:30.584657+00', NULL),
	(3, 3, 'IN', 'INR', NULL, NULL, true, '2025-05-14 21:48:51.311062+00', '2025-05-14 21:48:51.311062+00', 50);

INSERT INTO "public"."plans" ("plan_id", "name", "slug", "description", "default_price_monthly", "default_price_annual", "default_currency", "trial_period_days", "is_active", "display_order", "created_at", "updated_at") VALUES
	(1, 'Free', 'free', NULL, NULL, NULL, 'INR', NULL, true, 1, '2025-04-18 05:37:42.712918+00', '2025-04-18 05:37:42.712918+00'),
	(2, 'Pro', 'pro', NULL, 649.00, 7788.00, 'INR', 15, true, 2, '2025-04-18 05:40:21.105563+00', '2025-04-18 05:40:21.105563+00'),
	(3, 'Genius', 'genius', NULL, 999.00, 11980.00, 'INR', 15, true, 3, '2025-04-18 05:50:12.121007+00', '2025-04-18 05:50:12.121007+00');


--
-- Data for Name: plan_features; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."plan_features" ("plan_feature_id", "plan_id", "feature_id", "is_enabled", "limit_value", "created_at", "updated_at") VALUES
	(12, 1, 1, true, 1, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(13, 1, 2, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(14, 1, 3, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(15, 1, 4, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(16, 1, 5, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(17, 1, 6, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(18, 1, 7, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(19, 1, 8, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(20, 1, 9, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(21, 1, 10, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(22, 2, 1, true, 5, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(23, 2, 2, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(24, 2, 3, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(25, 2, 4, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(26, 2, 5, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(27, 2, 6, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(28, 2, 7, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(29, 2, 8, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(30, 2, 9, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(31, 2, 10, false, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(32, 3, 1, true, 5, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(33, 3, 2, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(34, 3, 3, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(35, 3, 4, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(36, 3, 5, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(37, 3, 6, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(38, 3, 7, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(39, 3, 8, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(40, 3, 9, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00'),
	(41, 3, 10, true, NULL, '2025-04-18 07:22:19.078229+00', '2025-04-18 07:22:19.078229+00');


--
-- Data for Name: plan_prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."plan_prices" ("plan_price_id", "plan_id", "country_code", "currency_code", "price_monthly", "price_annual", "is_active", "created_at", "updated_at") VALUES
	(1, 2, 'IN', 'INR', 649.00, 7788.00, true, '2025-04-21 04:41:57.760452+00', '2025-04-21 04:41:57.760452+00'),
	(2, 3, 'IN', 'INR', 999.00, 11980.00, true, '2025-04-21 04:42:28.81917+00', '2025-04-21 04:42:28.81917+00');



INSERT INTO "public"."razorpay_addons" ("razorpay_addon_id", "created_at", "addon_id", "billing_cycle") VALUES
	('plan_QOOMWDG4DHDzmv', '2025-05-14 21:52:33.04348+00', 1, 'monthly'),
	('plan_QOOMszJugHfNcD', '2025-05-14 21:53:04.658045+00', 2, 'monthly'),
	('plan_QUxtdd1g2xxXcT', '2025-05-14 21:57:12.661827+00', 1, 'annually'),
	('plan_QUxrgqNKOu382S', '2025-05-14 21:57:26.755737+00', 2, 'annually');


--
-- Data for Name: razorpay_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."razorpay_plans" ("razorpay_plan_id", "created_at", "plan_id", "billing_cycle") VALUES
	('plan_QM0wL34ItgCPb7', '2025-04-22 11:13:55.544923+00', 2, 'monthly'),
	('plan_QM0xcFjWZIlwuW', '2025-04-22 11:14:15.260831+00', 3, 'monthly'),
	('plan_QM0xGc1KWT8y79', '2025-04-22 10:27:12.842496+00', 2, 'annually'),
	('plan_QM0xqXScmvzrDj', '2025-04-22 10:29:28.463163+00', 3, 'annually'),
	('free', '2025-05-13 11:15:32.370893+00', 1, 'annually');
