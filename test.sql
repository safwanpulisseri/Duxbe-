-- FUNCTION: public.handle_new_user()

-- DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION PUBLIC.HANDLE_NEW_USER(
) RETURNS TRIGGER LANGUAGE 'plpgsql' COST 100 VOLATILE NOT LEAKPROOF SECURITY DEFINER AS
    $BODY$              DECLARE _PLATFORM TEXT;
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
    _PHONE_NUMBER := REGEXP_REPLACE((NEW.RAW_USER_META_DATA->>'phone_number'), '\+', '', 'g');
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

$BODY$;
ALTER FUNCTION PUBLIC.HANDLE_NEW_USER(
) OWNER TO POSTGRES;