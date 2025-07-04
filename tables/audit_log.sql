CREATE TABLE AuditLog (
    log_id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_pk TEXT NOT NULL, -- เก็บ Primary Key ของ record ที่ถูกแก้ไข (อาจเป็นค่าเดียว หรือหลายค่าเช่น "id1,id2")
    operation_type VARCHAR(10) NOT NULL, -- เช่น INSERT, UPDATE, DELETE
    old_data JSONB, -- ข้อมูลเก่า (สำหรับ UPDATE, DELETE)
    new_data JSONB, -- ข้อมูลใหม่ (สำหรับ INSERT, UPDATE)
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    changed_by INTEGER -- สามารถเก็บ user_id ที่ทำการเปลี่ยนแปลง (ถ้ามีข้อมูลจาก session/application)
                       -- REFERENCES "User"(user_id) -- อาจจะเพิ่ม FK ถ้าต้องการ
);

COMMENT ON COLUMN AuditLog.record_pk IS 'Primary key of the audited record. For composite keys, consider a consistent string representation.';
COMMENT ON COLUMN AuditLog.changed_by IS 'User ID who performed the change, if available.';
