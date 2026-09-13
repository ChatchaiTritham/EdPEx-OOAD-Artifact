-- DDL extracted from 021_owners.sql (sha256 465a525822d1c8487fccbb914c688ab74b71d01e36f78d37ed4efa85748541be)
CREATE TABLE IF NOT EXISTS edpex_owners (
  id         CHAR(36)     NOT NULL,
  tenant_id  CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  name       VARCHAR(190) NOT NULL,                    -- role label or a real person's name
  role_title VARCHAR(190) NULL,                        -- optional note (e.g. "ตามโครงสร้าง p.9")
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order SMALLINT     NOT NULL DEFAULT 0,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_owner_name (tenant_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
