-- DDL extracted from 009_strategy.sql (sha256 b6e123b7d71efda3e12b91bf64a320d8b6ed96e6568420ef16c2d312dcfff26e)
CREATE TABLE IF NOT EXISTS strategic_objective (
  id              CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id       CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  code            VARCHAR(20)  NOT NULL,                 -- SO-01 …
  strategy_no     TINYINT      NULL,                     -- อิงประเด็นยุทธศาสตร์ 1-3 (strategic_kpi)
  title           VARCHAR(300) NOT NULL,
  description     TEXT         NULL,
  perspective     ENUM('financial','customer','process','learning') NOT NULL DEFAULT 'process',
  timeframe_start SMALLINT     NULL,                     -- พ.ศ.
  timeframe_end   SMALLINT     NULL,
  owner           VARCHAR(120) NULL,
  status          ENUM('draft','active','achieved','dropped') NOT NULL DEFAULT 'active',
  sort            SMALLINT     NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_so_code (code),
  KEY idx_so_perspective (perspective)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS swot_item (
  id                  CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id           CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  quadrant            ENUM('S','W','O','T') NOT NULL,    -- Strength/Weakness/Opportunity/Threat
  title               VARCHAR(300) NOT NULL,
  detail              TEXT         NULL,
  impact              TINYINT      NULL,                 -- 1-5
  likelihood          TINYINT      NULL,                 -- 1-5 (สำหรับ O/T)
  source              VARCHAR(200) NULL,                 -- ที่มาข้อมูล
  linked_objective_id CHAR(36)     NULL,                 -- TOWS → วัตถุประสงค์
  sort                SMALLINT     NOT NULL DEFAULT 0,
  created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_swot_quadrant (quadrant)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS action_plan (
  id               CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  objective_id     CHAR(36)      NULL,
  strategic_kpi_id CHAR(36)      NULL,
  title            VARCHAR(300)  NOT NULL,
  owner            VARCHAR(120)  NULL,
  org_unit         VARCHAR(120)  NULL,                   -- หน่วยงานที่รับถ่ายทอด
  budget           DECIMAL(14,2) NULL,
  start_date       DATE          NULL,
  end_date         DATE          NULL,
  progress_pct     TINYINT       NOT NULL DEFAULT 0,
  status           ENUM('planned','in_progress','done','delayed') NOT NULL DEFAULT 'planned',
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_ap_objective (objective_id),
  KEY idx_ap_kpi (strategic_kpi_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS strategic_projection (
  id               CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  strategic_kpi_id CHAR(36)      NOT NULL,
  org_unit         VARCHAR(120)  NOT NULL,
  budget_year      SMALLINT      NOT NULL,               -- ปีงบที่คาดการณ์
  projected_value  DECIMAL(12,2) NULL,
  benchmark_value  DECIMAL(12,2) NULL,
  basis            VARCHAR(120)  NULL,                   -- วิธีคาดการณ์ (CAGR/linear/expert)
  created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_proj (strategic_kpi_id, org_unit, budget_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
