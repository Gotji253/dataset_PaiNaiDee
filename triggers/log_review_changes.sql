CREATE OR REPLACE FUNCTION log_review_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_record_pk TEXT;
    v_changed_by_user_id INTEGER;
BEGIN
    -- พยายามดึง user_id จาก session variable (ถ้ามีการตั้งค่าจาก application)
    -- นี่เป็นวิธีหนึ่งที่ app สามารถส่งข้อมูล user ปัจจุบันมาให้ database ได้
    -- หากไม่สามารถดึงได้ หรือไม่ได้ตั้งค่าไว้ จะเป็น NULL
    BEGIN
        v_changed_by_user_id := current_setting('app.current_user_id', TRUE)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_changed_by_user_id := NULL;
    END;

    IF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        v_record_pk := OLD.review_id::TEXT;
        -- หาก user_id ไม่ได้ถูก update ให้ใช้ user_id เดิมเป็น changed_by
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
            v_changed_by_user_id := NEW.user_id; -- User ที่สร้างรีวิว
        END IF;
    END IF;

    INSERT INTO AuditLog (table_name, record_pk, operation_type, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, v_record_pk, TG_OP, v_old_data, v_new_data, v_changed_by_user_id);

    RETURN NEW; -- สำหรับ INSERT/UPDATE, คืนค่า NEW เพื่อให้ operation ดำเนินการต่อ
               -- สำหรับ DELETE, ค่าที่คืนไม่สำคัญ แต่ต้องคืนค่า record-like
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER review_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON Review
FOR EACH ROW EXECUTE FUNCTION log_review_changes();
