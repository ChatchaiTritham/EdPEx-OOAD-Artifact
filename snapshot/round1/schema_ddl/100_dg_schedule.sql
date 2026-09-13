-- DDL extracted from 100_dg_schedule.sql (sha256 df6e19f3f40e5e92d8ddbba46b9c4e771ceadc8f8c1708553d13830c074a0b0b)
CREATE TABLE IF NOT EXISTS edpex_collection_cycles (
    id            CHAR(36)     NOT NULL  COMMENT 'appUuid() PK',
    tenant_id     CHAR(36)     NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    cycle_code    VARCHAR(40)  NOT NULL  COMMENT 'e.g. AY2569-CAT7-ANNUAL',
    label         VARCHAR(200) NOT NULL,
    academic_year SMALLINT     NOT NULL  COMMENT 'Buddhist-era AY',
    domain        VARCHAR(40)      NULL  COMMENT 'SURVEY/FINANCE/GOVERNANCE/REGISTRY/FORMULA/ALL',
    opens_date    DATE         NOT NULL,
    closes_date   DATE         NOT NULL,
    reminder_days TINYINT      NOT NULL  DEFAULT 7,
    status        ENUM('scheduled','open','closed','cancelled') NOT NULL DEFAULT 'scheduled',
    created_by    CHAR(36)     NOT NULL,
    created_at    DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cycle_code (tenant_id, cycle_code),
    KEY idx_cycle_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_collection_deadlines (
    id                CHAR(36)     NOT NULL  COMMENT 'appUuid() PK',
    tenant_id         CHAR(36)     NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    cycle_id          CHAR(36)     NOT NULL  COMMENT 'FK edpex_collection_cycles.id',
    indicator_code    VARCHAR(20)  NOT NULL  COMMENT 'FK edpex_cat7_indicators',
    owner_id          CHAR(36)         NULL  COMMENT 'R-role owner at cycle-create time (denorm)',
    due_date          DATE             NULL  COMMENT 'NULL=inherits cycle.closes_date',
    completed_at      DATETIME         NULL,
    completion_source VARCHAR(200)     NULL  COMMENT 'harvest_auto / manual:<user_id>',
    reminder_sent_at  DATETIME         NULL,
    status            ENUM('pending','in_progress','complete','overdue') NOT NULL DEFAULT 'pending',
    PRIMARY KEY (id),
    UNIQUE KEY uq_deadline (tenant_id, cycle_id, indicator_code),
    KEY idx_dl_owner  (tenant_id, owner_id),
    KEY idx_dl_status (tenant_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE edpex_milestone_status
  ADD COLUMN IF NOT EXISTS planned_date  DATE NULL
    COMMENT 'Machine-readable window start (QA data entry HITL-DG-6)',
  ADD COLUMN IF NOT EXISTS deadline_date DATE NULL
    COMMENT 'Machine-readable cut-off;

CREATE TABLE IF NOT EXISTS edpex_dg_notifications (
    id                CHAR(36)    NOT NULL  COMMENT 'appUuid() PK',
    tenant_id         CHAR(36)    NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    notification_type ENUM('deadline_approaching','overdue','owner_unassigned','benchmark_pending') NOT NULL,
    ref_type          ENUM('kpi_deadline','milestone','benchmark') NOT NULL,
    ref_id            VARCHAR(80) NOT NULL,
    owner_id          CHAR(36)        NULL  COMMENT 'FK edpex_owners.id;
