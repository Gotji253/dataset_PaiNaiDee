CREATE OR REPLACE FUNCTION log_place_changes()
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
        v_record_pk := OLD.place_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            -- หาก created_by ไม่ได้ถูก update ให้ใช้ created_by เดิม
            -- หรือถ้า created_by สามารถเปลี่ยนได้ ให้ใช้ NEW.created_by
            v_changed_by_user_id := COALESCE(NEW.created_by, OLD.created_by);
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
        v_record_pk := OLD.place_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            v_changed_by_user_id := OLD.created_by;
        END IF;
    ELSIF (TG_OP = 'INSERT') THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
        v_record_pk := NEW.place_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            v_changed_by_user_id := NEW.created_by; -- User ที่สร้างสถานที่
        END IF;
    END IF;

    INSERT INTO AuditLog (table_name, record_pk, operation_type, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, v_record_pk, TG_OP, v_old_data, v_new_data, v_changed_by_user_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER place_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Place
FOR EACH ROW EXECUTE FUNCTION log_place_changes();
