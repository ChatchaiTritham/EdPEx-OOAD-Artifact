-- DDL extracted from 010_customer.sql (sha256 0373ffd31a819c0da2c8a349f60724e01f9471eb7cafa57f3762b7859387b9ae)
CREATE TABLE IF NOT EXISTS customer_voc (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year SMALLINT     NOT NULL,
  segment       VARCHAR(40)  NOT NULL,            -- นักศึกษา/ผู้ใช้บัณฑิต/ศิษย์เก่า/ผู้ปกครอง/ชุมชน
  item_ref      VARCHAR(8)   NULL,                -- 3.1 / 3.2 / kpi code
  attribute     VARCHAR(160) NOT NULL,            -- ด้าน/ความต้องการ
  importance    DECIMAL(4,2) NULL,                -- ความสำคัญ 1-5 (IPA x)
  performance   DECIMAL(4,2) NULL,                -- การรับรู้/พึงพอใจ 1-5 (IPA y)
  sentiment     ENUM('pos','neu','neg') NULL,
  comment       TEXT         NULL,
  data_class    TINYINT      NOT NULL DEFAULT 2,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_voc_year (academic_year, segment)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_complaints (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year SMALLINT    NOT NULL,
  segment       VARCHAR(40) NULL,
  category      VARCHAR(80) NOT NULL,             -- ประเภท (Pareto)
  channel       VARCHAR(40) NULL,
  received_at   DATE        NULL,
  resolved_at   DATE        NULL,
  status        ENUM('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
  data_class    TINYINT     NOT NULL DEFAULT 2,
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_cmp_year (academic_year, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
