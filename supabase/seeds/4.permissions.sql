-- Grant full permissions to all existing links for default role
INSERT INTO "public"."permissions" (
    "permission_id",
    "created_at",
    "employee_role_id",
    "module_id",
    "link_id",
    "view",
    "create",
    "edit",
    "delete",
    "print"
)
    SELECT
        GEN_RANDOM_UUID(), -- auto-generate UUID
        NOW(), -- current timestamp
        '00000000-0000-0000-0000-000000000000'::UUID, -- default role ID
        L.MODULE_ID,
        L.LINK_ID,
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        TRUE
    FROM
        PUBLIC.LINKS L
        ON CONFLICT (EMPLOYEE_ROLE_ID,
        LINK_ID) DO UPDATE SET MODULE_ID = EXCLUDED.MODULE_ID,
        "view" = EXCLUDED.VIEW,
        "create" = EXCLUDED.CREATE,
        EDIT = EXCLUDED.EDIT,
        "delete" = EXCLUDED.DELETE,
        PRINT = EXCLUDED.PRINT,
        CREATED_AT = EXCLUDED.CREATED_AT;

-- Grant full permissions to all existing modules for default role
INSERT INTO "public"."permissions" (
    "permission_id",
    "created_at",
    "employee_role_id",
    "module_id",
    "view",
    "create",
    "edit",
    "delete",
    "print"
)
    SELECT
        GEN_RANDOM_UUID(), -- auto-generate UUID
        NOW(), -- current timestamp
        '00000000-0000-0000-0000-000000000000'::UUID, -- default role ID
        M.MODULE_ID,
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        TRUE
    FROM
        PUBLIC.MODULES M;