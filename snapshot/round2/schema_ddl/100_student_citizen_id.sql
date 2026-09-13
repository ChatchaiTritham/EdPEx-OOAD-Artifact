-- DDL extracted from 100_student_citizen_id.sql (sha256 77d421b38b994e9b0f666dcdc8538f1af408e8b4cc17f4a5099df100fba99545)
ALTER TABLE students
    ADD COLUMN IF NOT EXISTS citizen_id_no      VARCHAR(255) NULL COMMENT 'home-country national ID/citizen-card number — appEncryptPII() at write time — L4, display only, NOT lookupable' AFTER passport_expiry_date,
    ADD COLUMN IF NOT EXISTS citizen_id_no_bidx CHAR(64)     NULL COMMENT 'HMAC-SHA256(normalize(citizen_id_no), APP_PDPA_INDEX_KEY) — lookup/dedup' AFTER citizen_id_no;

ALTER TABLE students
    ADD UNIQUE KEY IF NOT EXISTS uq_students_citizen_id_bidx (tenant_id, citizen_id_no_bidx);
