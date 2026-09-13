-- DDL extracted from 016_strategy_2_1_process.sql (sha256 fcb87fb5a186c1f71c783b4d5c266d44d34e295dd4dfc2624bacee791b541a36)
CREATE TABLE IF NOT EXISTS strategy_process (
  id                    CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id             CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  academic_year         SMALLINT      NOT NULL,
  planning_horizon_th   VARCHAR(100)  NULL,
  cadence_desc          TEXT          NULL,
  process_steps         TEXT          NULL,
  responsible_unit      VARCHAR(200)  NULL,
  data_sources          TEXT          NULL,
  strategic_challenges  TEXT          NULL,
  strategic_advantages  TEXT          NULL,
  blind_spots           TEXT          NULL,
  stakeholder_inputs    TEXT          NULL,
  is_active             TINYINT(1)    NOT NULL DEFAULT 1,
  created_by            CHAR(36)      NULL,
  updated_by            CHAR(36)      NULL,
  created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_sp_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE strategic_objective
  ADD COLUMN IF NOT EXISTS short_term_goal     TEXT NULL AFTER description,
  ADD COLUMN IF NOT EXISTS long_term_goal      TEXT NULL AFTER short_term_goal,
  ADD COLUMN IF NOT EXISTS stakeholder_balance TEXT NULL AFTER long_term_goal;

ALTER TABLE strategic_projection
  ADD COLUMN IF NOT EXISTS methodology      ENUM('CAGR','linear','expert','trend','benchmark','other') NULL AFTER basis,
  ADD COLUMN IF NOT EXISTS competitor_name  VARCHAR(200) NULL AFTER methodology,
  ADD COLUMN IF NOT EXISTS benchmark_source VARCHAR(200) NULL AFTER competitor_name;
