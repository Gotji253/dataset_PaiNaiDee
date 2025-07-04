CREATE OR REPLACE FUNCTION validate_duplicate_review()
RETURNS TRIGGER AS $$
BEGIN
    -- ตรวจสอบว่ามีรีวิวจาก user_id เดียวกัน สำหรับ place_id เดียวกันอยู่แล้วหรือไม่
    IF EXISTS (
        SELECT 1
        FROM Review
        WHERE user_id = NEW.user_id AND place_id = NEW.place_id
    ) THEN
        -- ถ้ามีอยู่แล้ว ให้ยกเลิกการ INSERT และแจ้งข้อผิดพลาด
        RAISE EXCEPTION 'User % has already reviewed place %.', NEW.user_id, NEW.place_id
        USING ERRCODE = 'unique_violation', HINT = 'A user cannot review the same place multiple times.';
    END IF;

    -- ถ้าไม่มีรีวิวซ้ำ ให้ดำเนินการ INSERT ต่อไป
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_review_trigger
BEFORE INSERT ON Review
FOR EACH ROW EXECUTE FUNCTION validate_duplicate_review();
