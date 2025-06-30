SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 15.6

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

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") VALUES
	('00000000-0000-0000-0000-000000000000', '7d326979-8a90-485d-842c-5a03f6dc66b5', '{"action":"user_signedup","actor_id":"45b600f3-83c0-48b1-8821-9c40c37aae32","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 19:50:04.185652+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e7b0f00a-8d37-4e94-9e13-e756ea472065', '{"action":"login","actor_id":"45b600f3-83c0-48b1-8821-9c40c37aae32","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 19:50:04.192552+00', ''),
	('00000000-0000-0000-0000-000000000000', '92bc6d9d-6d66-46ed-a3d9-e45018a6f57e', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"45b600f3-83c0-48b1-8821-9c40c37aae32","user_phone":""}}', '2025-05-12 19:51:52.70163+00', ''),
	('00000000-0000-0000-0000-000000000000', '1133b5c3-c04c-4a0a-a8ae-b7d8017e0017', '{"action":"user_signedup","actor_id":"282059e7-417f-495d-85d3-aa7aee142fb6","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 19:55:28.725612+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e0ed8e02-0041-49c8-8416-a94d5294a6ba', '{"action":"login","actor_id":"282059e7-417f-495d-85d3-aa7aee142fb6","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 19:55:28.729227+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b18df739-b8e7-4559-91fc-927617321728', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"282059e7-417f-495d-85d3-aa7aee142fb6","user_phone":""}}', '2025-05-12 19:56:02.417952+00', ''),
	('00000000-0000-0000-0000-000000000000', 'de0a1e9f-b16a-4ce7-a56b-3934d346a9a8', '{"action":"user_signedup","actor_id":"e598f591-fe5e-43d7-933b-fa4756c9b108","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 19:56:45.925275+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd3d558bc-ad0e-488b-8a7e-67b48046b6e5', '{"action":"login","actor_id":"e598f591-fe5e-43d7-933b-fa4756c9b108","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 19:56:45.928656+00', ''),
	('00000000-0000-0000-0000-000000000000', '8cf4f440-e233-49ad-9245-65f93dbd8b8a', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"e598f591-fe5e-43d7-933b-fa4756c9b108","user_phone":""}}', '2025-05-12 19:59:43.009291+00', ''),
	('00000000-0000-0000-0000-000000000000', '503f7ac8-729c-4289-9580-02f24730e543', '{"action":"user_signedup","actor_id":"ddd9d3bf-c64f-4727-8de7-85a7de2eec16","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:02:09.454394+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c9fa9a39-774b-42b7-bdd1-808a97e36896', '{"action":"login","actor_id":"ddd9d3bf-c64f-4727-8de7-85a7de2eec16","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:02:09.459993+00', ''),
	('00000000-0000-0000-0000-000000000000', '890ca8d4-ae9e-4486-a779-ebb830b38238', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"ddd9d3bf-c64f-4727-8de7-85a7de2eec16","user_phone":""}}', '2025-05-12 20:03:18.989799+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bac10987-3e86-484c-9f69-7e44a98c7e53', '{"action":"user_signedup","actor_id":"c4921328-7087-41ba-919d-66b92762ee63","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:06:15.787041+00', ''),
	('00000000-0000-0000-0000-000000000000', 'eec59525-a444-4b9c-8499-f0efb0ab9a8d', '{"action":"login","actor_id":"c4921328-7087-41ba-919d-66b92762ee63","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:06:15.821352+00', ''),
	('00000000-0000-0000-0000-000000000000', '34abcc20-4960-4087-9bb9-0a7591a78fb2', '{"action":"logout","actor_id":"c4921328-7087-41ba-919d-66b92762ee63","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 20:14:08.320745+00', ''),
	('00000000-0000-0000-0000-000000000000', '8e345df5-5732-4c79-adef-40077d33c844', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"c4921328-7087-41ba-919d-66b92762ee63","user_phone":""}}', '2025-05-12 20:14:17.83685+00', ''),
	('00000000-0000-0000-0000-000000000000', '4578530d-5c23-4521-bcae-7d79f91d10ac', '{"action":"user_signedup","actor_id":"24c3be0c-3022-4c6a-8868-ec97fa21279c","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:14:55.495295+00', ''),
	('00000000-0000-0000-0000-000000000000', '069969a5-3642-4f9b-896c-295f07f5d099', '{"action":"login","actor_id":"24c3be0c-3022-4c6a-8868-ec97fa21279c","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:14:55.498794+00', ''),
	('00000000-0000-0000-0000-000000000000', '08ded38f-11dd-48eb-ac1c-6e03f91925dc', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"24c3be0c-3022-4c6a-8868-ec97fa21279c","user_phone":""}}', '2025-05-12 20:19:24.954289+00', ''),
	('00000000-0000-0000-0000-000000000000', '2774ac48-bf09-4e00-a19f-3c3b5b303f8a', '{"action":"user_signedup","actor_id":"0d07830f-4785-4d9a-a007-32ff5271876f","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:21:51.650694+00', ''),
	('00000000-0000-0000-0000-000000000000', '83085e20-844a-4613-b8d7-344c751a7cb0', '{"action":"login","actor_id":"0d07830f-4785-4d9a-a007-32ff5271876f","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:21:51.654029+00', ''),
	('00000000-0000-0000-0000-000000000000', '251b4989-b877-4212-9d8b-aba34ea6fc9a', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"0d07830f-4785-4d9a-a007-32ff5271876f","user_phone":""}}', '2025-05-12 20:24:47.970035+00', ''),
	('00000000-0000-0000-0000-000000000000', '2837ed19-076f-4868-8b45-cd065f264e04', '{"action":"user_signedup","actor_id":"b348589d-4f80-4a4b-bfe8-e71974a1d38e","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:33:34.696079+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aba7a09d-cd82-4cb8-804c-60f11c4e1462', '{"action":"login","actor_id":"b348589d-4f80-4a4b-bfe8-e71974a1d38e","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:33:34.699894+00', ''),
	('00000000-0000-0000-0000-000000000000', '92d9dadd-b99d-4333-adf0-ba93494bc15a', '{"action":"logout","actor_id":"b348589d-4f80-4a4b-bfe8-e71974a1d38e","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 20:35:55.590728+00', ''),
	('00000000-0000-0000-0000-000000000000', '8d2ddcae-a3ac-4986-bed8-e355bb4cfd16', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"b348589d-4f80-4a4b-bfe8-e71974a1d38e","user_phone":""}}', '2025-05-12 20:37:10.011999+00', ''),
	('00000000-0000-0000-0000-000000000000', 'cc417456-e544-4b99-92c9-7f1cc3c8fba3', '{"action":"user_signedup","actor_id":"899b8392-a642-4e53-9725-b1bd0f73b570","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:40:05.928567+00', ''),
	('00000000-0000-0000-0000-000000000000', '31118964-1faf-473f-9d60-0dfcd5fb032d', '{"action":"login","actor_id":"899b8392-a642-4e53-9725-b1bd0f73b570","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:40:05.933125+00', ''),
	('00000000-0000-0000-0000-000000000000', '1ee7aeb1-5e34-4620-aeb1-490df0317947', '{"action":"logout","actor_id":"899b8392-a642-4e53-9725-b1bd0f73b570","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 20:45:33.904083+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e9122ad1-adef-442e-acc8-48630c8ffdaa', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"899b8392-a642-4e53-9725-b1bd0f73b570","user_phone":""}}', '2025-05-12 20:45:42.730454+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bf62a2d8-b493-4b2d-a218-c652b2630cdc', '{"action":"user_signedup","actor_id":"2352c3bc-daed-4e50-840b-bd0dc10fbc5c","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:46:16.11166+00', ''),
	('00000000-0000-0000-0000-000000000000', '8162f924-7036-4684-bd5a-d687e72e3f32', '{"action":"login","actor_id":"2352c3bc-daed-4e50-840b-bd0dc10fbc5c","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:46:16.117188+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a5229fb0-3e49-4901-8db5-f39cc3d11c44', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"2352c3bc-daed-4e50-840b-bd0dc10fbc5c","user_phone":""}}', '2025-05-12 20:48:22.615506+00', ''),
	('00000000-0000-0000-0000-000000000000', '97cb1829-0ae2-4f03-b322-c193280cfd81', '{"action":"user_signedup","actor_id":"d3336048-8a31-4a55-b972-f903704347ef","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:51:53.843055+00', ''),
	('00000000-0000-0000-0000-000000000000', '99b8cd03-7800-4773-8f79-c53be146dc3e', '{"action":"login","actor_id":"d3336048-8a31-4a55-b972-f903704347ef","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:51:53.848082+00', ''),
	('00000000-0000-0000-0000-000000000000', '2ca45058-e200-46b7-915b-e6d30715be3c', '{"action":"logout","actor_id":"d3336048-8a31-4a55-b972-f903704347ef","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 20:57:00.674911+00', ''),
	('00000000-0000-0000-0000-000000000000', '3acb2cf2-ef8c-4f71-8889-75fbe763334c', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"d3336048-8a31-4a55-b972-f903704347ef","user_phone":""}}', '2025-05-12 20:57:27.806467+00', ''),
	('00000000-0000-0000-0000-000000000000', '5e098158-3efe-4b09-9148-a1d60e2926bd', '{"action":"user_signedup","actor_id":"2b72139e-daed-4225-bfdb-d97ff971f067","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 20:59:04.099538+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a018fe3b-aeee-4f7f-9e28-c5d4bb387150', '{"action":"login","actor_id":"2b72139e-daed-4225-bfdb-d97ff971f067","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 20:59:04.10533+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ac565ac7-0b94-456e-8e5e-aaeddd8a867a', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"2b72139e-daed-4225-bfdb-d97ff971f067","user_phone":""}}', '2025-05-12 21:01:33.612503+00', ''),
	('00000000-0000-0000-0000-000000000000', '59d44388-709b-480a-ba54-bc27ca293c7c', '{"action":"user_signedup","actor_id":"d2554967-2432-4d4b-89a7-4e4141929046","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 21:02:11.820389+00', ''),
	('00000000-0000-0000-0000-000000000000', '3a139fb8-99fa-4103-8048-cbc8e66ec278', '{"action":"login","actor_id":"d2554967-2432-4d4b-89a7-4e4141929046","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 21:02:11.824869+00', ''),
	('00000000-0000-0000-0000-000000000000', '5ed9c776-17f3-4c36-97b6-83d7914c719f', '{"action":"logout","actor_id":"d2554967-2432-4d4b-89a7-4e4141929046","actor_username":"alfas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 21:08:35.622926+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ac938909-a460-4ece-b723-73a710dd7f44', '{"action":"user_signedup","actor_id":"b9f3fa3c-0ce1-4b72-a082-6db77534fb5e","actor_username":"arbas@hancod.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 21:08:58.916951+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f5aef0b7-e4f0-45f7-95d7-c2af61c7a856', '{"action":"login","actor_id":"b9f3fa3c-0ce1-4b72-a082-6db77534fb5e","actor_username":"arbas@hancod.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 21:08:58.922481+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c7839b5e-0176-4b04-b822-a6cc0d7a59f5', '{"action":"logout","actor_id":"b9f3fa3c-0ce1-4b72-a082-6db77534fb5e","actor_username":"arbas@hancod.com","actor_via_sso":false,"log_type":"account"}', '2025-05-12 21:10:06.152277+00', ''),
	('00000000-0000-0000-0000-000000000000', '63a33231-6b0c-4180-a016-d192655914db', '{"action":"user_signedup","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 21:10:39.407782+00', ''),
	('00000000-0000-0000-0000-000000000000', '312322e3-76ed-47fd-879b-ffeb53f84e2b', '{"action":"login","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 21:10:39.415007+00', ''),
	('00000000-0000-0000-0000-000000000000', '787fc3ab-ec31-4137-b5a2-fa92d3f3efa5', '{"action":"user_modified","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"user"}', '2025-05-12 21:10:45.540118+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ef4b1401-f054-4fb0-9ca2-4a8320825416', '{"action":"token_refreshed","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"token"}', '2025-05-12 21:10:45.686139+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fcd32ffe-393f-4fa5-8060-b44b98517afc', '{"action":"token_revoked","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"token"}', '2025-05-12 21:10:45.687302+00', ''),
	('00000000-0000-0000-0000-000000000000', '0ca7cd1c-0535-4b62-938b-2466a3d6f422', '{"action":"logout","actor_id":"67423330-1e29-4b88-8b59-f892d503ff49","actor_username":"+918547480685","actor_via_sso":false,"log_type":"account"}', '2025-05-12 21:11:11.259167+00', ''),
	('00000000-0000-0000-0000-000000000000', '8cc0448a-6576-49be-ad06-7e4f04e448df', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"arbas@hancod.com","user_id":"b9f3fa3c-0ce1-4b72-a082-6db77534fb5e","user_phone":""}}', '2025-05-12 21:11:28.408282+00', ''),
	('00000000-0000-0000-0000-000000000000', '754528fc-bd31-41c2-841f-9e33dcd27a74', '{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"alfas@hancod.com","user_id":"d2554967-2432-4d4b-89a7-4e4141929046","user_phone":""}}', '2025-05-12 21:11:31.89415+00', ''),
	('00000000-0000-0000-0000-000000000000', '6a8e9009-32fd-4133-a383-35eb932550d9', '{"action":"user_signedup","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}', '2025-05-12 21:12:02.126265+00', ''),
	('00000000-0000-0000-0000-000000000000', '5b148971-54c2-4bd4-88c1-de7a836a6c46', '{"action":"login","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}', '2025-05-12 21:12:02.131308+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c5687fa0-a400-46fc-98b8-db3c9fcc6d0b', '{"action":"user_modified","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"user"}', '2025-05-12 21:12:02.701124+00', ''),
	('00000000-0000-0000-0000-000000000000', 'ce351260-3f3a-46aa-a32c-1b610e95156c', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-12 21:12:02.910897+00', ''),
	('00000000-0000-0000-0000-000000000000', '7c31a151-21ba-4c1d-8c5d-c4bb5dc0c86d', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-12 21:12:02.911674+00', ''),
	('00000000-0000-0000-0000-000000000000', '59bec06a-aad3-459c-92eb-8ba00d357aab', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 04:26:59.373944+00', ''),
	('00000000-0000-0000-0000-000000000000', '78f58c27-f910-43f6-847b-e9d4f15d5bc4', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 04:26:59.377184+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd5808f15-bae8-48c1-b81b-e927e98c0b23', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 05:26:26.527003+00', ''),
	('00000000-0000-0000-0000-000000000000', '588c5131-6172-40ec-82f7-b43d20b046b3', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 05:26:26.529541+00', ''),
	('00000000-0000-0000-0000-000000000000', '7a09aeed-1897-4dfd-bc59-9a151999f4f3', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 06:43:43.77556+00', ''),
	('00000000-0000-0000-0000-000000000000', '56b14373-f0ca-4424-9ce8-49310f905309', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 06:43:43.777371+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e4ccb3d9-c489-4936-a8cc-8d22dab4c0c1', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 07:43:05.282074+00', ''),
	('00000000-0000-0000-0000-000000000000', 'fc870b3a-44e9-44e8-b7be-58b881f900f9', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 07:43:05.283908+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c0c9d67d-f531-4c2e-8143-92ab212ad6dc', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 08:42:25.177979+00', ''),
	('00000000-0000-0000-0000-000000000000', '40706cb3-693d-4c12-ac34-a0de8cfc9cfb', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 08:42:25.179902+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f66e0b50-c8a7-4281-a313-69083212ea29', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 09:41:52.77437+00', ''),
	('00000000-0000-0000-0000-000000000000', '3f510295-c84e-4df3-97ae-b98546d6fcca', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 09:41:52.776304+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c80e455a-4c6f-4ef0-a8a5-507a70688a73', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 10:41:21.150708+00', ''),
	('00000000-0000-0000-0000-000000000000', '4e437e77-f32b-4d56-b1c1-554e55862cfb', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 10:41:21.15302+00', ''),
	('00000000-0000-0000-0000-000000000000', '26f4e590-78f6-4044-ab50-986b418d210e', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 11:40:49.918952+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b9cc6b2b-f37c-4368-b13b-e3e0cefac515', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 11:40:49.920949+00', ''),
	('00000000-0000-0000-0000-000000000000', '13914793-3652-4db6-8aa3-a9b89ec17de0', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 12:40:12.503902+00', ''),
	('00000000-0000-0000-0000-000000000000', '185a5001-0276-4c40-a0f1-29500dad6d26', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 12:40:12.506066+00', ''),
	('00000000-0000-0000-0000-000000000000', '5bd650cb-c536-4489-8c85-090c4d4f8c21', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 16:56:40.847373+00', ''),
	('00000000-0000-0000-0000-000000000000', '64b161df-7857-4ca9-8150-a64036641815', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 16:56:40.867545+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e3abc723-c276-4a8a-a9da-351a7b0b786f', '{"action":"user_modified","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"user"}', '2025-05-13 17:18:45.081622+00', ''),
	('00000000-0000-0000-0000-000000000000', '5cfc7075-eefd-4a24-8c72-dc9eb9088ffe', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 17:18:45.124386+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b8078a5e-ae70-41a7-98c0-a7b9188ed616', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 17:18:45.125621+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b17cb90c-d527-486d-9d50-1be60d250b12', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 18:18:09.577472+00', ''),
	('00000000-0000-0000-0000-000000000000', '9a909166-5015-4485-ab64-7c1d4c7e178e', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 18:18:09.581373+00', ''),
	('00000000-0000-0000-0000-000000000000', '901392b8-d989-40c1-9244-fbfb02e3b93a', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 19:17:34.172383+00', ''),
	('00000000-0000-0000-0000-000000000000', '05d98674-f28e-45ca-9d4d-23200481d6ae', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-13 19:17:34.174946+00', ''),
	('00000000-0000-0000-0000-000000000000', '5d3750f3-60b1-4f21-8021-9368a74a5db5', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 04:15:17.149626+00', ''),
	('00000000-0000-0000-0000-000000000000', '8e8bfe46-5276-4d86-b99d-701b11940eb5', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 04:15:17.15266+00', ''),
	('00000000-0000-0000-0000-000000000000', 'eb14e06e-b576-4c3d-8cab-91637346616c', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 05:14:37.746666+00', ''),
	('00000000-0000-0000-0000-000000000000', '3883b3d6-ff37-40dd-9013-e8742547e04e', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 05:14:37.754025+00', ''),
	('00000000-0000-0000-0000-000000000000', 'e2a9d972-35d4-4464-966c-4a39095bf62c', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 06:14:06.177871+00', ''),
	('00000000-0000-0000-0000-000000000000', '0de67c91-a750-4a9c-8802-0ac7f4a409bd', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 06:14:06.180053+00', ''),
	('00000000-0000-0000-0000-000000000000', '3d61442f-6213-49eb-a868-ea3542b62afc', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 07:13:28.468375+00', ''),
	('00000000-0000-0000-0000-000000000000', 'eb3c1069-6f50-4d2b-80e8-9bc63f162641', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 07:13:28.470748+00', ''),
	('00000000-0000-0000-0000-000000000000', '7343b633-a3df-47d1-9286-4b39ba171adc', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 08:28:13.708031+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b1c66757-414e-4662-8fe9-988c4ba7ba00', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 08:28:13.792276+00', ''),
	('00000000-0000-0000-0000-000000000000', '10f2ba31-9423-4e0f-9c6d-fcbd99c0400d', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 09:27:43.085039+00', ''),
	('00000000-0000-0000-0000-000000000000', 'abcb9e2a-8560-4e19-8caa-3dc625fd58c4', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 09:27:43.085983+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b0a193ee-e645-4e5f-8361-603e2217ac37', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 10:27:11.409358+00', ''),
	('00000000-0000-0000-0000-000000000000', '01a032e5-bd9a-4f3f-9f9a-2fa60ca21213', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 10:27:11.414988+00', ''),
	('00000000-0000-0000-0000-000000000000', '13186b6a-1d21-4aa0-8982-2a8e54ca395f', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 11:23:06.221059+00', ''),
	('00000000-0000-0000-0000-000000000000', '552e21a8-34ec-434b-a7af-98deb7319d0c', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 11:23:06.289228+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dd7d8e06-5076-4eb1-9515-bc526760e458', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 12:22:30.506034+00', ''),
	('00000000-0000-0000-0000-000000000000', 'dab7d418-51bc-4e1e-ab6d-463f62c51ead', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 12:22:30.50878+00', ''),
	('00000000-0000-0000-0000-000000000000', 'aad6f0af-bad4-4f7d-ae65-0abdf46821d4', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 13:21:53.584103+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c9386643-da27-4997-a9b0-aac92989936f', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 13:21:53.586624+00', ''),
	('00000000-0000-0000-0000-000000000000', 'cf519a32-4340-4ccd-a2a8-7a4c2dc2c27d', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 14:21:20.819289+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f213c5b8-255e-4f1a-99b4-1ddf5586c2d6', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 14:21:20.821521+00', ''),
	('00000000-0000-0000-0000-000000000000', 'afd2a7cb-895d-4c3c-ad22-06f26bf4004e', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 16:10:05.088608+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a367632d-322d-4724-94f9-ba279e59cce6', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 16:10:05.124638+00', ''),
	('00000000-0000-0000-0000-000000000000', '5ce8b2bf-c2af-4beb-a5e7-530401ef56ba', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 17:09:34.050869+00', ''),
	('00000000-0000-0000-0000-000000000000', 'bdcd496c-85b5-40b3-9847-96b512ed90ef', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 17:09:34.052793+00', ''),
	('00000000-0000-0000-0000-000000000000', 'd370949e-e963-419d-873c-a4a3f571cb36', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 18:08:59.379602+00', ''),
	('00000000-0000-0000-0000-000000000000', '6f39d557-9d85-48e3-bf61-bca11a510a48', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 18:08:59.387394+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f4c668ba-1334-4404-bbba-a1e8447b446b', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 19:08:24.382197+00', ''),
	('00000000-0000-0000-0000-000000000000', '6cb397c4-4940-465e-98c6-10d00aa1557f', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 19:08:24.385114+00', ''),
	('00000000-0000-0000-0000-000000000000', 'c9252923-3fd2-42e4-a583-cdc24bb9321b', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 20:07:45.357348+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a1e8e39f-100f-41c0-9c35-318b912e4c59', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 20:07:45.363021+00', ''),
	('00000000-0000-0000-0000-000000000000', '9e592a3f-9781-4c82-b1a6-4898d086606d', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 21:07:09.894668+00', ''),
	('00000000-0000-0000-0000-000000000000', '4265edfe-b032-4bd3-8911-46cb33534a29', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 21:07:09.899717+00', ''),
	('00000000-0000-0000-0000-000000000000', 'b435bc85-244a-4cb0-ad5d-904ec514580f', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 22:06:35.171959+00', ''),
	('00000000-0000-0000-0000-000000000000', '4eaa9d0a-c407-41de-96a5-11ceb8a25ec6', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-14 22:06:35.174083+00', ''),
	('00000000-0000-0000-0000-000000000000', 'a6033061-6696-4d64-a7bb-8ea500ccd657', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-15 05:21:21.905423+00', ''),
	('00000000-0000-0000-0000-000000000000', '7a5f9b9b-2dba-4ba0-abb2-fb5293017a6e', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-15 05:21:21.909043+00', ''),
	('00000000-0000-0000-0000-000000000000', '974b1aab-bb05-42e3-ac43-f39ae4b6b45f', '{"action":"token_refreshed","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-15 06:18:36.034853+00', ''),
	('00000000-0000-0000-0000-000000000000', 'f2fe0f48-284b-4728-af32-39c35a762f27', '{"action":"token_revoked","actor_id":"9d19c065-7591-419f-b357-289dc5dd4cab","actor_username":"+918891584808","actor_via_sso":false,"log_type":"token"}', '2025-05-15 06:18:36.071534+00', '');


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '67423330-1e29-4b88-8b59-f892d503ff49', 'authenticated', 'authenticated', 'hadi@hancod.com', '$2a$10$EpF9ejdHFQJ6e8rLPEernuAOSI0oYMoa5LlIbLF/j4.3PpErt60f6', '2025-05-12 21:10:39.40873+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-05-12 21:10:39.415835+00', '{"provider": "email", "providers": ["email"], "user_type": "employee", "current_org_id": "5e2ccbed-2195-4cf7-95b5-49a0226d6bf9"}', '{"sub": "67423330-1e29-4b88-8b59-f892d503ff49", "email": "hadi@hancod.com", "currency": {"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}, "user_name": "Deluxe Traders", "user_type": "employee", "business_id": "056a4d99-c3af-43f7-a8de-98b441e98240", "phone_number": "+918547480685", "business_type": "retail", "email_verified": true, "phone_verified": false, "initial_employee_role": "admin"}', NULL, '2025-05-12 21:10:39.370618+00', '2025-05-12 21:10:45.691158+00', '+918547480685', NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '9d19c065-7591-419f-b357-289dc5dd4cab', 'authenticated', 'authenticated', 'alfas@hancod.com', '$2a$10$fKAbxN7OwbnSmhaCPvWusexxeyesgrRNyyWo7AT852HPtZEdrbo3y', '2025-05-12 21:12:02.127002+00', NULL, '', NULL, '', NULL, '', '', NULL, '2025-05-12 21:12:02.132006+00', '{"provider": "email", "providers": ["email"], "user_type": "employee", "current_org_id": "c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8"}', '{"sub": "9d19c065-7591-419f-b357-289dc5dd4cab", "email": "alfas@hancod.com", "currency": {"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}, "user_name": "Lulu Traders", "user_type": "employee", "business_id": "96426e92-b2e1-47d2-9857-a7248133660f", "phone_number": "+918891584808", "business_type": "retail", "email_verified": true, "phone_verified": false, "initial_employee_role": "admin"}', NULL, '2025-05-12 21:12:02.107671+00', '2025-05-15 06:18:36.089189+00', '+918891584808', NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('67423330-1e29-4b88-8b59-f892d503ff49', '67423330-1e29-4b88-8b59-f892d503ff49', '{"sub": "67423330-1e29-4b88-8b59-f892d503ff49", "email": "hadi@hancod.com", "currency": {"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}, "user_name": "Deluxe Traders", "user_type": "employee", "phone_number": "+918547480685", "business_type": "retail", "email_verified": false, "phone_verified": false, "initial_employee_role": "admin"}', 'email', '2025-05-12 21:10:39.403524+00', '2025-05-12 21:10:39.403645+00', '2025-05-12 21:10:39.403645+00', 'a310cac5-7209-4f8f-94bd-b001a3cb2bbd'),
	('9d19c065-7591-419f-b357-289dc5dd4cab', '9d19c065-7591-419f-b357-289dc5dd4cab', '{"sub": "9d19c065-7591-419f-b357-289dc5dd4cab", "email": "alfas@hancod.com", "currency": {"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}, "user_name": "Lulu Traders", "user_type": "employee", "phone_number": "+918891584808", "business_type": "retail", "email_verified": false, "phone_verified": false, "initial_employee_role": "admin"}', 'email', '2025-05-12 21:12:02.12382+00', '2025-05-12 21:12:02.12386+00', '2025-05-12 21:12:02.12386+00', '62f1a020-0b97-49ee-9028-6e6bda142ae5');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag") VALUES
	('0d0b4711-30fc-47e9-8a05-d3307c425f8a', '9d19c065-7591-419f-b357-289dc5dd4cab', '2025-05-12 21:12:02.132065+00', '2025-05-15 06:18:36.105245+00', NULL, 'aal1', NULL, '2025-05-15 06:18:36.105112', 'Dart/3.5 (dart:io)', '172.18.0.1', NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('0d0b4711-30fc-47e9-8a05-d3307c425f8a', '2025-05-12 21:12:02.134564+00', '2025-05-12 21:12:02.134564+00', 'password', '537490fb-e5b9-4ce1-be85-0492bdd2df3b');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 17, 'TVoN6pbs4IHAr_N2Z2G1Dg', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-12 21:12:02.132976+00', '2025-05-12 21:12:02.912304+00', NULL, '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 18, 'YzU-NbJ27FWva4rou01rbQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-12 21:12:02.912743+00', '2025-05-13 04:26:59.377948+00', 'TVoN6pbs4IHAr_N2Z2G1Dg', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 19, 'AlH26JpzT6Lr2jdBiUYF0Q', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 04:26:59.379905+00', '2025-05-13 05:26:26.530218+00', 'YzU-NbJ27FWva4rou01rbQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 20, 'ahaaEVs2YvktBW-VDp87IA', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 05:26:26.531901+00', '2025-05-13 06:43:43.777807+00', 'AlH26JpzT6Lr2jdBiUYF0Q', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 21, 'VrWM9aIoJEYAW--eaRM8gA', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 06:43:43.779925+00', '2025-05-13 07:43:05.284476+00', 'ahaaEVs2YvktBW-VDp87IA', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 22, 'jPwz346QtbzTiAD8aJpCKA', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 07:43:05.285709+00', '2025-05-13 08:42:25.180634+00', 'VrWM9aIoJEYAW--eaRM8gA', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 23, 'O43-s1FvpA9OrvBkpuxYvw', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 08:42:25.182088+00', '2025-05-13 09:41:52.77686+00', 'jPwz346QtbzTiAD8aJpCKA', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 24, 'WCM3FrrXpDNrWDU5TRPGXw', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 09:41:52.777909+00', '2025-05-13 10:41:21.15361+00', 'O43-s1FvpA9OrvBkpuxYvw', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 25, 'MVhebbIe2HnJpfQKJMa4SQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 10:41:21.1548+00', '2025-05-13 11:40:49.921466+00', 'WCM3FrrXpDNrWDU5TRPGXw', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 26, 'hgKoTncOa2cdnhqnBsTreQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 11:40:49.92261+00', '2025-05-13 12:40:12.506598+00', 'MVhebbIe2HnJpfQKJMa4SQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 27, 'B4mA6yaX5dj_rmDLVwSZqg', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 12:40:12.507767+00', '2025-05-13 16:56:40.86931+00', 'hgKoTncOa2cdnhqnBsTreQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 28, '7gm2ihLplCEkCHD5Jr9YOQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 16:56:40.879316+00', '2025-05-13 17:18:45.126386+00', 'B4mA6yaX5dj_rmDLVwSZqg', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 29, 'zhp2kqi2YdNl3DSYtB7QqQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 17:18:45.12697+00', '2025-05-13 18:18:09.582336+00', '7gm2ihLplCEkCHD5Jr9YOQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 30, '-s0r7yDWJwzBoca5CkLWPg', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 18:18:09.58408+00', '2025-05-13 19:17:34.175675+00', 'zhp2kqi2YdNl3DSYtB7QqQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 31, 'pQvm4sKJb1x9rsQqFrAGDw', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-13 19:17:34.177696+00', '2025-05-14 04:15:17.153471+00', '-s0r7yDWJwzBoca5CkLWPg', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 32, 'f6kF_dKVIho9Q3YsMfV0bQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 04:15:17.154984+00', '2025-05-14 05:14:37.754659+00', 'pQvm4sKJb1x9rsQqFrAGDw', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 33, 'njLNdrKa1z4iGq_2N8j3HA', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 05:14:37.761405+00', '2025-05-14 06:14:06.180543+00', 'f6kF_dKVIho9Q3YsMfV0bQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 34, 'kSHnGxHhkNAjuaDuU8Wf3Q', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 06:14:06.181787+00', '2025-05-14 07:13:28.472463+00', 'njLNdrKa1z4iGq_2N8j3HA', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 35, 'IjoGnEibfENEBpGJH0p1xQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 07:13:28.47392+00', '2025-05-14 08:28:13.793544+00', 'kSHnGxHhkNAjuaDuU8Wf3Q', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 36, 'zAhkKzzThc0Z68qh6XSa4A', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 08:28:13.808466+00', '2025-05-14 09:27:43.086419+00', 'IjoGnEibfENEBpGJH0p1xQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 37, '39qAohYhSI1hNXfoPLufYg', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 09:27:43.087059+00', '2025-05-14 10:27:11.415661+00', 'zAhkKzzThc0Z68qh6XSa4A', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 38, 'gh0KeI8PJV7pZGtqj7Bzag', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 10:27:11.417636+00', '2025-05-14 11:23:06.290368+00', '39qAohYhSI1hNXfoPLufYg', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 39, 'RsXiG2G3xMxKP6nrigeg2g', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 11:23:06.29395+00', '2025-05-14 12:22:30.509309+00', 'gh0KeI8PJV7pZGtqj7Bzag', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 40, 'M--BCIeg_X8CJ5j549nNaQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 12:22:30.511541+00', '2025-05-14 13:21:53.587234+00', 'RsXiG2G3xMxKP6nrigeg2g', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 41, 'vwq4OUEByrboE2x3UFXtQQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 13:21:53.588751+00', '2025-05-14 14:21:20.822013+00', 'M--BCIeg_X8CJ5j549nNaQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 42, 'v-SHnbZcFBigXVAOzVNw5g', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 14:21:20.823467+00', '2025-05-14 16:10:05.125526+00', 'vwq4OUEByrboE2x3UFXtQQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 43, 'B8PveQzkEGYing8HWH7W0w', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 16:10:05.128159+00', '2025-05-14 17:09:34.053336+00', 'v-SHnbZcFBigXVAOzVNw5g', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 44, 'LVJaBZ01_I7uFeh_ctF-ig', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 17:09:34.05436+00', '2025-05-14 18:08:59.390035+00', 'B8PveQzkEGYing8HWH7W0w', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 45, '3kk0_N5HMMX-iSvQIevXqw', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 18:08:59.392887+00', '2025-05-14 19:08:24.385768+00', 'LVJaBZ01_I7uFeh_ctF-ig', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 46, 'jp1Kg1DcbYHIT16_4Ur5Kg', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 19:08:24.387585+00', '2025-05-14 20:07:45.363949+00', '3kk0_N5HMMX-iSvQIevXqw', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 47, '9cZrhPzaC20KrJ4SZFjI8A', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 20:07:45.366757+00', '2025-05-14 21:07:09.900558+00', 'jp1Kg1DcbYHIT16_4Ur5Kg', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 48, 'fhjwkZSMwO8Cb7sL3D-R8Q', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 21:07:09.903042+00', '2025-05-14 22:06:35.174633+00', '9cZrhPzaC20KrJ4SZFjI8A', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 49, 'tPwyB4Ks-mpQwDN19mYxQQ', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-14 22:06:35.176089+00', '2025-05-15 05:21:21.909918+00', 'fhjwkZSMwO8Cb7sL3D-R8Q', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 50, 'pb3xln4xmtmb', '9d19c065-7591-419f-b357-289dc5dd4cab', true, '2025-05-15 05:21:21.911073+00', '2025-05-15 06:18:36.072673+00', 'tPwyB4Ks-mpQwDN19mYxQQ', '0d0b4711-30fc-47e9-8a05-d3307c425f8a'),
	('00000000-0000-0000-0000-000000000000', 51, '4tx4esv7kp54', '9d19c065-7591-419f-b357-289dc5dd4cab', false, '2025-05-15 06:18:36.086859+00', '2025-05-15 06:18:36.086859+00', 'pb3xln4xmtmb', '0d0b4711-30fc-47e9-8a05-d3307c425f8a');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."users" ("user_id", "created_at", "name", "email", "phone", "image") VALUES
	('67423330-1e29-4b88-8b59-f892d503ff49', '2025-05-12 21:10:39.370166+00', 'Deluxe Traders', 'hadi@hancod.com', '+918547480685', NULL),
	('9d19c065-7591-419f-b357-289dc5dd4cab', '2025-05-12 21:12:02.107317+00', 'Lulu Traders', 'alfas@hancod.com', '+918891584808', NULL);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."employees" ("employee_id", "code", "created_at", "org_id", "role", "name", "image") VALUES
	('67423330-1e29-4b88-8b59-f892d503ff49', NULL, '2025-05-12 21:10:39.370166+00', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', 'admin', 'Deluxe Traders', NULL),
	('9d19c065-7591-419f-b357-289dc5dd4cab', NULL, '2025-05-12 21:12:02.107317+00', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', 'admin', 'Lulu Traders', NULL);


--
-- Data for Name: fiscal_years; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."fiscal_years" ("fiscal_id", "name", "start_month", "end_month") VALUES
	('00000000-0000-0000-0000-000000000001', 'APR - MAR', 4, 3),
	('00000000-0000-0000-0000-000000000002', 'JAN - DEC', 1, 12);


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."organizations" ("org_id", "name", "created_by", "created_at", "trial_activated") VALUES
	('5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', 'Deluxe Traders''s Organization', '67423330-1e29-4b88-8b59-f892d503ff49', '2025-05-12 21:10:39.370166+00', false),
	('c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', 'Lulu Traders''s Organization', '9d19c065-7591-419f-b357-289dc5dd4cab', '2025-05-12 21:12:02.107317+00', true);


--
-- Data for Name: businesses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."businesses" ("business_id", "name", "org_id", "created_at", "created_by", "subscription_status", "last_active_at", "contact_email", "contact_phone", "contact_address", "currency", "logo", "images", "store_name", "gst_in", "state", "country", "time_zone", "fiscal_id", "is_gst_registered", "legal_business_name", "gst_registered_date", "trade_name", "print_on_sale", "print_on_purchase", "allow_walkin_customer", "allow_sales_when_outofstock", "business_type", "print_barcode_on_purchase", "format") VALUES
	('056a4d99-c3af-43f7-a8de-98b441e98240', 'Deluxe Traders', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', '67423330-1e29-4b88-8b59-f892d503ff49', 'inactive', NULL, NULL, NULL, NULL, '{"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000002', NULL, NULL, NULL, NULL, true, true, false, false, 'retail', NULL, 'roll57'),
	('96426e92-b2e1-47d2-9857-a7248133660f', 'Lulu Traders', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', '9d19c065-7591-419f-b357-289dc5dd4cab', 'inactive', NULL, NULL, NULL, NULL, '{"code": "INR", "flag": "INR", "name": "Indian Rupee", "number": 356, "symbol": "₹", "name_plural": "Indian rupees", "country_code": ["IN", "BT", "NP"], "decimal_digits": 2, "symbol_on_left": true, "decimal_separator": ".", "thousands_separator": ",", "space_between_amount_and_symbol": false}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '00000000-0000-0000-0000-000000000002', NULL, NULL, NULL, NULL, true, true, false, false, 'retail', NULL, 'roll57');


--
-- Data for Name: account_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."account_categories" ("category_id", "name", "code", "description", "business_id", "created_at") VALUES
	('0842867a-f7e4-44f0-8821-d38d7bfe942e', 'ASSETS', 'AST', 'Asset accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('113b01ed-550e-4ac4-bf00-fce232b86755', 'LIABILITIES', 'LBT', 'Liability accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('7eaa4dac-3410-499e-85be-a4da1b7e7857', 'EQUITIES', 'EQT', 'Equity accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('0aefedcf-9be6-4fef-9544-251da9e04db0', 'REVENUES', 'RVN', 'Revenue accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('b4803e10-7697-44c3-8cbf-908ec8f41be6', 'COST OF SALES', 'COS', 'Cost of Sales accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('bd9cf274-d363-4423-98a4-62c083ed3891', 'OPERATING EXPENSES', 'OPE', 'Operating expenses accounts', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'ASSETS', 'AST', 'Asset accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00'),
	('90b488a3-a269-48ae-b6f5-58c02aab2d56', 'LIABILITIES', 'LBT', 'Liability accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00'),
	('b6f8190e-cb67-4ba9-95ef-47111fade80e', 'EQUITIES', 'EQT', 'Equity accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00'),
	('03d038d2-4d4a-483b-933b-51f08313423c', 'REVENUES', 'RVN', 'Revenue accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00'),
	('6a5f892f-09af-45f5-b941-c01e045fa7a4', 'COST OF SALES', 'COS', 'Cost of Sales accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00'),
	('d0b2b5c9-3c8f-4f88-ae45-36053a2f0cbf', 'OPERATING EXPENSES', 'OPE', 'Operating expenses accounts', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00');


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."accounts" ("account_id", "category_id", "name", "code", "description", "is_system", "business_id", "org_id", "created_at", "balance", "is_group", "parent_account_id") VALUES
	('19fcbb62-86ff-402c-b4dc-08f36b42a87a', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Current Assets', '1000', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('dd3fe282-f087-4b8b-aff2-6357fda7b145', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Fixed Assets', '1100', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('5a265384-5013-4252-bb6f-2e8eaec54994', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Petty Cash', '1010', 'Cash on hand.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '19fcbb62-86ff-402c-b4dc-08f36b42a87a'),
	('3e625c3a-2fe6-4641-91de-363db606cf66', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Cash in Bank', '1011', 'Cash in bank accounts.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '19fcbb62-86ff-402c-b4dc-08f36b42a87a'),
	('926bcb2d-b6ba-4c7b-a064-f8f63b7ffde6', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Accounts Receivable - Customers', '1020', 'Money owed to the business by customers for goods/services sold.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '19fcbb62-86ff-402c-b4dc-08f36b42a87a'),
	('f44f95e8-5bdf-4c5d-bd51-cf52ba85bc23', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Receivables from Suppliers', '1021', 'Money owed to the business by suppliers (e.g., refunds, overpayments).', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '19fcbb62-86ff-402c-b4dc-08f36b42a87a'),
	('e27d3445-db9e-4ef5-a2d1-b6d3c69f740e', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Inventory', '1030', 'Value of goods held for sale.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '19fcbb62-86ff-402c-b4dc-08f36b42a87a'),
	('5c5f1066-0112-4e4e-b2a8-157ccffc1bc5', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Land', '1110', 'Value of land owned.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, 'dd3fe282-f087-4b8b-aff2-6357fda7b145'),
	('15f3ca12-859f-41ff-b1ea-945b80354a2d', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Buildings', '1120', 'Value of buildings owned.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, 'dd3fe282-f087-4b8b-aff2-6357fda7b145'),
	('0fa8a080-3634-422a-a868-4794dbee3709', '0842867a-f7e4-44f0-8821-d38d7bfe942e', 'Equipment', '1130', 'Value of machinery and equipment owned.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, 'dd3fe282-f087-4b8b-aff2-6357fda7b145'),
	('3b8eabd7-817f-4142-a329-3b21243b0533', '113b01ed-550e-4ac4-bf00-fce232b86755', 'Current Liabilities', '2000', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('fe7db3f6-ab4d-4664-8517-716c6b7eae7a', '113b01ed-550e-4ac4-bf00-fce232b86755', 'Accounts Payable - Suppliers', '2010', 'Money owed by the business to suppliers for goods/services received.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '3b8eabd7-817f-4142-a329-3b21243b0533'),
	('5fa0e103-5930-4164-96d3-5d09a036f6b7', '113b01ed-550e-4ac4-bf00-fce232b86755', 'Payables to Customers', '2011', 'Money owed by the business to customers (e.g., refunds due, overpayments, deposits).', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '3b8eabd7-817f-4142-a329-3b21243b0533'),
	('5b0ddec7-e072-4cc4-9978-8b64164d4987', '113b01ed-550e-4ac4-bf00-fce232b86755', 'Sales Tax Payable', '2020', 'Sales tax collected from customers but not yet remitted.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '3b8eabd7-817f-4142-a329-3b21243b0533'),
	('40caa6a0-4e37-447c-8d6f-84b5dc6448b2', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Sales Revenue', '4000', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('59682066-513b-449a-bfed-a32b10a46617', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Sales of Goods', '4010', 'Revenue from the sale of physical goods.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '40caa6a0-4e37-447c-8d6f-84b5dc6448b2'),
	('f2f04995-86e9-45fc-b083-046e1c8c39b1', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Sales of Services', '4020', 'Revenue from the sale of services.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '40caa6a0-4e37-447c-8d6f-84b5dc6448b2'),
	('87fd7a00-079c-4673-a2c4-115328a97b4d', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Income from Other Sources', '4030', 'Income from other sources, such as interest or dividends.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('ab534c86-45f2-456e-a9eb-f8a0fde8ca1f', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Shipping Revenue', '4040', 'Revenue earned from shipping charges billed to customers.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('61d1f4b9-65d2-48b7-9255-6a2a3c976a30', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Sales Discount', '4900', 'Discounts on sale', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('561dc1db-033e-48df-a385-260e1ea40066', '0aefedcf-9be6-4fef-9544-251da9e04db0', 'Sales Returns and Allowances', '4910', 'Reductions in revenue due to customer returns or allowances.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('31bac463-9602-49ef-93eb-d430ea085460', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Cost of Sales', '5000', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('524be846-a8aa-4497-a3ba-ce6296443990', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Direct Materials', '5010', 'Cost of raw materials used in production.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('79815b5a-25c3-4f01-a157-117af8e9686a', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Direct Labor', '5020', 'Wages paid to workers directly involved in production.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('748931f0-a33c-4840-bd50-5abd95527a90', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Purchase Discount', '5030', 'Discount added to the item when purchasing.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('89c66d55-cc99-4679-91e4-034570c296ae', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Shipping Costs (Purchases)', '5040', 'Freight and shipping costs for purchased goods.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('c3dbb773-6fa4-4621-973f-bd65d7a8bbb9', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Cost of Goods Sold', '5015', 'Cost of inventory sold.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('c4bacfa3-4d39-4c6f-a7aa-2be858e3a555', 'b4803e10-7697-44c3-8cbf-908ec8f41be6', 'Purchase Returns and Allowances', '5041', 'Reductions in purchase costs due to returned goods or allowances.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '31bac463-9602-49ef-93eb-d430ea085460'),
	('5aacfc5f-bc72-464b-812a-2aa2471b20a0', 'bd9cf274-d363-4423-98a4-62c083ed3891', 'Selling, General, and Administrative Expenses', '6000', NULL, false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, true, NULL),
	('1151d3d8-4a81-479e-9e62-a5cec2a67137', 'bd9cf274-d363-4423-98a4-62c083ed3891', 'General Expense', '6090', 'Default account for uncategorized operating expenses.', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '5aacfc5f-bc72-464b-812a-2aa2471b20a0'),
	('c60a02b0-20d3-411b-a54f-6ddc10711ac0', 'bd9cf274-d363-4423-98a4-62c083ed3891', 'Stock Adjustment Expense', '6095', 'Expenses related to inventory adjustments (shrinkage, damage, etc.).', false, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, '5aacfc5f-bc72-464b-812a-2aa2471b20a0'),
	('0bc1c676-7f51-4afe-b4af-2711ebbe1a93', '7eaa4dac-3410-499e-85be-a4da1b7e7857', 'Retained Earnings', '3000', 'Accumulated profits retained by the business', true, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('f48d3bb1-e371-44d8-be8a-ff88233fb885', '7eaa4dac-3410-499e-85be-a4da1b7e7857', 'Opening Balance Equity', '3900', 'Contra-equity account for setting up initial balances.', true, '056a4d99-c3af-43f7-a8de-98b441e98240', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', '2025-05-12 21:10:39.370166+00', 0, false, NULL),
	('5c37aa06-e54d-4fab-83a2-a5cac31e0828', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Current Assets', '1000', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('a16413f3-a51f-49b9-9447-c3bbf40f09f2', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Fixed Assets', '1100', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('c24c15a6-e7c6-4146-8d54-3d5b8f6cb00d', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Petty Cash', '1010', 'Cash on hand.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '5c37aa06-e54d-4fab-83a2-a5cac31e0828'),
	('897e09c7-18a5-41b3-a6b7-afdafed192e3', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Cash in Bank', '1011', 'Cash in bank accounts.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '5c37aa06-e54d-4fab-83a2-a5cac31e0828'),
	('024fdffa-5c57-4231-8c99-6f630ed1b69a', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Accounts Receivable - Customers', '1020', 'Money owed to the business by customers for goods/services sold.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '5c37aa06-e54d-4fab-83a2-a5cac31e0828'),
	('ae67eb39-ec7f-4abd-8f06-5b243ee321b0', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Receivables from Suppliers', '1021', 'Money owed to the business by suppliers (e.g., refunds, overpayments).', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '5c37aa06-e54d-4fab-83a2-a5cac31e0828'),
	('3611077b-8c3c-4021-ace5-9d790ab98ede', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Inventory', '1030', 'Value of goods held for sale.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '5c37aa06-e54d-4fab-83a2-a5cac31e0828'),
	('a6b6d6bc-fe6e-4ad7-9327-b2993c4767e6', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Land', '1110', 'Value of land owned.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'a16413f3-a51f-49b9-9447-c3bbf40f09f2'),
	('405281cf-2af8-454e-bd36-80639ceecd41', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Buildings', '1120', 'Value of buildings owned.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'a16413f3-a51f-49b9-9447-c3bbf40f09f2'),
	('b37648a4-dad3-45db-acfa-40a9d32c0ddc', 'fd79b971-d0ca-49c2-9d02-d87e9ce37ba5', 'Equipment', '1130', 'Value of machinery and equipment owned.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'a16413f3-a51f-49b9-9447-c3bbf40f09f2'),
	('103830c4-14aa-4164-9d4a-cfd48350a8eb', '90b488a3-a269-48ae-b6f5-58c02aab2d56', 'Current Liabilities', '2000', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('bdacb387-2fb8-46c1-accd-0402f3e62fc0', '90b488a3-a269-48ae-b6f5-58c02aab2d56', 'Accounts Payable - Suppliers', '2010', 'Money owed by the business to suppliers for goods/services received.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '103830c4-14aa-4164-9d4a-cfd48350a8eb'),
	('2531319d-0d91-4ab9-834b-df97f3a75d65', '90b488a3-a269-48ae-b6f5-58c02aab2d56', 'Payables to Customers', '2011', 'Money owed by the business to customers (e.g., refunds due, overpayments, deposits).', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '103830c4-14aa-4164-9d4a-cfd48350a8eb'),
	('df717fd7-0c89-431d-95e7-e0b7488fb5b6', '90b488a3-a269-48ae-b6f5-58c02aab2d56', 'Sales Tax Payable', '2020', 'Sales tax collected from customers but not yet remitted.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, '103830c4-14aa-4164-9d4a-cfd48350a8eb'),
	('f077882b-8dc5-4875-9ec3-8b95ec26462c', '03d038d2-4d4a-483b-933b-51f08313423c', 'Sales Revenue', '4000', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('992f738b-9017-4dba-97a8-d6c589d9bc19', '03d038d2-4d4a-483b-933b-51f08313423c', 'Sales of Goods', '4010', 'Revenue from the sale of physical goods.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'f077882b-8dc5-4875-9ec3-8b95ec26462c'),
	('cec0668f-ab5a-4931-9e97-fef62e5d910e', '03d038d2-4d4a-483b-933b-51f08313423c', 'Sales of Services', '4020', 'Revenue from the sale of services.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'f077882b-8dc5-4875-9ec3-8b95ec26462c'),
	('eb00cc47-cc63-4034-9262-9a46bf334bad', '03d038d2-4d4a-483b-933b-51f08313423c', 'Income from Other Sources', '4030', 'Income from other sources, such as interest or dividends.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL),
	('4d8406d6-fa37-456e-acd2-054a24fac35d', '03d038d2-4d4a-483b-933b-51f08313423c', 'Shipping Revenue', '4040', 'Revenue earned from shipping charges billed to customers.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL),
	('fe7d5c27-3ce0-4eba-86c2-74a4f1349f92', '03d038d2-4d4a-483b-933b-51f08313423c', 'Sales Discount', '4900', 'Discounts on sale', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL),
	('8dfd0220-1c12-4c84-a2e5-b981621845f4', '03d038d2-4d4a-483b-933b-51f08313423c', 'Sales Returns and Allowances', '4910', 'Reductions in revenue due to customer returns or allowances.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL),
	('cee458a6-5fc4-42fe-b2be-00eb889b3abe', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Cost of Sales', '5000', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('e5458d00-902a-4a61-86b2-2065a5dfafbe', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Direct Materials', '5010', 'Cost of raw materials used in production.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('b34a019c-0075-4fc0-afca-15c2ffb03ade', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Direct Labor', '5020', 'Wages paid to workers directly involved in production.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('a6b18c3b-8390-454e-b595-783d1ca70953', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Purchase Discount', '5030', 'Discount added to the item when purchasing.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('e10576ce-000c-420e-ae40-5464899518d7', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Shipping Costs (Purchases)', '5040', 'Freight and shipping costs for purchased goods.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('d5de8d6c-bbee-429d-b45c-b014fa5b3846', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Cost of Goods Sold', '5015', 'Cost of inventory sold.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('fba9769e-27b6-4b61-b85e-c2aa23534522', '6a5f892f-09af-45f5-b941-c01e045fa7a4', 'Purchase Returns and Allowances', '5041', 'Reductions in purchase costs due to returned goods or allowances.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'cee458a6-5fc4-42fe-b2be-00eb889b3abe'),
	('eb35f774-d276-4408-b43a-977c8a50c2da', 'd0b2b5c9-3c8f-4f88-ae45-36053a2f0cbf', 'Selling, General, and Administrative Expenses', '6000', NULL, false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, true, NULL),
	('696dc928-1bb6-4d11-9b2a-4d3e7ccd7996', 'd0b2b5c9-3c8f-4f88-ae45-36053a2f0cbf', 'General Expense', '6090', 'Default account for uncategorized operating expenses.', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'eb35f774-d276-4408-b43a-977c8a50c2da'),
	('9910cce7-5192-408d-a107-95e5d23ab31f', 'd0b2b5c9-3c8f-4f88-ae45-36053a2f0cbf', 'Stock Adjustment Expense', '6095', 'Expenses related to inventory adjustments (shrinkage, damage, etc.).', false, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, 'eb35f774-d276-4408-b43a-977c8a50c2da'),
	('c300347b-1382-4838-853b-e0dc18ac2abf', 'b6f8190e-cb67-4ba9-95ef-47111fade80e', 'Retained Earnings', '3000', 'Accumulated profits retained by the business', true, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL),
	('08d87e55-a106-441b-8a41-70f6976d3f49', 'b6f8190e-cb67-4ba9-95ef-47111fade80e', 'Opening Balance Equity', '3900', 'Contra-equity account for setting up initial balances.', true, '96426e92-b2e1-47d2-9857-a7248133660f', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '2025-05-12 21:12:02.107317+00', 0, false, NULL);


--
-- Data for Name: features; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: business_customers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."countries" ("id", "name", "emoji", "emoji_u", "iso_code", "currency") VALUES
	(1, 'Afghanistan', '🇦🇫', 'U+1F1E6 U+1F1EB', 'AF', 'AFN'),
	(2, 'Aland Islands', '🇦🇽', 'U+1F1E6 U+1F1FD', 'AX', 'EUR'),
	(3, 'Albania', '🇦🇱', 'U+1F1E6 U+1F1F1', 'AL', 'ALL'),
	(4, 'Algeria', '🇩🇿', 'U+1F1E9 U+1F1FF', 'DZ', 'DZD'),
	(5, 'American Samoa', '🇦🇸', 'U+1F1E6 U+1F1F8', 'AS', 'USD'),
	(6, 'Andorra', '🇦🇩', 'U+1F1E6 U+1F1E9', 'AD', 'EUR'),
	(7, 'Angola', '🇦🇴', 'U+1F1E6 U+1F1F4', 'AO', 'AOA'),
	(8, 'Anguilla', '🇦🇮', 'U+1F1E6 U+1F1EE', 'AI', 'XCD'),
	(9, 'Antarctica', '🇦🇶', 'U+1F1E6 U+1F1F6', 'AQ', NULL),
	(10, 'Antigua And Barbuda', '🇦🇬', 'U+1F1E6 U+1F1EC', 'AG', 'XCD'),
	(11, 'Argentina', '🇦🇷', 'U+1F1E6 U+1F1F7', 'AR', 'ARS'),
	(12, 'Armenia', '🇦🇲', 'U+1F1E6 U+1F1F2', 'AM', 'AMD'),
	(13, 'Aruba', '🇦🇼', 'U+1F1E6 U+1F1FC', 'AW', 'AWG'),
	(14, 'Australia', '🇦🇺', 'U+1F1E6 U+1F1FA', 'AU', 'AUD'),
	(15, 'Austria', '🇦🇹', 'U+1F1E6 U+1F1F9', 'AT', 'EUR'),
	(16, 'Azerbaijan', '🇦🇿', 'U+1F1E6 U+1F1FF', 'AZ', 'AZN'),
	(17, 'Bahamas The', '🇧🇸', 'U+1F1E7 U+1F1F8', 'BS', 'BSD'),
	(18, 'Bahrain', '🇧🇭', 'U+1F1E7 U+1F1ED', 'BH', 'BHD'),
	(19, 'Bangladesh', '🇧🇩', 'U+1F1E7 U+1F1E9', 'BD', 'BDT'),
	(20, 'Barbados', '🇧🇧', 'U+1F1E7 U+1F1E7', 'BB', 'BBD'),
	(21, 'Belarus', '🇧🇾', 'U+1F1E7 U+1F1FE', 'BY', 'BYN'),
	(22, 'Belgium', '🇧🇪', 'U+1F1E7 U+1F1EA', 'BE', 'EUR'),
	(23, 'Belize', '🇧🇿', 'U+1F1E7 U+1F1FF', 'BZ', 'BZD'),
	(24, 'Benin', '🇧🇯', 'U+1F1E7 U+1F1EF', 'BJ', 'XOF'),
	(25, 'Bermuda', '🇧🇲', 'U+1F1E7 U+1F1F2', 'BM', 'BMD'),
	(26, 'Bhutan', '🇧🇹', 'U+1F1E7 U+1F1F9', 'BT', 'BTN'),
	(27, 'Bolivia', '🇧🇴', 'U+1F1E7 U+1F1F4', 'BO', 'BOB'),
	(28, 'Bosnia and Herzegovina', '🇧🇦', 'U+1F1E7 U+1F1E6', 'BA', 'BAM'),
	(29, 'Botswana', '🇧🇼', 'U+1F1E7 U+1F1FC', 'BW', 'BWP'),
	(30, 'Bouvet Island', '🇧🇻', 'U+1F1E7 U+1F1FB', 'BV', 'NOK'),
	(31, 'Brazil', '🇧🇷', 'U+1F1E7 U+1F1F7', 'BR', 'BRL'),
	(32, 'British Indian Ocean Territory', '🇮🇴', 'U+1F1EE U+1F1F4', 'IO', 'USD'),
	(33, 'Brunei', '🇧🇳', 'U+1F1E7 U+1F1F3', 'BN', 'BND'),
	(34, 'Bulgaria', '🇧🇬', 'U+1F1E7 U+1F1EC', 'BG', 'BGN'),
	(35, 'Burkina Faso', '🇧🇫', 'U+1F1E7 U+1F1EB', 'BF', 'XOF'),
	(36, 'Burundi', '🇧🇮', 'U+1F1E7 U+1F1EE', 'BI', 'BIF'),
	(37, 'Cambodia', '🇰🇭', 'U+1F1F0 U+1F1ED', 'KH', 'KHR'),
	(38, 'Cameroon', '🇨🇲', 'U+1F1E8 U+1F1F2', 'CM', 'XAF'),
	(39, 'Canada', '🇨🇦', 'U+1F1E8 U+1F1E6', 'CA', 'CAD'),
	(40, 'Cape Verde', '🇨🇻', 'U+1F1E8 U+1F1FB', 'CV', 'CVE'),
	(41, 'Cayman Islands', '🇰🇾', 'U+1F1F0 U+1F1FE', 'KY', 'KYD'),
	(42, 'Central African Republic', '🇨🇫', 'U+1F1E8 U+1F1EB', 'CF', 'XAF'),
	(43, 'Chad', '🇹🇩', 'U+1F1F9 U+1F1E9', 'TD', 'XAF'),
	(44, 'Chile', '🇨🇱', 'U+1F1E8 U+1F1F1', 'CL', 'CLP'),
	(45, 'China', '🇨🇳', 'U+1F1E8 U+1F1F3', 'CN', 'CNY'),
	(46, 'Christmas Island', '🇨🇽', 'U+1F1E8 U+1F1FD', 'CX', 'AUD'),
	(47, 'Cocos (Keeling) Islands', '🇨🇨', 'U+1F1E8 U+1F1E8', 'CC', 'AUD'),
	(48, 'Colombia', '🇨🇴', 'U+1F1E8 U+1F1F4', 'CO', 'COP'),
	(49, 'Comoros', '🇰🇲', 'U+1F1F0 U+1F1F2', 'KM', 'KMF'),
	(50, 'Congo', '🇨🇬', 'U+1F1E8 U+1F1EC', 'CG', 'XAF'),
	(51, 'Congo The Democratic Republic Of The', '🇨🇩', 'U+1F1E8 U+1F1E9', 'CD', 'CDF'),
	(52, 'Cook Islands', '🇨🇰', 'U+1F1E8 U+1F1F0', 'CK', 'NZD'),
	(53, 'Costa Rica', '🇨🇷', 'U+1F1E8 U+1F1F7', 'CR', 'CRC'),
	(54, 'Cote DIvoire (Ivory Coast)', '🇨🇮', 'U+1F1E8 U+1F1EE', 'CI', 'XOF'),
	(55, 'Croatia (Hrvatska)', '🇭🇷', 'U+1F1ED U+1F1F7', 'HR', 'EUR'),
	(56, 'Cuba', '🇨🇺', 'U+1F1E8 U+1F1FA', 'CU', 'CUP'),
	(57, 'Cyprus', '🇨🇾', 'U+1F1E8 U+1F1FE', 'CY', 'EUR'),
	(58, 'Czech Republic', '🇨🇿', 'U+1F1E8 U+1F1FF', 'CZ', 'CZK'),
	(59, 'Denmark', '🇩🇰', 'U+1F1E9 U+1F1F0', 'DK', 'DKK'),
	(60, 'Djibouti', '🇩🇯', 'U+1F1E9 U+1F1EF', 'DJ', 'DJF'),
	(61, 'Dominica', '🇩🇲', 'U+1F1E9 U+1F1F2', 'DM', 'XCD'),
	(62, 'Dominican Republic', '🇩🇴', 'U+1F1E9 U+1F1F4', 'DO', 'DOP'),
	(63, 'East Timor', '🇹🇱', 'U+1F1F9 U+1F1F1', 'TL', 'USD'),
	(64, 'Ecuador', '🇪🇨', 'U+1F1EA U+1F1E8', 'EC', 'USD'),
	(65, 'Egypt', '🇪🇬', 'U+1F1EA U+1F1EC', 'EG', 'EGP'),
	(66, 'El Salvador', '🇸🇻', 'U+1F1F8 U+1F1FB', 'SV', 'USD'),
	(67, 'Equatorial Guinea', '🇬🇶', 'U+1F1EC U+1F1F6', 'GQ', 'XAF'),
	(68, 'Eritrea', '🇪🇷', 'U+1F1EA U+1F1F7', 'ER', 'ERN'),
	(69, 'Estonia', '🇪🇪', 'U+1F1EA U+1F1EA', 'EE', 'EUR'),
	(70, 'Ethiopia', '🇪🇹', 'U+1F1EA U+1F1F9', 'ET', 'ETB'),
	(71, 'Falkland Islands', '🇫🇰', 'U+1F1EB U+1F1F0', 'FK', 'FKP'),
	(72, 'Faroe Islands', '🇫🇴', 'U+1F1EB U+1F1F4', 'FO', 'DKK'),
	(73, 'Fiji Islands', '🇫🇯', 'U+1F1EB U+1F1EF', 'FJ', 'FJD'),
	(74, 'Finland', '🇫🇮', 'U+1F1EB U+1F1EE', 'FI', 'EUR'),
	(75, 'France', '🇫🇷', 'U+1F1EB U+1F1F7', 'FR', 'EUR'),
	(76, 'French Guiana', '🇬🇫', 'U+1F1EC U+1F1EB', 'GF', 'EUR'),
	(77, 'French Polynesia', '🇵🇫', 'U+1F1F5 U+1F1EB', 'PF', 'XPF'),
	(78, 'French Southern Territories', '🇹🇫', 'U+1F1F9 U+1F1EB', 'TF', 'EUR'),
	(79, 'Gabon', '🇬🇦', 'U+1F1EC U+1F1E6', 'GA', 'XAF'),
	(80, 'Gambia The', '🇬🇲', 'U+1F1EC U+1F1F2', 'GM', 'GMD'),
	(81, 'Georgia', '🇬🇪', 'U+1F1EC U+1F1EA', 'GE', 'GEL'),
	(82, 'Germany', '🇩🇪', 'U+1F1E9 U+1F1EA', 'DE', 'EUR'),
	(83, 'Ghana', '🇬🇭', 'U+1F1EC U+1F1ED', 'GH', 'GHS'),
	(84, 'Gibraltar', '🇬🇮', 'U+1F1EC U+1F1EE', 'GI', 'GIP'),
	(85, 'Greece', '🇬🇷', 'U+1F1EC U+1F1F7', 'GR', 'EUR'),
	(86, 'Greenland', '🇬🇱', 'U+1F1EC U+1F1F1', 'GL', 'DKK'),
	(87, 'Grenada', '🇬🇩', 'U+1F1EC U+1F1E9', 'GD', 'XCD'),
	(88, 'Guadeloupe', '🇬🇵', 'U+1F1EC U+1F1F5', 'GP', 'EUR'),
	(89, 'Guam', '🇬🇺', 'U+1F1EC U+1F1FA', 'GU', 'USD'),
	(90, 'Guatemala', '🇬🇹', 'U+1F1EC U+1F1F9', 'GT', 'GTQ'),
	(91, 'Guernsey and Alderney', '🇬🇬', 'U+1F1EC U+1F1EC', 'GG', 'GBP'),
	(92, 'Guinea', '🇬🇳', 'U+1F1EC U+1F1F3', 'GN', 'GNF'),
	(93, 'Guinea-Bissau', '🇬🇼', 'U+1F1EC U+1F1FC', 'GW', 'XOF'),
	(94, 'Guyana', '🇬🇾', 'U+1F1EC U+1F1FE', 'GY', 'GYD'),
	(95, 'Haiti', '🇭🇹', 'U+1F1ED U+1F1F9', 'HT', 'HTG'),
	(96, 'Heard Island and McDonald Islands', '🇭🇲', 'U+1F1ED U+1F1F2', 'HM', 'AUD'),
	(97, 'Honduras', '🇭🇳', 'U+1F1ED U+1F1F3', 'HN', 'HNL'),
	(98, 'Hong Kong S.A.R.', '🇭🇰', 'U+1F1ED U+1F1F0', 'HK', 'HKD'),
	(99, 'Hungary', '🇭🇺', 'U+1F1ED U+1F1FA', 'HU', 'HUF'),
	(100, 'Iceland', '🇮🇸', 'U+1F1EE U+1F1F8', 'IS', 'ISK'),
	(101, 'India', '🇮🇳', 'U+1F1EE U+1F1F3', 'IN', 'INR'),
	(102, 'Indonesia', '🇮🇩', 'U+1F1EE U+1F1E9', 'ID', 'IDR'),
	(103, 'Iran', '🇮🇷', 'U+1F1EE U+1F1F7', 'IR', 'IRR'),
	(104, 'Iraq', '🇮🇶', 'U+1F1EE U+1F1F6', 'IQ', 'IQD'),
	(105, 'Ireland', '🇮🇪', 'U+1F1EE U+1F1EA', 'IE', 'EUR'),
	(106, 'Israel', '🇮🇱', 'U+1F1EE U+1F1F1', 'IL', 'ILS'),
	(107, 'Italy', '🇮🇹', 'U+1F1EE U+1F1F9', 'IT', 'EUR'),
	(108, 'Jamaica', '🇯🇲', 'U+1F1EF U+1F1F2', 'JM', 'JMD'),
	(109, 'Japan', '🇯🇵', 'U+1F1EF U+1F1F5', 'JP', 'JPY'),
	(110, 'Jersey', '🇯🇪', 'U+1F1EF U+1F1EA', 'JE', 'GBP'),
	(111, 'Jordan', '🇯🇴', 'U+1F1EF U+1F1F4', 'JO', 'JOD'),
	(112, 'Kazakhstan', '🇰🇿', 'U+1F1F0 U+1F1FF', 'KZ', 'KZT'),
	(113, 'Kenya', '🇰🇪', 'U+1F1F0 U+1F1EA', 'KE', 'KES'),
	(114, 'Kiribati', '🇰🇮', 'U+1F1F0 U+1F1EE', 'KI', 'AUD'),
	(115, 'Korea North', '🇰🇵', 'U+1F1F0 U+1F1F5', 'KP', 'KPW'),
	(116, 'Korea South', '🇰🇷', 'U+1F1F0 U+1F1F7', 'KR', 'KRW'),
	(117, 'Kuwait', '🇰🇼', 'U+1F1F0 U+1F1FC', 'KW', 'KWD'),
	(118, 'Kyrgyzstan', '🇰🇬', 'U+1F1F0 U+1F1EC', 'KG', 'KGS'),
	(119, 'Laos', '🇱🇦', 'U+1F1F1 U+1F1E6', 'LA', 'LAK'),
	(120, 'Latvia', '🇱🇻', 'U+1F1F1 U+1F1FB', 'LV', 'EUR'),
	(121, 'Lebanon', '🇱🇧', 'U+1F1F1 U+1F1E7', 'LB', 'LBP'),
	(122, 'Lesotho', '🇱🇸', 'U+1F1F1 U+1F1F8', 'LS', 'LSL'),
	(123, 'Liberia', '🇱🇷', 'U+1F1F1 U+1F1F7', 'LR', 'LRD'),
	(124, 'Libya', '🇱🇾', 'U+1F1F1 U+1F1FE', 'LY', 'LYD'),
	(125, 'Liechtenstein', '🇱🇮', 'U+1F1F1 U+1F1EE', 'LI', 'CHF'),
	(126, 'Lithuania', '🇱🇹', 'U+1F1F1 U+1F1F9', 'LT', 'EUR'),
	(127, 'Luxembourg', '🇱🇺', 'U+1F1F1 U+1F1FA', 'LU', 'EUR'),
	(128, 'Macau S.A.R.', '🇲🇴', 'U+1F1F2 U+1F1F4', 'MO', 'MOP'),
	(129, 'Macedonia', '🇲🇰', 'U+1F1F2 U+1F1F0', 'MK', 'MKD'),
	(130, 'Madagascar', '🇲🇬', 'U+1F1F2 U+1F1EC', 'MG', 'MGA'),
	(131, 'Malawi', '🇲🇼', 'U+1F1F2 U+1F1FC', 'MW', 'MWK'),
	(132, 'Malaysia', '🇲🇾', 'U+1F1F2 U+1F1FE', 'MY', 'MYR'),
	(133, 'Maldives', '🇲🇻', 'U+1F1F2 U+1F1FB', 'MV', 'MVR'),
	(134, 'Mali', '🇲🇱', 'U+1F1F2 U+1F1F1', 'ML', 'XOF'),
	(135, 'Malta', '🇲🇹', 'U+1F1F2 U+1F1F9', 'MT', 'EUR'),
	(136, 'Man (Isle of)', '🇮🇲', 'U+1F1EE U+1F1F2', 'IM', 'GBP'),
	(137, 'Marshall Islands', '🇲🇭', 'U+1F1F2 U+1F1ED', 'MH', 'USD'),
	(138, 'Martinique', '🇲🇶', 'U+1F1F2 U+1F1F6', 'MQ', 'EUR'),
	(139, 'Mauritania', '🇲🇷', 'U+1F1F2 U+1F1F7', 'MR', 'MRU'),
	(140, 'Mauritius', '🇲🇺', 'U+1F1F2 U+1F1FA', 'MU', 'MUR'),
	(141, 'Mayotte', '🇾🇹', 'U+1F1FE U+1F1F9', 'YT', 'EUR'),
	(142, 'Mexico', '🇲🇽', 'U+1F1F2 U+1F1FD', 'MX', 'MXN'),
	(143, 'Micronesia', '🇫🇲', 'U+1F1EB U+1F1F2', 'FM', 'USD'),
	(144, 'Moldova', '🇲🇩', 'U+1F1F2 U+1F1E9', 'MD', 'MDL'),
	(145, 'Monaco', '🇲🇨', 'U+1F1F2 U+1F1E8', 'MC', 'EUR'),
	(146, 'Mongolia', '🇲🇳', 'U+1F1F2 U+1F1F3', 'MN', 'MNT'),
	(147, 'Montenegro', '🇲🇪', 'U+1F1F2 U+1F1EA', 'ME', 'EUR'),
	(148, 'Montserrat', '🇲🇸', 'U+1F1F2 U+1F1F8', 'MS', 'XCD'),
	(149, 'Morocco', '🇲🇦', 'U+1F1F2 U+1F1E6', 'MA', 'MAD'),
	(150, 'Mozambique', '🇲🇿', 'U+1F1F2 U+1F1FF', 'MZ', 'MZN'),
	(151, 'Myanmar', '🇲🇲', 'U+1F1F2 U+1F1F2', 'MM', 'MMK'),
	(152, 'Namibia', '🇳🇦', 'U+1F1F3 U+1F1E6', 'NA', 'NAD'),
	(153, 'Nauru', '🇳🇷', 'U+1F1F3 U+1F1F7', 'NR', 'AUD'),
	(154, 'Nepal', '🇳🇵', 'U+1F1F3 U+1F1F5', 'NP', 'NPR'),
	(155, 'Bonaire, Sint Eustatius and Saba', '🇧🇶', 'U+1F1E7 U+1F1F6', 'BQ', 'USD'),
	(156, 'Netherlands The', '🇳🇱', 'U+1F1F3 U+1F1F1', 'NL', 'EUR'),
	(157, 'New Caledonia', '🇳🇨', 'U+1F1F3 U+1F1E8', 'NC', 'XPF'),
	(158, 'New Zealand', '🇳🇿', 'U+1F1F3 U+1F1FF', 'NZ', 'NZD'),
	(159, 'Nicaragua', '🇳🇮', 'U+1F1F3 U+1F1EE', 'NI', 'NIO'),
	(160, 'Niger', '🇳🇪', 'U+1F1F3 U+1F1EA', 'NE', 'XOF'),
	(161, 'Nigeria', '🇳🇬', 'U+1F1F3 U+1F1EC', 'NG', 'NGN'),
	(162, 'Niue', '🇳🇺', 'U+1F1F3 U+1F1FA', 'NU', 'NZD'),
	(163, 'Norfolk Island', '🇳🇫', 'U+1F1F3 U+1F1EB', 'NF', 'AUD'),
	(164, 'Northern Mariana Islands', '🇲🇵', 'U+1F1F2 U+1F1F5', 'MP', 'USD'),
	(165, 'Norway', '🇳🇴', 'U+1F1F3 U+1F1F4', 'NO', 'NOK'),
	(166, 'Oman', '🇴🇲', 'U+1F1F4 U+1F1F2', 'OM', 'OMR'),
	(167, 'Pakistan', '🇵🇰', 'U+1F1F5 U+1F1F0', 'PK', 'PKR'),
	(168, 'Palau', '🇵🇼', 'U+1F1F5 U+1F1FC', 'PW', 'USD'),
	(169, 'Palestinian Territory Occupied', '🇵🇸', 'U+1F1F5 U+1F1F8', 'PS', 'ILS'),
	(170, 'Panama', '🇵🇦', 'U+1F1F5 U+1F1E6', 'PA', 'PAB'),
	(171, 'Papua new Guinea', '🇵🇬', 'U+1F1F5 U+1F1EC', 'PG', 'PGK'),
	(172, 'Paraguay', '🇵🇾', 'U+1F1F5 U+1F1FE', 'PY', 'PYG'),
	(173, 'Peru', '🇵🇪', 'U+1F1F5 U+1F1EA', 'PE', 'PEN'),
	(174, 'Philippines', '🇵🇭', 'U+1F1F5 U+1F1ED', 'PH', 'PHP'),
	(175, 'Pitcairn Island', '🇵🇳', 'U+1F1F5 U+1F1F3', 'PN', 'NZD'),
	(176, 'Poland', '🇵🇱', 'U+1F1F5 U+1F1F1', 'PL', 'PLN'),
	(177, 'Portugal', '🇵🇹', 'U+1F1F5 U+1F1F9', 'PT', 'EUR'),
	(178, 'Puerto Rico', '🇵🇷', 'U+1F1F5 U+1F1F7', 'PR', 'USD'),
	(179, 'Qatar', '🇶🇦', 'U+1F1F6 U+1F1E6', 'QA', 'QAR'),
	(180, 'Reunion', '🇷🇪', 'U+1F1F7 U+1F1EA', 'RE', 'EUR'),
	(181, 'Romania', '🇷🇴', 'U+1F1F7 U+1F1F4', 'RO', 'RON'),
	(182, 'Russia', '🇷🇺', 'U+1F1F7 U+1F1FA', 'RU', 'RUB'),
	(183, 'Rwanda', '🇷🇼', 'U+1F1F7 U+1F1FC', 'RW', 'RWF'),
	(184, 'Saint Helena', '🇸🇭', 'U+1F1F8 U+1F1ED', 'SH', 'SHP'),
	(185, 'Saint Kitts And Nevis', '🇰🇳', 'U+1F1F0 U+1F1F3', 'KN', 'XCD'),
	(186, 'Saint Lucia', '🇱🇨', 'U+1F1F1 U+1F1E8', 'LC', 'XCD'),
	(187, 'Saint Pierre and Miquelon', '🇵🇲', 'U+1F1F5 U+1F1F2', 'PM', 'EUR'),
	(188, 'Saint Vincent And The Grenadines', '🇻🇨', 'U+1F1FB U+1F1E8', 'VC', 'XCD'),
	(189, 'Saint-Barthelemy', '🇧🇱', 'U+1F1E7 U+1F1F1', 'BL', 'EUR'),
	(190, 'Saint-Martin (French part)', '🇲🇫', 'U+1F1F2 U+1F1EB', 'MF', 'EUR'),
	(191, 'Samoa', '🇼🇸', 'U+1F1FC U+1F1F8', 'WS', 'WST'),
	(192, 'San Marino', '🇸🇲', 'U+1F1F8 U+1F1F2', 'SM', 'EUR'),
	(193, 'Sao Tome and Principe', '🇸🇹', 'U+1F1F8 U+1F1F9', 'ST', 'STN'),
	(194, 'Saudi Arabia', '🇸🇦', 'U+1F1F8 U+1F1E6', 'SA', 'SAR'),
	(195, 'Senegal', '🇸🇳', 'U+1F1F8 U+1F1F3', 'SN', 'XOF'),
	(196, 'Serbia', '🇷🇸', 'U+1F1F7 U+1F1F8', 'RS', 'RSD'),
	(197, 'Seychelles', '🇸🇨', 'U+1F1F8 U+1F1E8', 'SC', 'SCR'),
	(198, 'Sierra Leone', '🇸🇱', 'U+1F1F8 U+1F1F1', 'SL', 'SLL'),
	(199, 'Singapore', '🇸🇬', 'U+1F1F8 U+1F1EC', 'SG', 'SGD'),
	(200, 'Slovakia', '🇸🇰', 'U+1F1F8 U+1F1F0', 'SK', 'EUR'),
	(201, 'Slovenia', '🇸🇮', 'U+1F1F8 U+1F1EE', 'SI', 'EUR'),
	(202, 'Solomon Islands', '🇸🇧', 'U+1F1F8 U+1F1E7', 'SB', 'SBD'),
	(203, 'Somalia', '🇸🇴', 'U+1F1F8 U+1F1F4', 'SO', 'SOS'),
	(204, 'South Africa', '🇿🇦', 'U+1F1FF U+1F1E6', 'ZA', 'ZAR'),
	(205, 'South Georgia', '🇬🇸', 'U+1F1EC U+1F1F8', 'GS', 'GBP'),
	(206, 'South Sudan', '🇸🇸', 'U+1F1F8 U+1F1F8', 'SS', 'SSP'),
	(207, 'Spain', '🇪🇸', 'U+1F1EA U+1F1F8', 'ES', 'EUR'),
	(208, 'Sri Lanka', '🇱🇰', 'U+1F1F1 U+1F1F0', 'LK', 'LKR'),
	(209, 'Sudan', '🇸🇩', 'U+1F1F8 U+1F1E9', 'SD', 'SDG'),
	(210, 'Suriname', '🇸🇷', 'U+1F1F8 U+1F1F7', 'SR', 'SRD'),
	(211, 'Svalbard And Jan Mayen Islands', '🇸🇯', 'U+1F1F8 U+1F1EF', 'SJ', 'NOK'),
	(212, 'Swaziland', '🇸🇿', 'U+1F1F8 U+1F1FF', 'SZ', 'SZL'),
	(213, 'Sweden', '🇸🇪', 'U+1F1F8 U+1F1EA', 'SE', 'SEK'),
	(214, 'Switzerland', '🇨🇭', 'U+1F1E8 U+1F1ED', 'CH', 'CHF'),
	(215, 'Syria', '🇸🇾', 'U+1F1F8 U+1F1FE', 'SY', 'SYP'),
	(216, 'Taiwan', '🇹🇼', 'U+1F1F9 U+1F1FC', 'TW', 'TWD'),
	(217, 'Tajikistan', '🇹🇯', 'U+1F1F9 U+1F1EF', 'TJ', 'TJS'),
	(218, 'Tanzania', '🇹🇿', 'U+1F1F9 U+1F1FF', 'TZ', 'TZS'),
	(219, 'Thailand', '🇹🇭', 'U+1F1F9 U+1F1ED', 'TH', 'THB'),
	(220, 'Togo', '🇹🇬', 'U+1F1F9 U+1F1EC', 'TG', 'XOF'),
	(221, 'Tokelau', '🇹🇰', 'U+1F1F9 U+1F1F0', 'TK', 'NZD'),
	(222, 'Tonga', '🇹🇴', 'U+1F1F9 U+1F1F4', 'TO', 'TOP'),
	(223, 'Trinidad And Tobago', '🇹🇹', 'U+1F1F9 U+1F1F9', 'TT', 'TTD'),
	(224, 'Tunisia', '🇹🇳', 'U+1F1F9 U+1F1F3', 'TN', 'TND'),
	(225, 'Turkey', '🇹🇷', 'U+1F1F9 U+1F1F7', 'TR', 'TRY'),
	(226, 'Turkmenistan', '🇹🇲', 'U+1F1F9 U+1F1F2', 'TM', 'TMT'),
	(227, 'Turks And Caicos Islands', '🇹🇨', 'U+1F1F9 U+1F1E8', 'TC', 'USD'),
	(228, 'Tuvalu', '🇹🇻', 'U+1F1F9 U+1F1FB', 'TV', 'AUD'),
	(229, 'Uganda', '🇺🇬', 'U+1F1FA U+1F1EC', 'UG', 'UGX'),
	(230, 'Ukraine', '🇺🇦', 'U+1F1FA U+1F1E6', 'UA', 'UAH'),
	(231, 'United Arab Emirates', '🇦🇪', 'U+1F1E6 U+1F1EA', 'AE', 'AED'),
	(232, 'United Kingdom', '🇬🇧', 'U+1F1EC U+1F1E7', 'GB', 'GBP'),
	(233, 'United States', '🇺🇸', 'U+1F1FA U+1F1F8', 'US', 'USD'),
	(234, 'United States Minor Outlying Islands', '🇺🇲', 'U+1F1FA U+1F1F2', 'UM', 'USD'),
	(235, 'Uruguay', '🇺🇾', 'U+1F1FA U+1F1FE', 'UY', 'UYU'),
	(236, 'Uzbekistan', '🇺🇿', 'U+1F1FA U+1F1FF', 'UZ', 'UZS'),
	(237, 'Vanuatu', '🇻🇺', 'U+1F1FB U+1F1FA', 'VU', 'VUV'),
	(238, 'Vatican City State (Holy See)', '🇻🇦', 'U+1F1FB U+1F1E6', 'VA', 'EUR'),
	(239, 'Venezuela', '🇻🇪', 'U+1F1FB U+1F1EA', 'VE', 'VES'),
	(240, 'Vietnam', '🇻🇳', 'U+1F1FB U+1F1F3', 'VN', 'VND'),
	(241, 'Virgin Islands (British)', '🇻🇬', 'U+1F1FB U+1F1EC', 'VG', 'USD'),
	(242, 'Virgin Islands (US)', '🇻🇮', 'U+1F1FB U+1F1EE', 'VI', 'USD'),
	(243, 'Wallis And Futuna Islands', '🇼🇫', 'U+1F1FC U+1F1EB', 'WF', 'XPF'),
	(244, 'Western Sahara', '🇪🇭', 'U+1F1EA U+1F1ED', 'EH', 'MAD'),
	(245, 'Yemen', '🇾🇪', 'U+1F1FE U+1F1EA', 'YE', 'YER'),
	(246, 'Zambia', '🇿🇲', 'U+1F1FF U+1F1F2', 'ZM', 'ZMW'),
	(247, 'Zimbabwe', '🇿🇼', 'U+1F1FF U+1F1FC', 'ZW', 'USD'),
	(248, 'Kosovo', '🇽🇰', 'U+1F1FD U+1F1F0', 'XK', 'EUR'),
	(249, 'Curaçao', '🇨🇼', 'U+1F1E8 U+1F1FC', 'CW', 'ANG'),
	(250, 'Sint Maarten (Dutch part)', '🇸🇽', 'U+1F1F8 U+1F1FD', 'SX', 'ANG');


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."states" ("id", "name", "country_id") VALUES
	(1, 'Southern Nations, Nationalities, and Peoples'' Region', 70),
	(2, 'Somali Region', 70),
	(3, 'Amhara Region', 70),
	(4, 'Tigray Region', 70),
	(5, 'Oromia Region', 70),
	(6, 'Afar Region', 70),
	(7, 'Harari Region', 70),
	(8, 'Dire Dawa', 70),
	(9, 'Benishangul-Gumuz Region', 70),
	(10, 'Gambela Region', 70),
	(11, 'Addis Ababa', 70),
	(12, 'Petnjica Municipality', 147),
	(13, 'Bar Municipality', 147),
	(14, 'Danilovgrad Municipality', 147),
	(15, 'Rožaje Municipality', 147),
	(16, 'Plužine Municipality', 147),
	(17, 'Nikšić Municipality', 147),
	(18, 'Šavnik Municipality', 147),
	(19, 'Plav Municipality', 147),
	(20, 'Pljevlja Municipality', 147),
	(21, 'Berane Municipality', 147),
	(22, 'Mojkovac Municipality', 147),
	(23, 'Andrijevica Municipality', 147),
	(24, 'Gusinje Municipality', 147),
	(25, 'Bijelo Polje Municipality', 147),
	(26, 'Kotor Municipality', 147),
	(27, 'Podgorica Municipality', 147),
	(28, 'Old Royal Capital Cetinje', 147),
	(29, 'Tivat Municipality', 147),
	(30, 'Budva Municipality', 147),
	(31, 'Kolašin Municipality', 147),
	(32, 'Žabljak Municipality', 147),
	(33, 'Ulcinj Municipality', 147),
	(34, 'Kunene Region', 152),
	(35, 'Kavango West Region', 152),
	(36, 'Kavango East Region', 152),
	(37, 'Oshana Region', 152),
	(38, 'Hardap Region', 152),
	(39, 'Omusati Region', 152),
	(40, 'Ohangwena Region', 152),
	(41, 'Omaheke Region', 152),
	(42, 'Oshikoto Region', 152),
	(43, 'Erongo Region', 152),
	(44, 'Khomas Region', 152),
	(45, 'ǁKaras Region', 152),
	(46, 'Otjozondjupa Region', 152),
	(47, 'Zambezi Region', 152),
	(48, 'Ashanti Region', 83),
	(49, 'Western Region', 83),
	(50, 'Eastern Region', 83),
	(51, 'Northern Region', 83),
	(52, 'Central Region', 83),
	(53, 'Bono-Ahafo Region', 83),
	(54, 'Greater Accra Region', 83),
	(55, 'Upper East Region', 83),
	(56, 'Volta Region', 83),
	(57, 'Upper West Region', 83),
	(58, 'San Marino', 192),
	(59, 'Acquaviva', 192),
	(60, 'Chiesanuova', 192),
	(61, 'Borgo Maggiore', 192),
	(62, 'Faetano', 192),
	(63, 'Montegiardino', 192),
	(64, 'Domagnano', 192),
	(65, 'Serravalle', 192),
	(66, 'Fiorentino', 192),
	(67, 'Tillabéri Region', 160),
	(68, 'Dosso Region', 160),
	(69, 'Zinder Region', 160),
	(70, 'Maradi Region', 160),
	(71, 'Agadez Region', 160),
	(72, 'Diffa Region', 160),
	(73, 'Tahoua Region', 160),
	(74, 'Mqabba', 135),
	(75, 'San Ġwann', 135),
	(76, 'Żurrieq', 135),
	(77, 'Luqa', 135),
	(78, 'Marsaxlokk', 135),
	(79, 'Qala', 135),
	(80, 'Żebbuġ Malta', 135),
	(81, 'Xgħajra', 135),
	(82, 'Kirkop', 135),
	(83, 'Rabat', 135),
	(84, 'Floriana', 135),
	(85, 'Żebbuġ Gozo', 135),
	(86, 'Swieqi', 135),
	(87, 'Saint Lawrence', 135),
	(88, 'Birżebbuġa', 135),
	(89, 'Mdina', 135),
	(90, 'Santa Venera', 135),
	(91, 'Kerċem', 135),
	(92, 'Għarb', 135),
	(93, 'Iklin', 135),
	(94, 'Santa Luċija', 135),
	(95, 'Valletta', 135),
	(96, 'Msida', 135),
	(97, 'Birkirkara', 135),
	(98, 'Siġġiewi', 135),
	(99, 'Kalkara', 135),
	(100, 'St. Julian''s', 135),
	(101, 'Victoria', 135),
	(102, 'Mellieħa', 135),
	(103, 'Tarxien', 135),
	(104, 'Sliema', 135),
	(105, 'Ħamrun', 135),
	(106, 'Għasri', 135),
	(107, 'Birgu', 135),
	(108, 'Balzan', 135),
	(109, 'Mġarr', 135),
	(110, 'Attard', 135),
	(111, 'Qrendi', 135),
	(112, 'Naxxar', 135),
	(113, 'Gżira', 135),
	(114, 'Xagħra', 135),
	(115, 'Paola', 135),
	(116, 'Sannat', 135),
	(117, 'Dingli', 135),
	(118, 'Gudja', 135),
	(119, 'Qormi', 135),
	(120, 'Għargħur', 135),
	(121, 'Xewkija', 135),
	(122, 'Ta'' Xbiex', 135),
	(123, 'Żabbar', 135),
	(124, 'Għaxaq', 135),
	(125, 'Pembroke', 135),
	(126, 'Lija', 135),
	(127, 'Pietà', 135),
	(128, 'Marsa', 135),
	(129, 'Fgura', 135),
	(130, 'Għajnsielem', 135),
	(131, 'Mtarfa', 135),
	(132, 'Munxar', 135),
	(133, 'Nadur', 135),
	(134, 'Fontana', 135),
	(135, 'Żejtun', 135),
	(136, 'Senglea', 135),
	(137, 'Marsaskala', 135),
	(138, 'Cospicua', 135),
	(139, 'St. Paul''s Bay', 135),
	(140, 'Mosta', 135),
	(141, 'Mangystau Region', 112),
	(142, 'Kyzylorda Region', 112),
	(143, 'Almaty Region', 112),
	(144, 'North Kazakhstan Region', 112),
	(145, 'Akmola Region', 112),
	(146, 'Pavlodar Region', 112),
	(147, 'Jambyl Region', 112),
	(148, 'West Kazakhstan Province', 112),
	(149, 'Turkestan Region', 112),
	(150, 'Karaganda Region', 112),
	(151, 'Aktobe Region', 112),
	(152, 'Almaty', 112),
	(153, 'Atyrau Region', 112),
	(154, 'East Kazakhstan Region', 112),
	(155, 'Baikonur', 112),
	(156, 'Astana', 112),
	(157, 'Kostanay Region', 112),
	(158, 'Kakamega County', 113),
	(159, 'Kisii County', 113),
	(160, 'Central Province', 113),
	(161, 'Busia County', 113),
	(162, 'North Eastern Province', 113),
	(163, 'Embu County', 113),
	(164, 'Laikipia County', 113),
	(165, 'Nandi County', 113),
	(166, 'Lamu County', 113),
	(167, 'Kirinyaga County', 113),
	(168, 'Bungoma County', 113),
	(169, 'Uasin Gishu County', 113),
	(170, 'Isiolo County', 113),
	(171, 'Kisumu County', 113),
	(172, 'Coast Province', 113),
	(173, 'Kwale County', 113),
	(174, 'Kilifi County', 113),
	(175, 'Narok County', 113),
	(176, 'Taita-Taveta County', 113),
	(177, 'Western Province', 113),
	(178, 'Murang''a County', 113),
	(179, 'Rift Valley Province', 113),
	(180, 'Nyeri County', 113),
	(181, 'Baringo County', 113),
	(182, 'Wajir County', 113),
	(183, 'Trans Nzoia County', 113),
	(184, 'Machakos County', 113),
	(185, 'Tharaka-Nithi County', 113),
	(186, 'Siaya County', 113),
	(187, 'Mandera County', 113),
	(188, 'Makueni County', 113),
	(189, 'Eastern Province', 113),
	(190, 'Migori County', 113),
	(191, 'Nairobi County', 113),
	(192, 'Nyandarua County', 113),
	(193, 'Kericho County', 113),
	(194, 'Marsabit County', 113),
	(195, 'Homa Bay County', 113),
	(196, 'Garissa County', 113),
	(197, 'Kajiado County', 113),
	(198, 'Meru County', 113),
	(199, 'Kiambu County', 113),
	(200, 'Mombasa County', 113),
	(201, 'Elgeyo-Marakwet County', 113),
	(202, 'Vihiga County', 113),
	(203, 'Nakuru County', 113),
	(204, 'Nyanza Province', 113),
	(205, 'Tana River County', 113),
	(206, 'Turkana County', 113),
	(207, 'Samburu County', 113),
	(208, 'West Pokot County', 113),
	(209, 'Nyamira County', 113),
	(210, 'Bomet County', 113),
	(211, 'Kitui County', 113),
	(212, 'Bié Province', 7),
	(213, 'Huambo Province', 7),
	(214, 'Zaire Province', 7),
	(215, 'Cunene Province', 7),
	(216, 'Cuanza Sul Province', 7),
	(217, 'Cuanza Norte Province', 7),
	(218, 'Benguela Province', 7),
	(219, 'Moxico Province', 7),
	(220, 'Lunda Sul Province', 7),
	(221, 'Bengo Province', 7),
	(222, 'Luanda Province', 7),
	(223, 'Lunda Norte Province', 7),
	(224, 'Uíge Province', 7),
	(225, 'Huíla Province', 7),
	(226, 'Cuando Cubango Province', 7),
	(227, 'Malanje Province', 7),
	(228, 'Cabinda Province', 7),
	(229, 'Gasa District', 26),
	(230, 'Tsirang District', 26),
	(231, 'Wangdue Phodrang District', 26),
	(232, 'Haa District', 26),
	(233, 'Zhemgang District', 26),
	(234, 'Lhuntse District', 26),
	(235, 'Punakha District', 26),
	(236, 'Trashigang District', 26),
	(237, 'Paro District', 26),
	(238, 'Dagana District', 26),
	(239, 'Chukha District', 26),
	(240, 'Bumthang District', 26),
	(241, 'Thimphu District', 26),
	(242, 'Mongar District', 26),
	(243, 'Samdrup Jongkhar District', 26),
	(244, 'Pemagatshel District', 26),
	(245, 'Trongsa District', 26),
	(246, 'Samtse District', 26),
	(247, 'Sarpang District', 26),
	(248, 'Tombouctou Region', 134),
	(249, 'Ségou Region', 134),
	(250, 'Koulikoro Region', 134),
	(251, 'Ménaka Region', 134),
	(252, 'Kayes Region', 134),
	(253, 'Bamako', 134),
	(254, 'Sikasso Region', 134),
	(255, 'Mopti Region', 134),
	(256, 'Taoudénit Region', 134),
	(257, 'Kidal Region', 134),
	(258, 'Gao Region', 134),
	(259, 'Southern Province', 183),
	(260, 'Western Province', 183),
	(261, 'Eastern Province', 183),
	(262, 'Kigali City', 183),
	(263, 'Northern Province', 183),
	(264, 'Belize District', 23),
	(265, 'Stann Creek District', 23),
	(266, 'Corozal District', 23),
	(267, 'Toledo District', 23),
	(268, 'Orange Walk District', 23),
	(269, 'Cayo District', 23),
	(270, 'Príncipe Province', 193),
	(271, 'São Tomé Province', 193),
	(272, 'Havana Province', 56),
	(273, 'Santiago de Cuba Province', 56),
	(274, 'Sancti Spíritus Province', 56),
	(275, 'Granma Province', 56),
	(276, 'Mayabeque Province', 56),
	(277, 'Pinar del Río Province', 56),
	(278, 'Isla de la Juventud', 56),
	(279, 'Holguín Province', 56),
	(280, 'Villa Clara Province', 56),
	(281, 'Las Tunas Province', 56),
	(282, 'Ciego de Ávila Province', 56),
	(283, 'Artemisa Province', 56),
	(284, 'Matanzas Province', 56),
	(285, 'Guantánamo Province', 56),
	(286, 'Camagüey Province', 56),
	(287, 'Cienfuegos Province', 56),
	(288, 'Jigawa State', 161),
	(289, 'Enugu State', 161),
	(290, 'Kebbi State', 161),
	(291, 'Benue State', 161),
	(292, 'Sokoto State', 161),
	(293, 'Federal Capital Territory', 161),
	(294, 'Kaduna State', 161),
	(295, 'Kwara State', 161),
	(296, 'Oyo State', 161),
	(297, 'Yobe State', 161),
	(298, 'Kogi State', 161),
	(299, 'Zamfara State', 161),
	(300, 'Kano State', 161),
	(301, 'Nasarawa State', 161),
	(302, 'Plateau State', 161),
	(303, 'Abia State', 161),
	(304, 'Akwa Ibom State', 161),
	(305, 'Bayelsa State', 161),
	(306, 'Lagos State', 161),
	(307, 'Borno State', 161),
	(308, 'Imo State', 161),
	(309, 'Ekiti State', 161),
	(310, 'Gombe State', 161),
	(311, 'Ebonyi State', 161),
	(312, 'Bauchi State', 161),
	(313, 'Katsina State', 161),
	(314, 'Cross River State', 161),
	(315, 'Anambra State', 161),
	(316, 'Delta State', 161),
	(317, 'Niger State', 161),
	(318, 'Edo State', 161),
	(319, 'Taraba State', 161),
	(320, 'Adamawa State', 161),
	(321, 'Ondo State', 161),
	(322, 'Osun State', 161),
	(323, 'Ogun State', 161),
	(324, 'Rukungiri District', 229),
	(325, 'Kyankwanzi District', 229),
	(326, 'Kabarole District', 229),
	(327, 'Mpigi District', 229),
	(328, 'Apac District', 229),
	(329, 'Abim District', 229),
	(330, 'Yumbe District', 229),
	(331, 'Rukiga District', 229),
	(332, 'Northern Region', 229),
	(333, 'Serere District', 229),
	(334, 'Kamuli District', 229),
	(335, 'Amuru District', 229),
	(336, 'Kaberamaido District', 229),
	(337, 'Namutumba District', 229),
	(338, 'Kibuku District', 229),
	(339, 'Ibanda District', 229),
	(340, 'Iganga District', 229),
	(341, 'Dokolo District', 229),
	(342, 'Lira District', 229),
	(343, 'Bukedea District', 229),
	(344, 'Alebtong District', 229),
	(345, 'Koboko District', 229),
	(346, 'Kiryandongo District', 229),
	(347, 'Kiboga District', 229),
	(348, 'Kitgum District', 229),
	(349, 'Bududa District', 229),
	(350, 'Mbale District', 229),
	(351, 'Namayingo District', 229),
	(352, 'Amuria District', 229),
	(353, 'Amudat District', 229),
	(354, 'Masindi District', 229),
	(355, 'Kiruhura District', 229),
	(356, 'Masaka District', 229),
	(357, 'Pakwach District', 229),
	(358, 'Rubanda District', 229),
	(359, 'Tororo District', 229),
	(360, 'Kamwenge District', 229),
	(361, 'Adjumani District', 229),
	(362, 'Wakiso District', 229),
	(363, 'Moyo District', 229),
	(364, 'Mityana District', 229),
	(365, 'Butaleja District', 229),
	(366, 'Gomba District', 229),
	(367, 'Jinja District', 229),
	(368, 'Kayunga District', 229),
	(369, 'Kween District', 229),
	(370, 'Western Region', 229),
	(371, 'Mubende District', 229),
	(372, 'Eastern Region', 229),
	(373, 'Kanungu District', 229),
	(374, 'Omoro District', 229),
	(375, 'Bukomansimbi District', 229),
	(376, 'Lyantonde District', 229),
	(377, 'Buikwe District', 229),
	(378, 'Nwoya District', 229),
	(379, 'Zombo District', 229),
	(380, 'Buyende District', 229),
	(381, 'Bunyangabu District', 229),
	(382, 'Kampala District', 229),
	(383, 'Isingiro District', 229),
	(384, 'Butambala District', 229),
	(385, 'Bukwo District', 229),
	(386, 'Bushenyi District', 229),
	(387, 'Bugiri District', 229),
	(388, 'Butebo District', 229),
	(389, 'Buliisa District', 229),
	(390, 'Otuke District', 229),
	(391, 'Buhweju District', 229),
	(392, 'Agago District', 229),
	(393, 'Nakapiripirit District', 229),
	(394, 'Kalungu District', 229),
	(395, 'Moroto District', 229),
	(396, 'Central Region', 229),
	(397, 'Oyam District', 229),
	(398, 'Kaliro District', 229),
	(399, 'Kakumiro District', 229),
	(400, 'Namisindwa District', 229),
	(401, 'Kole District', 229),
	(402, 'Kyenjojo District', 229),
	(403, 'Kagadi District', 229),
	(404, 'Ntungamo District', 229),
	(405, 'Kalangala District', 229),
	(406, 'Nakasongola District', 229),
	(407, 'Sheema District', 229),
	(408, 'Pader District', 229),
	(409, 'Kisoro District', 229),
	(410, 'Mukono District', 229),
	(411, 'Lamwo District', 229),
	(412, 'Pallisa District', 229),
	(413, 'Gulu District', 229),
	(414, 'Buvuma District', 229),
	(415, 'Mbarara District', 229),
	(416, 'Amolatar District', 229),
	(417, 'Lwengo District', 229),
	(418, 'Mayuge District', 229),
	(419, 'Bundibugyo District', 229),
	(420, 'Katakwi District', 229),
	(421, 'Maracha District', 229),
	(422, 'Ntoroko District', 229),
	(423, 'Nakaseke District', 229),
	(424, 'Ngora District', 229),
	(425, 'Kumi District', 229),
	(426, 'Kabale District', 229),
	(427, 'Sembabule District', 229),
	(428, 'Bulambuli District', 229),
	(429, 'Sironko District', 229),
	(430, 'Napak District', 229),
	(431, 'Busia District', 229),
	(432, 'Kapchorwa District', 229),
	(433, 'Luwero District', 229),
	(434, 'Kaabong District', 229),
	(435, 'Mitooma District', 229),
	(436, 'Kibaale District', 229),
	(437, 'Kyegegwa District', 229),
	(438, 'Manafwa District', 229),
	(439, 'Rakai District', 229),
	(440, 'Kasese District', 229),
	(441, 'Budaka District', 229),
	(442, 'Rubirizi District', 229),
	(443, 'Kotido District', 229),
	(444, 'Soroti District', 229),
	(445, 'Luuka District', 229),
	(446, 'Nebbi District', 229),
	(447, 'Arua District', 229),
	(448, 'Kyotera District', 229),
	(449, 'Schellenberg', 125),
	(450, 'Schaan', 125),
	(451, 'Eschen', 125),
	(452, 'Vaduz', 125),
	(453, 'Ruggell', 125),
	(454, 'Planken', 125),
	(455, 'Mauren', 125),
	(456, 'Triesenberg', 125),
	(457, 'Gamprin', 125),
	(458, 'Balzers', 125),
	(459, 'Triesen', 125),
	(460, 'Brčko District', 28),
	(461, 'Tuzla Canton', 28),
	(462, 'Central Bosnia Canton', 28),
	(463, 'Herzegovina-Neretva Canton', 28),
	(464, 'Posavina Canton', 28),
	(465, 'Una-Sana Canton', 28),
	(466, 'Sarajevo Canton', 28),
	(467, 'Federation of Bosnia and Herzegovina', 28),
	(468, 'Zenica-Doboj Canton', 28),
	(469, 'West Herzegovina Canton', 28),
	(470, 'Republika Srpska', 28),
	(471, 'Canton 10', 28),
	(472, 'Bosnian Podrinje Canton Goražde', 28),
	(473, 'Dakar Region', 195),
	(474, 'Kolda Region', 195),
	(475, 'Kaffrine Region', 195),
	(476, 'Matam Region', 195),
	(477, 'Saint-Louis Region', 195),
	(478, 'Ziguinchor Region', 195),
	(479, 'Fatick Region', 195),
	(480, 'Diourbel Region', 195),
	(481, 'Kédougou Region', 195),
	(482, 'Sédhiou Region', 195),
	(483, 'Kaolack Region', 195),
	(484, 'Thiès Region', 195),
	(485, 'Louga Region', 195),
	(486, 'Tambacounda Region', 195),
	(487, 'Encamp', 6),
	(488, 'Andorra la Vella', 6),
	(489, 'Canillo', 6),
	(490, 'Sant Julià de Lòria', 6),
	(491, 'Ordino', 6),
	(492, 'Escaldes-Engordany', 6),
	(493, 'La Massana', 6),
	(494, 'Mont Buxton', 197),
	(495, 'La Digue', 197),
	(496, 'Saint Louis', 197),
	(497, 'Baie Lazare', 197),
	(498, 'Mont Fleuri', 197),
	(499, 'Les Mamelles', 197),
	(500, 'Grand''Anse Mahé', 197),
	(501, 'Roche Caïman', 197),
	(502, 'Anse Royale', 197),
	(503, 'Glacis', 197),
	(504, 'Grand''Anse Praslin', 197),
	(505, 'Bel Ombre', 197),
	(506, 'Anse-aux-Pins', 197),
	(507, 'Port Glaud', 197),
	(508, 'Au Cap', 197),
	(509, 'Takamaka', 197),
	(510, 'Pointe La Rue', 197),
	(511, 'Plaisance', 197),
	(512, 'Beau Vallon', 197),
	(513, 'Anse Boileau', 197),
	(514, 'Baie Sainte Anne', 197),
	(515, 'Bel Air', 197),
	(516, 'La Rivière Anglaise', 197),
	(517, 'Cascade', 197),
	(518, 'Shaki City', 16),
	(519, 'Tartar District', 16),
	(520, 'Shirvan City', 16),
	(521, 'Qazakh District', 16),
	(522, 'Sadarak District', 16),
	(523, 'Yevlakh District', 16),
	(524, 'Khojali District', 16),
	(525, 'Kalbajar District', 16),
	(526, 'Qakh District', 16),
	(527, 'Fizuli District', 16),
	(528, 'Astara District', 16),
	(529, 'Shamakhi District', 16),
	(530, 'Neftchala District', 16),
	(531, 'Goychay District', 16),
	(532, 'Bilasuvar District', 16),
	(533, 'Tovuz District', 16),
	(534, 'Ordubad District', 16),
	(535, 'Sharur District', 16),
	(536, 'Samukh District', 16),
	(537, 'Khizi District', 16),
	(538, 'Yevlakh City', 16),
	(539, 'Ujar District', 16),
	(540, 'Absheron District', 16),
	(541, 'Lachin District', 16),
	(542, 'Qabala District', 16),
	(543, 'Agstafa District', 16),
	(544, 'Imishli District', 16),
	(545, 'Salyan District', 16),
	(546, 'Lerik District', 16),
	(547, 'Agsu District', 16),
	(548, 'Qubadli District', 16),
	(549, 'Kurdamir District', 16),
	(550, 'Yardymli District', 16),
	(551, 'Goranboy District', 16),
	(552, 'Baku', 16),
	(553, 'Agdash District', 16),
	(554, 'Beylagan District', 16),
	(555, 'Masally District', 16),
	(556, 'Oghuz District', 16),
	(557, 'Saatly District', 16),
	(558, 'Lankaran District', 16),
	(559, 'Agdam District', 16),
	(560, 'Balakan District', 16),
	(561, 'Dashkasan District', 16),
	(562, 'Nakhchivan Autonomous Republic', 16),
	(563, 'Quba District', 16),
	(564, 'Ismailli District', 16),
	(565, 'Sabirabad District', 16),
	(566, 'Zaqatala District', 16),
	(567, 'Kangarli District', 16),
	(568, 'Martuni', 16),
	(569, 'Barda District', 16),
	(570, 'Jabrayil District', 16),
	(571, 'Hajigabul District', 16),
	(572, 'Julfa District', 16),
	(573, 'Gobustan District', 16),
	(574, 'Goygol District', 16),
	(575, 'Babek District', 16),
	(576, 'Zardab District', 16),
	(577, 'Aghjabadi District', 16),
	(578, 'Jalilabad District', 16),
	(579, 'Shahbuz District', 16),
	(580, 'Mingachevir City', 16),
	(581, 'Zangilan District', 16),
	(582, 'Sumqayit City', 16),
	(583, 'Shamkir District', 16),
	(584, 'Siazan District', 16),
	(585, 'Ganja City', 16),
	(586, 'Shaki District', 16),
	(587, 'Lankaran City', 16),
	(588, 'Qusar District', 16),
	(589, 'Gadabay District', 16),
	(590, 'Khachmaz District', 16),
	(591, 'Shabran District', 16),
	(592, 'Shusha District', 16),
	(593, 'Skrapar District', 3),
	(594, 'Kavajë District', 3),
	(595, 'Lezhë District', 3),
	(596, 'Librazhd District', 3),
	(597, 'Korçë District', 3),
	(598, 'Elbasan County', 3),
	(599, 'Lushnjë District', 3),
	(600, 'Has District', 3),
	(601, 'Kukës County', 3),
	(602, 'Malësi e Madhe District', 3),
	(603, 'Berat County', 3),
	(604, 'Gjirokastër County', 3),
	(605, 'Dibër District', 3),
	(606, 'Pogradec District', 3),
	(607, 'Bulqizë District', 3),
	(608, 'Devoll District', 3),
	(609, 'Lezhë County', 3),
	(610, 'Dibër County', 3),
	(611, 'Shkodër County', 3),
	(612, 'Kuçovë District', 3),
	(613, 'Vlorë District', 3),
	(614, 'Krujë District', 3),
	(615, 'Tirana County', 3),
	(616, 'Tepelenë District', 3),
	(617, 'Gramsh District', 3),
	(618, 'Delvinë District', 3),
	(619, 'Peqin District', 3),
	(620, 'Pukë District', 3),
	(621, 'Gjirokastër District', 3),
	(622, 'Kurbin District', 3),
	(623, 'Kukës District', 3),
	(624, 'Sarandë District', 3),
	(625, 'Përmet District', 3),
	(626, 'Shkodër District', 3),
	(627, 'Fier District', 3),
	(628, 'Kolonjë District', 3),
	(629, 'Berat District', 3),
	(630, 'Korçë County', 3),
	(631, 'Fier County', 3),
	(632, 'Durrës County', 3),
	(633, 'Tirana District', 3),
	(634, 'Vlorë County', 3),
	(635, 'Mat District', 3),
	(636, 'Tropojë District', 3),
	(637, 'Mallakastër District', 3),
	(638, 'Mirditë District', 3),
	(639, 'Durrës District', 3),
	(640, 'Sveti Nikole Municipality', 129),
	(641, 'Kratovo Municipality', 129),
	(642, 'Zajas Municipality', 129),
	(643, 'Staro Nagoričane Municipality', 129),
	(644, 'Češinovo-Obleševo Municipality', 129),
	(645, 'Debarca Municipality', 129),
	(646, 'Probištip Municipality', 129),
	(647, 'Krivogaštani Municipality', 129),
	(648, 'Gevgelija Municipality', 129),
	(649, 'Bogdanci Municipality', 129),
	(650, 'Vraneštica Municipality', 129),
	(651, 'Veles Municipality', 129),
	(652, 'Bosilovo Municipality', 129),
	(653, 'Mogila Municipality', 129),
	(654, 'Tearce Municipality', 129),
	(655, 'Demir Kapija Municipality', 129),
	(656, 'Aračinovo Municipality', 129),
	(657, 'Drugovo Municipality', 129),
	(658, 'Vasilevo Municipality', 129),
	(659, 'Lipkovo Municipality', 129),
	(660, 'Brvenica Municipality', 129),
	(661, 'Štip Municipality', 129),
	(662, 'Vevčani Municipality', 129),
	(663, 'Tetovo Municipality', 129),
	(664, 'Negotino Municipality', 129),
	(665, 'Konče Municipality', 129),
	(666, 'Prilep Municipality', 129),
	(667, 'Saraj Municipality', 129),
	(668, 'Želino Municipality', 129),
	(669, 'Mavrovo and Rostuša Municipality', 129),
	(670, 'Plasnica Municipality', 129),
	(671, 'Valandovo Municipality', 129),
	(672, 'Vinica Municipality', 129),
	(673, 'Zrnovci Municipality', 129),
	(674, 'Karbinci Municipality', 129),
	(675, 'Dolneni Municipality', 129),
	(676, 'Čaška Municipality', 129),
	(677, 'Kriva Palanka Municipality', 129),
	(678, 'Jegunovce Municipality', 129),
	(679, 'Bitola Municipality', 129),
	(680, 'Šuto Orizari Municipality', 129),
	(681, 'Karpoš Municipality', 129),
	(682, 'Oslomej Municipality', 129),
	(683, 'Kumanovo Municipality', 129),
	(684, 'City of Skopje', 129),
	(685, 'Pehčevo Municipality', 129),
	(686, 'Kisela Voda Municipality', 129),
	(687, 'Demir Hisar Municipality', 129),
	(688, 'Kičevo Municipality', 129),
	(689, 'Vrapčište Municipality', 129),
	(690, 'Ilinden Municipality', 129),
	(691, 'Rosoman Municipality', 129),
	(692, 'Makedonski Brod Municipality', 129),
	(693, 'Gostivar Municipality', 129),
	(694, 'Butel Municipality', 129),
	(695, 'Delčevo Municipality', 129),
	(696, 'Novaci Municipality', 129),
	(697, 'Dojran Municipality', 129),
	(698, 'Petrovec Municipality', 129),
	(699, 'Ohrid Municipality', 129),
	(700, 'Struga Municipality', 129),
	(701, 'Makedonska Kamenica Municipality', 129),
	(702, 'Centar Municipality', 129),
	(703, 'Aerodrom Municipality', 129),
	(704, 'Čair Municipality', 129),
	(705, 'Lozovo Municipality', 129),
	(706, 'Zelenikovo Municipality', 129),
	(707, 'Gazi Baba Municipality', 129),
	(708, 'Gradsko Municipality', 129),
	(709, 'Radoviš Municipality', 129),
	(710, 'Strumica Municipality', 129),
	(711, 'Studeničani Municipality', 129),
	(712, 'Resen Municipality', 129),
	(713, 'Kavadarci Municipality', 129),
	(714, 'Kruševo Municipality', 129),
	(715, 'Čučer-Sandevo Municipality', 129),
	(716, 'Berovo Municipality', 129),
	(717, 'Rankovce Municipality', 129),
	(718, 'Novo Selo Municipality', 129),
	(719, 'Sopište Municipality', 129),
	(720, 'Centar Župa Municipality', 129),
	(721, 'Bogovinje Municipality', 129),
	(722, 'Gjorče Petrov Municipality', 129),
	(723, 'Kočani Municipality', 129),
	(724, 'Požega-Slavonia County', 55),
	(725, 'Split-Dalmatia County', 55),
	(726, 'Međimurje County', 55),
	(727, 'Zadar County', 55),
	(728, 'Dubrovnik-Neretva County', 55),
	(729, 'Krapina-Zagorje County', 55),
	(730, 'Šibenik-Knin County', 55),
	(731, 'Lika-Senj County', 55),
	(732, 'Virovitica-Podravina County', 55),
	(733, 'Sisak-Moslavina County', 55),
	(734, 'Bjelovar-Bilogora County', 55),
	(735, 'Primorje-Gorski Kotar County', 55),
	(736, 'Zagreb County', 55),
	(737, 'Brod-Posavina County', 55),
	(738, 'City of Zagreb', 55),
	(739, 'Varaždin County', 55),
	(740, 'Osijek-Baranja County', 55),
	(741, 'Vukovar-Syrmia County', 55),
	(742, 'Koprivnica-Križevci County', 55),
	(743, 'Istria County', 55),
	(744, 'Kyrenia District', 57),
	(745, 'Nicosia District', 57),
	(746, 'Paphos District', 57),
	(747, 'Larnaca District', 57),
	(748, 'Limassol District', 57),
	(749, 'Famagusta District', 57),
	(750, 'Rangpur Division', 19),
	(751, 'Cox''s Bazar District', 19),
	(752, 'Bandarban District', 19),
	(753, 'Rajshahi Division', 19),
	(754, 'Pabna District', 19),
	(755, 'Sherpur District', 19),
	(756, 'Bhola District', 19),
	(757, 'Jashore District', 19),
	(758, 'Mymensingh Division', 19),
	(759, 'Rangpur District', 19),
	(760, 'Dhaka Division', 19),
	(761, 'Chapai Nawabganj District', 19),
	(762, 'Faridpur District', 19),
	(763, 'Cumilla District', 19),
	(764, 'Netrokona District', 19),
	(765, 'Sylhet Division', 19),
	(766, 'Mymensingh District', 19),
	(767, 'Sylhet District', 19),
	(768, 'Chandpur District', 19),
	(769, 'Narail District', 19),
	(770, 'Narayanganj District', 19),
	(771, 'Dhaka District', 19),
	(772, 'Nilphamari District', 19),
	(773, 'Rajbari District', 19),
	(774, 'Kushtia District', 19),
	(775, 'Khulna Division', 19),
	(776, 'Meherpur District', 19),
	(777, 'Patuakhali District', 19),
	(778, 'Jhalokati District', 19),
	(779, 'Kishoreganj District', 19),
	(780, 'Lalmonirhat District', 19),
	(781, 'Sirajganj District', 19),
	(782, 'Tangail District', 19),
	(783, 'Dinajpur District', 19),
	(784, 'Barguna District', 19),
	(785, 'Chattogram District', 19),
	(786, 'Khagrachari District', 19),
	(787, 'Natore District', 19),
	(788, 'Chuadanga District', 19),
	(789, 'Jhenaidah District', 19),
	(790, 'Munshiganj District', 19),
	(791, 'Pirojpur District', 19),
	(792, 'Gopalganj District', 19),
	(793, 'Kurigram District', 19),
	(794, 'Moulvibazar District', 19),
	(795, 'Gaibandha District', 19),
	(796, 'Bagerhat District', 19),
	(797, 'Bogura District', 19),
	(798, 'Gazipur District', 19),
	(799, 'Satkhira District', 19),
	(800, 'Panchagarh District', 19),
	(801, 'Shariatpur District', 19),
	(802, 'Barishal District', 19),
	(803, 'Chattogram Division', 19),
	(804, 'Thakurgaon District', 19),
	(805, 'Habiganj District', 19),
	(806, 'Joypurhat District', 19),
	(807, 'Barishal Division', 19),
	(808, 'Jamalpur District', 19),
	(809, 'Rangamati Hill District', 19),
	(810, 'Brahmanbaria District', 19),
	(811, 'Khulna District', 19),
	(812, 'Sunamganj District', 19),
	(813, 'Rajshahi District', 19),
	(814, 'Naogaon District', 19),
	(815, 'Noakhali District', 19),
	(816, 'Feni District', 19),
	(817, 'Madaripur District', 19),
	(818, 'Barishal District', 19),
	(819, 'Lakshmipur District', 19),
	(820, 'Okayama Prefecture', 109),
	(821, 'Chiba Prefecture', 109),
	(822, 'Ōita Prefecture', 109),
	(823, 'Tokyo Metropolis', 109),
	(824, 'Nara Prefecture', 109),
	(825, 'Shizuoka Prefecture', 109),
	(826, 'Shimane Prefecture', 109),
	(827, 'Aichi Prefecture', 109),
	(828, 'Hiroshima Prefecture', 109),
	(829, 'Akita Prefecture', 109),
	(830, 'Ishikawa Prefecture', 109),
	(831, 'Hyōgo Prefecture', 109),
	(832, 'Hokkaidō', 109),
	(833, 'Mie Prefecture', 109),
	(834, 'Kyōto Prefecture', 109),
	(835, 'Yamaguchi Prefecture', 109),
	(836, 'Tokushima Prefecture', 109),
	(837, 'Yamagata Prefecture', 109),
	(838, 'Toyama Prefecture', 109),
	(839, 'Aomori Prefecture', 109),
	(840, 'Kagoshima Prefecture', 109),
	(841, 'Niigata Prefecture', 109),
	(842, 'Kanagawa Prefecture', 109),
	(843, 'Nagano Prefecture', 109),
	(844, 'Wakayama Prefecture', 109),
	(845, 'Shiga Prefecture', 109),
	(846, 'Kumamoto Prefecture', 109),
	(847, 'Fukushima Prefecture', 109),
	(848, 'Fukui Prefecture', 109),
	(849, 'Nagasaki Prefecture', 109),
	(850, 'Tottori Prefecture', 109),
	(851, 'Ibaraki Prefecture', 109),
	(852, 'Yamanashi Prefecture', 109),
	(853, 'Okinawa Prefecture', 109),
	(854, 'Tochigi Prefecture', 109),
	(855, 'Miyazaki Prefecture', 109),
	(856, 'Iwate Prefecture', 109),
	(857, 'Miyagi Prefecture', 109),
	(858, 'Gifu Prefecture', 109),
	(859, 'Ōsaka Prefecture', 109),
	(860, 'Saitama Prefecture', 109),
	(861, 'Fukuoka Prefecture', 109),
	(862, 'Gunma Prefecture', 109),
	(863, 'Saga Prefecture', 109),
	(864, 'Kagawa Prefecture', 109),
	(865, 'Ehime Prefecture', 109),
	(866, 'Ontario', 39),
	(867, 'Manitoba', 39),
	(868, 'New Brunswick', 39),
	(869, 'Yukon', 39),
	(870, 'Saskatchewan', 39),
	(871, 'Prince Edward Island', 39),
	(872, 'Alberta', 39),
	(873, 'Quebec', 39),
	(874, 'Nova Scotia', 39),
	(875, 'British Columbia', 39),
	(876, 'Nunavut', 39),
	(877, 'Newfoundland and Labrador', 39),
	(878, 'Northwest Territories', 39),
	(879, 'White Nile', 209),
	(880, 'Red Sea', 209),
	(881, 'Khartoum', 209),
	(882, 'Sennar', 209),
	(883, 'South Kordofan', 209),
	(884, 'Kassala', 209),
	(885, 'Al Jazirah', 209),
	(886, 'Al Qadarif', 209),
	(887, 'Blue Nile', 209),
	(888, 'West Darfur', 209),
	(889, 'West Kordofan', 209),
	(890, 'North Darfur', 209),
	(891, 'River Nile', 209),
	(892, 'East Darfur', 209),
	(893, 'North Kordofan', 209),
	(894, 'South Darfur', 209),
	(895, 'Northern', 209),
	(896, 'Central Darfur', 209),
	(897, 'Khelvachauri Municipality', 81),
	(898, 'Senaki Municipality', 81),
	(899, 'Tbilisi', 81),
	(900, 'Adjara', 81),
	(901, 'Autonomous Republic of Abkhazia', 81),
	(902, 'Mtskheta-Mtianeti', 81),
	(903, 'Shida Kartli', 81),
	(904, 'Kvemo Kartli', 81),
	(905, 'Imereti', 81),
	(906, 'Samtskhe-Javakheti', 81),
	(907, 'Guria', 81),
	(908, 'Samegrelo-Zemo Svaneti', 81),
	(909, 'Racha-Lechkhumi and Kvemo Svaneti', 81),
	(910, 'Kakheti', 81),
	(911, 'Northern Province', 198),
	(912, 'Southern Province', 198),
	(913, 'Western Area', 198),
	(914, 'Eastern Province', 198),
	(915, 'Hiran', 203),
	(916, 'Mudug', 203),
	(917, 'Bakool', 203),
	(918, 'Galguduud', 203),
	(919, 'Sanaag', 203),
	(920, 'Nugal', 203),
	(921, 'Lower Shabelle', 203),
	(922, 'Middle Juba', 203),
	(923, 'Middle Shabelle', 203),
	(924, 'Lower Juba', 203),
	(925, 'Awdal', 203),
	(926, 'Bay', 203),
	(927, 'Banaadir', 203),
	(928, 'Gedo', 203),
	(929, 'Togdheer', 203),
	(930, 'Bari', 203),
	(931, 'Northern Cape', 204),
	(932, 'Free State', 204),
	(933, 'Limpopo', 204),
	(934, 'North West', 204),
	(935, 'KwaZulu-Natal', 204),
	(936, 'Gauteng', 204),
	(937, 'Mpumalanga', 204),
	(938, 'Eastern Cape', 204),
	(939, 'Western Cape', 204),
	(940, 'Chontales Department', 159),
	(941, 'Managua Department', 159),
	(942, 'Rivas Department', 159),
	(943, 'Granada Department', 159),
	(944, 'León Department', 159),
	(945, 'Estelí Department', 159),
	(946, 'Boaco Department', 159),
	(947, 'Matagalpa Department', 159),
	(948, 'Madriz Department', 159),
	(949, 'Río San Juan Department', 159),
	(950, 'Carazo Department', 159),
	(951, 'North Caribbean Coast Autonomous Region', 159),
	(952, 'South Caribbean Coast Autonomous Region', 159),
	(953, 'Masaya Department', 159),
	(954, 'Chinandega Department', 159),
	(955, 'Jinotega Department', 159),
	(956, 'Karak Governorate', 111),
	(957, 'Tafilah Governorate', 111),
	(958, 'Madaba Governorate', 111),
	(959, 'Aqaba Governorate', 111),
	(960, 'Irbid Governorate', 111),
	(961, 'Balqa Governorate', 111),
	(962, 'Mafraq Governorate', 111),
	(963, 'Ajloun Governorate', 111),
	(964, 'Ma''an Governorate', 111),
	(965, 'Amman Governorate', 111),
	(966, 'Jerash Governorate', 111),
	(967, 'Zarqa Governorate', 111),
	(968, 'Manzini District', 212),
	(969, 'Hhohho District', 212),
	(970, 'Lubombo District', 212),
	(971, 'Shiselweni District', 212),
	(972, 'Al Jahra Governorate', 117),
	(973, 'Hawalli Governorate', 117),
	(974, 'Mubarak Al-Kabeer Governorate', 117),
	(975, 'Al Farwaniyah Governorate', 117),
	(976, 'Capital Governorate', 117),
	(977, 'Al Ahmadi Governorate', 117),
	(978, 'Luang Prabang Province', 119),
	(979, 'Vientiane Prefecture', 119),
	(980, 'Vientiane Province', 119),
	(981, 'Salavan Province', 119),
	(982, 'Attapeu Province', 119),
	(983, 'Xaisomboun Province', 119),
	(984, 'Sekong Province', 119),
	(985, 'Bolikhamsai Province', 119),
	(986, 'Khammouane Province', 119),
	(987, 'Phongsaly Province', 119),
	(988, 'Oudomxay Province', 119),
	(989, 'Houaphanh Province', 119),
	(990, 'Savannakhet Province', 119),
	(991, 'Bokeo Province', 119),
	(992, 'Luang Namtha Province', 119),
	(993, 'Sainyabuli Province', 119),
	(994, 'Xaisomboun Special Zone (historical)', 119),
	(995, 'Xiangkhouang Province', 119),
	(996, 'Champasak Province', 119),
	(997, 'Talas Region', 118),
	(998, 'Batken Region', 118),
	(999, 'Naryn Region', 118),
	(1000, 'Jalal-Abad Region', 118),
	(1001, 'Bishkek City', 118),
	(1002, 'Issyk-Kul Region', 118),
	(1003, 'Osh City', 118),
	(1004, 'Chuy Region', 118),
	(1005, 'Osh Region', 118),
	(1006, 'Trøndelag', 165),
	(1007, 'Oslo', 165),
	(1008, 'Vestfold og Telemark', 165),
	(1009, 'Innlandet', 165),
	(1010, 'Sør-Trøndelag (historical)', 165),
	(1011, 'Viken', 165),
	(1012, 'Nord-Trøndelag (historical)', 165),
	(1013, 'Svalbard', 165),
	(1014, 'Agder', 165),
	(1015, 'Troms og Finnmark', 165),
	(1016, 'Finnmark (historical)', 165),
	(1017, 'Akershus (historical)', 165),
	(1018, 'Vestland', 165),
	(1019, 'Hedmark (historical)', 165),
	(1020, 'Møre og Romsdal', 165),
	(1021, 'Rogaland', 165),
	(1022, 'Østfold (historical)', 165),
	(1023, 'Hordaland (historical)', 165),
	(1024, 'Telemark (historical)', 165),
	(1025, 'Nordland', 165),
	(1026, 'Jan Mayen', 165),
	(1027, 'Hódmezővásárhely', 99),
	(1028, 'Érd', 99),
	(1029, 'Szeged', 99),
	(1030, 'Nagykanizsa', 99),
	(1031, 'Csongrád-Csanád County', 99),
	(1032, 'Debrecen', 99),
	(1033, 'Székesfehérvár', 99),
	(1034, 'Nyíregyháza', 99),
	(1035, 'Somogy County', 99),
	(1036, 'Békéscsaba', 99),
	(1037, 'Eger', 99),
	(1038, 'Tolna County', 99),
	(1039, 'Vas County', 99),
	(1040, 'Heves County', 99),
	(1041, 'Győr', 99),
	(1042, 'Győr-Moson-Sopron County', 99),
	(1043, 'Jász-Nagykun-Szolnok County', 99),
	(1044, 'Fejér County', 99),
	(1045, 'Szabolcs-Szatmár-Bereg County', 99),
	(1046, 'Zala County', 99),
	(1047, 'Szolnok', 99),
	(1048, 'Bács-Kiskun County', 99),
	(1049, 'Dunaújváros', 99),
	(1050, 'Zalaegerszeg', 99),
	(1051, 'Nógrád County', 99),
	(1052, 'Szombathely', 99),
	(1053, 'Pécs', 99),
	(1054, 'Veszprém County', 99),
	(1055, 'Baranya County', 99),
	(1056, 'Kecskemét', 99),
	(1057, 'Sopron', 99),
	(1058, 'Borsod-Abaúj-Zemplén County', 99),
	(1059, 'Pest County', 99),
	(1060, 'Békés County', 99),
	(1061, 'Szekszárd', 99),
	(1062, 'Veszprém', 99),
	(1063, 'Hajdú-Bihar County', 99),
	(1064, 'Budapest', 99),
	(1065, 'Miskolc', 99),
	(1066, 'Tatabánya', 99),
	(1067, 'Kaposvár', 99),
	(1068, 'Salgótarján', 99),
	(1069, 'County Tipperary', 105),
	(1070, 'County Sligo', 105),
	(1071, 'County Donegal', 105),
	(1072, 'County Dublin', 105),
	(1073, 'Leinster', 105),
	(1074, 'County Cork', 105),
	(1075, 'County Monaghan', 105),
	(1076, 'County Longford', 105),
	(1077, 'County Kerry', 105),
	(1078, 'County Offaly', 105),
	(1079, 'County Galway', 105),
	(1080, 'Munster', 105),
	(1081, 'County Roscommon', 105),
	(1082, 'County Kildare', 105),
	(1083, 'County Louth', 105),
	(1084, 'County Mayo', 105),
	(1085, 'County Wicklow', 105),
	(1086, 'Ulster', 105),
	(1087, 'Connacht', 105),
	(1088, 'County Cavan', 105),
	(1089, 'County Waterford', 105),
	(1090, 'County Kilkenny', 105),
	(1091, 'County Clare', 105),
	(1092, 'County Meath', 105),
	(1093, 'County Wexford', 105),
	(1094, 'County Limerick', 105),
	(1095, 'County Carlow', 105),
	(1096, 'County Laois', 105),
	(1097, 'County Westmeath', 105),
	(1098, 'Djelfa Province', 4),
	(1099, 'El Oued Province', 4),
	(1100, 'El Tarf Province', 4),
	(1101, 'Oran Province', 4),
	(1102, 'Naama Province', 4),
	(1103, 'Annaba Province', 4),
	(1104, 'Bouïra Province', 4),
	(1105, 'Chlef Province', 4),
	(1106, 'Tiaret Province', 4),
	(1107, 'Tlemcen Province', 4),
	(1108, 'Béchar Province', 4),
	(1109, 'Médéa Province', 4),
	(1110, 'Skikda Province', 4),
	(1111, 'Blida Province', 4),
	(1112, 'Illizi Province', 4),
	(1113, 'Jijel Province', 4),
	(1114, 'Biskra Province', 4),
	(1115, 'Tipaza Province', 4),
	(1116, 'Bordj Bou Arréridj Province', 4),
	(1117, 'Tébessa Province', 4),
	(1118, 'Adrar Province', 4),
	(1119, 'Aïn Defla Province', 4),
	(1120, 'Tindouf Province', 4),
	(1121, 'Constantine Province', 4),
	(1122, 'Aïn Témouchent Province', 4),
	(1123, 'Saïda Province', 4),
	(1124, 'Mascara Province', 4),
	(1125, 'Boumerdès Province', 4),
	(1126, 'Khenchela Province', 4),
	(1127, 'Ghardaïa Province', 4),
	(1128, 'Béjaïa Province', 4),
	(1129, 'El Bayadh Province', 4),
	(1130, 'Relizane Province', 4),
	(1131, 'Tizi Ouzou Province', 4),
	(1132, 'Mila Province', 4),
	(1133, 'Tissemsilt Province', 4),
	(1134, 'M''Sila Province', 4),
	(1135, 'Tamanrasset Province', 4),
	(1136, 'Oum El Bouaghi Province', 4),
	(1137, 'Guelma Province', 4),
	(1138, 'Laghouat Province', 4),
	(1139, 'Ouargla Province', 4),
	(1140, 'Mostaganem Province', 4),
	(1141, 'Sétif Province', 4),
	(1142, 'Batna Province', 4),
	(1143, 'Souk Ahras Province', 4),
	(1144, 'Algiers Province', 4),
	(1145, 'Region of Murcia', 207),
	(1146, 'Burgos Province', 207),
	(1147, 'Salamanca Province', 207),
	(1148, 'Álava / Araba', 207),
	(1149, 'Madrid Province (historical)', 207),
	(1150, 'Ciudad Real Province', 207),
	(1151, 'Almería Province', 207),
	(1152, 'Valencia Province', 207),
	(1153, 'Badajoz Province', 207),
	(1154, 'Pontevedra Province', 207),
	(1155, 'Seville Province', 207),
	(1156, 'Alicante Province', 207),
	(1157, 'Palencia Province', 207),
	(1158, 'Community of Madrid', 207),
	(1159, 'Melilla', 207),
	(1160, 'Asturias', 207),
	(1161, 'Zamora Province', 207),
	(1162, 'Zaragoza Province', 207),
	(1163, 'Huesca Province', 207),
	(1164, 'Tarragona Province', 207),
	(1165, 'Toledo Province', 207),
	(1166, 'Las Palmas Province', 207),
	(1167, 'Galicia', 207),
	(1168, 'Albacete Province', 207),
	(1169, 'Cuenca Province', 207),
	(1170, 'Cantabria', 207),
	(1171, 'La Rioja', 207),
	(1172, 'Guadalajara Province', 207),
	(1173, 'Ourense Province', 207),
	(1174, 'Balearic Islands', 207),
	(1175, 'Valencian Community', 207),
	(1176, 'Region of Murcia', 207),
	(1177, 'Aragon', 207),
	(1178, 'Girona Province', 207),
	(1179, 'A Coruña Province', 207),
	(1180, 'Barcelona Province', 207),
	(1181, 'Jaén Province', 207),
	(1182, 'Teruel Province', 207),
	(1183, 'Valladolid Province', 207),
	(1184, 'Castile and León', 207),
	(1185, 'Canary Islands', 207),
	(1186, 'Biscay', 207),
	(1187, 'Lugo Province', 207),
	(1188, 'Málaga Province', 207),
	(1189, 'Ávila Province', 207),
	(1190, 'Extremadura', 207),
	(1191, 'Basque Country', 207),
	(1192, 'Segovia Province', 207),
	(1193, 'Andalusia', 207),
	(1194, 'Granada Province', 207),
	(1195, 'Lleida Province', 207),
	(1196, 'Cáceres Province', 207),
	(1197, 'Córdoba Province', 207),
	(1198, 'Santa Cruz de Tenerife Province', 207),
	(1199, 'Huelva Province', 207),
	(1200, 'León Province', 207),
	(1201, 'Cádiz Province', 207),
	(1202, 'Gipuzkoa', 207),
	(1203, 'Catalonia', 207),
	(1204, 'Navarre', 207),
	(1205, 'Castilla-La Mancha', 207),
	(1206, 'Ceuta', 207),
	(1207, 'Castellón Province', 207),
	(1208, 'Soria Province', 207),
	(1209, 'Guanacaste Province', 53),
	(1210, 'Puntarenas Province', 53),
	(1211, 'Cartago Province', 53),
	(1212, 'Heredia Province', 53),
	(1213, 'Limón Province', 53),
	(1214, 'San José Province', 53),
	(1215, 'Alajuela Province', 53),
	(1216, 'Brunei-Muara District', 33),
	(1217, 'Belait District', 33),
	(1218, 'Temburong District', 33),
	(1219, 'Tutong District', 33),
	(1220, 'Saint Philip', 20),
	(1221, 'Saint Lucy', 20),
	(1222, 'Saint Peter', 20),
	(1223, 'Saint Joseph', 20),
	(1224, 'Saint James', 20),
	(1225, 'Saint Thomas', 20),
	(1226, 'Saint George', 20),
	(1227, 'Saint John', 20),
	(1228, 'Christ Church', 20),
	(1229, 'Saint Andrew', 20),
	(1230, 'Saint Michael', 20),
	(1231, 'Ta''izz Governorate', 245),
	(1232, 'Sana''a City (Capital)', 245),
	(1233, 'Ibb Governorate', 245),
	(1234, 'Ma''rib Governorate', 245),
	(1235, 'Al Mahwit Governorate', 245),
	(1236, 'Sana''a Governorate', 245),
	(1237, 'Abyan Governorate', 245),
	(1238, 'Hadhramaut Governorate', 245),
	(1239, 'Socotra Governorate', 245),
	(1240, 'Al Bayda'' Governorate', 245),
	(1241, 'Al Hudaydah Governorate', 245),
	(1242, '''Adan Governorate', 245),
	(1243, 'Al Jawf Governorate', 245),
	(1244, 'Hajjah Governorate', 245),
	(1245, 'Lahij Governorate', 245),
	(1246, 'Dhamar Governorate', 245),
	(1247, 'Shabwah Governorate', 245),
	(1248, 'Raymah Governorate', 245),
	(1249, 'Saada Governorate', 245),
	(1250, '''Amran Governorate', 245),
	(1251, 'Al Mahrah Governorate', 245),
	(1252, 'Sangha-Mbaéré', 42),
	(1253, 'Nana-Grébizi', 42),
	(1254, 'Ouham Prefecture', 42),
	(1255, 'Ombella-M''Poko Prefecture', 42),
	(1256, 'Lobaye Prefecture', 42),
	(1257, 'Mambéré-Kadéï', 42),
	(1258, 'Haut-Mbomou Prefecture', 42),
	(1259, 'Bamingui-Bangoran Prefecture', 42),
	(1260, 'Nana-Mambéré Prefecture', 42),
	(1261, 'Vakaga Prefecture', 42),
	(1262, 'Bangui', 42),
	(1263, 'Kémo Prefecture', 42),
	(1264, 'Basse-Kotto Prefecture', 42),
	(1265, 'Ouaka Prefecture', 42),
	(1266, 'Mbomou Prefecture', 42),
	(1267, 'Ouham-Pendé Prefecture', 42),
	(1268, 'Haute-Kotto Prefecture', 42),
	(1269, 'Romblon', 174),
	(1270, 'Bukidnon', 174),
	(1271, 'Rizal', 174),
	(1272, 'Bohol', 174),
	(1273, 'Quirino', 174),
	(1274, 'Biliran', 174),
	(1275, 'Quezon', 174),
	(1276, 'Siquijor', 174),
	(1277, 'Sarangani', 174),
	(1278, 'Bulacan', 174),
	(1279, 'Cagayan', 174),
	(1280, 'South Cotabato', 174),
	(1281, 'Sorsogon', 174),
	(1282, 'Sultan Kudarat', 174),
	(1283, 'Camarines Norte', 174),
	(1284, 'Southern Leyte', 174),
	(1285, 'Camiguin', 174),
	(1286, 'Surigao del Norte', 174),
	(1287, 'Camarines Sur', 174),
	(1288, 'Sulu', 174),
	(1289, 'Davao Oriental', 174),
	(1290, 'Eastern Samar', 174),
	(1291, 'Dinagat Islands', 174),
	(1292, 'Capiz', 174),
	(1293, 'Tawi-Tawi', 174),
	(1294, 'Calabarzon', 174),
	(1295, 'Tarlac', 174),
	(1296, 'Surigao del Sur', 174),
	(1297, 'Zambales', 174),
	(1298, 'Ilocos Norte', 174),
	(1299, 'Mimaropa', 174),
	(1300, 'Ifugao', 174),
	(1301, 'Catanduanes', 174),
	(1302, 'Zamboanga del Norte', 174),
	(1303, 'Guimaras', 174),
	(1304, 'Bicol Region', 174),
	(1305, 'Western Visayas', 174),
	(1306, 'Cebu', 174),
	(1307, 'Cavite', 174),
	(1308, 'Central Visayas', 174),
	(1309, 'Davao Occidental', 174),
	(1310, 'Soccsksargen', 174),
	(1311, 'Davao de Oro', 174),
	(1312, 'Kalinga', 174),
	(1313, 'Isabela', 174),
	(1314, 'Caraga', 174),
	(1315, 'Iloilo', 174),
	(1316, 'Bangsamoro Autonomous Region in Muslim Mindanao', 174),
	(1317, 'La Union', 174),
	(1318, 'Davao del Sur', 174),
	(1319, 'Davao del Norte', 174),
	(1320, 'Cotabato', 174),
	(1321, 'Ilocos Sur', 174),
	(1322, 'Eastern Visayas', 174),
	(1323, 'Agusan del Norte', 174),
	(1324, 'Abra', 174),
	(1325, 'Zamboanga Peninsula', 174),
	(1326, 'Agusan del Sur', 174),
	(1327, 'Lanao del Norte', 174),
	(1328, 'Laguna', 174),
	(1329, 'Marinduque', 174),
	(1330, 'Maguindanao', 174),
	(1331, 'Aklan', 174),
	(1332, 'Leyte', 174),
	(1333, 'Lanao del Sur', 174),
	(1334, 'Apayao', 174),
	(1335, 'Cordillera Administrative Region', 174),
	(1336, 'Antique', 174),
	(1337, 'Albay', 174),
	(1338, 'Masbate', 174),
	(1339, 'Northern Mindanao', 174),
	(1340, 'Davao Region', 174),
	(1341, 'Aurora', 174),
	(1342, 'Cagayan Valley', 174),
	(1343, 'Misamis Occidental', 174),
	(1344, 'Bataan', 174),
	(1345, 'Central Luzon', 174),
	(1346, 'Basilan', 174),
	(1347, 'Metro Manila', 174),
	(1348, 'Misamis Oriental', 174),
	(1349, 'Northern Samar', 174),
	(1350, 'Negros Oriental', 174),
	(1351, 'Negros Occidental', 174),
	(1352, 'Batanes', 174),
	(1353, 'Mountain Province', 174),
	(1354, 'Oriental Mindoro', 174),
	(1355, 'Ilocos Region', 174),
	(1356, 'Occidental Mindoro', 174),
	(1357, 'Zamboanga del Sur', 174),
	(1358, 'Nueva Vizcaya', 174),
	(1359, 'Batangas', 174),
	(1360, 'Nueva Ecija', 174),
	(1361, 'Palawan', 174),
	(1362, 'Zamboanga Sibugay', 174),
	(1363, 'Benguet', 174),
	(1364, 'Pangasinan', 174),
	(1365, 'Pampanga', 174),
	(1366, 'Northern District', 106),
	(1367, 'Central District', 106),
	(1368, 'Southern District', 106),
	(1369, 'Haifa District', 106),
	(1370, 'Jerusalem District', 106),
	(1371, 'Tel Aviv District', 106),
	(1372, 'Limburg', 22),
	(1373, 'Flanders', 22),
	(1374, 'Flemish Brabant', 22),
	(1375, 'Hainaut', 22),
	(1376, 'Brussels-Capital Region', 22),
	(1377, 'East Flanders', 22),
	(1378, 'Namur', 22),
	(1379, 'Luxembourg', 22),
	(1380, 'Wallonia', 22),
	(1381, 'Antwerp', 22),
	(1382, 'Walloon Brabant', 22),
	(1383, 'West Flanders', 22),
	(1384, 'Liège', 22),
	(1385, 'Darién Province', 170),
	(1386, 'Colón Province', 170),
	(1387, 'Coclé Province', 170),
	(1388, 'Guna Yala', 170),
	(1389, 'Herrera Province', 170),
	(1390, 'Los Santos Province', 170),
	(1391, 'Ngäbe-Buglé Comarca', 170),
	(1392, 'Veraguas Province', 170),
	(1393, 'Bocas del Toro Province', 170),
	(1394, 'Panamá Oeste Province', 170),
	(1395, 'Panamá Province', 170),
	(1396, 'Emberá-Wounaan Comarca', 170),
	(1397, 'Chiriquí Province', 170),
	(1398, 'Howland Island', 233),
	(1399, 'Delaware', 233),
	(1400, 'Alaska', 233),
	(1401, 'Maryland', 233),
	(1402, 'Baker Island', 233),
	(1403, 'Kingman Reef', 233),
	(1404, 'New Hampshire', 233),
	(1405, 'Wake Island', 233),
	(1406, 'Kansas', 233),
	(1407, 'Texas', 233),
	(1408, 'Nebraska', 233),
	(1409, 'Vermont', 233),
	(1410, 'Jarvis Island', 233),
	(1411, 'Hawaii', 233),
	(1412, 'Guam', 233),
	(1413, 'United States Virgin Islands', 233),
	(1414, 'Utah', 233),
	(1415, 'Oregon', 233),
	(1416, 'California', 233),
	(1417, 'New Jersey', 233),
	(1418, 'North Dakota', 233),
	(1419, 'Kentucky', 233),
	(1420, 'Minnesota', 233),
	(1421, 'Oklahoma', 233),
	(1422, 'Pennsylvania', 233),
	(1423, 'New Mexico', 233),
	(1424, 'American Samoa', 233),
	(1425, 'Illinois', 233),
	(1426, 'Michigan', 233),
	(1427, 'Virginia', 233),
	(1428, 'Johnston Atoll', 233),
	(1429, 'West Virginia', 233),
	(1430, 'Mississippi', 233),
	(1431, 'Northern Mariana Islands', 233),
	(1432, 'United States Minor Outlying Islands', 233),
	(1433, 'Massachusetts', 233),
	(1434, 'Arizona', 233),
	(1435, 'Connecticut', 233),
	(1436, 'Florida', 233),
	(1437, 'District of Columbia', 233),
	(1438, 'Midway Atoll', 233),
	(1439, 'Navassa Island', 233),
	(1440, 'Indiana', 233),
	(1441, 'Wisconsin', 233),
	(1442, 'Wyoming', 233),
	(1443, 'South Carolina', 233),
	(1444, 'Arkansas', 233),
	(1445, 'South Dakota', 233),
	(1446, 'Montana', 233),
	(1447, 'North Carolina', 233),
	(1448, 'Palmyra Atoll', 233),
	(1449, 'Puerto Rico', 233),
	(1450, 'Colorado', 233),
	(1451, 'Missouri', 233),
	(1452, 'New York', 233),
	(1453, 'Maine', 233),
	(1454, 'Tennessee', 233),
	(1455, 'Georgia', 233),
	(1456, 'Alabama', 233),
	(1457, 'Louisiana', 233),
	(1458, 'Nevada', 233),
	(1459, 'Iowa', 233),
	(1460, 'Idaho', 233),
	(1461, 'Rhode Island', 233),
	(1462, 'Washington', 233),
	(1463, 'Shinyanga Region', 218),
	(1464, 'Simiyu Region', 218),
	(1465, 'Kagera Region', 218),
	(1466, 'Dodoma Region', 218),
	(1467, 'Kilimanjaro Region', 218),
	(1468, 'Mara Region', 218),
	(1469, 'Tabora Region', 218),
	(1470, 'Morogoro Region', 218),
	(1471, 'Unguja South Region', 218),
	(1472, 'Pemba South Region', 218),
	(1473, 'Unguja North Region', 218),
	(1474, 'Singida Region', 218),
	(1475, 'Unguja Urban West Region', 218),
	(1476, 'Mtwara Region', 218),
	(1477, 'Rukwa Region', 218),
	(1478, 'Kigoma Region', 218),
	(1479, 'Mwanza Region', 218),
	(1480, 'Njombe Region', 218),
	(1481, 'Geita Region', 218),
	(1482, 'Katavi Region', 218),
	(1483, 'Lindi Region', 218),
	(1484, 'Manyara Region', 218),
	(1485, 'Pwani Region', 218),
	(1486, 'Ruvuma Region', 218),
	(1487, 'Tanga Region', 218),
	(1488, 'Pemba North Region', 218),
	(1489, 'Iringa Region', 218),
	(1490, 'Dar es Salaam Region', 218),
	(1491, 'Arusha Region', 218),
	(1492, 'Eastern Finland Province (historical)', 74),
	(1493, 'Tavastia Proper', 74),
	(1494, 'Central Ostrobothnia', 74),
	(1495, 'Southern Savonia', 74),
	(1496, 'Kainuu', 74),
	(1497, 'South Karelia', 74),
	(1498, 'Southern Ostrobothnia', 74),
	(1499, 'Oulu Province (historical)', 74),
	(1500, 'Lapland', 74),
	(1501, 'Satakunta', 74),
	(1502, 'Päijät-Häme', 74),
	(1503, 'Northern Savonia', 74),
	(1504, 'North Karelia', 74),
	(1505, 'Northern Ostrobothnia', 74),
	(1506, 'Pirkanmaa', 74),
	(1507, 'Finland Proper', 74),
	(1508, 'Ostrobothnia', 74),
	(1509, 'Åland Islands', 74),
	(1510, 'Uusimaa', 74),
	(1511, 'Central Finland', 74),
	(1512, 'Kymenlaakso', 74),
	(1513, 'Canton of Diekirch', 127),
	(1514, 'Luxembourg District (historical)', 127),
	(1515, 'Canton of Echternach', 127),
	(1516, 'Canton of Redange', 127),
	(1517, 'Canton of Esch-sur-Alzette', 127),
	(1518, 'Canton of Capellen', 127),
	(1519, 'Canton of Remich', 127),
	(1520, 'Grevenmacher District (historical)', 127),
	(1521, 'Canton of Clervaux', 127),
	(1522, 'Canton of Mersch', 127),
	(1523, 'Canton of Vianden', 127),
	(1524, 'Diekirch District (historical)', 127),
	(1525, 'Canton of Grevenmacher', 127),
	(1526, 'Canton of Wiltz', 127),
	(1527, 'Canton of Luxembourg', 127),
	(1528, 'Region Zealand', 59),
	(1529, 'Region of Southern Denmark', 59),
	(1530, 'Capital Region of Denmark', 59),
	(1531, 'Central Denmark Region', 59),
	(1532, 'North Denmark Region', 59),
	(1533, 'Gävleborg County', 213),
	(1534, 'Dalarna County', 213),
	(1535, 'Värmland County', 213),
	(1536, 'Östergötland County', 213),
	(1537, 'Blekinge County', 213),
	(1538, 'Norrbotten County', 213),
	(1539, 'Örebro County', 213),
	(1540, 'Södermanland County', 213),
	(1541, 'Skåne County', 213),
	(1542, 'Kronoberg County', 213),
	(1543, 'Västerbotten County', 213),
	(1544, 'Kalmar County', 213),
	(1545, 'Uppsala County', 213),
	(1546, 'Gotland County', 213),
	(1547, 'Västra Götaland County', 213),
	(1548, 'Halland County', 213),
	(1549, 'Västmanland County', 213),
	(1550, 'Jönköping County', 213),
	(1551, 'Stockholm County', 213),
	(1552, 'Västernorrland County', 213),
	(1553, 'Plungė District Municipality', 126),
	(1554, 'Šiauliai District Municipality', 126),
	(1555, 'Jurbarkas District Municipality', 126),
	(1556, 'Kaunas County', 126),
	(1557, 'Mažeikiai District Municipality', 126),
	(1558, 'Panevėžys County', 126),
	(1559, 'Elektrėnai Municipality', 126),
	(1560, 'Švenčionys District Municipality', 126),
	(1561, 'Akmenė District Municipality', 126),
	(1562, 'Ignalina District Municipality', 126),
	(1563, 'Neringa Municipality', 126),
	(1564, 'Visaginas Municipality', 126),
	(1565, 'Kaunas District Municipality', 126),
	(1566, 'Biržai District Municipality', 126),
	(1567, 'Jonava District Municipality', 126),
	(1568, 'Radviliškis District Municipality', 126),
	(1569, 'Telšiai County', 126),
	(1570, 'Marijampolė County', 126),
	(1571, 'Kretinga District Municipality', 126),
	(1572, 'Tauragė District Municipality', 126),
	(1573, 'Tauragė County', 126),
	(1574, 'Alytus County', 126),
	(1575, 'Kazlų Rūda Municipality', 126),
	(1576, 'Šakiai District Municipality', 126),
	(1577, 'Šalčininkai District Municipality', 126),
	(1578, 'Prienai District Municipality', 126),
	(1579, 'Druskininkai Municipality', 126),
	(1580, 'Kaunas City Municipality', 126),
	(1581, 'Joniškis District Municipality', 126),
	(1582, 'Molėtai District Municipality', 126),
	(1583, 'Kaišiadorys District Municipality', 126),
	(1584, 'Kėdainiai District Municipality', 126),
	(1585, 'Kupiškis District Municipality', 126),
	(1586, 'Šiauliai County', 126),
	(1587, 'Raseiniai District Municipality', 126),
	(1588, 'Palanga City Municipality', 126),
	(1589, 'Panevėžys City Municipality', 126),
	(1590, 'Rietavas Municipality', 126),
	(1591, 'Kalvarija Municipality', 126),
	(1592, 'Vilnius District Municipality', 126),
	(1593, 'Trakai District Municipality', 126),
	(1594, 'Širvintos District Municipality', 126),
	(1595, 'Pakruojis District Municipality', 126),
	(1596, 'Ukmergė District Municipality', 126),
	(1597, 'Klaipėda City Municipality', 126),
	(1598, 'Utena District Municipality', 126),
	(1599, 'Alytus District Municipality', 126),
	(1600, 'Klaipėda County', 126),
	(1601, 'Vilnius County', 126),
	(1602, 'Varėna District Municipality', 126),
	(1603, 'Birštonas Municipality', 126),
	(1604, 'Klaipėda District Municipality', 126),
	(1605, 'Alytus City Municipality', 126),
	(1606, 'Vilnius City Municipality', 126),
	(1607, 'Šilutė District Municipality', 126),
	(1608, 'Telšiai District Municipality', 126),
	(1609, 'Šiauliai City Municipality', 126),
	(1610, 'Marijampolė Municipality', 126),
	(1611, 'Lazdijai District Municipality', 126),
	(1612, 'Pagėgiai Municipality', 126),
	(1613, 'Šilalė District Municipality', 126),
	(1614, 'Panevėžys District Municipality', 126),
	(1615, 'Rokiškis District Municipality', 126),
	(1616, 'Pasvalys District Municipality', 126),
	(1617, 'Skuodas District Municipality', 126),
	(1618, 'Kelmė District Municipality', 126),
	(1619, 'Zarasai District Municipality', 126),
	(1620, 'Vilkaviškis District Municipality', 126),
	(1621, 'Utena County', 126),
	(1622, 'Opole Voivodeship', 176),
	(1623, 'Silesian Voivodeship', 176),
	(1624, 'Pomeranian Voivodeship', 176),
	(1625, 'Kuyavian-Pomeranian Voivodeship', 176),
	(1626, 'Podkarpackie Voivodeship', 176),
	(1627, 'Kielce (historical)', 176),
	(1628, 'Warmian-Masurian Voivodeship', 176),
	(1629, 'Lower Silesian Voivodeship', 176),
	(1630, 'Świętokrzyskie Voivodeship', 176),
	(1631, 'Lubusz Voivodeship', 176),
	(1632, 'Podlaskie Voivodeship', 176),
	(1633, 'West Pomeranian Voivodeship', 176),
	(1634, 'Greater Poland Voivodeship', 176),
	(1635, 'Lesser Poland Voivodeship', 176),
	(1636, 'Łódź Voivodeship', 176),
	(1637, 'Masovian Voivodeship', 176),
	(1638, 'Lublin Voivodeship', 176),
	(1639, 'Aargau', 214),
	(1640, 'Canton of Fribourg', 214),
	(1641, 'Basel-Landschaft', 214),
	(1642, 'Uri', 214),
	(1643, 'Ticino', 214),
	(1644, 'Canton of St. Gallen', 214),
	(1645, 'Canton of Bern', 214),
	(1646, 'Canton of Zug', 214),
	(1647, 'Canton of Geneva', 214),
	(1648, 'Canton of Valais', 214),
	(1649, 'Appenzell Innerrhoden', 214),
	(1650, 'Obwalden', 214),
	(1651, 'Canton of Vaud', 214),
	(1652, 'Nidwalden', 214),
	(1653, 'Schwyz', 214),
	(1654, 'Canton of Schaffhausen', 214),
	(1655, 'Appenzell Ausserrhoden', 214),
	(1656, 'Canton of Zürich', 214),
	(1657, 'Thurgau', 214),
	(1658, 'Canton of Jura', 214),
	(1659, 'Canton of Neuchâtel', 214),
	(1660, 'Graubünden', 214),
	(1661, 'Glarus', 214),
	(1662, 'Canton of Solothurn', 214),
	(1663, 'Canton of Lucerne', 214),
	(1664, 'Tuscany', 107),
	(1665, 'Province of Padua', 107),
	(1666, 'Province of Parma', 107),
	(1667, 'Free municipal consortium of Syracuse', 107),
	(1668, 'Metropolitan City of Palermo', 107),
	(1669, 'Campania', 107),
	(1670, 'Marche', 107),
	(1671, 'Metropolitan City of Reggio Calabria', 107),
	(1672, 'Province of Ancona', 107),
	(1673, 'Metropolitan City of Venice', 107),
	(1674, 'Province of Latina', 107),
	(1675, 'Province of Lecce', 107),
	(1676, 'Province of Pavia', 107),
	(1677, 'Province of Lecco', 107),
	(1678, 'Lazio', 107),
	(1679, 'Abruzzo', 107),
	(1680, 'Metropolitan City of Florence', 107),
	(1681, 'Province of Ascoli Piceno', 107),
	(1682, 'Metropolitan City of Cagliari', 107),
	(1683, 'Umbria', 107),
	(1684, 'Metropolitan City of Bologna', 107),
	(1685, 'Province of Pisa', 107),
	(1686, 'Province of Barletta-Andria-Trani', 107),
	(1687, 'Province of Pistoia', 107),
	(1688, 'Apulia', 107),
	(1689, 'Province of Belluno', 107),
	(1690, 'Province of Pordenone', 107),
	(1691, 'Province of Perugia', 107),
	(1692, 'Province of Avellino', 107),
	(1693, 'Province of Pesaro and Urbino', 107),
	(1694, 'Province of Pescara', 107),
	(1695, 'Molise', 107),
	(1696, 'Province of Piacenza', 107),
	(1697, 'Province of Potenza', 107),
	(1698, 'Metropolitan City of Milan', 107),
	(1699, 'Metropolitan City of Genoa', 107),
	(1700, 'Province of Prato', 107),
	(1701, 'Province of Benevento', 107),
	(1702, 'Piedmont', 107),
	(1703, 'Calabria', 107),
	(1704, 'Province of Bergamo', 107),
	(1705, 'Lombardy', 107),
	(1706, 'Basilicata', 107),
	(1707, 'Province of Ravenna', 107),
	(1708, 'Province of Reggio Emilia', 107),
	(1709, 'Sicily', 107),
	(1710, 'Metropolitan City of Turin', 107),
	(1711, 'Metropolitan City of Rome Capital', 107),
	(1712, 'Province of Rieti', 107),
	(1713, 'Province of Rimini', 107),
	(1714, 'Province of Brindisi', 107),
	(1715, 'Sardinia', 107),
	(1716, 'Aosta Valley', 107),
	(1717, 'Province of Brescia', 107),
	(1718, 'Free municipal consortium of Caltanissetta', 107),
	(1719, 'Province of Rovigo', 107),
	(1720, 'Province of Salerno', 107),
	(1721, 'Province of Campobasso', 107),
	(1722, 'Province of Sassari', 107),
	(1723, 'Free municipal consortium of Enna', 107),
	(1724, 'Metropolitan City of Naples', 107),
	(1725, 'Trentino-Alto Adige/Südtirol', 107),
	(1726, 'Province of Verbano-Cusio-Ossola', 107),
	(1727, 'Free municipal consortium of Agrigento', 107),
	(1728, 'Province of Catanzaro', 107),
	(1729, 'Free municipal consortium of Ragusa', 107),
	(1730, 'Province of South Sardinia', 107),
	(1731, 'Province of Caserta', 107),
	(1732, 'Province of Savona', 107),
	(1733, 'Free municipal consortium of Trapani', 107),
	(1734, 'Province of Siena', 107),
	(1735, 'Province of Viterbo', 107),
	(1736, 'Province of Verona', 107),
	(1737, 'Province of Vibo Valentia', 107),
	(1738, 'Province of Vicenza', 107),
	(1739, 'Province of Chieti', 107),
	(1740, 'Province of Como', 107),
	(1741, 'Province of Sondrio', 107),
	(1742, 'Province of Cosenza', 107),
	(1743, 'Province of Taranto', 107),
	(1744, 'Province of Fermo', 107),
	(1745, 'Province of Livorno', 107),
	(1746, 'Province of Ferrara', 107),
	(1747, 'Province of Lodi', 107),
	(1748, 'Autonomous Province of Trento', 107),
	(1749, 'Province of Lucca', 107),
	(1750, 'Province of Macerata', 107),
	(1751, 'Province of Cremona', 107),
	(1752, 'Province of Teramo', 107),
	(1753, 'Veneto', 107),
	(1754, 'Province of Crotone', 107),
	(1755, 'Province of Terni', 107),
	(1756, 'Friuli-Venezia Giulia', 107),
	(1757, 'Province of Modena', 107),
	(1758, 'Province of Mantua', 107),
	(1759, 'Province of Massa and Carrara', 107),
	(1760, 'Province of Matera', 107),
	(1761, 'Province of Medio Campidano (historical)', 107),
	(1762, 'Province of Treviso', 107),
	(1763, 'Province of Trieste (historical)', 107),
	(1764, 'Province of Udine (historical)', 107),
	(1765, 'Province of Varese', 107),
	(1766, 'Metropolitan City of Catania', 107),
	(1767, 'Autonomous Province of Bolzano – South Tyrol', 107),
	(1768, 'Liguria', 107),
	(1769, 'Province of Monza and Brianza', 107),
	(1770, 'Metropolitan City of Messina', 107),
	(1771, 'Province of Foggia', 107),
	(1772, 'Metropolitan City of Bari', 107),
	(1773, 'Emilia-Romagna', 107),
	(1774, 'Province of Novara', 107),
	(1775, 'Province of Cuneo', 107),
	(1776, 'Province of Frosinone', 107),
	(1777, 'Province of Gorizia (historical)', 107),
	(1778, 'Province of Biella', 107),
	(1779, 'Province of Forlì-Cesena', 107),
	(1780, 'Province of Asti', 107),
	(1781, 'Province of L''Aquila', 107),
	(1782, 'Province of Ogliastra (historical)', 107),
	(1783, 'Province of Alessandria', 107),
	(1784, 'Province of Olbia-Tempio (historical)', 107),
	(1785, 'Province of Vercelli', 107),
	(1786, 'Province of Oristano', 107),
	(1787, 'Province of Grosseto', 107),
	(1788, 'Province of Imperia', 107),
	(1789, 'Province of Isernia', 107),
	(1790, 'Province of Nuoro', 107),
	(1791, 'Province of La Spezia', 107),
	(1792, 'North Sumatra', 102),
	(1793, 'Bengkulu', 102),
	(1794, 'Central Kalimantan', 102),
	(1795, 'South Sulawesi', 102),
	(1796, 'Southeast Sulawesi', 102),
	(1797, 'Sumatra', 102),
	(1798, 'Papua', 102),
	(1799, 'West Papua', 102),
	(1800, 'Maluku', 102),
	(1801, 'North Maluku', 102),
	(1802, 'Central Java', 102),
	(1803, 'Sulawesi', 102),
	(1804, 'East Kalimantan', 102),
	(1805, 'Jakarta Special Capital Region', 102),
	(1806, 'Kalimantan', 102),
	(1807, 'Riau Islands', 102),
	(1808, 'North Sulawesi', 102),
	(1809, 'Riau', 102),
	(1810, 'Banten', 102),
	(1811, 'Lampung', 102),
	(1812, 'Gorontalo', 102),
	(1813, 'Central Sulawesi', 102),
	(1814, 'West Nusa Tenggara', 102),
	(1815, 'Jambi', 102),
	(1816, 'South Sumatra', 102),
	(1817, 'West Sulawesi', 102),
	(1818, 'East Nusa Tenggara', 102),
	(1819, 'South Kalimantan', 102),
	(1820, 'Bangka Belitung Islands', 102),
	(1821, 'Nusa Tenggara', 102),
	(1822, 'Aceh', 102),
	(1823, 'Maluku Islands', 102),
	(1824, 'North Kalimantan', 102),
	(1825, 'West Java', 102),
	(1826, 'Bali', 102),
	(1827, 'East Java', 102),
	(1828, 'West Sumatra', 102),
	(1829, 'Special Region of Yogyakarta', 102),
	(1830, 'Phoenix Islands', 114),
	(1831, 'Gilbert Islands', 114),
	(1832, 'Line Islands', 114),
	(1833, 'Primorsky Krai', 182),
	(1834, 'Novgorod Oblast', 182),
	(1835, 'Jewish Autonomous Oblast', 182),
	(1836, 'Nenets Autonomous Okrug', 182),
	(1837, 'Rostov Oblast', 182),
	(1838, 'Khanty-Mansi Autonomous Okrug', 182),
	(1839, 'Magadan Oblast', 182),
	(1840, 'Krasnoyarsk Krai', 182),
	(1841, 'Republic of Karelia', 182),
	(1842, 'Republic of Buryatia', 182),
	(1843, 'Murmansk Oblast', 182),
	(1844, 'Kaluga Oblast', 182),
	(1845, 'Chelyabinsk Oblast', 182),
	(1846, 'Omsk Oblast', 182),
	(1847, 'Yamalo-Nenets Autonomous Okrug', 182),
	(1848, 'Sakha (Yakutia) Republic', 182),
	(1849, 'Arkhangelsk Oblast', 182),
	(1850, 'Republic of Dagestan', 182),
	(1851, 'Yaroslavl Oblast', 182),
	(1852, 'Republic of Adygea', 182),
	(1853, 'Republic of North Ossetia–Alania', 182),
	(1854, 'Republic of Bashkortostan', 182),
	(1855, 'Kursk Oblast', 182),
	(1856, 'Ulyanovsk Oblast', 182),
	(1857, 'Nizhny Novgorod Oblast', 182),
	(1858, 'Amur Oblast', 182),
	(1859, 'Chukotka Autonomous Okrug', 182),
	(1860, 'Tver Oblast', 182),
	(1861, 'Republic of Tatarstan', 182),
	(1862, 'Samara Oblast', 182),
	(1863, 'Pskov Oblast', 182),
	(1864, 'Ivanovo Oblast', 182),
	(1865, 'Kamchatka Krai', 182),
	(1866, 'Astrakhan Oblast', 182),
	(1867, 'Bryansk Oblast', 182),
	(1868, 'Stavropol Krai', 182),
	(1869, 'Karachay-Cherkess Republic', 182),
	(1870, 'Mari El Republic', 182),
	(1871, 'Perm Krai', 182),
	(1872, 'Tomsk Oblast', 182),
	(1873, 'Khabarovsk Krai', 182),
	(1874, 'Vologda Oblast', 182),
	(1875, 'Sakhalin Oblast', 182),
	(1876, 'Altai Republic', 182),
	(1877, 'Republic of Khakassia', 182),
	(1878, 'Tambov Oblast', 182),
	(1879, 'Saint Petersburg', 182),
	(1880, 'Irkutsk Oblast', 182),
	(1881, 'Vladimir Oblast', 182),
	(1882, 'Moscow Oblast', 182),
	(1883, 'Republic of Kalmykia', 182),
	(1884, 'Republic of Ingushetia', 182),
	(1885, 'Smolensk Oblast', 182),
	(1886, 'Orenburg Oblast', 182),
	(1887, 'Saratov Oblast', 182),
	(1888, 'Novosibirsk Oblast', 182),
	(1889, 'Lipetsk Oblast', 182),
	(1890, 'Kirov Oblast', 182),
	(1891, 'Krasnodar Krai', 182),
	(1892, 'Kabardino-Balkar Republic', 182),
	(1893, 'Chechen Republic', 182),
	(1894, 'Sverdlovsk Oblast', 182),
	(1895, 'Tula Oblast', 182),
	(1896, 'Leningrad Oblast', 182),
	(1897, 'Kemerovo Oblast - Kuzbass', 182),
	(1898, 'Republic of Mordovia', 182),
	(1899, 'Komi Republic', 182),
	(1900, 'Tuva Republic', 182),
	(1901, 'Moscow', 182),
	(1902, 'Kaliningrad Oblast', 182),
	(1903, 'Belgorod Oblast', 182),
	(1904, 'Zabaykalsky Krai', 182),
	(1905, 'Ryazan Oblast', 182),
	(1906, 'Voronezh Oblast', 182),
	(1907, 'Tyumen Oblast', 182),
	(1908, 'Oryol Oblast', 182),
	(1909, 'Penza Oblast', 182),
	(1910, 'Kostroma Oblast', 182),
	(1911, 'Altai Krai', 182),
	(1912, 'Sevastopol', 182),
	(1913, 'Udmurt Republic', 182),
	(1914, 'Chuvash Republic', 182),
	(1915, 'Kurgan Oblast', 182),
	(1916, 'Lomaiviti Province', 73),
	(1917, 'Ba Province', 73),
	(1918, 'Tailevu Province', 73),
	(1919, 'Nadroga-Navosa Province', 73),
	(1920, 'Rewa Province', 73),
	(1921, 'Northern Division', 73),
	(1922, 'Macuata Province', 73),
	(1923, 'Western Division', 73),
	(1924, 'Cakaudrove Province', 73),
	(1925, 'Serua Province', 73),
	(1926, 'Ra Province', 73),
	(1927, 'Naitasiri Province', 73),
	(1928, 'Namosi Province', 73),
	(1929, 'Central Division', 73),
	(1930, 'Bua Province', 73),
	(1931, 'Rotuma', 73),
	(1932, 'Eastern Division', 73),
	(1933, 'Lau Province', 73),
	(1934, 'Kadavu Province', 73),
	(1935, 'Labuan', 132),
	(1936, 'Sabah', 132),
	(1937, 'Sarawak', 132),
	(1938, 'Perlis', 132),
	(1939, 'Penang', 132),
	(1940, 'Pahang', 132),
	(1941, 'Melaka', 132),
	(1942, 'Terengganu', 132),
	(1943, 'Perak', 132),
	(1944, 'Selangor', 132),
	(1945, 'Putrajaya', 132),
	(1946, 'Kelantan', 132),
	(1947, 'Kedah', 132),
	(1948, 'Negeri Sembilan', 132),
	(1949, 'Kuala Lumpur', 132),
	(1950, 'Johor', 132),
	(1951, 'Mashonaland East Province', 247),
	(1952, 'Matabeleland South Province', 247),
	(1953, 'Mashonaland West Province', 247),
	(1954, 'Matabeleland North Province', 247),
	(1955, 'Mashonaland Central Province', 247),
	(1956, 'Bulawayo Province', 247),
	(1957, 'Midlands Province', 247),
	(1958, 'Harare Province', 247),
	(1959, 'Manicaland Province', 247),
	(1960, 'Masvingo Province', 247),
	(1961, 'Bulgan Province', 146),
	(1962, 'Darkhan-Uul Province', 146),
	(1963, 'Dornod Province', 146),
	(1964, 'Khovd Province', 146),
	(1965, 'Övörkhangai Province', 146),
	(1966, 'Orkhon Province', 146),
	(1967, 'Ömnögovi Province', 146),
	(1968, 'Töv Province', 146),
	(1969, 'Bayan-Ölgii Province', 146),
	(1970, 'Dundgovi Province', 146),
	(1971, 'Uvs Province', 146),
	(1972, 'Govi-Altai Province', 146),
	(1973, 'Arkhangai Province', 146),
	(1974, 'Khentii Province', 146),
	(1975, 'Khövsgöl Province', 146),
	(1976, 'Bayankhongor Province', 146),
	(1977, 'Sükhbaatar Province', 146),
	(1978, 'Govisümber Province', 146),
	(1979, 'Zavkhan Province', 146),
	(1980, 'Selenge Province', 146),
	(1981, 'Dornogovi Province', 146),
	(1982, 'Northern Province', 246),
	(1983, 'Western Province', 246),
	(1984, 'Copperbelt Province', 246),
	(1985, 'Northwestern Province', 246),
	(1986, 'Central Province', 246),
	(1987, 'Luapula Province', 246),
	(1988, 'Lusaka Province', 246),
	(1989, 'Muchinga Province', 246),
	(1990, 'Southern Province', 246),
	(1991, 'Eastern Province', 246),
	(1992, 'Capital Governorate', 18),
	(1993, 'Southern Governorate', 18),
	(1994, 'Northern Governorate', 18),
	(1995, 'Muharraq Governorate', 18),
	(1996, 'Central Governorate (historical)', 18),
	(1997, 'Rio de Janeiro', 31),
	(1998, 'Minas Gerais', 31),
	(1999, 'Amapá', 31),
	(2000, 'Goiás', 31),
	(2001, 'Rio Grande do Sul', 31),
	(2002, 'Bahia', 31),
	(2003, 'Sergipe', 31),
	(2004, 'Amazonas', 31),
	(2005, 'Paraíba', 31),
	(2006, 'Pernambuco', 31),
	(2007, 'Alagoas', 31),
	(2008, 'Piauí', 31),
	(2009, 'Pará', 31),
	(2010, 'Mato Grosso do Sul', 31),
	(2011, 'Mato Grosso', 31),
	(2012, 'Acre', 31),
	(2013, 'Rondônia', 31),
	(2014, 'Santa Catarina', 31),
	(2015, 'Maranhão', 31),
	(2016, 'Ceará', 31),
	(2017, 'Federal District', 31),
	(2018, 'Espírito Santo', 31),
	(2019, 'Rio Grande do Norte', 31),
	(2020, 'Tocantins', 31),
	(2021, 'São Paulo', 31),
	(2022, 'Paraná', 31),
	(2023, 'Aragatsotn Region', 12),
	(2024, 'Ararat Province', 12),
	(2025, 'Vayots Dzor Region', 12),
	(2026, 'Armavir Region', 12),
	(2027, 'Syunik Province', 12),
	(2028, 'Gegharkunik Province', 12),
	(2029, 'Lori Region', 12),
	(2030, 'Yerevan', 12),
	(2031, 'Shirak Region', 12),
	(2032, 'Tavush Region', 12),
	(2033, 'Kotayk Region', 12),
	(2034, 'Cojedes', 239),
	(2035, 'Falcón', 239),
	(2036, 'Portuguesa', 239),
	(2037, 'Miranda', 239),
	(2038, 'Lara', 239),
	(2039, 'Bolívar', 239),
	(2040, 'Carabobo', 239),
	(2041, 'Yaracuy', 239),
	(2042, 'Zulia', 239),
	(2043, 'Trujillo', 239),
	(2044, 'Amazonas', 239),
	(2045, 'Guárico', 239),
	(2046, 'Federal Dependencies of Venezuela', 239),
	(2047, 'Aragua', 239),
	(2048, 'Táchira', 239),
	(2049, 'Barinas', 239),
	(2050, 'Anzoátegui', 239),
	(2051, 'Delta Amacuro', 239),
	(2052, 'Nueva Esparta', 239),
	(2053, 'Mérida', 239),
	(2054, 'Monagas', 239),
	(2055, 'La Guaira', 239),
	(2056, 'Sucre', 239),
	(2057, 'Carinthia', 15),
	(2058, 'Upper Austria', 15),
	(2059, 'Styria', 15),
	(2060, 'Vienna', 15),
	(2061, 'Salzburg', 15),
	(2062, 'Burgenland', 15),
	(2063, 'Vorarlberg', 15),
	(2064, 'Tyrol', 15),
	(2065, 'Lower Austria', 15),
	(2066, 'Karnali Province', 154),
	(2067, 'Gandaki Province', 154),
	(2068, 'Sudurpashchim Province', 154),
	(2069, 'Province No. 1', 154),
	(2070, 'Mechi Zone (historical)', 154),
	(2071, 'Bheri Zone (historical)', 154),
	(2072, 'Kosi Zone (historical)', 154),
	(2073, 'Bagmati Province', 154),
	(2074, 'Lumbini Zone (historical)', 154),
	(2075, 'Narayani Zone (historical)', 154),
	(2076, 'Janakpur Zone (historical)', 154),
	(2077, 'Rapti Zone (historical)', 154),
	(2078, 'Seti Zone (historical)', 154),
	(2079, 'Karnali Zone (historical)', 154),
	(2080, 'Dhaulagiri Zone (historical)', 154),
	(2081, 'Gandaki Zone (historical)', 154),
	(2082, 'Bagmati Zone (historical)', 154),
	(2083, 'Mahakali Zone (historical)', 154),
	(2084, 'Sagarmatha Zone (historical)', 154),
	(2085, 'Unity State', 206),
	(2086, 'Upper Nile State', 206),
	(2087, 'Warrap State', 206),
	(2088, 'Northern Bahr el Ghazal State', 206),
	(2089, 'Western Equatoria State', 206),
	(2090, 'Lakes State', 206),
	(2091, 'Western Bahr el Ghazal State', 206),
	(2092, 'Central Equatoria State', 206),
	(2093, 'Eastern Equatoria State', 206),
	(2094, 'Jonglei State', 206),
	(2095, 'Karditsa Regional Unit', 85),
	(2096, 'West Greece Region', 85),
	(2097, 'Thessaloniki Regional Unit', 85),
	(2098, 'Arcadia Regional Unit', 85),
	(2099, 'Imathia Regional Unit', 85),
	(2100, 'Kastoria Regional Unit', 85),
	(2101, 'Euboea Regional Unit', 85),
	(2102, 'Grevena Regional Unit', 85),
	(2103, 'Preveza Regional Unit', 85),
	(2104, 'Lefkada Regional Unit', 85),
	(2105, 'Argolis Regional Unit', 85),
	(2106, 'Laconia Regional Unit', 85),
	(2107, 'Pella Regional Unit', 85),
	(2108, 'West Macedonia Region', 85),
	(2109, 'Crete Region', 85),
	(2110, 'Epirus Region', 85),
	(2111, 'Kilkis Regional Unit', 85),
	(2112, 'Kozani Regional Unit', 85),
	(2113, 'Ioannina Regional Unit', 85),
	(2114, 'Phthiotis Regional Unit', 85),
	(2115, 'Chania Regional Unit', 85),
	(2116, 'Achaea Regional Unit', 85),
	(2117, 'East Macedonia and Thrace Region', 85),
	(2118, 'South Aegean Region', 85),
	(2119, 'Peloponnese Region', 85),
	(2120, 'East Attica Regional Unit', 85),
	(2121, 'Serres Regional Unit', 85),
	(2122, 'Attica Region', 85),
	(2123, 'Aetolia-Acarnania Regional Unit', 85),
	(2124, 'Corfu Regional Unit', 85),
	(2125, 'Central Macedonia Region', 85),
	(2126, 'Boeotia Regional Unit', 85),
	(2127, 'Kefalonia Regional Unit', 85),
	(2128, 'Central Greece Region', 85),
	(2129, 'Corinthia Regional Unit', 85),
	(2130, 'Drama Regional Unit', 85),
	(2131, 'Ionian Islands Region', 85),
	(2132, 'Larissa Regional Unit', 85),
	(2133, 'Kayin State', 151),
	(2134, 'Mandalay Region', 151),
	(2135, 'Yangon Region', 151),
	(2136, 'Magway Region', 151),
	(2137, 'Chin State', 151),
	(2138, 'Rakhine State', 151),
	(2139, 'Shan State', 151),
	(2140, 'Tanintharyi Region', 151),
	(2141, 'Bago Region', 151),
	(2142, 'Ayeyarwady Region', 151),
	(2143, 'Kachin State', 151),
	(2144, 'Kayah State', 151),
	(2145, 'Sagaing Region', 151),
	(2146, 'Naypyidaw Union Territory', 151),
	(2147, 'Mon State', 151),
	(2148, 'Bartın Province', 225),
	(2149, 'Kütahya Province', 225),
	(2150, 'Sakarya Province', 225),
	(2151, 'Edirne Province', 225),
	(2152, 'Van Province', 225),
	(2153, 'Bingöl Province', 225),
	(2154, 'Kilis Province', 225),
	(2155, 'Adıyaman Province', 225),
	(2156, 'Mersin Province', 225),
	(2157, 'Denizli Province', 225),
	(2158, 'Malatya Province', 225),
	(2159, 'Elazığ Province', 225),
	(2160, 'Erzincan Province', 225),
	(2161, 'Amasya Province', 225),
	(2162, 'Muş Province', 225),
	(2163, 'Bursa Province', 225),
	(2164, 'Eskişehir Province', 225),
	(2165, 'Erzurum Province', 225),
	(2166, 'Iğdır Province', 225),
	(2167, 'Tekirdağ Province', 225),
	(2168, 'Çankırı Province', 225),
	(2169, 'Antalya Province', 225),
	(2170, 'Istanbul Province', 225),
	(2171, 'Konya Province', 225),
	(2172, 'Bolu Province', 225),
	(2173, 'Çorum Province', 225),
	(2174, 'Ordu Province', 225),
	(2175, 'Balıkesir Province', 225),
	(2176, 'Kırklareli Province', 225),
	(2177, 'Bayburt Province', 225),
	(2178, 'Kırıkkale Province', 225),
	(2179, 'Afyonkarahisar Province', 225),
	(2180, 'Kırşehir Province', 225),
	(2181, 'Sivas Province', 225),
	(2182, 'Muğla Province', 225),
	(2183, 'Şanlıurfa Province', 225),
	(2184, 'Karaman Province', 225),
	(2185, 'Ardahan Province', 225),
	(2186, 'Giresun Province', 225),
	(2187, 'Aydın Province', 225),
	(2188, 'Yozgat Province', 225),
	(2189, 'Niğde Province', 225),
	(2190, 'Hakkâri Province', 225),
	(2191, 'Artvin Province', 225),
	(2192, 'Tunceli Province', 225),
	(2193, 'Ağrı Province', 225),
	(2194, 'Batman Province', 225),
	(2195, 'Kocaeli Province', 225),
	(2196, 'Nevşehir Province', 225),
	(2197, 'Kastamonu Province', 225),
	(2198, 'Manisa Province', 225),
	(2199, 'Tokat Province', 225),
	(2200, 'Kayseri Province', 225),
	(2201, 'Uşak Province', 225),
	(2202, 'Düzce Province', 225),
	(2203, 'Gaziantep Province', 225),
	(2204, 'Gümüşhane Province', 225),
	(2205, 'İzmir Province', 225),
	(2206, 'Trabzon Province', 225),
	(2207, 'Siirt Province', 225),
	(2208, 'Kars Province', 225),
	(2209, 'Burdur Province', 225),
	(2210, 'Aksaray Province', 225),
	(2211, 'Hatay Province', 225),
	(2212, 'Adana Province', 225),
	(2213, 'Zonguldak Province', 225),
	(2214, 'Osmaniye Province', 225),
	(2215, 'Bitlis Province', 225),
	(2216, 'Çanakkale Province', 225),
	(2217, 'Ankara Province', 225),
	(2218, 'Yalova Province', 225),
	(2219, 'Rize Province', 225),
	(2220, 'Samsun Province', 225),
	(2221, 'Bilecik Province', 225),
	(2222, 'Isparta Province', 225),
	(2223, 'Karabük Province', 225),
	(2224, 'Mardin Province', 225),
	(2225, 'Şırnak Province', 225),
	(2226, 'Diyarbakır Province', 225),
	(2227, 'Kahramanmaraş Province', 225),
	(2228, 'Lisbon District', 177),
	(2229, 'Bragança District', 177),
	(2230, 'Beja District', 177),
	(2231, 'Madeira', 177),
	(2232, 'Portalegre District', 177),
	(2233, 'Azores', 177),
	(2234, 'Vila Real District', 177),
	(2235, 'Aveiro District', 177),
	(2236, 'Évora District', 177),
	(2237, 'Viseu District', 177),
	(2238, 'Santarém District', 177),
	(2239, 'Faro District', 177),
	(2240, 'Leiria District', 177),
	(2241, 'Castelo Branco District', 177),
	(2242, 'Setúbal District', 177),
	(2243, 'Porto District', 177),
	(2244, 'Braga District', 177),
	(2245, 'Viana do Castelo District', 177),
	(2246, 'Coimbra District', 177),
	(2247, 'Zhejiang', 45),
	(2248, 'Fujian', 45),
	(2249, 'Shanghai', 45),
	(2250, 'Jiangsu', 45),
	(2251, 'Anhui', 45),
	(2252, 'Shandong', 45),
	(2253, 'Jilin', 45),
	(2254, 'Shanxi', 45),
	(2255, 'Taiwan Province', 45),
	(2256, 'Jiangxi', 45),
	(2257, 'Beijing', 45),
	(2258, 'Hunan', 45),
	(2259, 'Henan', 45),
	(2260, 'Yunnan', 45),
	(2261, 'Guizhou', 45),
	(2262, 'Ningxia Hui Autonomous Region', 45),
	(2263, 'Xinjiang Uyghur Autonomous Region', 45),
	(2264, 'Tibet Autonomous Region', 45),
	(2265, 'Heilongjiang', 45),
	(2266, 'Macau SAR', 45),
	(2267, 'Hong Kong SAR', 45),
	(2268, 'Liaoning', 45),
	(2269, 'Inner Mongolia Autonomous Region', 45),
	(2270, 'Qinghai', 45),
	(2271, 'Chongqing', 45),
	(2272, 'Shaanxi', 45),
	(2273, 'Hainan', 45),
	(2274, 'Hubei', 45),
	(2275, 'Gansu', 45),
	(2276, 'Keelung (Taiwan)', 45),
	(2277, 'Sichuan', 45),
	(2278, 'Guangxi Zhuang Autonomous Region', 45),
	(2279, 'Guangdong', 45),
	(2280, 'Hebei', 45),
	(2281, 'South Governorate', 121),
	(2282, 'Mount Lebanon Governorate', 121),
	(2283, 'Baalbek-Hermel Governorate', 121),
	(2284, 'North Governorate', 121),
	(2285, 'Akkar Governorate', 121),
	(2286, 'Beirut Governorate', 121),
	(2287, 'Beqaa Governorate', 121),
	(2288, 'Nabatieh Governorate', 121),
	(2289, 'Isle of Wight', 232),
	(2290, 'St Helens', 232),
	(2291, 'London Borough of Brent', 232),
	(2292, 'Walsall', 232),
	(2293, 'Trafford', 232),
	(2294, 'City of Southampton', 232),
	(2295, 'Sheffield', 232),
	(2296, 'West Sussex', 232),
	(2297, 'City of Peterborough', 232),
	(2298, 'Caerphilly County Borough', 232),
	(2299, 'Vale of Glamorgan', 232),
	(2300, 'Shetland Islands', 232),
	(2301, 'Rhondda Cynon Taf', 232),
	(2302, 'Poole (historical)', 232),
	(2303, 'Central Bedfordshire', 232),
	(2304, 'Down District Council (historical)', 232),
	(2305, 'City of Portsmouth', 232),
	(2306, 'London Borough of Haringey', 232),
	(2307, 'London Borough of Bexley', 232),
	(2308, 'Rotherham', 232),
	(2309, 'Hartlepool', 232),
	(2310, 'Telford and Wrekin', 232),
	(2311, 'Belfast', 232),
	(2312, 'Cornwall', 232),
	(2313, 'London Borough of Sutton', 232),
	(2314, 'Omagh District Council (historical)', 232),
	(2315, 'Banbridge (historical)', 232),
	(2316, 'Causeway Coast and Glens', 232),
	(2317, 'Newtownabbey Borough Council (historical)', 232),
	(2318, 'City of Leicester', 232),
	(2319, 'London Borough of Islington', 232),
	(2320, 'Wigan', 232),
	(2321, 'Oxfordshire', 232),
	(2322, 'Magherafelt District Council (historical)', 232),
	(2323, 'Southend-on-Sea', 232),
	(2324, 'Armagh, Banbridge and Craigavon', 232),
	(2325, 'Perth and Kinross', 232),
	(2326, 'London Borough of Waltham Forest', 232),
	(2327, 'Rochdale', 232),
	(2328, 'Merthyr Tydfil County Borough', 232),
	(2329, 'Blackburn with Darwen', 232),
	(2330, 'Knowsley', 232),
	(2331, 'Armagh City and District Council (historical)', 232),
	(2332, 'Middlesbrough', 232),
	(2333, 'East Renfrewshire', 232),
	(2334, 'Cumbria (historical)', 232),
	(2335, 'Scotland', 232),
	(2336, 'England', 232),
	(2337, 'Northern Ireland', 232),
	(2338, 'Wales', 232),
	(2339, 'Bath and North East Somerset', 232),
	(2340, 'Liverpool', 232),
	(2341, 'Sandwell', 232),
	(2342, 'Bournemouth (historical)', 232),
	(2343, 'Isles of Scilly', 232),
	(2344, 'Falkirk', 232),
	(2345, 'Dorset', 232),
	(2346, 'Scottish Borders', 232),
	(2347, 'London Borough of Havering', 232),
	(2348, 'Moyle District Council (historical)', 232),
	(2349, 'London Borough of Camden', 232),
	(2350, 'Newry and Mourne District Council (historical)', 232),
	(2351, 'Neath Port Talbot', 232),
	(2352, 'Conwy County Borough', 232),
	(2353, 'Na h-Eileanan Siar (Outer Hebrides)', 232),
	(2354, 'West Lothian', 232),
	(2355, 'Lincolnshire', 232),
	(2356, 'London Borough of Barking and Dagenham', 232),
	(2357, 'City of Westminster', 232),
	(2358, 'London Borough of Lewisham', 232),
	(2359, 'City of Nottingham', 232),
	(2360, 'Moray', 232),
	(2361, 'Ballymoney (historical)', 232),
	(2362, 'South Lanarkshire', 232),
	(2363, 'Ballymena Borough (historical)', 232),
	(2364, 'Doncaster', 232),
	(2365, 'Northumberland', 232),
	(2366, 'Fermanagh and Omagh', 232),
	(2367, 'Tameside', 232),
	(2368, 'Royal Borough of Kensington and Chelsea', 232),
	(2369, 'Hertfordshire', 232),
	(2370, 'East Riding of Yorkshire', 232),
	(2371, 'Kirklees', 232),
	(2372, 'City of Sunderland', 232),
	(2373, 'Gloucestershire', 232),
	(2374, 'East Ayrshire', 232),
	(2375, 'United Kingdom', 232),
	(2376, 'London Borough of Hillingdon', 232),
	(2377, 'South Ayrshire', 232),
	(2378, 'Ascension Island', 232),
	(2379, 'Gwynedd', 232),
	(2380, 'London Borough of Hounslow', 232),
	(2381, 'Medway', 232),
	(2382, 'Limavady Borough Council (historical)', 232),
	(2383, 'Highland', 232),
	(2384, 'North East Lincolnshire', 232),
	(2385, 'London Borough of Harrow', 232),
	(2386, 'Somerset', 232),
	(2387, 'Angus', 232),
	(2388, 'Inverclyde', 232),
	(2389, 'Darlington', 232),
	(2390, 'London Borough of Tower Hamlets', 232),
	(2391, 'Wiltshire', 232),
	(2392, 'Argyll and Bute', 232),
	(2393, 'Strabane District Council (historical)', 232),
	(2394, 'Stockport', 232),
	(2395, 'Brighton and Hove', 232),
	(2396, 'London Borough of Lambeth', 232),
	(2397, 'London Borough of Redbridge', 232),
	(2398, 'Manchester', 232),
	(2399, 'Mid Ulster', 232),
	(2400, 'South Gloucestershire', 232),
	(2401, 'Aberdeenshire', 232),
	(2402, 'Monmouthshire', 232),
	(2403, 'Derbyshire', 232),
	(2404, 'Glasgow City', 232),
	(2405, 'Buckinghamshire', 232),
	(2406, 'County Durham', 232),
	(2407, 'Shropshire', 232),
	(2408, 'Wirral', 232),
	(2409, 'South Tyneside', 232),
	(2410, 'Essex', 232),
	(2411, 'London Borough of Hackney', 232),
	(2412, 'Antrim and Newtownabbey', 232),
	(2413, 'City of Bristol', 232),
	(2414, 'East Sussex', 232),
	(2415, 'Dumfries and Galloway', 232),
	(2416, 'Milton Keynes', 232),
	(2417, 'Derry City Council (historical)', 232),
	(2418, 'London Borough of Newham', 232),
	(2419, 'Wokingham', 232),
	(2420, 'Warrington', 232),
	(2421, 'Stockton-on-Tees', 232),
	(2422, 'Swindon', 232),
	(2423, 'Cambridgeshire', 232),
	(2424, 'City of London', 232),
	(2425, 'Birmingham', 232),
	(2426, 'City of York', 232),
	(2427, 'Slough', 232),
	(2428, 'City of Edinburgh', 232),
	(2429, 'Mid and East Antrim', 232),
	(2430, 'North Somerset', 232),
	(2431, 'Gateshead', 232),
	(2432, 'London Borough of Southwark', 232),
	(2433, 'Swansea', 232),
	(2434, 'London Borough of Wandsworth', 232),
	(2435, 'Hampshire', 232),
	(2436, 'Wrexham County Borough', 232),
	(2437, 'Flintshire', 232),
	(2438, 'Coventry', 232),
	(2439, 'Carrickfergus Borough Council (historical)', 232),
	(2440, 'West Dunbartonshire', 232),
	(2441, 'Powys', 232),
	(2442, 'Cheshire West and Chester', 232),
	(2443, 'Renfrewshire', 232),
	(2444, 'Cheshire East', 232),
	(2445, 'Cookstown District Council (historical)', 232),
	(2446, 'Derry City and Strabane', 232),
	(2447, 'Staffordshire', 232),
	(2448, 'London Borough of Hammersmith and Fulham', 232),
	(2449, 'Craigavon Borough Council (historical)', 232),
	(2450, 'Clackmannanshire', 232),
	(2451, 'Blackpool', 232),
	(2452, 'Bridgend County Borough', 232),
	(2453, 'North Lincolnshire', 232),
	(2454, 'East Dunbartonshire', 232),
	(2455, 'Reading', 232),
	(2456, 'Nottinghamshire', 232),
	(2457, 'Dudley', 232),
	(2458, 'Newcastle upon Tyne', 232),
	(2459, 'Bury', 232),
	(2460, 'Lisburn and Castlereagh', 232),
	(2461, 'Coleraine Borough Council (historical)', 232),
	(2462, 'East Lothian', 232),
	(2463, 'Aberdeen City', 232),
	(2464, 'Kent', 232),
	(2465, 'Wakefield', 232),
	(2466, 'Halton', 232),
	(2467, 'Suffolk', 232),
	(2468, 'Thurrock', 232),
	(2469, 'Solihull', 232),
	(2470, 'Bracknell Forest', 232),
	(2471, 'West Berkshire', 232),
	(2472, 'Rutland', 232),
	(2473, 'Norfolk', 232),
	(2474, 'Orkney Islands', 232),
	(2475, 'Kingston upon Hull', 232),
	(2476, 'London Borough of Enfield', 232),
	(2477, 'Oldham', 232),
	(2478, 'Torbay', 232),
	(2479, 'Fife', 232),
	(2480, 'Northamptonshire (historical)', 232),
	(2481, 'Royal Borough of Kingston upon Thames', 232),
	(2482, 'Royal Borough of Windsor and Maidenhead', 232),
	(2483, 'London Borough of Merton', 232),
	(2484, 'Carmarthenshire', 232),
	(2485, 'City of Derby', 232),
	(2486, 'Pembrokeshire', 232),
	(2487, 'North Lanarkshire', 232),
	(2488, 'Stirling', 232),
	(2489, 'City of Wolverhampton', 232),
	(2490, 'London Borough of Bromley', 232),
	(2491, 'Devon', 232),
	(2492, 'Royal Borough of Greenwich', 232),
	(2493, 'Salford', 232),
	(2494, 'Lisburn City Council (historical)', 232),
	(2495, 'Lancashire', 232),
	(2496, 'Torfaen', 232),
	(2497, 'Denbighshire', 232),
	(2498, 'Ards Borough Council (historical)', 232),
	(2499, 'Barnsley', 232),
	(2500, 'Herefordshire', 232),
	(2501, 'London Borough of Richmond upon Thames', 232),
	(2502, 'Saint Helena', 232),
	(2503, 'Leeds', 232),
	(2504, 'Bolton', 232),
	(2505, 'Warwickshire', 232),
	(2506, 'City of Stoke-on-Trent', 232),
	(2507, 'Bedford', 232),
	(2508, 'Dungannon and South Tyrone Borough Council (historical)', 232),
	(2509, 'Ceredigion', 232),
	(2510, 'Worcestershire', 232),
	(2511, 'Dundee City', 232),
	(2512, 'London Borough of Croydon', 232),
	(2513, 'North Down Borough Council (historical)', 232),
	(2514, 'City of Plymouth', 232),
	(2515, 'Larne Borough Council (historical)', 232),
	(2516, 'Leicestershire', 232),
	(2517, 'Calderdale', 232),
	(2518, 'Sefton', 232),
	(2519, 'Midlothian', 232),
	(2520, 'London Borough of Barnet', 232),
	(2521, 'North Tyneside', 232),
	(2522, 'North Yorkshire', 232),
	(2523, 'Ards and North Down', 232),
	(2524, 'Newport', 232),
	(2525, 'Castlereagh (historical)', 232),
	(2526, 'Surrey', 232),
	(2527, 'Redcar and Cleveland', 232),
	(2528, 'Cardiff', 232),
	(2529, 'Bradford', 232),
	(2530, 'Blaenau Gwent County Borough', 232),
	(2531, 'Fermanagh District Council (historical)', 232),
	(2532, 'London Borough of Ealing', 232),
	(2533, 'Antrim Borough Council (historical)', 232),
	(2534, 'Newry, Mourne and Down', 232),
	(2535, 'North Ayrshire', 232),
	(2536, 'Tashkent City', 236),
	(2537, 'Namangan Region', 236),
	(2538, 'Fergana Region', 236),
	(2539, 'Xorazm Region', 236),
	(2540, 'Andijan Region', 236),
	(2541, 'Bukhara Region', 236),
	(2542, 'Navoiy Region', 236),
	(2543, 'Qashqadaryo Region', 236),
	(2544, 'Samarqand Region', 236),
	(2545, 'Jizzakh Region', 236),
	(2546, 'Surxondaryo Region', 236),
	(2547, 'Sirdaryo Region', 236),
	(2548, 'Republic of Karakalpakstan', 236),
	(2549, 'Tashkent Region', 236),
	(2550, 'Ariana Governorate', 224),
	(2551, 'Bizerte Governorate', 224),
	(2552, 'Jendouba Governorate', 224),
	(2553, 'Monastir Governorate', 224),
	(2554, 'Tunis Governorate', 224),
	(2555, 'Manouba Governorate', 224),
	(2556, 'Gafsa Governorate', 224),
	(2557, 'Sfax Governorate', 224),
	(2558, 'Gabès Governorate', 224),
	(2559, 'Tataouine Governorate', 224),
	(2560, 'Medenine Governorate', 224),
	(2561, 'Kef Governorate', 224),
	(2562, 'Kebili Governorate', 224),
	(2563, 'Siliana Governorate', 224),
	(2564, 'Kairouan Governorate', 224),
	(2565, 'Zaghouan Governorate', 224),
	(2566, 'Ben Arous Governorate', 224),
	(2567, 'Sidi Bouzid Governorate', 224),
	(2568, 'Mahdia Governorate', 224),
	(2569, 'Tozeur Governorate', 224),
	(2570, 'Kasserine Governorate', 224),
	(2571, 'Sousse Governorate', 224),
	(2572, 'Kasserine Governorate', 224),
	(2573, 'Ratak Chain', 137),
	(2574, 'Ralik Chain', 137),
	(2575, 'Centrale Region', 220),
	(2576, 'Maritime Region', 220),
	(2577, 'Plateaux Region', 220),
	(2578, 'Savanes Region', 220),
	(2579, 'Kara Region', 220),
	(2580, 'Chuuk State', 143),
	(2581, 'Pohnpei State', 143),
	(2582, 'Yap State', 143),
	(2583, 'Kosrae State', 143),
	(2584, 'Vaavu Atoll', 133),
	(2585, 'Shaviyani Atoll', 133),
	(2586, 'Haa Alif Atoll', 133),
	(2587, 'Alif Alif Atoll', 133),
	(2588, 'North Province (historical)', 133),
	(2589, 'North Central Province (historical)', 133),
	(2590, 'Dhaalu Atoll', 133),
	(2591, 'Thaa Atoll', 133),
	(2592, 'Noonu Atoll', 133),
	(2593, 'Upper South Province (historical)', 133),
	(2594, 'Addu Atoll', 133),
	(2595, 'Gnaviyani Atoll', 133),
	(2596, 'Kaafu Atoll', 133),
	(2597, 'Haa Dhaalu Atoll', 133),
	(2598, 'Gaafu Alif Atoll', 133),
	(2599, 'Faafu Atoll', 133),
	(2600, 'Alif Dhaal Atoll', 133),
	(2601, 'Laamu Atoll', 133),
	(2602, 'Raa Atoll', 133),
	(2603, 'Gaafu Dhaalu Atoll', 133),
	(2604, 'Central Province (historical)', 133),
	(2605, 'South Province (historical)', 133),
	(2606, 'South Central Province (historical)', 133),
	(2607, 'Lhaviyani Atoll', 133),
	(2608, 'Meemu Atoll', 133),
	(2609, 'Malé', 133),
	(2610, 'Utrecht', 156),
	(2611, 'Gelderland', 156),
	(2612, 'North Holland', 156),
	(2613, 'Drenthe', 156),
	(2614, 'South Holland', 156),
	(2615, 'Limburg', 156),
	(2616, 'Sint Eustatius', 156),
	(2617, 'Groningen', 156),
	(2618, 'Overijssel', 156),
	(2619, 'Flevoland', 156),
	(2620, 'Zeeland', 156),
	(2621, 'Saba', 156),
	(2622, 'Friesland', 156),
	(2623, 'North Brabant', 156),
	(2624, 'Bonaire', 156),
	(2625, 'Savanes Region', 54),
	(2626, 'Agnéby Region (historical)', 54),
	(2627, 'Lagunes District', 54),
	(2628, 'Sud-Bandama Region (historical)', 54),
	(2629, 'Montagnes District', 54),
	(2630, 'Moyen-Comoé Region (historical)', 54),
	(2631, 'Marahoué Region', 54),
	(2632, 'Lacs District', 54),
	(2633, 'Fromager Region (historical)', 54),
	(2634, 'Abidjan Autonomous District', 54),
	(2635, 'Bas-Sassandra Region (historical)', 54),
	(2636, 'Bafing Region', 54),
	(2637, 'Vallée du Bandama District', 54),
	(2638, 'Haut-Sassandra Region', 54),
	(2639, 'Lagunes Region (historical)', 54),
	(2640, 'Lacs Region (historical)', 54),
	(2641, 'Zanzan Region (historical)', 54),
	(2642, 'Denguélé Region (historical)', 54),
	(2643, 'Bas-Sassandra District', 54),
	(2644, 'Denguélé District', 54),
	(2645, 'Dix-Huit Montagnes Region (historical)', 54),
	(2646, 'Moyen-Cavally Region (historical)', 54),
	(2647, 'Vallée du Bandama Region (historical)', 54),
	(2648, 'Sassandra-Marahoué District', 54),
	(2649, 'Worodougou Region', 54),
	(2650, 'Woroba District', 54),
	(2651, 'Gôh-Djiboua District', 54),
	(2652, 'Sud-Comoé Region', 54),
	(2653, 'Yamoussoukro Autonomous District', 54),
	(2654, 'Comoé District', 54),
	(2655, 'N''zi-Comoé Region (historical)', 54),
	(2656, 'Far North Region', 38),
	(2657, 'Northwest Region', 38),
	(2658, 'Southwest Region', 38),
	(2659, 'South Region', 38),
	(2660, 'Centre Region', 38),
	(2661, 'East Region', 38),
	(2662, 'Littoral Region', 38),
	(2663, 'Adamawa Region', 38),
	(2664, 'West Region', 38),
	(2665, 'North Region', 38),
	(2666, 'Banjul', 80),
	(2667, 'West Coast Region', 80),
	(2668, 'Upper River Region', 80),
	(2669, 'Central River Region', 80),
	(2670, 'Lower River Region', 80),
	(2671, 'North Bank Region', 80),
	(2672, 'Beyla Prefecture', 92),
	(2673, 'Mandiana Prefecture', 92),
	(2674, 'Yomou Prefecture', 92),
	(2675, 'Fria Prefecture', 92),
	(2676, 'Boké Region', 92),
	(2677, 'Labé Region', 92),
	(2678, 'Nzérékoré Prefecture', 92),
	(2679, 'Dabola Prefecture', 92),
	(2680, 'Labé Prefecture', 92),
	(2681, 'Dubréka Prefecture', 92),
	(2682, 'Faranah Prefecture', 92),
	(2683, 'Forécariah Prefecture', 92),
	(2684, 'Nzérékoré Region', 92),
	(2685, 'Gaoual Prefecture', 92),
	(2686, 'Conakry', 92),
	(2687, 'Télimélé Prefecture', 92),
	(2688, 'Dinguiraye Prefecture', 92),
	(2689, 'Mamou Prefecture', 92),
	(2690, 'Lélouma Prefecture', 92),
	(2691, 'Kissidougou Prefecture', 92),
	(2692, 'Koubia Prefecture', 92),
	(2693, 'Kindia Prefecture', 92),
	(2694, 'Pita Prefecture', 92),
	(2695, 'Kouroussa Prefecture', 92),
	(2696, 'Tougué Prefecture', 92),
	(2697, 'Kankan Region', 92),
	(2698, 'Mamou Region', 92),
	(2699, 'Boffa Prefecture', 92),
	(2700, 'Mali Prefecture', 92),
	(2701, 'Kindia Region', 92),
	(2702, 'Macenta Prefecture', 92),
	(2703, 'Koundara Prefecture', 92),
	(2704, 'Kankan Prefecture', 92),
	(2705, 'Coyah Prefecture', 92),
	(2706, 'Dalaba Prefecture', 92),
	(2707, 'Siguiri Prefecture', 92),
	(2708, 'Lola Prefecture', 92),
	(2709, 'Boké Prefecture', 92),
	(2710, 'Kérouané Prefecture', 92),
	(2711, 'Guéckédou Prefecture', 92),
	(2712, 'Tombali Region', 93),
	(2713, 'Cacheu Region', 93),
	(2714, 'Biombo Region', 93),
	(2715, 'Quinara Region', 93),
	(2716, 'Sul Province (historical)', 93),
	(2717, 'Norte Province (historical)', 93),
	(2718, 'Oio Region', 93),
	(2719, 'Gabú Region', 93),
	(2720, 'Bafatá Region', 93),
	(2721, 'Leste Province (historical)', 93),
	(2722, 'Bolama Region', 93),
	(2723, 'Woleu-Ntem Province', 79),
	(2724, 'Ogooué-Ivindo Province', 79),
	(2725, 'Nyanga Province', 79),
	(2726, 'Haut-Ogooué Province', 79),
	(2727, 'Estuaire Province', 79),
	(2728, 'Ogooué-Maritime Province', 79),
	(2729, 'Ogooué-Lolo Province', 79),
	(2730, 'Moyen-Ogooué Province', 79),
	(2731, 'Ngounié Province', 79),
	(2732, 'Tshuapa', 51),
	(2733, 'Tanganyika Province', 51),
	(2734, 'Haut-Uele', 51),
	(2735, 'Kasaï-Oriental', 51),
	(2736, 'Orientale Province (historical)', 51),
	(2737, 'Kasaï-Central', 51),
	(2738, 'South Kivu', 51),
	(2739, 'Nord-Ubangi', 51),
	(2740, 'Kwango', 51),
	(2741, 'Kinshasa', 51),
	(2742, 'Katanga Province (historical)', 51),
	(2743, 'Sankuru', 51),
	(2744, 'Équateur', 51),
	(2745, 'Maniema', 51),
	(2746, 'Kongo Central', 51),
	(2747, 'Lomami Province', 51),
	(2748, 'Sud-Ubangi', 51),
	(2749, 'North Kivu', 51),
	(2750, 'Haut-Katanga Province', 51),
	(2751, 'Ituri', 51),
	(2752, 'Mongala', 51),
	(2753, 'Bas-Uele', 51),
	(2754, 'Bandundu Province (historical)', 51),
	(2755, 'Mai-Ndombe Province', 51),
	(2756, 'Tshopo', 51),
	(2757, 'Kasaï', 51),
	(2758, 'Haut-Lomami', 51),
	(2759, 'Kwilu', 51),
	(2760, 'Cuyuni-Mazaruni', 94),
	(2761, 'Potaro-Siparuni', 94),
	(2762, 'Mahaica-Berbice', 94),
	(2763, 'Upper Demerara-Berbice', 94),
	(2764, 'Barima-Waini', 94),
	(2765, 'Pomeroon-Supenaam', 94),
	(2766, 'East Berbice-Corentyne', 94),
	(2767, 'Demerara-Mahaica', 94),
	(2768, 'Essequibo Islands-West Demerara', 94),
	(2769, 'Upper Takutu-Upper Essequibo', 94),
	(2770, 'Presidente Hayes Department', 172),
	(2771, 'Canindeyú Department', 172),
	(2772, 'Guairá Department', 172),
	(2773, 'Caaguazú Department', 172),
	(2774, 'Paraguarí Department', 172),
	(2775, 'Caazapá Department', 172),
	(2776, 'San Pedro Department', 172),
	(2777, 'Central Department', 172),
	(2778, 'Itapúa Department', 172),
	(2779, 'Concepción Department', 172),
	(2780, 'Boquerón Department', 172),
	(2781, 'Ñeembucú Department', 172),
	(2782, 'Amambay Department', 172),
	(2783, 'Cordillera Department', 172),
	(2784, 'Alto Paraná Department', 172),
	(2785, 'Alto Paraguay Department', 172),
	(2786, 'Misiones Department', 172),
	(2787, 'Jaffna District', 208),
	(2788, 'Kandy District', 208),
	(2789, 'Kalutara District', 208),
	(2790, 'Badulla District', 208),
	(2791, 'Hambantota District', 208),
	(2792, 'Galle District', 208),
	(2793, 'Kilinochchi District', 208),
	(2794, 'Nuwara Eliya District', 208),
	(2795, 'Trincomalee District', 208),
	(2796, 'Puttalam District', 208),
	(2797, 'Kegalle District', 208),
	(2798, 'Central Province', 208),
	(2799, 'Ampara District', 208),
	(2800, 'North Central Province', 208),
	(2801, 'Southern Province', 208),
	(2802, 'Western Province', 208),
	(2803, 'Sabaragamuwa Province', 208),
	(2804, 'Gampaha District', 208),
	(2805, 'Mannar District', 208),
	(2806, 'Matara District', 208),
	(2807, 'Ratnapura District', 208),
	(2808, 'Eastern Province', 208),
	(2809, 'Vavuniya District', 208),
	(2810, 'Matale District', 208),
	(2811, 'Uva Province', 208),
	(2812, 'Polonnaruwa District', 208),
	(2813, 'Northern Province', 208),
	(2814, 'Mullaitivu District', 208),
	(2815, 'Colombo District', 208),
	(2816, 'Anuradhapura District', 208),
	(2817, 'North Western Province', 208),
	(2818, 'Batticaloa District', 208),
	(2819, 'Monaragala District', 208),
	(2820, 'Mohéli', 49),
	(2821, 'Anjouan', 49),
	(2822, 'Grande Comore', 49),
	(2823, 'Atacama Region', 44),
	(2824, 'Santiago Metropolitan Region', 44),
	(2825, 'Coquimbo Region', 44),
	(2826, 'Araucanía Region', 44),
	(2827, 'Biobío Region', 44),
	(2828, 'Aysén Region', 44),
	(2829, 'Arica y Parinacota Region', 44),
	(2830, 'Valparaíso Region', 44),
	(2831, 'Ñuble Region', 44),
	(2832, 'Antofagasta Region', 44),
	(2833, 'Maule Region', 44),
	(2834, 'Los Ríos Region', 44),
	(2835, 'Los Lagos Region', 44),
	(2836, 'Magallanes and Chilean Antarctica Region', 44),
	(2837, 'Tarapacá Region', 44),
	(2838, 'O''Higgins Region', 44),
	(2839, 'Commewijne District', 210),
	(2840, 'Nickerie District', 210),
	(2841, 'Para District', 210),
	(2842, 'Coronie District', 210),
	(2843, 'Paramaribo District', 210),
	(2844, 'Wanica District', 210),
	(2845, 'Marowijne District', 210),
	(2846, 'Brokopondo District', 210),
	(2847, 'Sipaliwini District', 210),
	(2848, 'Saramacca District', 210),
	(2849, 'Riyadh Region', 194),
	(2850, 'Makkah Region', 194),
	(2851, 'Al Madinah Region', 194),
	(2852, 'Tabuk Region', 194),
	(2853, '''Asir Region', 194),
	(2854, 'Northern Borders Region', 194),
	(2855, 'Ha''il Region', 194),
	(2856, 'Eastern Province', 194),
	(2857, 'Al Jawf Region', 194),
	(2858, 'Jizan Region', 194),
	(2859, 'Al Bahah Region', 194),
	(2860, 'Najran Region', 194),
	(2861, 'Al-Qassim Region', 194),
	(2862, 'Plateaux Department', 50),
	(2863, 'Pointe-Noire Department', 50),
	(2864, 'Cuvette Department', 50),
	(2865, 'Likouala Department', 50),
	(2866, 'Bouenza Department', 50),
	(2867, 'Kouilou Department', 50),
	(2868, 'Lékoumou Department', 50),
	(2869, 'Cuvette-Ouest Department', 50),
	(2870, 'Brazzaville Department', 50),
	(2871, 'Sangha Department', 50),
	(2872, 'Niari Department', 50),
	(2873, 'Pool Department', 50),
	(2874, 'Quindío Department', 48),
	(2875, 'Cundinamarca Department', 48),
	(2876, 'Chocó Department', 48),
	(2877, 'Norte de Santander Department', 48),
	(2878, 'Meta Department', 48),
	(2879, 'Risaralda Department', 48),
	(2880, 'Atlántico Department', 48),
	(2881, 'Arauca Department', 48),
	(2882, 'Guainía Department', 48),
	(2883, 'Tolima Department', 48),
	(2884, 'Cauca Department', 48),
	(2885, 'Vaupés Department', 48),
	(2886, 'Magdalena Department', 48),
	(2887, 'Caldas Department', 48),
	(2888, 'Guaviare Department', 48),
	(2889, 'La Guajira Department', 48),
	(2890, 'Antioquia Department', 48),
	(2891, 'Caquetá Department', 48),
	(2892, 'Casanare Department', 48),
	(2893, 'Bolívar Department', 48),
	(2894, 'Vichada Department', 48),
	(2895, 'Amazonas Department', 48),
	(2896, 'Putumayo Department', 48),
	(2897, 'Nariño Department', 48),
	(2898, 'Córdoba Department', 48),
	(2899, 'Cesar Department', 48),
	(2900, 'Archipelago of San Andrés, Providencia and Santa Catalina Department', 48),
	(2901, 'Santander Department', 48),
	(2902, 'Sucre Department', 48),
	(2903, 'Boyacá Department', 48),
	(2904, 'Valle del Cauca Department', 48),
	(2905, 'Galápagos Province', 64),
	(2906, 'Sucumbíos Province', 64),
	(2907, 'Pastaza Province', 64),
	(2908, 'Tungurahua Province', 64),
	(2909, 'Zamora-Chinchipe Province', 64),
	(2910, 'Los Ríos Province', 64),
	(2911, 'Imbabura Province', 64),
	(2912, 'Santa Elena Province', 64),
	(2913, 'Manabí Province', 64),
	(2914, 'Guayas Province', 64),
	(2915, 'Carchi Province', 64),
	(2916, 'Napo Province', 64),
	(2917, 'Cañar Province', 64),
	(2918, 'Morona-Santiago Province', 64),
	(2919, 'Santo Domingo de los Tsáchilas Province', 64),
	(2920, 'Bolívar Province', 64),
	(2921, 'Cotopaxi Province', 64),
	(2922, 'Esmeraldas Province', 64),
	(2923, 'Azuay Province', 64),
	(2924, 'El Oro Province', 64),
	(2925, 'Chimborazo Province', 64),
	(2926, 'Orellana Province', 64),
	(2927, 'Pichincha Province', 64),
	(2928, 'Obock Region', 60),
	(2929, 'Djibouti Region', 60),
	(2930, 'Dikhil Region', 60),
	(2931, 'Tadjourah Region', 60),
	(2932, 'Arta Region', 60),
	(2933, 'Ali Sabieh Region', 60),
	(2934, 'Hama Governorate', 215),
	(2935, 'Rif Dimashq Governorate', 215),
	(2936, 'As-Suwayda Governorate', 215),
	(2937, 'Deir ez-Zor Governorate', 215),
	(2938, 'Latakia Governorate', 215),
	(2939, 'Damascus Governorate', 215),
	(2940, 'Idlib Governorate', 215),
	(2941, 'Al-Hasakah Governorate', 215),
	(2942, 'Homs Governorate', 215),
	(2943, 'Quneitra Governorate', 215),
	(2944, 'Al-Raqqah Governorate', 215),
	(2945, 'Daraa Governorate', 215),
	(2946, 'Aleppo Governorate', 215),
	(2947, 'Tartus Governorate', 215),
	(2948, 'Fianarantsoa Province (historical)', 130),
	(2949, 'Toliara Province (historical)', 130),
	(2950, 'Antsiranana Province (historical)', 130),
	(2951, 'Antananarivo Province (historical)', 130),
	(2952, 'Toamasina Province (historical)', 130),
	(2953, 'Mahajanga Province (historical)', 130),
	(2954, 'Mogilev Region', 21),
	(2955, 'Gomel Region', 21),
	(2956, 'Grodno Region', 21),
	(2957, 'Minsk Region', 21),
	(2958, 'Minsk City', 21),
	(2959, 'Brest Region', 21),
	(2960, 'Vitebsk Region', 21),
	(2961, 'Murqub District', 124),
	(2962, 'Nuqat al Khams District', 124),
	(2963, 'Zawiya District', 124),
	(2964, 'Al Wahat District', 124),
	(2965, 'Sabha District', 124),
	(2966, 'Derna District', 124),
	(2967, 'Murzuq District', 124),
	(2968, 'Marj District', 124),
	(2969, 'Ghat District', 124),
	(2970, 'Jufra District', 124),
	(2971, 'Tripoli District', 124),
	(2972, 'Kufra District', 124),
	(2973, 'Wadi al Hayaa District', 124),
	(2974, 'Jabal al Gharbi District', 124),
	(2975, 'Wadi al Shatii District', 124),
	(2976, 'Nalut District', 124),
	(2977, 'Sirte District', 124),
	(2978, 'Misrata District', 124),
	(2979, 'Jafara District', 124),
	(2980, 'Jabal al Akhdar District', 124),
	(2981, 'Benghazi District', 124),
	(2982, 'Ribeira Brava Municipality', 40),
	(2983, 'Tarrafal Municipality', 40),
	(2984, 'Ribeira Grande de Santiago Municipality', 40),
	(2985, 'Santa Catarina Municipality', 40),
	(2986, 'São Domingos Municipality', 40),
	(2987, 'Mosteiros Municipality', 40),
	(2988, 'Praia Municipality', 40),
	(2989, 'Porto Novo Municipality', 40),
	(2990, 'São Miguel Municipality', 40),
	(2991, 'Maio Municipality', 40),
	(2992, 'Sotavento Islands', 40),
	(2993, 'São Lourenço dos Órgãos Municipality', 40),
	(2994, 'Barlavento Islands', 40),
	(2995, 'Santa Catarina do Fogo Municipality', 40),
	(2996, 'Brava Municipality', 40),
	(2997, 'Paul Municipality', 40),
	(2998, 'Sal Municipality', 40),
	(2999, 'Boa Vista Municipality', 40),
	(3000, 'São Filipe Municipality', 40),
	(3001, 'São Vicente Municipality', 40),
	(3002, 'Ribeira Grande Municipality', 40),
	(3003, 'Tarrafal de São Nicolau Municipality', 40),
	(3004, 'Santa Cruz Municipality', 40),
	(3005, 'Schleswig-Holstein', 82),
	(3006, 'Baden-Württemberg', 82),
	(3007, 'Mecklenburg-Vorpommern', 82),
	(3008, 'Lower Saxony', 82),
	(3009, 'Bavaria', 82),
	(3010, 'Berlin', 82),
	(3011, 'Saxony-Anhalt', 82),
	(3013, 'Brandenburg', 82),
	(3014, 'Bremen', 82),
	(3015, 'Thuringia', 82),
	(3016, 'Hamburg', 82),
	(3017, 'North Rhine-Westphalia', 82),
	(3018, 'Hesse', 82),
	(3019, 'Rhineland-Palatinate', 82),
	(3020, 'Saarland', 82),
	(3021, 'Saxony', 82),
	(3022, 'Mafeteng District', 122),
	(3023, 'Mohale''s Hoek District', 122),
	(3024, 'Mokhotlong District', 122),
	(3025, 'Qacha''s Nek District', 122),
	(3026, 'Leribe District', 122),
	(3027, 'Quthing District', 122),
	(3028, 'Maseru District', 122),
	(3029, 'Butha-Buthe District', 122),
	(3030, 'Berea District', 122),
	(3031, 'Thaba-Tseka District', 122),
	(3032, 'Montserrado County', 123),
	(3033, 'River Cess County', 123),
	(3034, 'Bong County', 123),
	(3035, 'Sinoe County', 123),
	(3036, 'Grand Cape Mount County', 123),
	(3037, 'Lofa County', 123),
	(3038, 'River Gee County', 123),
	(3039, 'Grand Gedeh County', 123),
	(3040, 'Grand Bassa County', 123),
	(3041, 'Bomi County', 123),
	(3042, 'Maryland County', 123),
	(3043, 'Margibi County', 123),
	(3044, 'Gbarpolu County', 123),
	(3045, 'Grand Kru County', 123),
	(3046, 'Nimba County', 123),
	(3047, 'Ad Dhahirah Governorate', 166),
	(3048, 'Al Batinah North Governorate', 166),
	(3049, 'Al Batinah South Governorate', 166),
	(3050, 'Al Batinah Region (historical)', 166),
	(3051, 'Ash Sharqiyah Region (historical)', 166),
	(3052, 'Musandam Governorate', 166),
	(3053, 'Ash Sharqiyah North Governorate', 166),
	(3054, 'Ash Sharqiyah South Governorate', 166),
	(3055, 'Muscat Governorate', 166),
	(3056, 'Al Wusta Governorate', 166),
	(3057, 'Dhofar Governorate', 166),
	(3058, 'Ad Dakhiliyah Governorate', 166),
	(3059, 'Al Buraimi Governorate', 166),
	(3060, 'Ngamiland District (historical)', 29),
	(3061, 'Ghanzi District', 29),
	(3062, 'Kgatleng District', 29),
	(3063, 'Southern District', 29),
	(3064, 'South-East District', 29),
	(3065, 'North-West District', 29),
	(3066, 'Kgalagadi District', 29),
	(3067, 'Central District', 29),
	(3068, 'North-East District', 29),
	(3069, 'Kweneng District', 29),
	(3070, 'Collines Department', 24),
	(3071, 'Kouffo Department', 24),
	(3072, 'Donga Department', 24),
	(3073, 'Zou Department', 24),
	(3074, 'Plateau Department', 24),
	(3075, 'Mono Department', 24),
	(3076, 'Atakora Department', 24),
	(3077, 'Alibori Department', 24),
	(3078, 'Borgou Department', 24),
	(3079, 'Atlantique Department', 24),
	(3080, 'Ouémé Department', 24),
	(3081, 'Littoral Department', 24),
	(3082, 'Machinga District', 131),
	(3083, 'Zomba District', 131),
	(3084, 'Mwanza District', 131),
	(3085, 'Nsanje District', 131),
	(3086, 'Salima District', 131),
	(3087, 'Chitipa District', 131),
	(3088, 'Ntcheu District', 131),
	(3089, 'Rumphi District', 131),
	(3090, 'Dowa District', 131),
	(3091, 'Karonga District', 131),
	(3092, 'Central Region', 131),
	(3093, 'Likoma District', 131),
	(3094, 'Kasungu District', 131),
	(3095, 'Nkhata Bay District', 131),
	(3096, 'Balaka District', 131),
	(3097, 'Dedza District', 131),
	(3098, 'Thyolo District', 131),
	(3099, 'Mchinji District', 131),
	(3100, 'Nkhotakota District', 131),
	(3101, 'Lilongwe District', 131),
	(3102, 'Blantyre District', 131),
	(3103, 'Mulanje District', 131),
	(3104, 'Mzimba District', 131),
	(3105, 'Northern Region', 131),
	(3106, 'Southern Region', 131),
	(3107, 'Chikwawa District', 131),
	(3108, 'Phalombe District', 131),
	(3109, 'Chiradzulu District', 131),
	(3110, 'Mangochi District', 131),
	(3111, 'Ntchisi District', 131),
	(3112, 'Kénédougou Province', 35),
	(3113, 'Namentenga Province', 35),
	(3114, 'Sahel Region', 35),
	(3115, 'Centre-Ouest Region', 35),
	(3116, 'Nahouri Province', 35),
	(3117, 'Passoré Province', 35),
	(3118, 'Zoundwéogo Province', 35),
	(3119, 'Sissili Province', 35),
	(3120, 'Banwa Province', 35),
	(3121, 'Bougouriba Province', 35),
	(3122, 'Gnagna Province', 35),
	(3123, 'Mouhoun Province', 35),
	(3124, 'Yagha Province', 35),
	(3125, 'Plateau-Central Region', 35),
	(3126, 'Sanmatenga Province', 35),
	(3127, 'Centre-Nord Region', 35),
	(3128, 'Tapoa Province', 35),
	(3129, 'Houet Province', 35),
	(3130, 'Zondoma Province', 35),
	(3131, 'Boulgou Province', 35),
	(3132, 'Komondjari Province', 35),
	(3133, 'Koulpélogo Province', 35),
	(3134, 'Tuy Province', 35),
	(3135, 'Ioba Province', 35),
	(3136, 'Centre Region', 35),
	(3137, 'Sourou Province', 35),
	(3138, 'Boucle du Mouhoun Region', 35),
	(3139, 'Séno Province', 35),
	(3140, 'Sud-Ouest Region', 35),
	(3141, 'Oubritenga Province', 35),
	(3142, 'Nayala Province', 35),
	(3143, 'Gourma Province', 35),
	(3144, 'Oudalan Province', 35),
	(3145, 'Ziro Province', 35),
	(3146, 'Kossi Province', 35),
	(3147, 'Kourwéogo Province', 35),
	(3148, 'Ganzourgou Province', 35),
	(3149, 'Centre-Sud Region', 35),
	(3150, 'Yatenga Province', 35),
	(3151, 'Loroum Province', 35),
	(3152, 'Bazèga Province', 35),
	(3153, 'Cascades Region', 35),
	(3154, 'Sanguié Province', 35),
	(3155, 'Bam Province', 35),
	(3156, 'Noumbiel Province', 35),
	(3157, 'Kompienga Province', 35),
	(3158, 'Est Region', 35),
	(3159, 'Léraba Province', 35),
	(3160, 'Balé Province', 35),
	(3161, 'Kouritenga Province', 35),
	(3162, 'Centre-Est Region', 35),
	(3163, 'Poni Province', 35),
	(3164, 'Nord Region', 35),
	(3165, 'Hauts-Bassins Region', 35),
	(3166, 'Soum Province', 35),
	(3167, 'Comoé Province', 35),
	(3168, 'Kadiogo Province', 35),
	(3169, 'Islamabad Capital Territory', 167),
	(3170, 'Gilgit-Baltistan', 167),
	(3171, 'Khyber Pakhtunkhwa', 167),
	(3172, 'Azad Jammu and Kashmir', 167),
	(3173, 'Federally Administered Tribal Areas (historical)', 167),
	(3174, 'Balochistan', 167),
	(3175, 'Sindh', 167),
	(3176, 'Punjab', 167),
	(3177, 'Al Rayyan Municipality', 179),
	(3178, 'Al Shamal Municipality', 179),
	(3179, 'Al Wakrah Municipality', 179),
	(3180, 'Madinat ash Shamal', 179),
	(3181, 'Doha Municipality', 179),
	(3182, 'Al Daayen Municipality', 179),
	(3183, 'Al Khor Municipality', 179),
	(3184, 'Umm Salal Municipality', 179),
	(3185, 'Rumonge Province', 36),
	(3186, 'Muyinga Province', 36),
	(3187, 'Mwaro Province', 36),
	(3188, 'Makamba Province', 36),
	(3189, 'Rutana Province', 36),
	(3190, 'Cibitoke Province', 36),
	(3191, 'Ruyigi Province', 36),
	(3192, 'Kayanza Province', 36),
	(3193, 'Muramvya Province', 36),
	(3194, 'Karuzi Province', 36),
	(3195, 'Kirundo Province', 36),
	(3196, 'Bubanza Province', 36),
	(3197, 'Gitega Province', 36),
	(3198, 'Bujumbura Mairie Province', 36),
	(3199, 'Ngozi Province', 36),
	(3200, 'Bujumbura Rural Province', 36),
	(3201, 'Cankuzo Province', 36),
	(3202, 'Bururi Province', 36),
	(3203, 'Flores Department', 235),
	(3204, 'San José Department', 235),
	(3205, 'Artigas Department', 235),
	(3206, 'Maldonado Department', 235),
	(3207, 'Rivera Department', 235),
	(3208, 'Colonia Department', 235),
	(3209, 'Durazno Department', 235),
	(3210, 'Río Negro Department', 235),
	(3211, 'Cerro Largo Department', 235),
	(3212, 'Paysandú Department', 235),
	(3213, 'Canelones Department', 235),
	(3214, 'Treinta y Tres Department', 235),
	(3215, 'Lavalleja Department', 235),
	(3216, 'Rocha Department', 235),
	(3217, 'Florida Department', 235),
	(3218, 'Montevideo Department', 235),
	(3219, 'Soriano Department', 235),
	(3220, 'Salto Department', 235),
	(3221, 'Tacuarembó Department', 235),
	(3222, 'Kafr el-Sheikh Governorate', 65),
	(3223, 'Cairo Governorate', 65),
	(3224, 'Damietta Governorate', 65),
	(3225, 'Aswan Governorate', 65),
	(3226, 'Sohag Governorate', 65),
	(3227, 'North Sinai Governorate', 65),
	(3228, 'Monufia Governorate', 65),
	(3229, 'Port Said Governorate', 65),
	(3230, 'Beni Suef Governorate', 65),
	(3231, 'Matrouh Governorate', 65),
	(3232, 'Qalyubia Governorate', 65),
	(3233, 'Suez Governorate', 65),
	(3234, 'Gharbia Governorate', 65),
	(3235, 'Alexandria Governorate', 65),
	(3236, 'Asyut Governorate', 65),
	(3237, 'South Sinai Governorate', 65),
	(3238, 'Faiyum Governorate', 65),
	(3239, 'Giza Governorate', 65),
	(3240, 'Red Sea Governorate', 65),
	(3241, 'Beheira Governorate', 65),
	(3242, 'Luxor Governorate', 65),
	(3243, 'Minya Governorate', 65),
	(3244, 'Ismailia Governorate', 65),
	(3245, 'Dakahlia Governorate', 65),
	(3246, 'New Valley Governorate', 65),
	(3247, 'Qena Governorate', 65),
	(3248, 'Agaléga', 140),
	(3249, 'Rodrigues', 140),
	(3250, 'Pamplemousses District', 140),
	(3251, 'Saint Brandon (Cargados Carajos Shoals)', 140),
	(3252, 'Vacoas-Phoenix', 140),
	(3253, 'Moka District', 140),
	(3254, 'Flacq District', 140),
	(3255, 'Curepipe', 140),
	(3256, 'Port Louis City', 140),
	(3257, 'Savanne District', 140),
	(3258, 'Quatre Bornes', 140),
	(3259, 'Rivière Noire District', 140),
	(3260, 'Port Louis District', 140),
	(3261, 'Rivière du Rempart District', 140),
	(3262, 'Beau Bassin-Rose Hill', 140),
	(3263, 'Plaines Wilhems District', 140),
	(3264, 'Grand Port District', 140),
	(3265, 'Guelmim Province (historical)', 149),
	(3266, 'Aousserd Province', 149),
	(3267, 'Al Hoceïma Province', 149),
	(3268, 'Larache Province', 149),
	(3269, 'Ouarzazate Province', 149),
	(3270, 'Boulemane Province', 149),
	(3271, 'Oriental Region', 149),
	(3272, 'Béni-Mellal Province', 149),
	(3273, 'Marrakesh Prefecture', 149),
	(3274, 'Chichaoua Province', 149),
	(3275, 'Boujdour Province', 149),
	(3276, 'Khémisset Province', 149),
	(3277, 'Tiznit Province', 149),
	(3278, 'Béni Mellal-Khénifra', 149),
	(3279, 'Sidi Kacem Province', 149),
	(3280, 'El Jadida Province', 149),
	(3281, 'Nador Province', 149),
	(3282, 'Settat Province', 149),
	(3283, 'Zagora Province', 149),
	(3284, 'Médiouna Province', 149),
	(3285, 'Berkane Province', 149),
	(3286, 'Tan-Tan Province', 149),
	(3287, 'Nouaceur Province', 149),
	(3288, 'Marrakesh-Safi', 149),
	(3289, 'Sefrou Province', 149),
	(3290, 'Drâa-Tafilalet', 149),
	(3291, 'El Hajeb Province', 149),
	(3292, 'Es Semara Province', 149),
	(3293, 'Laâyoune Province', 149),
	(3294, 'Inezgane-Aït Melloul Prefecture', 149),
	(3295, 'Souss-Massa', 149),
	(3296, 'Taza Province', 149),
	(3297, 'Assa-Zag Province', 149),
	(3298, 'Laâyoune-Sakia El Hamra', 149),
	(3299, 'Errachidia Province', 149),
	(3300, 'Fahs-Anjra Province', 149),
	(3301, 'Figuig Province', 149),
	(3302, 'Chtouka-Aït Baha Province', 149),
	(3303, 'Casablanca-Settat', 149),
	(3304, 'Benslimane Province', 149),
	(3305, 'Guelmim-Oued Noun', 149),
	(3306, 'Dakhla-Oued Ed-Dahab', 149),
	(3307, 'Jerada Province', 149),
	(3308, 'Kénitra Province', 149),
	(3309, 'El Kelâa des Sraghna Province', 149),
	(3310, 'Chefchaouen Province', 149),
	(3311, 'Safi Province', 149),
	(3312, 'Tata Province', 149),
	(3313, 'Fès-Meknès', 149),
	(3314, 'Taroudant Province', 149),
	(3315, 'Moulay Yacoub Province', 149),
	(3316, 'Essaouira Province', 149),
	(3317, 'Khénifra Province', 149),
	(3318, 'Tétouan Province', 149),
	(3319, 'Oued Ed-Dahab Province (historical)', 149),
	(3320, 'Al Haouz Province', 149),
	(3321, 'Azilal Province', 149),
	(3322, 'Taourirt Province', 149),
	(3323, 'Taounate Province', 149),
	(3324, 'Tanger-Tétouan-Al Hoceïma', 149),
	(3325, 'Ifrane Province', 149),
	(3326, 'Khouribga Province', 149),
	(3327, 'Cabo Delgado Province', 150),
	(3328, 'Zambezia Province', 150),
	(3329, 'Gaza Province', 150),
	(3330, 'Inhambane Province', 150),
	(3331, 'Sofala Province', 150),
	(3332, 'Maputo Province', 150),
	(3333, 'Niassa Province', 150),
	(3334, 'Tete Province', 150),
	(3335, 'Maputo City', 150),
	(3336, 'Nampula Province', 150),
	(3337, 'Manica Province', 150),
	(3338, 'Hodh Ech Chargui Region', 139),
	(3339, 'Brakna Region', 139),
	(3340, 'Tiris Zemmour Region', 139),
	(3341, 'Gorgol Region', 139),
	(3342, 'Inchiri Region', 139),
	(3343, 'Nouakchott-Nord Region', 139),
	(3344, 'Adrar Region', 139),
	(3345, 'Tagant Region', 139),
	(3346, 'Dakhlet Nouadhibou Region', 139),
	(3347, 'Nouakchott-Sud Region', 139),
	(3348, 'Trarza Region', 139),
	(3349, 'Assaba Region', 139),
	(3350, 'Guidimaka Region', 139),
	(3351, 'Hodh El Gharbi Region', 139),
	(3352, 'Nouakchott-Ouest Region', 139),
	(3353, 'Tobago', 223),
	(3354, 'Couva-Tabaquite-Talparo Regional Corporation', 223),
	(3355, 'Tobago', 223),
	(3356, 'Rio Claro-Mayaro Regional Corporation', 223),
	(3357, 'San Juan-Laventille Regional Corporation', 223),
	(3358, 'Tunapuna-Piarco Regional Corporation', 223),
	(3359, 'San Fernando', 223),
	(3360, 'Point Fortin', 223),
	(3361, 'Sangre Grande Regional Corporation', 223),
	(3362, 'Arima', 223),
	(3363, 'Port of Spain', 223),
	(3364, 'Siparia Regional Corporation', 223),
	(3365, 'Penal-Debe Regional Corporation', 223),
	(3366, 'Chaguanas', 223),
	(3367, 'Diego Martin Regional Corporation', 223),
	(3368, 'Princes Town Regional Corporation', 223),
	(3369, 'Mary Region', 226),
	(3370, 'Lebap Region', 226),
	(3371, 'Ashgabat City', 226),
	(3372, 'Balkan Region', 226),
	(3373, 'Daşoguz Region', 226),
	(3374, 'Ahal Region', 226),
	(3375, 'Beni Department', 27),
	(3376, 'Oruro Department', 27),
	(3377, 'Santa Cruz Department', 27),
	(3378, 'Tarija Department', 27),
	(3379, 'Pando Department', 27),
	(3380, 'La Paz Department', 27),
	(3381, 'Cochabamba Department', 27),
	(3382, 'Chuquisaca Department', 27),
	(3383, 'Potosí Department', 27),
	(3384, 'Saint George Parish', 188),
	(3385, 'Saint Patrick Parish', 188),
	(3386, 'Saint Andrew Parish', 188),
	(3387, 'Saint David Parish', 188),
	(3388, 'Grenadines Parish', 188),
	(3389, 'Charlotte Parish', 188),
	(3390, 'Sharjah Emirate', 231),
	(3391, 'Dubai Emirate', 231),
	(3392, 'Umm al-Quwain Emirate', 231),
	(3393, 'Fujairah Emirate', 231),
	(3394, 'Ras al-Khaimah Emirate', 231),
	(3395, 'Ajman Emirate', 231),
	(3396, 'Abu Dhabi Emirate', 231),
	(3397, 'Districts of Republican Subordination', 217),
	(3398, 'Khatlon Province', 217),
	(3399, 'Gorno-Badakhshan Autonomous Province', 217),
	(3400, 'Sughd Province', 217),
	(3401, 'Tainan County (historical)', 216),
	(3402, 'Yilan County', 216),
	(3403, 'Penghu County', 216),
	(3404, 'Changhua County', 216),
	(3405, 'Pingtung County', 216),
	(3406, 'Taichung City', 216),
	(3407, 'Nantou County', 216),
	(3408, 'Chiayi County', 216),
	(3409, 'Kaohsiung County (historical)', 216),
	(3410, 'Taitung County', 216),
	(3411, 'Hualien County', 216),
	(3412, 'Kaohsiung City', 216),
	(3413, 'Miaoli County', 216),
	(3414, 'Taichung County (historical)', 216),
	(3415, 'Kinmen County', 216),
	(3416, 'Yunlin County', 216),
	(3417, 'Hsinchu City', 216),
	(3418, 'Chiayi City', 216),
	(3419, 'Taoyuan City', 216),
	(3420, 'Lienchiang County', 216),
	(3421, 'Tainan City', 216),
	(3422, 'Taipei City', 216),
	(3423, 'Hsinchu County', 216),
	(3424, 'Northern Red Sea Region', 68),
	(3425, 'Anseba Region', 68),
	(3426, 'Maekel Region', 68),
	(3427, 'Debub Region', 68),
	(3428, 'Gash-Barka Region', 68),
	(3429, 'Southern Red Sea Region', 68),
	(3430, 'Westfjords Region', 100),
	(3431, 'Capital Region', 100),
	(3432, 'Westfjords Region', 100),
	(3433, 'Eastern Region', 100),
	(3434, 'Southern Region', 100),
	(3435, 'Northwestern Region', 100),
	(3436, 'Western Region', 100),
	(3437, 'Northeastern Region', 100),
	(3438, 'Río Muni', 67),
	(3439, 'Kié-Ntem Province', 67),
	(3440, 'Wele-Nzas Province', 67),
	(3441, 'Litoral Province', 67),
	(3442, 'Insular Region', 67),
	(3443, 'Bioko Sur Province', 67),
	(3444, 'Annobón Province', 67),
	(3445, 'Centro Sur Province', 67),
	(3446, 'Bioko Norte Province', 67),
	(3447, 'Chihuahua', 142),
	(3448, 'Oaxaca', 142),
	(3449, 'Sinaloa', 142),
	(3450, 'State of Mexico', 142),
	(3451, 'Chiapas', 142),
	(3452, 'Nuevo León', 142),
	(3453, 'Durango', 142),
	(3454, 'Tabasco', 142),
	(3455, 'Querétaro', 142),
	(3456, 'Aguascalientes', 142),
	(3457, 'Baja California', 142),
	(3458, 'Tlaxcala', 142),
	(3459, 'Guerrero', 142),
	(3460, 'Baja California Sur', 142),
	(3461, 'San Luis Potosí', 142),
	(3462, 'Zacatecas', 142),
	(3463, 'Tamaulipas', 142),
	(3464, 'Veracruz', 142),
	(3465, 'Morelos', 142),
	(3466, 'Yucatán', 142),
	(3467, 'Quintana Roo', 142),
	(3468, 'Sonora', 142),
	(3469, 'Guanajuato', 142),
	(3470, 'Hidalgo', 142),
	(3471, 'Coahuila', 142),
	(3472, 'Colima', 142),
	(3473, 'Mexico City', 142),
	(3474, 'Michoacán', 142),
	(3475, 'Campeche', 142),
	(3476, 'Puebla', 142),
	(3477, 'Nayarit', 142),
	(3478, 'Krabi', 219),
	(3479, 'Ranong', 219),
	(3480, 'Nong Bua Lam Phu', 219),
	(3481, 'Samut Prakan', 219),
	(3482, 'Surat Thani', 219),
	(3483, 'Lamphun', 219),
	(3484, 'Nong Khai', 219),
	(3485, 'Khon Kaen', 219),
	(3486, 'Chanthaburi', 219),
	(3487, 'Saraburi', 219),
	(3488, 'Phatthalung', 219),
	(3489, 'Uttaradit', 219),
	(3490, 'Sing Buri', 219),
	(3491, 'Chiang Mai', 219),
	(3492, 'Nakhon Sawan', 219),
	(3493, 'Yala', 219),
	(3494, 'Phra Nakhon Si Ayutthaya', 219),
	(3495, 'Nonthaburi', 219),
	(3496, 'Trat', 219),
	(3497, 'Nakhon Ratchasima', 219),
	(3498, 'Chiang Rai', 219),
	(3499, 'Ratchaburi', 219),
	(3500, 'Pathum Thani', 219),
	(3501, 'Sakon Nakhon', 219),
	(3502, 'Samut Songkhram', 219),
	(3503, 'Nakhon Pathom', 219),
	(3504, 'Samut Sakhon', 219),
	(3505, 'Mae Hong Son', 219),
	(3506, 'Phitsanulok', 219),
	(3507, 'Pattaya', 219),
	(3508, 'Prachuap Khiri Khan', 219),
	(3509, 'Loei', 219),
	(3510, 'Roi Et', 219),
	(3511, 'Kanchanaburi', 219),
	(3512, 'Ubon Ratchathani', 219),
	(3513, 'Chon Buri', 219),
	(3514, 'Phichit', 219),
	(3515, 'Phetchabun', 219),
	(3516, 'Kamphaeng Phet', 219),
	(3517, 'Maha Sarakham', 219),
	(3518, 'Rayong', 219),
	(3519, 'Ang Thong', 219),
	(3520, 'Nakhon Si Thammarat', 219),
	(3521, 'Yasothon', 219),
	(3522, 'Chai Nat', 219),
	(3523, 'Amnat Charoen', 219),
	(3524, 'Suphan Buri', 219),
	(3525, 'Tak', 219),
	(3526, 'Chumphon', 219),
	(3527, 'Udon Thani', 219),
	(3528, 'Phrae', 219),
	(3529, 'Sa Kaeo', 219),
	(3530, 'Nan', 219),
	(3531, 'Surin', 219),
	(3532, 'Phetchaburi', 219),
	(3533, 'Bueng Kan', 219),
	(3534, 'Buri Ram', 219),
	(3535, 'Nakhon Nayok', 219),
	(3536, 'Phuket', 219),
	(3537, 'Satun', 219),
	(3538, 'Phayao', 219),
	(3539, 'Songkhla', 219),
	(3540, 'Pattani', 219),
	(3541, 'Trang', 219),
	(3542, 'Prachin Buri', 219),
	(3543, 'Lopburi', 219),
	(3544, 'Lampang', 219),
	(3545, 'Sukhothai', 219),
	(3546, 'Mukdahan', 219),
	(3547, 'Si Sa Ket', 219),
	(3548, 'Nakhon Phanom', 219),
	(3549, 'Phang Nga', 219),
	(3550, 'Kalasin', 219),
	(3551, 'Uthai Thani', 219),
	(3552, 'Chachoengsao', 219),
	(3553, 'Narathiwat', 219),
	(3554, 'Bangkok', 219),
	(3555, 'Hiiu County', 69),
	(3556, 'Viljandi County', 69),
	(3557, 'Tartu County', 69),
	(3558, 'Valga County', 69),
	(3559, 'Rapla County', 69),
	(3560, 'Võru County', 69),
	(3561, 'Saare County', 69),
	(3562, 'Pärnu County', 69),
	(3563, 'Põlva County', 69),
	(3564, 'Lääne-Viru County', 69),
	(3565, 'Jõgeva County', 69),
	(3566, 'Järva County', 69),
	(3567, 'Harju County', 69),
	(3568, 'Lääne County', 69),
	(3569, 'Ida-Viru County', 69),
	(3570, 'Moyen-Chari Region', 43),
	(3571, 'Mayo-Kebbi Ouest Region', 43),
	(3572, 'Sila Region', 43),
	(3573, 'Hadjer-Lamis Region', 43),
	(3574, 'Borkou Region', 43),
	(3575, 'Ennedi-Est Region', 43),
	(3576, 'Guéra Region', 43),
	(3577, 'Lac Region', 43),
	(3578, 'Ennedi Region (historical)', 43),
	(3579, 'Tandjilé Region', 43),
	(3580, 'Mayo-Kebbi Est Region', 43),
	(3581, 'Wadi Fira Region', 43),
	(3582, 'Ouaddaï Region', 43),
	(3583, 'Barh El Gazel Region', 43),
	(3584, 'Ennedi-Ouest Region', 43),
	(3585, 'Logone Occidental Region', 43),
	(3586, 'N''Djamena', 43),
	(3587, 'Tibesti Region', 43),
	(3588, 'Kanem Region', 43),
	(3589, 'Mandoul Region', 43),
	(3590, 'Batha Region', 43),
	(3591, 'Logone Oriental Region', 43),
	(3592, 'Salamat Region', 43),
	(3593, 'Berry Islands', 17),
	(3594, 'North Andros and Berry Islands (historical)', 17),
	(3595, 'Hope Town', 17),
	(3596, 'Central Eleuthera', 17),
	(3597, 'Governor''s Harbour (historical)', 17),
	(3598, 'East Grand Bahama', 17),
	(3599, 'West Grand Bahama', 17),
	(3600, 'Rum Cay', 17),
	(3601, 'Acklins', 17),
	(3602, 'North Eleuthera', 17),
	(3603, 'Central Abaco', 17),
	(3604, 'Marsh Harbour (historical)', 17),
	(3605, 'Black Point', 17),
	(3606, 'South Abaco', 17),
	(3607, 'South Eleuthera', 17),
	(3608, 'South Abaco', 17),
	(3609, 'Inagua', 17),
	(3610, 'Long Island', 17),
	(3611, 'Cat Island', 17),
	(3612, 'Exuma', 17),
	(3613, 'Harbour Island', 17),
	(3614, 'East Grand Bahama', 17),
	(3615, 'Ragged Island', 17),
	(3616, 'North Abaco', 17),
	(3617, 'North Andros', 17),
	(3618, 'South Andros and Mangrove Cay (historical)', 17),
	(3619, 'Central Andros', 17),
	(3620, 'San Salvador and Rum Cay (historical)', 17),
	(3621, 'Crooked Island and Long Cay', 17),
	(3622, 'South Andros', 17),
	(3623, 'South Eleuthera (historical)', 17),
	(3624, 'Hope Town', 17),
	(3625, 'Mangrove Cay', 17),
	(3626, 'Freeport (historical)', 17),
	(3627, 'San Salvador', 17),
	(3628, 'Acklins and Crooked Islands (historical)', 17),
	(3629, 'Bimini', 17),
	(3630, 'Spanish Wells', 17),
	(3631, 'Central Andros', 17),
	(3632, 'Grand Cay', 17),
	(3633, 'Mayaguana', 17),
	(3634, 'San Juan Province', 11),
	(3635, 'Santiago del Estero Province', 11),
	(3636, 'San Luis Province', 11),
	(3637, 'Tucumán Province', 11),
	(3638, 'Corrientes Province', 11),
	(3639, 'Río Negro Province', 11),
	(3640, 'Chaco Province', 11),
	(3641, 'Santa Fe Province', 11),
	(3642, 'Córdoba Province', 11),
	(3643, 'Salta Province', 11),
	(3644, 'Misiones Province', 11),
	(3645, 'Jujuy Province', 11),
	(3646, 'Mendoza Province', 11),
	(3647, 'Catamarca Province', 11),
	(3648, 'Neuquén Province', 11),
	(3649, 'Santa Cruz Province', 11),
	(3650, 'Tierra del Fuego, Antarctica and South Atlantic Islands Province', 11),
	(3651, 'Chubut Province', 11),
	(3652, 'Formosa Province', 11),
	(3653, 'La Rioja Province', 11),
	(3654, 'Entre Ríos Province', 11),
	(3655, 'La Pampa Province', 11),
	(3656, 'Buenos Aires Province', 11),
	(3657, 'Quiché Department', 90),
	(3658, 'Jalapa Department', 90),
	(3659, 'Izabal Department', 90),
	(3660, 'Suchitepéquez Department', 90),
	(3661, 'Sololá Department', 90),
	(3662, 'El Progreso Department', 90),
	(3663, 'Totonicapán Department', 90),
	(3664, 'Retalhuleu Department', 90),
	(3665, 'Santa Rosa Department', 90),
	(3666, 'Chiquimula Department', 90),
	(3667, 'San Marcos Department', 90),
	(3668, 'Quetzaltenango Department', 90),
	(3669, 'Petén Department', 90),
	(3670, 'Huehuetenango Department', 90),
	(3671, 'Alta Verapaz Department', 90),
	(3672, 'Guatemala Department', 90),
	(3673, 'Jutiapa Department', 90),
	(3674, 'Baja Verapaz Department', 90),
	(3675, 'Chimaltenango Department', 90),
	(3676, 'Sacatepéquez Department', 90),
	(3677, 'Escuintla Department', 90),
	(3678, 'Madre de Dios Department', 173),
	(3679, 'Huancavelica Department', 173),
	(3680, 'Áncash Department', 173),
	(3681, 'Arequipa Department', 173),
	(3682, 'Puno Department', 173),
	(3683, 'La Libertad Department', 173),
	(3684, 'Ucayali Department', 173),
	(3685, 'Amazonas Department', 173),
	(3686, 'Pasco Department', 173),
	(3687, 'Huánuco Department', 173),
	(3688, 'Cajamarca Department', 173),
	(3689, 'Tumbes Department', 173),
	(3691, 'Cusco Department', 173),
	(3692, 'Ayacucho Department', 173),
	(3693, 'Junín Department', 173),
	(3694, 'San Martín Department', 173),
	(3695, 'Lima Province', 173),
	(3696, 'Tacna Department', 173),
	(3697, 'Piura Department', 173),
	(3698, 'Moquegua Department', 173),
	(3699, 'Apurímac Department', 173),
	(3700, 'Ica Department', 173),
	(3701, 'Callao Constitutional Province', 173),
	(3702, 'Lambayeque Department', 173),
	(3703, 'Redonda', 10),
	(3704, 'Saint Peter Parish', 10),
	(3705, 'Saint Paul Parish', 10),
	(3706, 'Saint John Parish', 10),
	(3707, 'Saint Mary Parish', 10),
	(3708, 'Barbuda', 10),
	(3709, 'Saint George Parish', 10),
	(3710, 'Saint Philip Parish', 10),
	(3711, 'South Bačka District', 196),
	(3712, 'Pirot District', 196),
	(3713, 'South Banat District', 196),
	(3714, 'North Bačka District', 196),
	(3715, 'Jablanica District', 196),
	(3716, 'Central Banat District', 196),
	(3717, 'Bor District', 196),
	(3718, 'Toplica District', 196),
	(3719, 'Mačva District', 196),
	(3720, 'Rasina District', 196),
	(3721, 'Pčinja District', 196),
	(3722, 'Nišava District', 196),
	(3723, 'Prizren District (Kosovo)', 248),
	(3724, 'Kolubara District', 196),
	(3725, 'Raška District', 196),
	(3726, 'West Bačka District', 196),
	(3727, 'Moravica District', 196),
	(3728, 'Belgrade City', 196),
	(3729, 'Zlatibor District', 196),
	(3731, 'Zaječar District', 196),
	(3732, 'Braničevo District', 196),
	(3733, 'Vojvodina', 196),
	(3734, 'Šumadija District', 196),
	(3736, 'North Banat District', 196),
	(3737, 'Pomoravlje District', 196),
	(3738, 'Peć District (Kosovo)', 248),
	(3740, 'Srem District', 196),
	(3741, 'Podunavlje District', 196),
	(3742, 'Westmoreland Parish', 108),
	(3743, 'Saint Elizabeth Parish', 108),
	(3744, 'Saint Ann Parish', 108),
	(3745, 'Saint James Parish', 108),
	(3746, 'Saint Catherine Parish', 108),
	(3747, 'Saint Mary Parish', 108),
	(3748, 'Kingston Parish', 108),
	(3749, 'Hanover Parish', 108),
	(3750, 'Saint Thomas Parish', 108),
	(3751, 'Saint Andrew Parish', 108),
	(3752, 'Portland Parish', 108),
	(3753, 'Clarendon Parish', 108),
	(3754, 'Manchester Parish', 108),
	(3755, 'Trelawny Parish', 108),
	(3756, 'Dennery Quarter', 186),
	(3757, 'Anse la Raye Quarter', 186),
	(3758, 'Castries Quarter', 186),
	(3759, 'Laborie Quarter', 186),
	(3760, 'Choiseul Quarter', 186),
	(3761, 'Canaries Quarter', 186),
	(3762, 'Micoud Quarter', 186),
	(3763, 'Vieux Fort Quarter', 186),
	(3764, 'Soufrière Quarter', 186),
	(3765, 'Praslin Quarter', 186),
	(3766, 'Gros Islet Quarter', 186),
	(3767, 'Dauphin Quarter (historical)', 186),
	(3768, 'Hưng Yên Province', 240),
	(3769, 'Đồng Tháp Province', 240),
	(3770, 'Bà Rịa-Vũng Tàu Province', 240),
	(3771, 'Thanh Hóa Province', 240),
	(3772, 'Kon Tum Province', 240),
	(3773, 'Điện Biên Province', 240),
	(3774, 'Vĩnh Phúc Province', 240),
	(3775, 'Thái Bình Province', 240),
	(3776, 'Quảng Nam Province', 240),
	(3777, 'Hậu Giang Province', 240),
	(3778, 'Cà Mau Province', 240),
	(3779, 'Hà Giang Province', 240),
	(3780, 'Nghệ An Province', 240),
	(3781, 'Tiền Giang Province', 240),
	(3782, 'Cao Bằng Province', 240),
	(3783, 'Hải Phòng Municipality', 240),
	(3784, 'Yên Bái Province', 240),
	(3785, 'Bình Dương Province', 240),
	(3786, 'Ninh Bình Province', 240),
	(3787, 'Bình Thuận Province', 240),
	(3788, 'Ninh Thuận Province', 240),
	(3789, 'Nam Định Province', 240),
	(3790, 'Vĩnh Long Province', 240),
	(3791, 'Bắc Ninh Province', 240),
	(3792, 'Lạng Sơn Province', 240),
	(3793, 'Khánh Hòa Province', 240),
	(3794, 'An Giang Province', 240),
	(3795, 'Tuyên Quang Province', 240),
	(3796, 'Bến Tre Province', 240),
	(3797, 'Bình Phước Province', 240),
	(3798, 'Thừa Thiên Huế Province', 240),
	(3799, 'Hòa Bình Province', 240),
	(3800, 'Kiên Giang Province', 240),
	(3801, 'Phú Thọ Province', 240),
	(3802, 'Hà Nam Province', 240),
	(3803, 'Quảng Trị Province', 240),
	(3804, 'Bạc Liêu Province', 240),
	(3805, 'Trà Vinh Province', 240),
	(3806, 'Đà Nẵng Municipality', 240),
	(3807, 'Thái Nguyên Province', 240),
	(3808, 'Long An Province', 240),
	(3809, 'Quảng Bình Province', 240),
	(3810, 'Hà Nội Municipality', 240),
	(3811, 'Hồ Chí Minh City Municipality', 240),
	(3812, 'Sơn La Province', 240),
	(3813, 'Gia Lai Province', 240),
	(3814, 'Quảng Ninh Province', 240),
	(3815, 'Bắc Giang Province', 240),
	(3816, 'Hà Tĩnh Province', 240),
	(3817, 'Lào Cai Province', 240),
	(3818, 'Lâm Đồng Province', 240),
	(3819, 'Sóc Trăng Province', 240),
	(3820, 'Hà Tây Province (historical)', 240),
	(3821, 'Đồng Nai Province', 240),
	(3822, 'Bắc Kạn Province', 240),
	(3823, 'Đắk Nông Province', 240),
	(3824, 'Phú Yên Province', 240),
	(3825, 'Lai Châu Province', 240),
	(3826, 'Tây Ninh Province', 240),
	(3827, 'Hải Dương Province', 240),
	(3828, 'Quảng Ngãi Province', 240),
	(3829, 'Đắk Lắk Province', 240),
	(3830, 'Bình Định Province', 240),
	(3831, 'Saint Peter Basseterre Parish', 185),
	(3832, 'Nevis', 185),
	(3833, 'Christ Church Nichola Town Parish', 185),
	(3834, 'Saint Paul Capisterre Parish', 185),
	(3835, 'Saint James Windward Parish', 185),
	(3836, 'Saint Anne Sandy Point Parish', 185),
	(3837, 'Saint George Gingerland Parish', 185),
	(3838, 'Saint Paul Charlestown Parish', 185),
	(3839, 'Saint Thomas Lowland Parish', 185),
	(3840, 'Saint John Figtree Parish', 185),
	(3841, 'Saint Kitts', 185),
	(3842, 'Saint Thomas Middle Island Parish', 185),
	(3843, 'Trinity Palmetto Point Parish', 185),
	(3844, 'Saint Mary Cayon Parish', 185),
	(3845, 'Saint John Capisterre Parish', 185),
	(3846, 'Daegu Metropolitan City', 116),
	(3847, 'Gyeonggi Province', 116),
	(3848, 'Incheon Metropolitan City', 116),
	(3849, 'Seoul Special City', 116),
	(3850, 'Daejeon Metropolitan City', 116),
	(3851, 'North Jeolla Province', 116),
	(3852, 'Ulsan Metropolitan City', 116),
	(3853, 'Jeju Special Self-Governing Province', 116),
	(3854, 'North Chungcheong Province', 116),
	(3855, 'North Gyeongsang Province', 116),
	(3856, 'South Jeolla Province', 116),
	(3857, 'South Gyeongsang Province', 116),
	(3858, 'Gwangju Metropolitan City', 116),
	(3859, 'South Chungcheong Province', 116),
	(3860, 'Busan Metropolitan City', 116),
	(3861, 'Sejong Special Self-Governing City', 116),
	(3862, 'Gangwon Special Self-Governing Province', 116),
	(3863, 'Saint Patrick Parish', 87),
	(3864, 'Saint George Parish', 87),
	(3865, 'Saint Andrew Parish', 87),
	(3866, 'Saint Mark Parish', 87),
	(3867, 'Carriacou and Petite Martinique', 87),
	(3868, 'Saint John Parish', 87),
	(3869, 'Saint David Parish', 87),
	(3870, 'Ghazni Province', 1),
	(3871, 'Badghis Province', 1),
	(3872, 'Bamyan Province', 1),
	(3873, 'Helmand Province', 1),
	(3874, 'Zabul Province', 1),
	(3875, 'Baghlan Province', 1),
	(3876, 'Kunar Province', 1),
	(3877, 'Paktika Province', 1),
	(3878, 'Khost Province', 1),
	(3879, 'Kapisa Province', 1),
	(3880, 'Nuristan Province', 1),
	(3881, 'Panjshir Province', 1),
	(3882, 'Nangarhar Province', 1),
	(3883, 'Samangan Province', 1),
	(3884, 'Balkh Province', 1),
	(3885, 'Sar-e Pol Province', 1),
	(3886, 'Jowzjan Province', 1),
	(3887, 'Herat Province', 1),
	(3888, 'Ghōr Province', 1),
	(3889, 'Faryab Province', 1),
	(3890, 'Kandahar Province', 1),
	(3891, 'Laghman Province', 1),
	(3892, 'Daykundi Province', 1),
	(3893, 'Takhar Province', 1),
	(3894, 'Paktia Province', 1),
	(3895, 'Parwan Province', 1),
	(3896, 'Nimruz Province', 1),
	(3897, 'Logar Province', 1),
	(3898, 'Urozgan Province', 1),
	(3899, 'Farah Province', 1),
	(3900, 'Kunduz Province', 1),
	(3901, 'Badakhshan Province', 1),
	(3902, 'Kabul Province', 1),
	(3903, 'Victoria', 14),
	(3904, 'South Australia', 14),
	(3905, 'Queensland', 14),
	(3906, 'Western Australia', 14),
	(3907, 'Australian Capital Territory', 14),
	(3908, 'Tasmania', 14),
	(3909, 'New South Wales', 14),
	(3910, 'Northern Territory', 14),
	(3911, 'Vavaʻu', 222),
	(3912, 'Tongatapu', 222),
	(3913, 'Haʻapai', 222),
	(3914, 'Niuas', 222),
	(3915, 'ʻEua', 222),
	(3916, 'Markazi Province', 103),
	(3917, 'Khuzestan Province', 103),
	(3918, 'Ilam Province', 103),
	(3919, 'Kermanshah Province', 103),
	(3920, 'Gilan Province', 103),
	(3921, 'Chaharmahal and Bakhtiari Province', 103),
	(3922, 'Qom Province', 103),
	(3923, 'Isfahan Province', 103),
	(3924, 'West Azerbaijan Province', 103),
	(3925, 'Zanjan Province', 103),
	(3926, 'Kohgiluyeh and Boyer-Ahmad Province', 103),
	(3927, 'Razavi Khorasan Province', 103),
	(3928, 'Lorestan Province', 103),
	(3929, 'Alborz Province', 103),
	(3930, 'South Khorasan Province', 103),
	(3931, 'Sistan and Baluchestan Province', 103),
	(3932, 'Bushehr Province', 103),
	(3933, 'Golestan Province', 103),
	(3934, 'Ardabil Province', 103),
	(3935, 'Kurdistan Province', 103),
	(3936, 'Yazd Province', 103),
	(3937, 'Hormozgan Province', 103),
	(3938, 'Mazandaran Province', 103),
	(3939, 'Fars Province', 103),
	(3940, 'Semnan Province', 103),
	(3941, 'Qazvin Province', 103),
	(3942, 'North Khorasan Province', 103),
	(3943, 'Kerman Province', 103),
	(3944, 'East Azerbaijan Province', 103),
	(3945, 'Tehran Province', 103),
	(3946, 'Niutao', 228),
	(3947, 'Nanumanga', 228),
	(3948, 'Nui', 228),
	(3949, 'Nanumea', 228),
	(3950, 'Vaitupu', 228),
	(3951, 'Funafuti', 228),
	(3952, 'Nukufetau', 228),
	(3953, 'Nukulaelae', 228),
	(3954, 'Dhi Qar Governorate', 104),
	(3955, 'Babylon Governorate', 104),
	(3956, 'Al-Qādisiyyah Governorate', 104),
	(3957, 'Karbala Governorate', 104),
	(3958, 'Al Muthanna Governorate', 104),
	(3959, 'Baghdad Governorate', 104),
	(3960, 'Basra Governorate', 104),
	(3961, 'Saladin Governorate', 104),
	(3962, 'Najaf Governorate', 104),
	(3963, 'Nineveh Governorate', 104),
	(3964, 'Al Anbar Governorate', 104),
	(3965, 'Diyala Governorate', 104),
	(3966, 'Maysan Governorate', 104),
	(3967, 'Dohuk Governorate', 104),
	(3968, 'Erbil Governorate', 104),
	(3969, 'Sulaymaniyah Governorate', 104),
	(3970, 'Wasit Governorate', 104),
	(3971, 'Kirkuk Governorate', 104),
	(3972, 'Svay Rieng Province', 37),
	(3973, 'Preah Vihear Province', 37),
	(3974, 'Prey Veng Province', 37),
	(3975, 'Takéo Province', 37),
	(3976, 'Battambang Province', 37),
	(3977, 'Pursat Province', 37),
	(3978, 'Kep Province', 37),
	(3979, 'Kampong Chhnang Province', 37),
	(3980, 'Pailin Province', 37),
	(3981, 'Kampot Province', 37),
	(3982, 'Koh Kong Province', 37),
	(3983, 'Kandal Province', 37),
	(3984, 'Banteay Meanchey Province', 37),
	(3985, 'Mondulkiri Province', 37),
	(3986, 'Kratié Province', 37),
	(3987, 'Oddar Meanchey Province', 37),
	(3988, 'Kampong Speu Province', 37),
	(3989, 'Preah Sihanouk Province', 37),
	(3990, 'Ratanakiri Province', 37),
	(3991, 'Kampong Cham Province', 37),
	(3992, 'Siem Reap Province', 37),
	(3993, 'Stung Treng Province', 37),
	(3994, 'Phnom Penh', 37),
	(3995, 'North Hamgyong Province', 115),
	(3996, 'Ryanggang Province', 115),
	(3997, 'South Pyongan Province', 115),
	(3998, 'Chagang Province', 115),
	(3999, 'Kangwon Province', 115),
	(4000, 'South Hamgyong Province', 115),
	(4001, 'Rason Special City', 115),
	(4002, 'North Pyongan Province', 115),
	(4003, 'South Hwanghae Province', 115),
	(4004, 'North Hwanghae Province', 115),
	(4005, 'Pyongyang Directly Governed City', 115),
	(4006, 'Meghalaya', 101),
	(4007, 'Haryana', 101),
	(4008, 'Maharashtra', 101),
	(4009, 'Goa', 101),
	(4010, 'Manipur', 101),
	(4011, 'Puducherry', 101),
	(4012, 'Telangana', 101),
	(4013, 'Odisha', 101),
	(4014, 'Rajasthan', 101),
	(4015, 'Punjab', 101),
	(4016, 'Uttarakhand', 101),
	(4017, 'Andhra Pradesh', 101),
	(4018, 'Nagaland', 101),
	(4019, 'Lakshadweep', 101),
	(4020, 'Himachal Pradesh', 101),
	(4021, 'National Capital Territory of Delhi', 101),
	(4022, 'Uttar Pradesh', 101),
	(4023, 'Andaman and Nicobar Islands', 101),
	(4024, 'Arunachal Pradesh', 101),
	(4025, 'Jharkhand', 101),
	(4026, 'Karnataka', 101),
	(4027, 'Assam', 101),
	(4028, 'Kerala', 101),
	(4029, 'Jammu and Kashmir', 101),
	(4030, 'Gujarat', 101),
	(4031, 'Chandigarh', 101),
	(4032, 'Dadra and Nagar Haveli and Daman and Diu', 101),
	(4033, 'Dadra and Nagar Haveli and Daman and Diu', 101),
	(4034, 'Sikkim', 101),
	(4035, 'Tamil Nadu', 101),
	(4036, 'Mizoram', 101),
	(4037, 'Bihar', 101),
	(4038, 'Tripura', 101),
	(4039, 'Madhya Pradesh', 101),
	(4040, 'Chhattisgarh', 101),
	(4041, 'Choluteca Department', 97),
	(4042, 'Comayagua Department', 97),
	(4043, 'El Paraíso Department', 97),
	(4044, 'Intibucá Department', 97),
	(4045, 'Bay Islands Department', 97),
	(4046, 'Cortés Department', 97),
	(4047, 'Atlántida Department', 97),
	(4048, 'Gracias a Dios Department', 97),
	(4049, 'Copán Department', 97),
	(4050, 'Olancho Department', 97),
	(4051, 'Colón Department', 97),
	(4052, 'Francisco Morazán Department', 97),
	(4053, 'Santa Bárbara Department', 97),
	(4054, 'Lempira Department', 97),
	(4055, 'Valle Department', 97),
	(4056, 'Ocotepeque Department', 97),
	(4057, 'Yoro Department', 97),
	(4058, 'La Paz Department', 97),
	(4059, 'Northland Region', 158),
	(4060, 'Manawatū-Whanganui Region', 158),
	(4061, 'Waikato Region', 158),
	(4062, 'Otago Region', 158),
	(4063, 'Marlborough Region', 158),
	(4064, 'West Coast Region', 158),
	(4065, 'Wellington Region', 158),
	(4066, 'Canterbury Region', 158),
	(4067, 'Chatham Islands Territory', 158),
	(4068, 'Gisborne District', 158),
	(4069, 'Taranaki Region', 158),
	(4070, 'Nelson Region', 158),
	(4071, 'Southland Region', 158),
	(4072, 'Auckland Region', 158),
	(4073, 'Tasman District', 158),
	(4074, 'Bay of Plenty Region', 158),
	(4075, 'Hawke''s Bay Region', 158),
	(4076, 'Saint John Parish', 61),
	(4077, 'Saint Mark Parish', 61),
	(4078, 'Saint David Parish', 61),
	(4079, 'Saint George Parish', 61),
	(4080, 'Saint Patrick Parish', 61),
	(4081, 'Saint Peter Parish', 61),
	(4082, 'Saint Andrew Parish', 61),
	(4083, 'Saint Luke Parish', 61),
	(4084, 'Saint Paul Parish', 61),
	(4085, 'Saint Joseph Parish', 61),
	(4086, 'El Seibo Province', 62),
	(4087, 'La Romana Province', 62),
	(4088, 'Sánchez Ramírez Province', 62),
	(4089, 'Hermanas Mirabal Province', 62),
	(4090, 'Barahona Province', 62),
	(4091, 'San Cristóbal Province', 62),
	(4092, 'Puerto Plata Province', 62),
	(4093, 'Santo Domingo Province', 62),
	(4094, 'María Trinidad Sánchez Province', 62),
	(4095, 'Distrito Nacional', 62),
	(4096, 'Peravia Province', 62),
	(4097, 'Independencia Province', 62),
	(4098, 'San Juan Province', 62),
	(4099, 'Monseñor Nouel Province', 62),
	(4100, 'Santiago Rodríguez Province', 62),
	(4101, 'Pedernales Province', 62),
	(4102, 'Espaillat Province', 62),
	(4103, 'Samaná Province', 62),
	(4104, 'Valverde Province', 62),
	(4105, 'Bahoruco Province', 62),
	(4106, 'Hato Mayor Province', 62),
	(4107, 'Dajabón Province', 62),
	(4108, 'Santiago Province', 62),
	(4109, 'La Altagracia Province', 62),
	(4110, 'San Pedro de Macorís Province', 62),
	(4111, 'Monte Plata Province', 62),
	(4112, 'San José de Ocoa Province', 62),
	(4113, 'Duarte Province', 62),
	(4114, 'Azua Province', 62),
	(4115, 'Monte Cristi Province', 62),
	(4116, 'La Vega Province', 62),
	(4117, 'Nord Department', 95),
	(4118, 'Nippes Department', 95),
	(4119, 'Grand''Anse Department', 95),
	(4120, 'Ouest Department', 95),
	(4121, 'Nord-Est Department', 95),
	(4122, 'Sud Department', 95),
	(4123, 'Artibonite Department', 95),
	(4124, 'Sud-Est Department', 95),
	(4125, 'Centre Department', 95),
	(4126, 'Nord-Ouest Department', 95),
	(4127, 'San Vicente Department', 66),
	(4128, 'Santa Ana Department', 66),
	(4129, 'Usulután Department', 66),
	(4130, 'Morazán Department', 66),
	(4131, 'Chalatenango Department', 66),
	(4132, 'Cabañas Department', 66),
	(4133, 'San Salvador Department', 66),
	(4134, 'La Libertad Department', 66),
	(4135, 'San Miguel Department', 66),
	(4136, 'La Paz Department', 66),
	(4137, 'Cuscatlán Department', 66),
	(4138, 'La Unión Department', 66),
	(4139, 'Ahuachapán Department', 66),
	(4140, 'Sonsonate Department', 66),
	(4141, 'Braslovče Municipality', 201),
	(4142, 'Lenart Municipality', 201),
	(4143, 'Oplotnica Municipality', 201),
	(4144, 'Velike Lašče Municipality', 201),
	(4145, 'Hajdina Municipality', 201),
	(4146, 'Podčetrtek Municipality', 201),
	(4147, 'Cankova Municipality', 201),
	(4148, 'Vitanje Municipality', 201),
	(4149, 'Sežana Municipality', 201),
	(4150, 'Kidričevo Municipality', 201),
	(4151, 'Črenšovci Municipality', 201),
	(4152, 'Idrija Municipality', 201),
	(4153, 'Trnovska Vas Municipality', 201),
	(4154, 'Vodice Municipality', 201),
	(4155, 'Ravne na Koroškem Municipality', 201),
	(4156, 'Lovrenc na Pohorju Municipality', 201),
	(4157, 'Majšperk Municipality', 201),
	(4158, 'Loški Potok Municipality', 201),
	(4159, 'Domžale Municipality', 201),
	(4160, 'Rečica ob Savinji Municipality', 201),
	(4161, 'Podlehnik Municipality', 201),
	(4162, 'Cerknica Municipality', 201),
	(4163, 'Vransko Municipality', 201),
	(4164, 'Sveta Ana Municipality', 201),
	(4165, 'Brezovica Municipality', 201),
	(4166, 'Benedikt Municipality', 201),
	(4167, 'Divača Municipality', 201),
	(4168, 'Moravče Municipality', 201),
	(4169, 'Slovenj Gradec City Municipality', 201),
	(4170, 'Škocjan Municipality', 201),
	(4171, 'Šentjur Municipality', 201),
	(4172, 'Pesnica Municipality', 201),
	(4173, 'Dol pri Ljubljani Municipality', 201),
	(4174, 'Loška Dolina Municipality', 201),
	(4175, 'Hoče–Slivnica Municipality', 201),
	(4176, 'Cerkvenjak Municipality', 201),
	(4177, 'Naklo Municipality', 201),
	(4178, 'Cerkno Municipality', 201),
	(4179, 'Bistrica ob Sotli Municipality', 201),
	(4180, 'Kamnik Municipality', 201),
	(4181, 'Bovec Municipality', 201),
	(4182, 'Zavrč Municipality', 201),
	(4183, 'Ajdovščina Municipality', 201),
	(4184, 'Pivka Municipality', 201),
	(4185, 'Štore Municipality', 201),
	(4186, 'Kozje Municipality', 201),
	(4187, 'Škofljica Municipality', 201),
	(4188, 'Prebold Municipality', 201),
	(4189, 'Dobrovnik Municipality', 201),
	(4190, 'Mozirje Municipality', 201),
	(4191, 'Celje City Municipality', 201),
	(4192, 'Žiri Municipality', 201),
	(4193, 'Horjul Municipality', 201),
	(4194, 'Tabor Municipality', 201),
	(4195, 'Radeče Municipality', 201),
	(4196, 'Vipava Municipality', 201),
	(4197, 'Kungota Municipality', 201),
	(4198, 'Slovenske Konjice Municipality', 201),
	(4199, 'Osilnica Municipality', 201),
	(4200, 'Borovnica Municipality', 201),
	(4201, 'Piran Municipality', 201),
	(4202, 'Bled Municipality', 201),
	(4203, 'Jezersko Municipality', 201),
	(4204, 'Rače–Fram Municipality', 201),
	(4205, 'Nova Gorica City Municipality', 201),
	(4206, 'Razkrižje Municipality', 201),
	(4207, 'Ribnica na Pohorju Municipality', 201),
	(4208, 'Muta Municipality', 201),
	(4209, 'Rogatec Municipality', 201),
	(4210, 'Gorišnica Municipality', 201),
	(4211, 'Kuzma Municipality', 201),
	(4212, 'Mislinja Municipality', 201),
	(4213, 'Duplek Municipality', 201),
	(4214, 'Trebnje Municipality', 201),
	(4215, 'Brežice Municipality', 201),
	(4216, 'Dobrepolje Municipality', 201),
	(4217, 'Grad Municipality', 201),
	(4218, 'Moravske Toplice Municipality', 201),
	(4219, 'Luče Municipality', 201),
	(4220, 'Miren–Kostanjevica Municipality', 201),
	(4221, 'Ormož Municipality', 201),
	(4222, 'Šalovci Municipality', 201),
	(4223, 'Miklavž na Dravskem Polju Municipality', 201),
	(4224, 'Makole Municipality', 201),
	(4225, 'Lendava Municipality', 201),
	(4226, 'Vuzenica Municipality', 201),
	(4227, 'Kanal ob Soči Municipality', 201),
	(4228, 'Ptuj City Municipality', 201),
	(4229, 'Sveti Andraž v Slovenskih Goricah Municipality', 201),
	(4230, 'Selnica ob Dravi Municipality', 201),
	(4231, 'Radovljica Municipality', 201),
	(4232, 'Črna na Koroškem Municipality', 201),
	(4233, 'Rogaška Slatina Municipality', 201),
	(4234, 'Podvelka Municipality', 201),
	(4235, 'Ribnica Municipality', 201),
	(4236, 'Novo Mesto City Municipality', 201),
	(4237, 'Mirna Peč Municipality', 201),
	(4238, 'Križevci Municipality', 201),
	(4239, 'Poljčane Municipality', 201),
	(4240, 'Brda Municipality', 201),
	(4241, 'Šentjernej Municipality', 201),
	(4242, 'Maribor City Municipality', 201),
	(4243, 'Kobarid Municipality', 201),
	(4244, 'Markovci Municipality', 201),
	(4245, 'Vojnik Municipality', 201),
	(4246, 'Trbovlje Municipality', 201),
	(4247, 'Tolmin Municipality', 201),
	(4248, 'Šoštanj Municipality', 201),
	(4249, 'Žetale Municipality', 201),
	(4250, 'Tržič Municipality', 201),
	(4251, 'Turnišče Municipality', 201),
	(4252, 'Dobrna Municipality', 201),
	(4253, 'Renče–Vogrsko Municipality', 201),
	(4254, 'Kostanjevica na Krki Municipality', 201),
	(4255, 'Sveti Jurij ob Ščavnici Municipality', 201),
	(4256, 'Železniki Municipality', 201),
	(4257, 'Veržej Municipality', 201),
	(4258, 'Žalec Municipality', 201),
	(4259, 'Starše Municipality', 201),
	(4260, 'Sveta Trojica v Slovenskih Goricah Municipality', 201),
	(4261, 'Solčava Municipality', 201),
	(4262, 'Vrhnika Municipality', 201),
	(4263, 'Središče ob Dravi Municipality', 201),
	(4264, 'Rogašovci Municipality', 201),
	(4265, 'Mežica Municipality', 201),
	(4266, 'Juršinci Municipality', 201),
	(4267, 'Velika Polana Municipality', 201),
	(4268, 'Sevnica Municipality', 201),
	(4269, 'Zagorje ob Savi Municipality', 201),
	(4270, 'Ljubljana City Municipality', 201),
	(4271, 'Gornji Petrovci Municipality', 201),
	(4272, 'Polzela Municipality', 201),
	(4273, 'Sveti Tomaž Municipality', 201),
	(4274, 'Prevalje Municipality', 201),
	(4275, 'Radlje ob Dravi Municipality', 201),
	(4276, 'Žirovnica Municipality', 201),
	(4277, 'Sodražica Municipality', 201),
	(4278, 'Bloke Municipality', 201),
	(4279, 'Šmartno pri Litiji Municipality', 201),
	(4280, 'Ruše Municipality', 201),
	(4281, 'Dolenjske Toplice Municipality', 201),
	(4282, 'Bohinj Municipality', 201),
	(4283, 'Komenda Municipality', 201),
	(4284, 'Gorje Municipality', 201),
	(4285, 'Šmarje pri Jelšah Municipality', 201),
	(4286, 'Ig Municipality', 201),
	(4287, 'Kranj City Municipality', 201),
	(4288, 'Puconci Municipality', 201),
	(4289, 'Šmarješke Toplice Municipality', 201),
	(4290, 'Dornava Municipality', 201),
	(4291, 'Črnomelj Municipality', 201),
	(4292, 'Radenci Municipality', 201),
	(4293, 'Gorenja Vas–Poljane Municipality', 201),
	(4294, 'Ljubno Municipality', 201),
	(4295, 'Dobje Municipality', 201),
	(4296, 'Šmartno ob Paki Municipality', 201),
	(4297, 'Mokronog–Trebelno Municipality', 201),
	(4298, 'Mirna Municipality', 201),
	(4299, 'Šenčur Municipality', 201),
	(4300, 'Videm Municipality', 201),
	(4301, 'Beltinci Municipality', 201),
	(4302, 'Lukovica Municipality', 201),
	(4303, 'Preddvor Municipality', 201),
	(4304, 'Destrnik Municipality', 201),
	(4305, 'Ivančna Gorica Municipality', 201),
	(4306, 'Log–Dragomer Municipality', 201),
	(4307, 'Žužemberk Municipality', 201),
	(4308, 'Dobrova–Polhov Gradec Municipality', 201),
	(4309, 'Cirkulane Municipality', 201),
	(4310, 'Cerklje na Gorenjskem Municipality', 201),
	(4311, 'Šentrupert Municipality', 201),
	(4312, 'Tišina Municipality', 201),
	(4313, 'Murska Sobota City Municipality', 201),
	(4314, 'Krško Municipality', 201),
	(4315, 'Komen Municipality', 201),
	(4316, 'Škofja Loka Municipality', 201),
	(4317, 'Šempeter–Vrtojba Municipality', 201),
	(4318, 'Apače Municipality', 201),
	(4319, 'Koper City Municipality', 201),
	(4320, 'Odranci Municipality', 201),
	(4321, 'Hrpelje–Kozina Municipality', 201),
	(4322, 'Izola Municipality', 201),
	(4323, 'Metlika Municipality', 201),
	(4324, 'Šentilj Municipality', 201),
	(4325, 'Kobilje Municipality', 201),
	(4326, 'Ankaran Municipality', 201),
	(4327, 'Hodoš Municipality', 201),
	(4328, 'Sveti Jurij v Slovenskih Goricah Municipality', 201),
	(4329, 'Nazarje Municipality', 201),
	(4330, 'Postojna Municipality', 201),
	(4331, 'Kostel Municipality', 201),
	(4332, 'Slovenska Bistrica Municipality', 201),
	(4333, 'Straža Municipality', 201),
	(4334, 'Trzin Municipality', 201),
	(4335, 'Kočevje Municipality', 201),
	(4336, 'Grosuplje Municipality', 201),
	(4337, 'Jesenice Municipality', 201),
	(4338, 'Laško Municipality', 201),
	(4339, 'Gornji Grad Municipality', 201),
	(4340, 'Kranjska Gora Municipality', 201),
	(4341, 'Hrastnik Municipality', 201),
	(4342, 'Zreče Municipality', 201),
	(4343, 'Gornja Radgona Municipality', 201),
	(4344, 'Ilirska Bistrica Municipality', 201),
	(4345, 'Dravograd Municipality', 201),
	(4346, 'Semič Municipality', 201),
	(4347, 'Litija Municipality', 201),
	(4348, 'Mengeš Municipality', 201),
	(4349, 'Medvode Municipality', 201),
	(4350, 'Logatec Municipality', 201),
	(4351, 'Ljutomer Municipality', 201),
	(4352, 'Banská Bystrica Region', 200),
	(4353, 'Košice Region', 200),
	(4354, 'Prešov Region', 200),
	(4355, 'Trnava Region', 200),
	(4356, 'Bratislava Region', 200),
	(4357, 'Nitra Region', 200),
	(4358, 'Trenčín Region', 200),
	(4359, 'Žilina Region', 200),
	(4360, 'Cimișlia District', 144),
	(4361, 'Orhei District', 144),
	(4362, 'Bender Municipality', 144),
	(4363, 'Nisporeni District', 144),
	(4364, 'Sîngerei District', 144),
	(4365, 'Căușeni District', 144),
	(4366, 'Călărași District', 144),
	(4367, 'Glodeni District', 144),
	(4368, 'Anenii Noi District', 144),
	(4369, 'Ialoveni District', 144),
	(4370, 'Florești District', 144),
	(4371, 'Telenești District', 144),
	(4372, 'Taraclia District', 144),
	(4373, 'Chișinău Municipality', 144),
	(4374, 'Soroca District', 144),
	(4375, 'Briceni District', 144),
	(4376, 'Rîșcani District', 144),
	(4377, 'Strășeni District', 144),
	(4378, 'Ștefan Vodă District', 144),
	(4379, 'Basarabeasca District', 144),
	(4380, 'Cantemir District', 144),
	(4381, 'Fălești District', 144),
	(4382, 'Hîncești District', 144),
	(4383, 'Dubăsari District', 144),
	(4384, 'Dondușeni District', 144),
	(4385, 'Gagauzia Autonomous Territorial Unit', 144),
	(4386, 'Ungheni District', 144),
	(4387, 'Edineț District', 144),
	(4388, 'Șoldănești District', 144),
	(4389, 'Ocnița District', 144),
	(4390, 'Criuleni District', 144),
	(4391, 'Cahul District', 144),
	(4392, 'Drochia District', 144),
	(4393, 'Bălți Municipality', 144),
	(4394, 'Rezina District', 144),
	(4395, 'Administrative-Territorial Units of the Left Bank of the Dniester', 144),
	(4396, 'Salacgrīva Municipality (historical)', 120),
	(4397, 'Vecumnieki Municipality (historical)', 120),
	(4398, 'Naukšēni Municipality (historical)', 120),
	(4399, 'Ilūkste Municipality (historical)', 120),
	(4400, 'Gulbene Municipality', 120),
	(4401, 'Līvāni Municipality', 120),
	(4402, 'Salaspils Municipality', 120),
	(4403, 'Ventspils Municipality', 120),
	(4404, 'Rundāle Municipality (historical)', 120),
	(4405, 'Pļaviņas Municipality (historical)', 120),
	(4406, 'Vārkava Municipality (historical)', 120),
	(4407, 'Jaunpiebalga Municipality (historical)', 120),
	(4408, 'Sēja Municipality (historical)', 120),
	(4409, 'Tukums Municipality', 120),
	(4410, 'Cibla Municipality (historical)', 120),
	(4411, 'Burtnieki Municipality (historical)', 120),
	(4412, 'Ķegums Municipality (historical)', 120),
	(4413, 'Krustpils Municipality (historical)', 120),
	(4414, 'Cesvaine Municipality (historical)', 120),
	(4415, 'Skrīveri Municipality (historical)', 120),
	(4416, 'Ogre Municipality', 120),
	(4417, 'Olaine Municipality', 120),
	(4418, 'Limbaži Municipality', 120),
	(4419, 'Lubāna Municipality (historical)', 120),
	(4420, 'Kandava Municipality (historical)', 120),
	(4421, 'Ventspils State City', 120),
	(4422, 'Krimulda Municipality (historical)', 120),
	(4423, 'Rugāji Municipality (historical)', 120),
	(4424, 'Jelgava Municipality', 120),
	(4425, 'Valka Municipality', 120),
	(4426, 'Rūjiena Municipality (historical)', 120),
	(4427, 'Babīte Municipality (historical)', 120),
	(4428, 'Dundaga Municipality (historical)', 120),
	(4429, 'Priekule Municipality (historical)', 120),
	(4430, 'Zilupe Municipality (historical)', 120),
	(4431, 'Varakļāni Municipality', 120),
	(4432, 'Nereta Municipality (historical)', 120),
	(4433, 'Madona Municipality', 120),
	(4434, 'Sala Municipality (historical)', 120),
	(4435, 'Ķekava Municipality', 120),
	(4436, 'Nīca Municipality (historical)', 120),
	(4437, 'Dobele Municipality', 120),
	(4438, 'Jēkabpils Municipality', 120),
	(4439, 'Saldus Municipality', 120),
	(4440, 'Roja Municipality (historical)', 120),
	(4441, 'Iecava Municipality (historical)', 120),
	(4442, 'Ozolnieki Municipality (historical)', 120),
	(4443, 'Saulkrasti Municipality', 120),
	(4444, 'Ērgļi Municipality (historical)', 120),
	(4445, 'Aglona Municipality (historical)', 120),
	(4446, 'Jūrmala State City', 120),
	(4447, 'Skrunda Municipality (historical)', 120),
	(4448, 'Engure Municipality (historical)', 120),
	(4449, 'Inčukalns Municipality (historical)', 120),
	(4450, 'Mārupe Municipality', 120),
	(4451, 'Mērsrags Municipality (historical)', 120),
	(4452, 'Koknese Municipality (historical)', 120),
	(4453, 'Kārsava Municipality (historical)', 120),
	(4454, 'Carnikava Municipality (historical)', 120),
	(4455, 'Rēzekne Municipality', 120),
	(4456, 'Viesīte Municipality (historical)', 120),
	(4457, 'Ape Municipality (historical)', 120),
	(4458, 'Durbe Municipality (historical)', 120),
	(4459, 'Talsi Municipality', 120),
	(4460, 'Liepāja State City', 120),
	(4461, 'Mālpils Municipality (historical)', 120),
	(4462, 'Smiltene Municipality', 120),
	(4463, 'Daugavpils State City', 120),
	(4464, 'Jēkabpils State City', 120),
	(4465, 'Bauska Municipality', 120),
	(4466, 'Vecpiebalga Municipality (historical)', 120),
	(4467, 'Pāvilosta Municipality (historical)', 120),
	(4468, 'Brocēni Municipality (historical)', 120),
	(4469, 'Cēsis Municipality', 120),
	(4470, 'Grobiņa Municipality (historical)', 120),
	(4471, 'Beverīna Municipality (historical)', 120),
	(4472, 'Aizkraukle Municipality', 120),
	(4473, 'Valmiera State City', 120),
	(4474, 'Krāslava Municipality', 120),
	(4475, 'Jaunjelgava Municipality (historical)', 120),
	(4476, 'Sigulda Municipality', 120),
	(4477, 'Viļaka Municipality (historical)', 120),
	(4478, 'Stopiņi Municipality (historical)', 120),
	(4479, 'Rauna Municipality (historical)', 120),
	(4480, 'Tērvete Municipality (historical)', 120),
	(4481, 'Auce Municipality (historical)', 120),
	(4482, 'Baldone Municipality (historical)', 120),
	(4483, 'Preiļi Municipality', 120),
	(4484, 'Aloja Municipality (historical)', 120),
	(4485, 'Alsunga Municipality (historical)', 120),
	(4486, 'Viļāni Municipality (historical)', 120),
	(4487, 'Alūksne Municipality', 120),
	(4488, 'Līgatne Municipality (historical)', 120),
	(4489, 'Jaunpils Municipality (historical)', 120),
	(4490, 'Kuldīga Municipality', 120),
	(4491, 'Riga State City', 120),
	(4492, 'Augšdaugava Municipality', 120),
	(4493, 'Ropaži Municipality', 120),
	(4494, 'Strenči Municipality (historical)', 120),
	(4495, 'Kocēni Municipality (historical)', 120),
	(4496, 'Aizpute Municipality (historical)', 120),
	(4497, 'Amata Municipality (historical)', 120),
	(4498, 'Baltinava Municipality (historical)', 120),
	(4499, 'Aknīste Municipality (historical)', 120),
	(4500, 'Jelgava State City', 120),
	(4501, 'Ludza Municipality', 120),
	(4502, 'Riebiņi Municipality (historical)', 120),
	(4503, 'Rucava Municipality (historical)', 120),
	(4504, 'Dagda Municipality (historical)', 120),
	(4505, 'Balvi Municipality', 120),
	(4506, 'Priekuļi Municipality (historical)', 120),
	(4507, 'Pārgauja Municipality (historical)', 120),
	(4508, 'Vaiņode Municipality (historical)', 120),
	(4509, 'Rēzekne State City', 120),
	(4510, 'Garkalne Municipality (historical)', 120),
	(4511, 'Ikšķile Municipality (historical)', 120),
	(4512, 'Lielvārde Municipality (historical)', 120),
	(4513, 'Mazsalaca Municipality (historical)', 120),
	(4514, 'Viqueque Municipality', 63),
	(4515, 'Liquiçá Municipality', 63),
	(4516, 'Ermera Municipality', 63),
	(4517, 'Manatuto Municipality', 63),
	(4518, 'Ainaro Municipality', 63),
	(4519, 'Manufahi Municipality', 63),
	(4520, 'Aileu Municipality', 63),
	(4521, 'Baucau Municipality', 63),
	(4522, 'Cova Lima Municipality', 63),
	(4523, 'Lautém Municipality', 63),
	(4524, 'Dili Municipality', 63),
	(4525, 'Bobonaro Municipality', 63),
	(4526, 'Peleliu', 168),
	(4527, 'Ngardmau', 168),
	(4528, 'Airai', 168),
	(4529, 'Hatohobei', 168),
	(4530, 'Melekeok', 168),
	(4531, 'Ngatpang', 168),
	(4532, 'Koror', 168),
	(4533, 'Ngarchelong', 168),
	(4534, 'Ngiwal', 168),
	(4535, 'Sonsorol', 168),
	(4536, 'Ngchesar', 168),
	(4537, 'Ngaraard', 168),
	(4538, 'Angaur', 168),
	(4539, 'Kayangel', 168),
	(4540, 'Aimeliik', 168),
	(4541, 'Ngeremlengui', 168),
	(4542, 'Břeclav District', 58),
	(4543, 'Český Krumlov District', 58),
	(4544, 'Plzeň-City District', 58),
	(4545, 'Brno-Country District', 58),
	(4546, 'Příbram District', 58),
	(4547, 'Pardubice District', 58),
	(4548, 'Nový Jičín District', 58),
	(4549, 'Prague 12 District', 58),
	(4550, 'Náchod District', 58),
	(4551, 'Prostějov District', 58),
	(4552, 'Zlín Region', 58),
	(4553, 'Chomutov District', 58),
	(4554, 'Central Bohemian Region', 58),
	(4555, 'Prague 13 District', 58),
	(4556, 'České Budějovice District', 58),
	(4557, 'Prague 5 District', 58),
	(4558, 'Rakovník District', 58),
	(4559, 'Frýdek-Místek District', 58),
	(4560, 'Písek District', 58),
	(4561, 'Hodonín District', 58),
	(4562, 'Prague 1 District', 58),
	(4563, 'Zlín District', 58),
	(4564, 'Plzeň-North District', 58),
	(4565, 'Tábor District', 58),
	(4566, 'Prague 9 District', 58),
	(4567, 'Prague 16 District', 58),
	(4568, 'Brno-City District', 58),
	(4569, 'Prague 6 District', 58),
	(4570, 'Prague 11 District', 58),
	(4571, 'Svitavy District', 58),
	(4572, 'Vsetín District', 58),
	(4573, 'Cheb District', 58),
	(4574, 'Olomouc District', 58),
	(4575, 'Vysočina Region', 58),
	(4576, 'Ústí nad Labem Region', 58),
	(4577, 'Prague 20 District (Horní Počernice)', 58),
	(4578, 'Prachatice District', 58),
	(4579, 'Trutnov District', 58),
	(4580, 'Hradec Králové District', 58),
	(4581, 'Karlovy Vary Region', 58),
	(4582, 'Nymburk District', 58),
	(4583, 'Rokycany District', 58),
	(4584, 'Ostrava-City District', 58),
	(4585, 'Prague 14 District', 58),
	(4586, 'Karviná District', 58),
	(4587, 'Prague 4 District', 58),
	(4588, 'Pardubice Region', 58),
	(4589, 'Olomouc Region', 58),
	(4590, 'Liberec District', 58),
	(4591, 'Klatovy District', 58),
	(4592, 'Uherské Hradiště District', 58),
	(4593, 'Kroměříž District', 58),
	(4594, 'Prague 8 District', 58),
	(4595, 'Sokolov District', 58),
	(4596, 'Semily District', 58),
	(4597, 'Třebíč District', 58),
	(4598, 'Prague Capital City', 58),
	(4599, 'Ústí nad Labem District', 58),
	(4600, 'Moravian-Silesian Region', 58),
	(4601, 'Liberec Region', 58),
	(4602, 'South Moravian Region', 58),
	(4603, 'Prague 10 District', 58),
	(4604, 'Karlovy Vary District', 58),
	(4605, 'Litoměřice District', 58),
	(4606, 'Prague-East District', 58),
	(4607, 'Plzeň Region', 58),
	(4608, 'Plzeň-South District', 58),
	(4609, 'Děčín District', 58),
	(4610, 'Prague 7 District', 58),
	(4611, 'Havlíčkův Brod District', 58),
	(4612, 'Jablonec nad Nisou District', 58),
	(4613, 'Jihlava District', 58),
	(4614, 'Hradec Králové Region', 58),
	(4615, 'Blansko District', 58),
	(4616, 'Prague 2 District', 58),
	(4617, 'Louny District', 58),
	(4618, 'Kolín District', 58),
	(4619, 'Prague-West District', 58),
	(4620, 'Beroun District', 58),
	(4621, 'Teplice District', 58),
	(4622, 'Vyškov District', 58),
	(4623, 'Opava District', 58),
	(4624, 'Jindřichův Hradec District', 58),
	(4625, 'Jeseník District', 58),
	(4626, 'Přerov District', 58),
	(4627, 'Benešov District', 58),
	(4628, 'Strakonice District', 58),
	(4629, 'Most District', 58),
	(4630, 'Znojmo District', 58),
	(4631, 'Kladno District', 58),
	(4632, 'Prague 21 District (Újezd nad Lesy)', 58),
	(4633, 'Česká Lípa District', 58),
	(4634, 'Chrudim District', 58),
	(4635, 'Prague 3 District', 58),
	(4636, 'Rychnov nad Kněžnou District', 58),
	(4637, 'Prague 15 District', 58),
	(4638, 'Mělník District', 58),
	(4639, 'South Bohemian Region', 58),
	(4640, 'Jičín District', 58),
	(4641, 'Domažlice District', 58),
	(4642, 'Šumperk District', 58),
	(4643, 'Mladá Boleslav District', 58),
	(4644, 'Bruntál District', 58),
	(4645, 'Pelhřimov District', 58),
	(4646, 'Tachov District', 58),
	(4647, 'Ústí nad Orlicí District', 58),
	(4648, 'Žďár nad Sázavou District', 58),
	(4649, 'North East Community Development Council', 199),
	(4650, 'South East Community Development Council', 199),
	(4651, 'Central Singapore Community Development Council', 199),
	(4652, 'South West Community Development Council', 199),
	(4653, 'North West Community Development Council', 199),
	(4654, 'Ewa District', 153),
	(4655, 'Uaboe District', 153),
	(4656, 'Aiwo District', 153),
	(4657, 'Meneng District', 153),
	(4658, 'Anabar District', 153),
	(4659, 'Nibok District', 153),
	(4660, 'Baiti District', 153),
	(4661, 'Ijuw District', 153),
	(4662, 'Buada District', 153),
	(4663, 'Anibare District', 153),
	(4664, 'Yaren District', 153),
	(4665, 'Boe District', 153),
	(4666, 'Denigomodu District', 153),
	(4667, 'Anetan District', 153),
	(4668, 'Zhytomyr Oblast', 230),
	(4669, 'Vinnytsia Oblast', 230),
	(4670, 'Zakarpattia Oblast', 230),
	(4671, 'Kyiv Oblast', 230),
	(4672, 'Lviv Oblast', 230),
	(4673, 'Luhansk Oblast', 230),
	(4674, 'Ternopil Oblast', 230),
	(4675, 'Dnipropetrovsk Oblast', 230),
	(4676, 'Kyiv City', 230),
	(4677, 'Kirovohrad Oblast', 230),
	(4678, 'Chernivtsi Oblast', 230),
	(4679, 'Mykolaiv Oblast', 230),
	(4680, 'Cherkasy Oblast', 230),
	(4681, 'Khmelnytskyi Oblast', 230),
	(4682, 'Ivano-Frankivsk Oblast', 230),
	(4683, 'Rivne Oblast', 230),
	(4684, 'Kherson Oblast', 230),
	(4685, 'Sumy Oblast', 230),
	(4686, 'Kharkiv Oblast', 230),
	(4687, 'Zaporizhzhia Oblast', 230),
	(4688, 'Odesa Oblast', 230),
	(4689, 'Autonomous Republic of Crimea', 230),
	(4690, 'Volyn Oblast', 230),
	(4691, 'Donetsk Oblast', 230),
	(4692, 'Chernihiv Oblast', 230),
	(4693, 'Gabrovo Province', 34),
	(4694, 'Smolyan Province', 34),
	(4695, 'Pernik Province', 34),
	(4696, 'Montana Province', 34),
	(4697, 'Vidin Province', 34),
	(4698, 'Razgrad Province', 34),
	(4699, 'Blagoevgrad Province', 34),
	(4700, 'Sliven Province', 34),
	(4701, 'Plovdiv Province', 34),
	(4702, 'Kardzhali Province', 34),
	(4703, 'Kyustendil Province', 34),
	(4704, 'Haskovo Province', 34),
	(4705, 'Sofia City Province', 34),
	(4706, 'Pleven Province', 34),
	(4707, 'Stara Zagora Province', 34),
	(4708, 'Silistra Province', 34),
	(4709, 'Veliko Tarnovo Province', 34),
	(4710, 'Lovech Province', 34),
	(4711, 'Vratsa Province', 34),
	(4712, 'Pazardzhik Province', 34),
	(4713, 'Ruse Province', 34),
	(4714, 'Targovishte Province', 34),
	(4715, 'Burgas Province', 34),
	(4716, 'Yambol Province', 34),
	(4717, 'Varna Province', 34),
	(4718, 'Dobrich Province', 34),
	(4719, 'Sofia Province', 34),
	(4720, 'Suceava County', 181),
	(4721, 'Hunedoara County', 181),
	(4722, 'Argeș County', 181),
	(4723, 'Bihor County', 181),
	(4724, 'Alba County', 181),
	(4725, 'Ilfov County', 181),
	(4726, 'Giurgiu County', 181),
	(4727, 'Tulcea County', 181),
	(4728, 'Teleorman County', 181),
	(4729, 'Prahova County', 181),
	(4730, 'Bucharest Municipality', 181),
	(4731, 'Neamț County', 181),
	(4732, 'Călărași County', 181),
	(4733, 'Bistrița-Năsăud County', 181),
	(4734, 'Cluj County', 181),
	(4735, 'Iași County', 181),
	(4736, 'Brăila County', 181),
	(4737, 'Constanța County', 181),
	(4738, 'Olt County', 181),
	(4739, 'Arad County', 181),
	(4740, 'Botoșani County', 181),
	(4741, 'Sălaj County', 181),
	(4742, 'Dolj County', 181),
	(4743, 'Ialomița County', 181),
	(4744, 'Bacău County', 181),
	(4745, 'Dâmbovița County', 181),
	(4746, 'Satu Mare County', 181),
	(4747, 'Galați County', 181),
	(4748, 'Timiș County', 181),
	(4749, 'Harghita County', 181),
	(4750, 'Gorj County', 181),
	(4751, 'Mehedinți County', 181),
	(4752, 'Vaslui County', 181),
	(4753, 'Caraș-Severin County', 181),
	(4754, 'Covasna County', 181),
	(4755, 'Sibiu County', 181),
	(4756, 'Buzău County', 181),
	(4757, 'Vâlcea County', 181),
	(4758, 'Vrancea County', 181),
	(4759, 'Brașov County', 181),
	(4760, 'Mureș County', 181),
	(4761, 'Aiga-i-le-Tai District', 191),
	(4762, 'Satupa''itea District', 191),
	(4763, 'A''ana District', 191),
	(4764, 'Fa''asaleleaga District', 191),
	(4765, 'Atua District', 191),
	(4766, 'Vaisigano District', 191),
	(4767, 'Palauli District', 191),
	(4768, 'Va''a-o-Fonoti District', 191),
	(4769, 'Gaga''emauga District', 191),
	(4770, 'Tuamasaga District', 191),
	(4771, 'Gaga''ifomauga District', 191),
	(4772, 'Torba Province', 237),
	(4773, 'Penama Province', 237),
	(4774, 'Shefa Province', 237),
	(4775, 'Malampa Province', 237),
	(4776, 'Sanma Province', 237),
	(4777, 'Tafea Province', 237),
	(4778, 'Honiara Capital Territory', 202),
	(4779, 'Temotu Province', 202),
	(4780, 'Isabel Province', 202),
	(4781, 'Choiseul Province', 202),
	(4782, 'Makira-Ulawa Province', 202),
	(4783, 'Malaita Province', 202),
	(4784, 'Central Province', 202),
	(4785, 'Guadalcanal Province', 202),
	(4786, 'Western Province', 202),
	(4787, 'Rennell and Bellona Province', 202),
	(4788, 'Burgundy (historical)', 75),
	(4789, 'Auvergne (historical)', 75),
	(4790, 'Picardy (historical)', 75),
	(4791, 'Champagne-Ardenne (historical)', 75),
	(4792, 'Limousin (historical)', 75),
	(4793, 'Nord-Pas-de-Calais (historical)', 75),
	(4794, 'Saint Barthélemy', 75),
	(4795, 'Nouvelle-Aquitaine', 75),
	(4796, 'Île-de-France', 75),
	(4797, 'Mayotte', 75),
	(4798, 'Auvergne-Rhône-Alpes', 75),
	(4799, 'Occitania', 75),
	(4800, 'Alo', 75),
	(4801, 'Lorraine (historical)', 75),
	(4802, 'Pays de la Loire', 75),
	(4803, 'Languedoc-Roussillon (historical)', 75),
	(4804, 'Normandy', 75),
	(4805, 'Franche-Comté (historical)', 75),
	(4806, 'Corsica', 75),
	(4807, 'Brittany', 75),
	(4808, 'Aquitaine (historical)', 75),
	(4809, 'Saint Martin', 75),
	(4810, 'Wallis and Futuna', 75),
	(4811, 'Alsace (historical)', 75),
	(4812, 'Provence-Alpes-Côte d''Azur', 75),
	(4813, 'Rhône-Alpes (historical)', 75),
	(4814, 'Lower Normandy (historical)', 75),
	(4815, 'Poitou-Charentes (historical)', 75),
	(4816, 'Paris', 75),
	(4817, 'Uvea', 75),
	(4818, 'Centre-Val de Loire', 75),
	(4819, 'Sigave', 75),
	(4820, 'Grand Est', 75),
	(4821, 'Saint Pierre and Miquelon', 75),
	(4822, 'French Guiana', 75),
	(4823, 'Réunion', 75),
	(4824, 'French Polynesia', 75),
	(4825, 'Bourgogne-Franche-Comté', 75),
	(4826, 'Upper Normandy (historical)', 75),
	(4827, 'Martinique', 75),
	(4828, 'Hauts-de-France', 75),
	(4829, 'Guadeloupe', 75),
	(4830, 'West New Britain Province', 171),
	(4831, 'Autonomous Region of Bougainville', 171),
	(4832, 'Jiwaka Province', 171),
	(4833, 'Hela Province', 171),
	(4834, 'East New Britain Province', 171),
	(4835, 'Morobe Province', 171),
	(4836, 'Sandaun Province', 171),
	(4837, 'National Capital District', 171),
	(4838, 'Oro Province', 171),
	(4839, 'Gulf Province', 171),
	(4840, 'Western Highlands Province', 171),
	(4841, 'New Ireland Province', 171),
	(4842, 'Manus Province', 171),
	(4843, 'Madang Province', 171),
	(4844, 'Southern Highlands Province', 171),
	(4845, 'Eastern Highlands Province', 171),
	(4846, 'Chimbu Province', 171),
	(4847, 'Central Province', 171),
	(4848, 'Enga Province', 171),
	(4849, 'Milne Bay Province', 171),
	(4850, 'Western Province', 171),
	(4851, 'Ohio', 233),
	(4852, 'Ladakh', 101),
	(4853, 'West Bengal', 101),
	(4854, 'Sinop Province', 225),
	(4855, 'Capital District', 239),
	(4856, 'Apure State', 239),
	(4857, 'Jalisco', 142),
	(4858, 'Roraima', 31),
	(4859, 'Guarda District', 177),
	(4860, 'Devonshire Parish', 25),
	(4861, 'Hamilton Parish', 25),
	(4862, 'Hamilton City', 25),
	(4863, 'Paget Parish', 25),
	(4864, 'Pembroke Parish', 25),
	(4865, 'Saint George Town', 25),
	(4866, 'Saint George''s Parish', 25),
	(4867, 'Sandys Parish', 25),
	(4868, 'Smith''s Parish', 25),
	(4869, 'Southampton Parish', 25),
	(4870, 'Warwick Parish', 25),
	(4871, 'Huila Department', 48),
	(4874, 'Ferizaj District', 248),
	(4876, 'Gjakova District', 248),
	(4877, 'Gjilan District', 248),
	(4878, 'Mitrovica District', 248),
	(4879, 'Pristina District', 248),
	(4880, 'Autonomous City of Buenos Aires', 11),
	(4881, 'New Providence', 17),
	(4882, 'Shumen Province', 34),
	(4883, 'Rivers State', 161);


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: employee_branch_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."employee_branch_access" ("employee_id", "business_id", "created_at") VALUES
	('67423330-1e29-4b88-8b59-f892d503ff49', '056a4d99-c3af-43f7-a8de-98b441e98240', '2025-05-12 21:10:39.370166+00'),
	('9d19c065-7591-419f-b357-289dc5dd4cab', '96426e92-b2e1-47d2-9857-a7248133660f', '2025-05-12 21:12:02.107317+00');


--
-- Data for Name: employee_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."employee_roles" ("employee_role_id", "created_at", "business_id", "name", "description", "editable") VALUES
	('00000000-0000-0000-0000-000000000000', '2024-12-23 09:45:34.401479+00', NULL, 'Admin', NULL, false);


--
-- Data for Name: expense_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: item_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: taxes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: income_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: incomes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: item_custom_field_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: item_custom_field_values; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."modules" ("module_id", "created_at", "name", "description", "url", "sort_order") VALUES
	(1, '2024-12-23 09:21:35.524119+00', 'Dashboard', NULL, 'dashboard', 1),
	(2, '2024-12-23 09:21:35.524119+00', 'Sale', NULL, 'sale', 2),
	(3, '2024-12-23 09:21:35.524119+00', 'Purchase', NULL, 'purchase', 3),
	(4, '2024-12-23 09:21:35.524119+00', 'Inventory', NULL, 'inventory', 4),
	(5, '2024-12-23 09:21:35.524119+00', 'Accounting', NULL, 'accounting', 5),
	(6, '2024-12-23 09:21:35.524119+00', 'Reports', NULL, 'reports', 6),
	(7, '2024-12-23 09:21:35.524119+00', 'Users', NULL, 'users', 7),
	(8, '2024-12-23 09:21:35.524119+00', 'Settings', NULL, 'settings', 8),
	(9, '2024-12-27 09:48:03.055666+00', 'Branch', NULL, 'branch', 6);


--
-- Data for Name: links; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."links" ("link_id", "created_at", "name", "description", "url", "module_id", "visibility", "sort_order") VALUES
	(1, '2024-12-23 09:28:42.722677+00', 'POS', NULL, 'pos', 2, true, 1),
	(2, '2024-12-23 09:28:42.722677+00', 'Sale List', NULL, 'sale_list', 2, true, 2),
	(3, '2024-12-23 09:28:42.722677+00', 'Order List', NULL, 'order_list', 2, true, 3),
	(4, '2024-12-23 09:28:42.722677+00', 'Sale Return', NULL, 'sale_return', 2, true, 4),
	(5, '2024-12-23 09:28:42.722677+00', 'Customer', NULL, 'customer', 2, true, 5),
	(6, '2024-12-23 09:28:42.722677+00', 'Purchase', NULL, 'purchasing', 3, true, 1),
	(7, '2024-12-23 09:28:42.722677+00', 'Purchase List', NULL, 'purchase_list', 3, true, 2),
	(8, '2024-12-23 09:28:42.722677+00', 'Purchase Return', NULL, 'purchase_return', 3, true, 3),
	(9, '2024-12-23 09:28:42.722677+00', 'Supplier', NULL, 'supplier', 3, true, 4),
	(10, '2024-12-23 09:28:42.722677+00', 'Item List', NULL, 'item_list', 4, true, 1),
	(11, '2024-12-23 09:28:42.722677+00', 'Category', NULL, 'category', 4, true, 2),
	(12, '2024-12-23 09:28:42.722677+00', 'Units', NULL, 'units', 4, true, 3),
	(13, '2024-12-23 09:28:42.722677+00', 'Brands', NULL, 'brands', 4, true, 4),
	(14, '2024-12-23 09:28:42.722677+00', 'Manage Stock', NULL, 'manage_stock', 4, true, 5),
	(15, '2024-12-23 09:28:42.722677+00', 'Stock Adjustment', NULL, 'stock_adjustment', 4, true, 6),
	(16, '2024-12-23 09:28:42.722677+00', 'Expense', NULL, 'expense', 5, true, 1),
	(17, '2024-12-23 09:28:42.722677+00', 'Income', NULL, 'income', 5, true, 2),
	(18, '2024-12-23 09:28:42.722677+00', 'Ledger', NULL, 'ledger', 5, true, 3),
	(19, '2024-12-23 09:28:42.722677+00', 'User List', NULL, 'user_list', 7, true, 1),
	(20, '2024-12-23 09:28:42.722677+00', 'User Role', NULL, 'user_role', 7, true, 2),
	(21, '2025-01-10 11:21:16.074998+00', 'Print Barcode', NULL, 'print_barcode', 4, true, 7);


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."permissions" ("permission_id", "created_at", "employee_role_id", "module_id", "link_id", "view", "create", "edit", "delete", "print") VALUES
	('0315c8de-e046-42ab-bc59-aa2eb954b02c', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 14, true, true, true, true, true),
	('064111e8-8faf-406e-b229-374a24cd98ff', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, 5, true, true, true, true, true),
	('0a4723f2-faaa-41a3-9890-f55c65620167', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 5, NULL, true, true, true, true, true),
	('0b81897e-5b50-44e6-b04b-d1216066968a', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 1, NULL, true, true, true, true, true),
	('1b2081b2-b0ae-4a4c-acaa-5df0e43a0859', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 5, 16, true, true, true, true, true),
	('1fd21282-9d3a-48b7-bd2c-5b67d8d93090', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 5, 18, true, true, true, true, true),
	('2ec66827-8964-4426-8587-11a41691d1fb', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 12, true, true, true, true, true),
	('4743ce9a-05c2-41a8-b235-a171ed0becb5', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 9, NULL, true, true, true, true, true),
	('475f522f-2351-428a-bc62-32fdaec3f34a', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 3, 6, true, true, true, true, true),
	('5361aa4b-899b-4d33-af5c-586b87a4acb9', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, 4, true, true, true, true, true),
	('56270cd6-1f05-4f83-a9c2-a65181c993bc', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 8, NULL, true, true, true, true, true),
	('5984d2bf-110a-4263-b66f-cbace4dd4d06', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, 3, true, true, true, true, true),
	('5bbafad7-65d7-4ae8-8205-37ad301d4fdb', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 5, 17, true, true, true, true, true),
	('5e934849-abf7-4325-a6aa-6d93598132f5', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 3, 7, true, true, true, true, true),
	('617fbe19-b0b2-4e98-a05c-f1240ba423c4', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 21, true, true, true, true, true),
	('6bebd19c-e4e1-44e4-9908-7ecddcafdf1f', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 15, true, true, true, true, true),
	('6c7fb111-3a2c-4a4c-9d2e-fb07e8de7e2e', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 13, true, true, true, true, true),
	('74728070-fb6c-4358-abbc-b172948f5d6b', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, NULL, true, true, true, true, true),
	('7b7436c7-8320-4086-af58-6f062760467e', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 7, NULL, true, true, true, true, true),
	('8788e14c-6f86-4daa-b95e-6441969ff1b1', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 3, NULL, true, true, true, true, true),
	('99353fac-1ddf-490b-b97f-1c64c3c03def', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 3, 9, true, true, true, true, true),
	('9deaf703-8804-456c-a7a3-d4ce110a054b', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 6, NULL, true, true, true, true, true),
	('b15892e5-e555-4b89-97c8-3872608b9cf5', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 7, 20, true, true, true, true, true),
	('e3da12fb-0f30-406a-a8c5-c53504ebc45b', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 11, true, true, true, true, true),
	('efd58fe2-a76e-4523-82fb-5f01e2760fd2', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 7, 19, true, true, true, true, true),
	('f306c345-dd6b-4f0b-9548-127d2abffd25', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, 1, true, true, true, true, true),
	('f70b3f97-eea9-4ceb-a384-c6bab3707fbf', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 2, 2, true, true, true, true, true),
	('f76c9f27-a836-450b-89bc-e0273d7ad47a', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, NULL, true, true, true, true, true),
	('f8bc32ee-b332-4bee-8ab0-fb579fdcc365', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 4, 10, true, true, true, true, true),
	('fb6381af-7573-4026-bd90-39bc7fcaaa9e', '2025-01-10 11:22:22.136906+00', '00000000-0000-0000-0000-000000000000', 3, 8, true, true, true, true, true);


--
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- Data for Name: processed_webhook_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."processed_webhook_events" ("event_id", "created_at") VALUES
	('QUPPJodtjrO8od', '2025-05-13 12:12:50.06883+00'),
	('QUPTXpqgk25tNW', '2025-05-13 12:16:30.826198+00'),
	('QUPaAuoIR5zD5E', '2025-05-13 12:22:47.199369+00'),
	('QUPsyngQRUp9pk', '2025-05-13 12:40:30.461819+00'),
	('QUPzc7Se3Y0kfb', '2025-05-13 12:46:50.354794+00'),
	('QUQHWUygCJpIND', '2025-05-13 13:03:48.157688+00'),
	('QUQId13mM4xPAJ', '2025-05-13 13:04:56.893258+00'),
	('QUQLHbc7Vn9lyy', '2025-05-13 13:07:20.137909+00'),
	('QUQMPGaon1zyrF', '2025-05-13 13:08:30.059579+00'),
	('QUUK5GoM6IViGR', '2025-05-13 17:00:42.847162+00'),
	('QUUcOdndLjlEx9', '2025-05-13 17:18:02.836267+00'),
	('QUUcdOw21EnZj1', '2025-05-13 17:18:16.080809+00'),
	('QUUdn1tbQ9rbNv', '2025-05-13 17:19:22.528873+00'),
	('QUUdnI6IEnDGDf', '2025-05-13 17:19:22.887807+00'),
	('QUUdnZ3qYo6kQE', '2025-05-13 17:19:23.308043+00'),
	('QUUh6k073cnYDB', '2025-05-13 17:22:30.368473+00'),
	('QUUiDmgonwWtLW', '2025-05-13 17:23:34.364186+00'),
	('QUUiEiO9xgHRtz', '2025-05-13 17:23:34.949687+00'),
	('QUUiDloZ2nGDdg', '2025-05-13 17:23:35.137696+00'),
	('QUUjDctA0A9PPt', '2025-05-13 17:24:29.875+00'),
	('QUUkL57O9RKEkV', '2025-05-13 17:25:34.50579+00'),
	('QUUkL1OM6TCLU3', '2025-05-13 17:25:34.706931+00'),
	('QUUkKrkQw8NgWD', '2025-05-13 17:25:34.937264+00'),
	('QUQIePqVszbI1A', '2025-05-13 18:03:25.614553+00'),
	('QUQIdjAnsNUxNl', '2025-05-13 18:03:31.185142+00'),
	('QUQMPhtRlnoj5z', '2025-05-13 18:06:47.066705+00'),
	('QUQMP7TY5K1Ad2', '2025-05-13 18:06:47.366468+00'),
	('QUhzsgAP0XRoy6', '2025-05-14 06:23:37.485897+00'),
	('QUi1FpVYGP9Fow', '2025-05-14 06:25:05.030521+00'),
	('QUi2PECXweKpjG', '2025-05-14 06:25:56.525564+00'),
	('QUqSwxqWeCqKNZ', '2025-05-14 14:40:38.3373+00'),
	('QUqU8159ms78EI', '2025-05-14 14:41:42.137589+00'),
	('QUqW6b6rmCSVni', '2025-05-14 14:43:42.872359+00'),
	('QUqWRzrb98Q6k1', '2025-05-14 14:44:28.759389+00'),
	('QUqXZOEWt6kGY2', '2025-05-14 14:45:00.069232+00'),
	('QUqZPtvyeCJiyD', '2025-05-14 14:47:22.508798+00'),
	('QUqahmZ3KqyYKN', '2025-05-14 14:48:00.807348+00'),
	('QUqboP0EI1RyPH', '2025-05-14 14:49:52.816521+00'),
	('QUqhxUvnvLqn1Z', '2025-05-14 14:55:02.131125+00'),
	('QUqj6qDjnhDngT', '2025-05-14 14:55:57.161601+00'),
	('QUqnY29v2sgd34', '2025-05-14 15:00:07.576373+00'),
	('QUqnyCD5isnTCD', '2025-05-14 15:00:35.098723+00'),
	('QUqp88b1JN5Io5', '2025-05-14 15:01:38.425347+00'),
	('QUqs7tW0T62CLD', '2025-05-14 15:04:33.558564+00'),
	('QUqtF0h43K0A3o', '2025-05-14 15:05:28.389339+00'),
	('QUsXR5cp273Z5e', '2025-05-14 16:42:21.468084+00'),
	('QUsYtl3vuJ6G8y', '2025-05-14 16:43:40.210265+00'),
	('QUsccekpZ9vI78', '2025-05-14 16:46:58.258198+00'),
	('QUsiV7dI8tGoS5', '2025-05-14 16:52:30.208511+00'),
	('QUsmfSAKs6WxAk', '2025-05-14 16:56:26.369753+00'),
	('QUsnp0rPVcytzL', '2025-05-14 16:57:31.226856+00'),
	('QUsnpCDNY3Ttyh', '2025-05-14 16:57:31.517576+00'),
	('QUsnpxdBduvLIo', '2025-05-14 16:57:31.832502+00'),
	('QUswhpgAQVMyhP', '2025-05-14 17:05:59.186327+00'),
	('QUsxSy9bl9WB4q', '2025-05-14 17:06:38.797863+00'),
	('QUsyZq2XfciQlf', '2025-05-14 17:07:42.259043+00'),
	('QUsya1znh60Dlc', '2025-05-14 17:07:42.529266+00'),
	('QUsyaHYWLEsGTg', '2025-05-14 17:07:42.774925+00'),
	('QUt4GevnptRwco', '2025-05-14 17:13:05.885007+00'),
	('QUt5NwDt3AJb03', '2025-05-14 17:14:10.190393+00'),
	('QUt5O7KaK0MxNg', '2025-05-14 17:14:10.377708+00'),
	('QUt5OXis6tZ6OY', '2025-05-14 17:14:10.588425+00'),
	('QUtAfkrBO1hmZW', '2025-05-14 17:19:09.251882+00'),
	('QUtBmaKuOG28cm', '2025-05-14 17:20:14.161945+00'),
	('QUtBnmesDHnPaC', '2025-05-14 17:20:14.387119+00'),
	('QUtBnDyni7VGvf', '2025-05-14 17:20:14.712136+00'),
	('QUtIYY9w9Rk3wm', '2025-05-14 17:26:39.992741+00'),
	('QUtIndJEnpBN1m', '2025-05-14 17:26:50.860564+00'),
	('QUtJuqeNu0tHGN', '2025-05-14 17:27:54.396384+00'),
	('QUtJvFSb8cxla0', '2025-05-14 17:27:54.866756+00'),
	('QUtJvOCJhyXy4H', '2025-05-14 17:27:55.100869+00'),
	('QUuEgYIEbZMXNN', '2025-05-14 18:21:40.451971+00'),
	('QUuF6HruQGwQRG', '2025-05-14 18:22:02.348524+00'),
	('QUuGD8xQSIOjdw', '2025-05-14 18:23:05.355268+00'),
	('QUuGD1DCAa0mu4', '2025-05-14 18:23:05.604783+00'),
	('QUuGCSzWuQBjuU', '2025-05-14 18:23:05.839591+00'),
	('QUvIkQvuNMMNJc', '2025-05-14 19:24:11.715243+00'),
	('QUvKeT7itkU9aB', '2025-05-14 19:25:59.768607+00'),
	('QUvM0xsYLxmoUg', '2025-05-14 19:27:16.606741+00'),
	('QUvM2tdPYrr5Hb', '2025-05-14 19:27:18.529434+00'),
	('QUvM4n1ZtNsTTk', '2025-05-14 19:27:20.402468+00'),
	('QUvTUyVhduFZdR', '2025-05-14 19:34:21.736731+00'),
	('QUvU6kl2HHV2GA', '2025-05-14 19:34:56.764327+00'),
	('QUvUeyxXvtGz61', '2025-05-14 19:35:27.884464+00'),
	('QUvUfIjRqYm3lr', '2025-05-14 19:35:28.208989+00'),
	('QUvUfT3O9Orlio', '2025-05-14 19:35:28.415463+00'),
	('QUy0FPSgBceTm5', '2025-05-14 22:02:44.953757+00'),
	('QUy1PCDfPPfUWc', '2025-05-14 22:03:51.029278+00'),
	('QUy1PHZmUajPBv', '2025-05-14 22:03:51.527923+00'),
	('QUy1PQv7oF3HYu', '2025-05-14 22:03:51.780443+00'),
	('QUyFMCzlOLI7Zp', '2025-05-14 22:17:04.196763+00'),
	('QUyGSum7c1Ny1p', '2025-05-14 22:18:06.017814+00'),
	('QUyGT1uWQXRj7n', '2025-05-14 22:18:06.28705+00'),
	('QUyGTBxwEYD9Ek', '2025-05-14 22:18:06.486113+00'),
	('QUyKJqt444zyu2', '2025-05-14 22:21:56.530906+00'),
	('QUyLQ6cjfBilDd', '2025-05-14 22:23:08.765223+00'),
	('QUyQ6PxximW0at', '2025-05-14 22:27:27.513305+00'),
	('QUyQxOfnb7oVWY', '2025-05-14 22:28:24.396242+00'),
	('QUyS6MBDAZgjdv', '2025-05-14 22:29:30.455331+00'),
	('QUyZTyktAv2WHL', '2025-05-14 22:36:21.876753+00'),
	('QUyb0zaqxSSQxe', '2025-05-14 22:37:48.448342+00'),
	('QUybdXoZBmnu3s', '2025-05-14 22:38:20.048568+00'),
	('QUygC4vpCy9gHY', '2025-05-14 22:42:42.919206+00'),
	('QUyhIUCbiCPLhS', '2025-05-14 22:43:44.760172+00'),
	('QUystPFeiuJVMc', '2025-05-14 22:54:42.782357+00'),
	('QUyvJsnGEeEvQB', '2025-05-14 22:57:03.082226+00'),
	('QUyvYPyoPkAHN4', '2025-05-14 22:57:20.065638+00'),
	('QUywcoyuDODQAv', '2025-05-14 22:58:17.947142+00'),
	('QV5baE7wkgSLE5', '2025-05-15 05:28:56.908381+00'),
	('QV5cgYmOv6uDkR', '2025-05-15 05:29:59.805447+00'),
	('QV5cglcNCOIuKv', '2025-05-15 05:30:00.22198+00'),
	('QV5ch9z0rYe7ch', '2025-05-15 05:30:00.470909+00');


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_audits; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_custom_field_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_custom_field_values; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_returns; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: purchase_return_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: razorpay_addons; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- Data for Name: resellers; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: roles_of_employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."roles_of_employees" ("employee_role_id", "employee_id", "created_at") VALUES
	('00000000-0000-0000-0000-000000000000', '67423330-1e29-4b88-8b59-f892d503ff49', '2025-05-12 21:10:39.370166+00'),
	('00000000-0000-0000-0000-000000000000', '9d19c065-7591-419f-b357-289dc5dd4cab', '2025-05-12 21:12:02.107317+00');


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."statuses" ("status_id", "business_id", "name", "sequence_order", "moving_order", "is_default", "created_at", "updated_at", "type", "is_editable") VALUES
	('f69a5ead-2e29-42a4-a764-b76daadb045a', '056a4d99-c3af-43f7-a8de-98b441e98240', 'Booked', 1, NULL, true, '2025-05-12 21:10:39.370166+00', '2025-05-12 21:10:39.370166+00', 'sale', true),
	('553c5cc7-1cca-48be-bc7d-1f8078f3529c', '056a4d99-c3af-43f7-a8de-98b441e98240', 'In Process', 2, NULL, false, '2025-05-12 21:10:39.370166+00', '2025-05-12 21:10:39.370166+00', 'sale', true),
	('fc3dfb96-a970-4626-9f0b-aad1237da897', '056a4d99-c3af-43f7-a8de-98b441e98240', 'Cancelled', 3, NULL, false, '2025-05-12 21:10:39.370166+00', '2025-05-12 21:10:39.370166+00', 'sale', false),
	('1e4577fa-7d4c-407b-abf8-50cbf359ce22', '056a4d99-c3af-43f7-a8de-98b441e98240', 'Completed', 4, NULL, false, '2025-05-12 21:10:39.370166+00', '2025-05-12 21:10:39.370166+00', 'sale', false),
	('96a2c3f2-4f30-4944-b4f3-2d57abd14ea1', '96426e92-b2e1-47d2-9857-a7248133660f', 'Booked', 1, NULL, true, '2025-05-12 21:12:02.107317+00', '2025-05-12 21:12:02.107317+00', 'sale', true),
	('2339cc6f-1735-4e38-a63b-68459b8ab9bf', '96426e92-b2e1-47d2-9857-a7248133660f', 'In Process', 2, NULL, false, '2025-05-12 21:12:02.107317+00', '2025-05-12 21:12:02.107317+00', 'sale', true),
	('751474e6-e6fa-4665-819b-af8b2317c734', '96426e92-b2e1-47d2-9857-a7248133660f', 'Cancelled', 3, NULL, false, '2025-05-12 21:12:02.107317+00', '2025-05-12 21:12:02.107317+00', 'sale', false),
	('bcb4e911-95af-46f5-9bae-af3e42a769f8', '96426e92-b2e1-47d2-9857-a7248133660f', 'Completed', 4, NULL, false, '2025-05-12 21:12:02.107317+00', '2025-05-12 21:12:02.107317+00', 'sale', false);


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_audits; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_custom_field_definitions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_custom_field_values; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: subservices; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_item_subservices; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_returns; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sale_return_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: stock_adjustments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: stock_adjustment_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."subscriptions" ("subscription_id", "org_id", "plan_id", "status", "start_date", "end_date", "trial_end_date", "cancel_at_period_end", "canceled_at", "payment_provider_subscription_id", "created_at", "updated_at", "addon_id", "payment_provider_customer_id", "payment_provider", "payment_provider_plan_id", "current_start", "current_end", "payment_url", "currency", "plan_amount", "total_invoice_amount", "metadata", "billing_cycle", "tax_amount", "quantity") VALUES
	('861011b6-ba8b-4087-ab95-cfad43f6abe4', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', 2, 'active', '2025-05-15', '2029-05-14', NULL, false, NULL, 'sub_QV5XT3dQ9azIZk', '2025-05-15 05:25:05.724381+00', '2025-05-15 05:25:05.724381+00', NULL, NULL, 'razorpay', 'plan_QM0xGc1KWT8y79', '2025-05-15', '2026-05-14', 'https://rzp.io/rzp/yk02bDtO', 'INR', 7788.00, 7788, '{"id": "pay_QV5bVcdxTdWwJA", "fee": 826, "tax": 126, "vpa": "testuser@razorpay", "bank": null, "email": "alfas@hancod.com", "notes": [], "amount": 778800, "end_at": 1873477800, "entity": "payment", "method": "upi", "source": "api", "status": "captured", "wallet": null, "card_id": null, "contact": "+918891584808", "plan_id": "plan_QM0xGc1KWT8y79", "captured": "1", "currency": "INR", "ended_at": null, "offer_id": null, "order_id": "order_QV5XUlmIaCSk5d", "quantity": 1, "start_at": 1747286933, "token_id": "token_QV5bW6vw5wfdHT", "charge_at": 1778783400, "expire_by": null, "short_url": null, "created_at": 1747286933, "error_code": null, "invoice_id": "inv_QV5XTk3YHM7QkY", "paid_count": 1, "current_end": 1778783400, "customer_id": null, "description": null, "total_count": 5, "acquirer_data": {"rrn": "001000100002", "upi_transaction_id": "npci_txn_id_for_QV5bVcdxTdWwJA"}, "auth_attempts": 0, "current_start": 1747286933, "international": false, "refund_status": null, "payment_method": "upi", "amount_refunded": 0, "customer_notify": false, "remaining_count": 4, "error_description": null, "amount_transferred": 0, "change_scheduled_at": null, "has_scheduled_changes": false}', 'annually', 1.26, 1),
	('10d0b56a-e89b-4720-8259-456d40ded26a', '5e2ccbed-2195-4cf7-95b5-49a0226d6bf9', 1, 'active', '2025-05-15', NULL, NULL, false, NULL, NULL, '2025-05-14 22:14:33.959025+00', '2025-05-14 22:14:33.959025+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'annually', NULL, 1),
	('deb67223-5d81-4bc5-9d08-e50183524d2a', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', 1, 'ended', '2025-05-15', '2025-05-15', NULL, false, NULL, NULL, '2025-05-14 22:15:00.69906+00', '2025-05-14 22:15:00.69906+00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'annually', NULL, 1);


--
-- Data for Name: subscription_invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."subscription_invoices" ("subscription_invoice_id", "org_id", "subscription_id", "payment_provider_subscription_id", "payment_provider_invoice_id", "payment_provider_order_id", "payment_provider_payment_id", "payment_provider", "status", "amount", "amount_paid", "amount_due", "currency", "due_date", "paid_at", "issued_at", "created_at", "updated_at", "line_items", "notes", "pdf_url", "metadata", "payment_url") VALUES
	('89b56283-8eac-4f7c-91a3-dbad26fbc3aa', 'c0ae8dea-4fdd-4587-b0df-3cd96c68cbc8', '861011b6-ba8b-4087-ab95-cfad43f6abe4', 'sub_QV5XT3dQ9azIZk', 'inv_QV5XTk3YHM7QkY', 'order_QV5XUlmIaCSk5d', 'pay_QV5bVcdxTdWwJA', 'razorpay', 'paid', 7788.00, 7788.00, 0.00, 'INR', NULL, '2025-05-15 05:28:55+00', '2025-05-15 05:25:03+00', '2025-05-15 05:25:04+00', '2025-05-15 05:25:05.724381+00', '[{"id": "li_QV5XTkXKxYkgFG", "name": "Pro-Yearly", "type": "plan", "unit": null, "taxes": [], "amount": 778800, "ref_id": null, "item_id": null, "currency": "INR", "hsn_code": null, "quantity": 1, "ref_type": null, "sac_code": null, "tax_rate": null, "net_amount": 778800, "tax_amount": 0, "description": null, "unit_amount": 778800, "gross_amount": 778800, "tax_inclusive": false, "taxable_amount": 778800}]', '[]', 'https://rzp.io/rzp/vAsiLNr', '{"id": "inv_QV5XTk3YHM7QkY", "date": 1747286703, "type": "invoice", "notes": [], "terms": null, "amount": 778800, "entity": "invoice", "status": "paid", "comment": null, "paid_at": 1747286935, "receipt": null, "ref_num": null, "user_id": null, "currency": "INR", "order_id": "order_QV5XUlmIaCSk5d", "expire_by": null, "issued_at": 1747286703, "short_url": "https://rzp.io/rzp/vAsiLNr", "view_less": true, "amount_due": 0, "created_at": 1747286704, "expired_at": null, "payment_id": "pay_QV5bVcdxTdWwJA", "sms_status": null, "tax_amount": 0, "amount_paid": 778800, "billing_end": null, "customer_id": null, "description": null, "cancelled_at": null, "email_status": null, "gross_amount": 778800, "billing_start": null, "invoice_number": null, "taxable_amount": 778800, "currency_symbol": "₹", "idempotency_key": null, "partial_payment": false, "reminder_status": null, "subscription_id": "sub_QV5XT3dQ9azIZk", "customer_details": {"id": null, "name": null, "email": "alfas@hancod.com", "gstin": null, "contact": "+918891584808", "customer_name": null, "customer_email": "alfas@hancod.com", "billing_address": null, "customer_contact": "+918891584808", "shipping_address": null}, "supply_state_code": null, "subscription_status": null, "group_taxes_discounts": false, "first_payment_min_amount": null}', 'https://rzp.io/rzp/vAsiLNr');


--
-- Data for Name: transaction_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: whatsapp_integration; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--



--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--



--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_employee_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_employee_code"', 1, false);


--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_item_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_item_code"', 1, false);


--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_purchase_invoice; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_purchase_invoice"', 1, false);


--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_purchase_return_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_purchase_return_code"', 1, false);


--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_sale_invoice; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_sale_invoice"', 1, false);


--
-- Name: 056a4d99-c3af-43f7-a8de-98b441e98240_sale_return_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."056a4d99-c3af-43f7-a8de-98b441e98240_sale_return_code"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_employee_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_employee_code"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_item_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_item_code"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_purchase_invoice; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_purchase_invoice"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_purchase_return_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_purchase_return_code"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_sale_invoice; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_sale_invoice"', 1, false);


--
-- Name: 96426e92-b2e1-47d2-9857-a7248133660f_sale_return_code; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('"auth"."96426e92-b2e1-47d2-9857-a7248133660f_sale_return_code"', 1, false);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 51, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('"pgsodium"."key_key_id_seq"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000001_item_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000001_item_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000001_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000001_purchase_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000001_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000001_purchase_return_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000001_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000001_sale_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000001_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000001_sale_return_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000002_item_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000002_item_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000002_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000002_purchase_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000002_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000002_purchase_return_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000002_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000002_sale_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000002_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000002_sale_return_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000003_item_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000003_item_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000003_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000003_purchase_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000003_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000003_purchase_return_code"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000003_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000003_sale_invoice"', 1, false);


--
-- Name: 00000000-0000-0000-0000-000000000003_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."00000000-0000-0000-0000-000000000003_sale_return_code"', 1, false);


--
-- Name: 025d858f-20ad-4db7-b548-52e9ae17b8dc_item_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."025d858f-20ad-4db7-b548-52e9ae17b8dc_item_code"', 1, false);


--
-- Name: 025d858f-20ad-4db7-b548-52e9ae17b8dc_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."025d858f-20ad-4db7-b548-52e9ae17b8dc_purchase_invoice"', 1, false);


--
-- Name: 025d858f-20ad-4db7-b548-52e9ae17b8dc_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."025d858f-20ad-4db7-b548-52e9ae17b8dc_purchase_return_code"', 1, false);


--
-- Name: 025d858f-20ad-4db7-b548-52e9ae17b8dc_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."025d858f-20ad-4db7-b548-52e9ae17b8dc_sale_invoice"', 1, false);


--
-- Name: 025d858f-20ad-4db7-b548-52e9ae17b8dc_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."025d858f-20ad-4db7-b548-52e9ae17b8dc_sale_return_code"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_employee_code"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_item_code"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_purchase_invoice"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_purchase_return_code"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_sale_invoice"', 1, false);


--
-- Name: 06a4b5f9-18de-4755-81e9-0409f0433ec8_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."06a4b5f9-18de-4755-81e9-0409f0433ec8_sale_return_code"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_employee_code"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_item_code"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_purchase_invoice"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_purchase_return_code"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_sale_invoice"', 1, false);


--
-- Name: 0ba915e6-b958-4c2a-8fca-16a66e057619_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."0ba915e6-b958-4c2a-8fca-16a66e057619_sale_return_code"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_employee_code"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_item_code"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_purchase_invoice"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_purchase_return_code"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_sale_invoice"', 1, false);


--
-- Name: 107ed223-7f7e-4adf-98e7-4b61016b7aca_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."107ed223-7f7e-4adf-98e7-4b61016b7aca_sale_return_code"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_employee_code"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_item_code"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_purchase_invoice"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_purchase_return_code"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_sale_invoice"', 1, false);


--
-- Name: 274d1379-2925-46ea-962a-88105bdab0dc_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."274d1379-2925-46ea-962a-88105bdab0dc_sale_return_code"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_employee_code"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_item_code"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_purchase_invoice"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_purchase_return_code"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_sale_invoice"', 1, false);


--
-- Name: 2a108b1f-140d-42ee-a6f8-d80658b9ba72_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2a108b1f-140d-42ee-a6f8-d80658b9ba72_sale_return_code"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_employee_code"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_item_code"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_purchase_invoice"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_purchase_return_code"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_sale_invoice"', 1, false);


--
-- Name: 2b7e598a-ac54-40e3-a757-15d3960fcc2e_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."2b7e598a-ac54-40e3-a757-15d3960fcc2e_sale_return_code"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_employee_code"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_item_code"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_purchase_invoice"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_purchase_return_code"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_sale_invoice"', 1, false);


--
-- Name: 546629b4-4fbe-4c68-85eb-5508d487b8c9_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."546629b4-4fbe-4c68-85eb-5508d487b8c9_sale_return_code"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_employee_code"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_item_code"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_purchase_invoice"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_purchase_return_code"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_sale_invoice"', 1, false);


--
-- Name: 57d424c5-82a3-4741-9dbd-3845846fe546_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."57d424c5-82a3-4741-9dbd-3845846fe546_sale_return_code"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_employee_code"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_item_code"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_purchase_invoice"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_purchase_return_code"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_sale_invoice"', 1, false);


--
-- Name: 6ec1c373-b3f1-4c43-9ccb-055afcc3586b_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6ec1c373-b3f1-4c43-9ccb-055afcc3586b_sale_return_code"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_employee_code"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_item_code"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_purchase_invoice"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_purchase_return_code"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_sale_invoice"', 1, false);


--
-- Name: 6f302d75-51cc-41b1-9807-1f7060418b83_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."6f302d75-51cc-41b1-9807-1f7060418b83_sale_return_code"', 1, false);


--
-- Name: 8281774e-2484-4580-956f-1a9f4e24e9dd_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."8281774e-2484-4580-956f-1a9f4e24e9dd_item_code"', 1, false);


--
-- Name: 9192eeab-a721-4045-ae23-63e0fa597035_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9192eeab-a721-4045-ae23-63e0fa597035_item_code"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_employee_code"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_item_code"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_purchase_invoice"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_purchase_return_code"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_sale_invoice"', 1, false);


--
-- Name: 97550aae-0379-4981-8c16-df9513e50af0_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."97550aae-0379-4981-8c16-df9513e50af0_sale_return_code"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_employee_code"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_item_code"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_purchase_invoice"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_purchase_return_code"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_sale_invoice"', 1, false);


--
-- Name: 9a5f910b-621c-4111-a0cb-178df768fd46_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."9a5f910b-621c-4111-a0cb-178df768fd46_sale_return_code"', 1, false);


--
-- Name: a0cdfff6-5bfd-47d3-ab16-399427c39a46_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a0cdfff6-5bfd-47d3-ab16-399427c39a46_item_code"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_employee_code"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_item_code"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_purchase_invoice"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_purchase_return_code"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_sale_invoice"', 1, false);


--
-- Name: a24df654-2247-462b-9df8-081c37290e7c_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."a24df654-2247-462b-9df8-081c37290e7c_sale_return_code"', 1, false);


--
-- Name: addon_prices_addon_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."addon_prices_addon_price_id_seq"', 3, true);


--
-- Name: addons_addon_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."addons_addon_id_seq"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_employee_code"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_item_code"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_purchase_invoice"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_purchase_return_code"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_sale_invoice"', 1, false);


--
-- Name: b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b49dda84-d0e1-47b5-9898-4d0d5b0d85c4_sale_return_code"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_employee_code"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_item_code"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_purchase_invoice"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_purchase_return_code"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_sale_invoice"', 1, false);


--
-- Name: b4e20922-debf-40d1-b79c-2e07bef3ff2a_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."b4e20922-debf-40d1-b79c-2e07bef3ff2a_sale_return_code"', 1, false);


--
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."cities_id_seq"', 1, false);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."countries_id_seq"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_employee_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_employee_code"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_item_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_item_code"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_purchase_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_purchase_invoice"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_purchase_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_purchase_return_code"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_sale_invoice; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_sale_invoice"', 1, false);


--
-- Name: fd67b99a-b6d2-4f26-81af-6c6df8a98841_sale_return_code; Type: SEQUENCE SET; Schema: public; Owner: authenticated
--

SELECT pg_catalog.setval('"public"."fd67b99a-b6d2-4f26-81af-6c6df8a98841_sale_return_code"', 1, false);


--
-- Name: features_feature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."features_feature_id_seq"', 1, false);


--
-- Name: links_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."links_link_id_seq"', 1, false);


--
-- Name: modules_module_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."modules_module_id_seq"', 1, false);


--
-- Name: plan_features_plan_feature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."plan_features_plan_feature_id_seq"', 1, false);


--
-- Name: plan_prices_plan_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."plan_prices_plan_price_id_seq"', 1, false);


--
-- Name: plans_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."plans_plan_id_seq"', 1, false);


--
-- Name: states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."states_id_seq"', 1, false);


--
-- Name: subscriptions_subscription_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."subscriptions_subscription_id_seq"', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('"supabase_functions"."hooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

RESET ALL;
