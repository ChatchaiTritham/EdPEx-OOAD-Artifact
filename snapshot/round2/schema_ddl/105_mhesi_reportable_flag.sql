-- DDL extracted from 105_mhesi_reportable_flag.sql (sha256 91925187dd7fa668d07a6256d8d470757862f7147a4dafc2d7feaa909957b355)
ALTER TABLE students
    ADD COLUMN IF NOT EXISTS requires_mhesi_report TINYINT(1) NOT NULL DEFAULT 0
        COMMENT 'อยู่ในรายชื่อที่ต้องรายงาน อว. รอบปัจจุบันหรือไม่ (จากไฟล์ ...ที่ต้องรายงาน อว..xlsx) — ไม่ใช่แค่ "เป็นนักศึกษาต่างชาติ"';
