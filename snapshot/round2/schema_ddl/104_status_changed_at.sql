-- DDL extracted from 104_status_changed_at.sql (sha256 3ee4ee11a0d8ef4224592e40d0fa284cd0779f31fe5d29fe657a1fc2894d691c)
ALTER TABLE student_enrollments
    ADD COLUMN IF NOT EXISTS status_changed_at DATE NULL COMMENT 'วันที่เปลี่ยนสถานะจริง (จบ/ถอนชื่อ/ลาออก/พ้นสภาพ ฯลฯ) ตามหลักฐาน — ว่างจนกว่าจะยืนยันได้' AFTER student_status_code,
    ADD COLUMN IF NOT EXISTS status_changed_source VARCHAR(120) NULL COMMENT 'ที่มาของวันที่ เช่น reg.rmutk.ac.th, ทะเบียนประวัติ, เจ้าหน้าที่แจ้งด้วยตนเอง' AFTER status_changed_at;
