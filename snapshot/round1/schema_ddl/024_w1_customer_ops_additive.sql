-- DDL extracted from 024_w1_customer_ops_additive.sql (sha256 659368e630bf1057d42b88495bdd6abf07ed4679533a103670f192d2bf75142f)
CREATE TABLE IF NOT EXISTS ref_customer_segments (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  code           VARCHAR(40)  NOT NULL,
  name_th        VARCHAR(120) NOT NULL,
  is_prospective TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1 = prospective/future student (EdPEx 3.1ก(2))',
  is_active      TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order     SMALLINT     NOT NULL DEFAULT 0,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_seg_code (tenant_id, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_complaint_events (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  complaint_id CHAR(36)     NOT NULL                COMMENT 'customer_complaints.id',
  from_status  VARCHAR(20)  NULL,
  to_status    VARCHAR(20)  NOT NULL,
  note         VARCHAR(300) NULL,
  changed_by   CHAR(36)     NULL                    COMMENT 'users.id',
  changed_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_cce_complaint (complaint_id),
  KEY ix_cce_changed   (changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supply_network_partners (
  id                 CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id          CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year      SMALLINT     NOT NULL,
  partner_name       VARCHAR(190) NOT NULL,
  partner_type       VARCHAR(40)  NOT NULL DEFAULT 'supplier' COMMENT 'supplier|partner|contractor|vendor',
  selection_criteria TEXT         NULL,
  last_eval_year     SMALLINT     NULL,
  rating             TINYINT      NULL              COMMENT '1-5 annual rating',
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY ix_snp_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS risk_register (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year SMALLINT     NOT NULL,
  risk_code     VARCHAR(20)  NOT NULL,
  area          ENUM('safety','cyber','financial','continuity','other') NOT NULL DEFAULT 'other',
  title         VARCHAR(255) NOT NULL,
  likelihood    TINYINT      NOT NULL DEFAULT 3 COMMENT '1-5',
  impact        TINYINT      NOT NULL DEFAULT 3 COMMENT '1-5',
  mitigation    TEXT         NULL,
  status        ENUM('identified','mitigating','residual','closed') NOT NULL DEFAULT 'identified',
  review_year   SMALLINT     NULL,
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_risk (tenant_id, academic_year, risk_code),
  KEY ix_risk_area (area)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE customer_voc        ADD COLUMN IF NOT EXISTS deleted_at  DATETIME NULL AFTER created_at;

ALTER TABLE customer_voc        ADD COLUMN IF NOT EXISTS segment_id  CHAR(36) NULL AFTER segment;

ALTER TABLE customer_voc        ADD INDEX  IF NOT EXISTS ix_voc_deleted (deleted_at);

ALTER TABLE customer_voc        ADD INDEX  IF NOT EXISTS ix_voc_seg     (segment_id);

ALTER TABLE customer_complaints ADD COLUMN IF NOT EXISTS deleted_at  DATETIME NULL AFTER created_at;

ALTER TABLE customer_complaints ADD INDEX  IF NOT EXISTS ix_cmp_deleted (deleted_at);

ALTER TABLE evidence            ADD COLUMN IF NOT EXISTS deleted_at  DATETIME NULL AFTER created_at;

ALTER TABLE evidence            ADD INDEX  IF NOT EXISTS ix_evi_deleted (deleted_at);

ALTER TABLE improvements        ADD COLUMN IF NOT EXISTS deleted_at  DATETIME NULL AFTER created_at;

ALTER TABLE improvements        ADD INDEX  IF NOT EXISTS ix_imp_deleted (deleted_at);

ALTER TABLE km_practices ADD COLUMN IF NOT EXISTS review_cycle_id CHAR(36) NULL
  COMMENT 'assessments.id binds KM practice to the assessment cycle (MeasurementKM BC)' AFTER academic_year;

ALTER TABLE km_practices ADD INDEX IF NOT EXISTS ix_km_cycle (review_cycle_id);

ALTER TABLE work_processes ADD UNIQUE KEY IF NOT EXISTS uq_proc_year (tenant_id, academic_year, code);
