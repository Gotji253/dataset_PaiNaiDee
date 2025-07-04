CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_record_pk TEXT;
    v_changed_by_user_id INTEGER;
    v_performing_user_id INTEGER; -- User performing the action
BEGIN
    -- Try to get the performing user from app context
    BEGIN
        v_performing_user_id := current_setting('app.current_user_id', TRUE)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_performing_user_id := NULL;
    END;

    -- The user_id of the record being changed is OLD.user_id or NEW.user_id
    -- The changed_by field in AuditLog should be v_performing_user_id if available,
    -- otherwise, if it's a self-update, it could be OLD.user_id or NEW.user_id.
    -- For user changes, 'changed_by' usually refers to an admin or the user themselves.

    IF (TG_OP = 'UPDATE') THEN
        -- IMPORTANT SECURITY NOTE: to_jsonb(OLD) and to_jsonb(NEW) will include password_hash.
        -- In a production system, password_hash should be excluded from audit logs or handled carefully.
        -- For example, by removing the key: v_old_data = to_jsonb(OLD) - 'password_hash';
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        v_record_pk := OLD.user_id::TEXT;

        IF v_performing_user_id IS NULL THEN
            -- If no admin/system user context, assume the user is performing action on their own record
            v_changed_by_user_id := OLD.user_id;
        ELSE
            v_changed_by_user_id := v_performing_user_id;
        END IF;

    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
        v_record_pk := OLD.user_id::TEXT;
        IF v_performing_user_id IS NULL THEN
            v_changed_by_user_id := OLD.user_id; -- Or a system/placeholder ID if deleted by system
        ELSE
            v_changed_by_user_id := v_performing_user_id;
        END IF;

    ELSIF (TG_OP = 'INSERT') THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
        v_record_pk := NEW.user_id::TEXT;
        -- For inserts, changed_by is typically the user themselves or the admin creating the user.
        IF v_performing_user_id IS NULL THEN
            v_changed_by_user_id := NEW.user_id;
        ELSE
            v_changed_by_user_id := v_performing_user_id;
        END IF;
    END IF;

    INSERT INTO "AuditLog" (table_name, record_pk, operation_type, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME::TEXT, v_record_pk, TG_OP, v_old_data, v_new_data, v_changed_by_user_id);

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;
