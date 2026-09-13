-- DDL extracted from 103_missing_subsystems.sql (sha256 e07e227a5ef0547ad578c34e270e8440cd43adc99167416fc786b162b3f11e32)
CREATE TABLE IF NOT EXISTS fact_short_courses (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year  SMALLINT     NOT NULL,
  course_code    VARCHAR(40)  NULL,
  course_name    VARCHAR(255) NOT NULL,
  participants   INT          NULL,
  hours          INT          NULL,
  start_date     DATE         NULL,
  source_channel VARCHAR(20)  NULL,
  source_ref     VARCHAR(190) NULL,
  evidence_url   VARCHAR(500) NULL,
  evidence_id    CHAR(36)     NULL,
  verify_status  VARCHAR(12)  NULL,
  recorded_by    CHAR(36)     NULL,
  recorded_at    DATETIME     NULL,
  created_at     DATETIME     NOT NULL DEFAULT current_timestamp(),
  INDEX ix_fsc_year (tenant_id, academic_year),
  INDEX ix_fsc_evidence (evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fact_is_datasets (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year  SMALLINT     NOT NULL,
  dataset_code   VARCHAR(40)  NULL,
  dataset_name   VARCHAR(255) NOT NULL,
  status         VARCHAR(20)  NOT NULL DEFAULT 'planned',  -- planned | in_progress | done
  planned_year   SMALLINT     NULL,
  source_channel VARCHAR(20)  NULL,
  source_ref     VARCHAR(190) NULL,
  evidence_url   VARCHAR(500) NULL,
  evidence_id    CHAR(36)     NULL,
  verify_status  VARCHAR(12)  NULL,
  recorded_by    CHAR(36)     NULL,
  recorded_at    DATETIME     NULL,
  created_at     DATETIME     NOT NULL DEFAULT current_timestamp(),
  INDEX ix_fid_year (tenant_id, academic_year),
  INDEX ix_fid_status (status),
  INDEX ix_fid_evidence (evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS fact_program_intake (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year  SMALLINT     NOT NULL,
  program_code   VARCHAR(40)  NULL,
  program_name   VARCHAR(255) NOT NULL,
  plan_target    INT          NULL,
  admitted       INT          NULL,
  met_plan       TINYINT(1)   NOT NULL DEFAULT 0,  -- 1 = รับได้ตามแผน
  source_channel VARCHAR(20)  NULL,
  source_ref     VARCHAR(190) NULL,
  evidence_url   VARCHAR(500) NULL,
  evidence_id    CHAR(36)     NULL,
  verify_status  VARCHAR(12)  NULL,
  recorded_by    CHAR(36)     NULL,
  recorded_at    DATETIME     NULL,
  created_at     DATETIME     NOT NULL DEFAULT current_timestamp(),
  INDEX ix_fpi_year (tenant_id, academic_year),
  INDEX ix_fpi_evidence (evidence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
