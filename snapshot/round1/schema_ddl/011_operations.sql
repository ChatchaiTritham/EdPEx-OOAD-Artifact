-- DDL extracted from 011_operations.sql (sha256 4ab5959c5b03b26606ad23b29b9cb415910300444b205eae7f4c9eb078a8bc2d)
CREATE TABLE IF NOT EXISTS work_processes (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year SMALLINT     NOT NULL,
  code          VARCHAR(20)  NOT NULL,             -- PROC-001
  name          VARCHAR(160) NOT NULL,
  category      ENUM('core','support') NOT NULL DEFAULT 'core',
  owner         VARCHAR(120) NULL,                 -- ผู้รับผิดชอบกระบวนการ
  objective     VARCHAR(255) NULL,
  cycle_time    VARCHAR(80)  NULL,                 -- เป้ารอบเวลา
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_proc (tenant_id, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
