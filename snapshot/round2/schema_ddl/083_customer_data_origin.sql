-- DDL extracted from 083_customer_data_origin.sql (sha256 9974f3354210fb49549c890b1161eee1310a7303942cf004183ed1f835c9b3d1)
ALTER TABLE customer_complaints
  ADD COLUMN IF NOT EXISTS data_origin ENUM('seed','manual','system','import')
  NOT NULL DEFAULT 'seed' AFTER data_class;

ALTER TABLE customer_voc
  ADD COLUMN IF NOT EXISTS data_origin ENUM('seed','manual','system','import')
  NOT NULL DEFAULT 'seed' AFTER data_class;

ALTER TABLE customer_complaints ADD INDEX IF NOT EXISTS ix_cmp_origin (tenant_id, data_origin);

ALTER TABLE customer_voc        ADD INDEX IF NOT EXISTS ix_voc_origin (tenant_id, data_origin);
