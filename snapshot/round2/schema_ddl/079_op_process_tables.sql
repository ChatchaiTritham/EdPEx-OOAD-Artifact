-- DDL extracted from 079_op_process_tables.sql (sha256 ca58df08ae2d4e5d32b6c4aea5de1af97f25f3ecf1dbf945634891e42899d269)
CREATE TABLE IF NOT EXISTS edpex_op_table (
  id            CHAR(36)     NOT NULL,
  tenant_id     CHAR(36)     NOT NULL,
  assessment_id CHAR(36)     NULL,                          -- NULL = applies to any round
  group_code    VARCHAR(16)  NOT NULL,                      -- OP group it sits under (P.1ก(2), P.1ก(3)…)
  table_key     VARCHAR(64)  NOT NULL,                      -- vmv|workforce|laws|assets|stakeholders…
  title         VARCHAR(255) NOT NULL DEFAULT '',
  col_headers   JSON         NOT NULL,                      -- ["คอลัมน์1","คอลัมน์2", …] (reserved-word-safe)
  row_data      JSON         NOT NULL,                      -- [["a","b"], …] cells aligned to col_headers
  sort          INT          NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tenant_group (tenant_id, group_code, sort),
  KEY idx_assessment (assessment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_process_control (
  id            CHAR(36)     NOT NULL,
  tenant_id     CHAR(36)     NOT NULL,
  assessment_id CHAR(36)     NULL,
  item_code     VARCHAR(16)  NOT NULL,                      -- 6.1, 6.2ก, 6.2ค(3)…
  process_name  VARCHAR(255) NOT NULL DEFAULT '',           -- กระบวนการ
  objective     TEXT         NULL,                          -- วัตถุประสงค์
  method        TEXT         NULL,                          -- วิธีการ/กิจกรรม
  control_tool  VARCHAR(255) NULL,                          -- เครื่องมือควบคุม
  frequency     VARCHAR(128) NULL,                          -- ความถี่การควบคุม
  report_method VARCHAR(255) NULL,                          -- วิธีการรายงาน
  owner         VARCHAR(255) NULL,                          -- ผู้รับผิดชอบ
  sort          INT          NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tenant_item (tenant_id, item_code, sort),
  KEY idx_assessment (assessment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
