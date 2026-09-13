-- DDL extracted from 103_registrar_status_evidence.sql (sha256 664b891473feb01f357b1433a4c72d8880028a4fb74445b8816af3bb27b6d47c)
ALTER TABLE student_enrollments
    ADD COLUMN IF NOT EXISTS registrar_status_evidence_url VARCHAR(500) NULL COMMENT 'หลักฐานสถานภาพจากระบบทะเบียน reg.rmutk.ac.th — ไฟล์ท้องถิ่นหรือลิงก์ภายนอก' AFTER visa_evidence_url;
