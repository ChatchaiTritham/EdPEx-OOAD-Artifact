-- DDL extracted from 008_strategic_kpi.sql (sha256 15d34745898c2f6d39c80f281293db7c4a57a778bd19eb723610caffb6ee4bd8)
CREATE TABLE IF NOT EXISTS strategic_kpi (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id   CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  strategy_no TINYINT      NOT NULL,            -- ประเด็นยุทธศาสตร์ 1-3
  seq         SMALLINT     NOT NULL,            -- ลำดับในเอกสาร 1-22
  code        VARCHAR(20)  NOT NULL,            -- SP69-01 … SP69-22
  name_th     VARCHAR(500) NOT NULL,
  unit        VARCHAR(50)  NOT NULL DEFAULT '', -- ล้านบาท / ร้อยละ / คะแนน / เรื่อง …
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_sp_code (code),
  KEY idx_sp_strategy (strategy_no, seq)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS strategic_kpi_target (
  id               CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  strategic_kpi_id CHAR(36)      NOT NULL,
  budget_year      SMALLINT      NOT NULL,           -- ปีงบประมาณ พ.ศ. (เช่น 2569)
  org_unit         VARCHAR(120)  NOT NULL,           -- 'คณะวิทยาศาสตร์และเทคโนโลยี' | 'มหาวิทยาลัย' …
  target_value     DECIMAL(12,2) NULL,               -- NULL = เว้นว่างในต้นฉบับ (ไม่มีเป้า)
  actual_value     DECIMAL(12,2) NULL,
  data_status      ENUM('pending','entered','verified') NOT NULL DEFAULT 'entered',
  source_note      VARCHAR(200)  NULL,               -- หมายเหตุเจ้าของข้อมูล (เช่น Data Hub: กองนโยบายและแผน)
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_sp_target (strategic_kpi_id, budget_year, org_unit),
  KEY idx_sp_year_unit (budget_year, org_unit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
