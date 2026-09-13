-- DDL extracted from 093_person_student_code_key.sql (sha256 d2b2c499c7b6d36fb5661c494648a381f61a2dede0d009db64e54a1d24ffd989)
ALTER TABLE ic_person
    ADD COLUMN IF NOT EXISTS student_code VARCHAR(20) NULL AFTER person_type;

ALTER TABLE ic_person
    ADD UNIQUE KEY IF NOT EXISTS uq_person_student_code (tenant_id, student_code);
