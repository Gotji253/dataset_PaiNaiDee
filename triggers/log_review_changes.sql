CREATE OR REPLACE FUNCTION log_review_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_record_pk TEXT;
    v_changed_by_user_id INTEGER;
BEGIN
    BEGIN
        v_changed_by_user_id := current_setting('app.current_user_id', TRUE)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_changed_by_user_id := NULL;
    END;

    IF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        v_record_pk := OLD.review_id::TEXT;
        -- For Review, user_id is the author.
        IF v_changed_by_user_id IS NULL THEN
            v_changed_by_user_id := OLD.user_id;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
        v_record_pk := OLD.review_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            v_changed_by_user_id := OLD.user_id;
        END IF;
    ELSIF (TG_OP = 'INSERT') THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
        v_record_pk := NEW.review_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            v_changed_by_user_id := NEW.user_id;
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
