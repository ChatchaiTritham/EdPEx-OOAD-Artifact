-- DDL extracted from 012_entry_provenance.sql (sha256 dd56d9865c8f15e293b472a8da2d34e973fc4da77d66126235443469a73b480e)
ALTER TABLE kpi_values
  ADD COLUMN IF NOT EXISTS entered_by  CHAR(36) NULL AFTER updated_at,
  ADD COLUMN IF NOT EXISTS verified_by CHAR(36) NULL AFTER entered_by,
  ADD COLUMN IF NOT EXISTS verified_at DATETIME NULL AFTER verified_by;

ALTER TABLE customer_voc
  ADD COLUMN IF NOT EXISTS created_by CHAR(36) NULL AFTER data_class;

ALTER TABLE customer_complaints
  ADD COLUMN IF NOT EXISTS created_by CHAR(36) NULL AFTER data_class;
