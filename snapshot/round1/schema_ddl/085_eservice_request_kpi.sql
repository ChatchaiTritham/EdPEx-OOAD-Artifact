-- DDL extracted from 085_eservice_request_kpi.sql (sha256 f7d2b8e881884ba58609ef58fc32a4f711b959d8595655d1da57cd061f921b95)
ALTER TABLE eservice_request
  ADD COLUMN IF NOT EXISTS fee          DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER status,
  ADD COLUMN IF NOT EXISTS contact_hash CHAR(64)      NULL             AFTER contact_enc;

ALTER TABLE eservice_request
  ADD INDEX IF NOT EXISTS ix_esreq_contact (tenant_id, academic_year, contact_hash);

ALTER TABLE eservice_definition
  ADD COLUMN IF NOT EXISTS fee DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER sla_days;
