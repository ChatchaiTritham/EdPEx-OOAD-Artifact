-- DDL extracted from 002_assessment.sql (sha256 26247b0ecc553ac5f10cbcdecc961f95c08ac140fd5473078c884bf8a54daa6d)
ALTER TABLE users        ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE assessments  ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE scores       ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE kpis         ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE evidence     ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE improvements ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

ALTER TABLE audit_log    ADD COLUMN IF NOT EXISTS tenant_id CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001';

CREATE TABLE IF NOT EXISTS op_responses (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  assessment_id CHAR(36)    NOT NULL,
  group_code    VARCHAR(12) NOT NULL,            -- P.1ก, P.1ข, P.2ก, P.2ข, P.2ค
  body          TEXT        NULL,
  updated_by    CHAR(36)    NULL,
  updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_op (assessment_id, group_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS item_responses (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  assessment_id CHAR(36)    NOT NULL,
  item_code     VARCHAR(8)  NOT NULL,            -- 1.1 .. 7.5
  body          TEXT        NULL,                -- คำตอบตามคำถามของหัวข้อ (ใช้ทำ SAR)
  updated_by    CHAR(36)    NULL,
  updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_item (assessment_id, item_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE scores
  ADD COLUMN IF NOT EXISTS band VARCHAR(8) NULL AFTER score_pct,   -- e.g. '50-65%'
  ADD COLUMN IF NOT EXISTS dim1 TINYINT NULL,                      -- A / Le
  ADD COLUMN IF NOT EXISTS dim2 TINYINT NULL,                      -- D / T
  ADD COLUMN IF NOT EXISTS dim3 TINYINT NULL,                      -- L / C
  ADD COLUMN IF NOT EXISTS dim4 TINYINT NULL;

ALTER TABLE evidence ADD COLUMN IF NOT EXISTS data_class TINYINT NOT NULL DEFAULT 2;
