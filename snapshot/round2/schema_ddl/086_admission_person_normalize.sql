-- DDL extracted from 086_admission_person_normalize.sql (sha256 2fa93d556575fc75cc9078790a3acaea3b49cba02254cc162e28d6c7ed7f7a5e)
ALTER TABLE ic_person
  ADD COLUMN IF NOT EXISTS nationality_code CHAR(2) NULL COMMENT 'FK ref_country.code (app-level)'
  AFTER nationality;

ALTER TABLE ic_person
  DROP COLUMN IF EXISTS nationality;

ALTER TABLE ic_person ADD INDEX IF NOT EXISTS idx_person_nationality (tenant_id, nationality_code);

ALTER TABLE ic_visa_record
  ADD COLUMN IF NOT EXISTS deleted_at DATETIME NULL COMMENT 'PDPA retention/erasure, same as ic_person'
  AFTER evidence_document_id;

ALTER TABLE ic_visa_record ADD INDEX IF NOT EXISTS idx_visa_deleted (deleted_at);
