-- DDL extracted from 098_complete_44.sql (sha256 0c273120230146c80b1c3e66c2be20b911c4e6fe224b7f235b7345cb06f4c964)
CREATE TABLE IF NOT EXISTS fact_research_projects (
  id                CHAR(36)     NOT NULL,
  tenant_id         CHAR(36)     NOT NULL,
  academic_year     SMALLINT     NOT NULL,
  project_title     VARCHAR(255) NULL,
  planned_end_year  SMALLINT     NULL,
  completed_on_time TINYINT(1)   NOT NULL DEFAULT 0,   -- 1 = finished within the planned timeframe
  created_by        CHAR(36)     NULL,
  created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_rp_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE fact_kpi_student_enrollment ADD COLUMN IF NOT EXISTS retention_y2 DECIMAL(5,2) NULL;
