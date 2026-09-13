-- DDL extracted from 078_governance_assess_staging.sql (sha256 2edf6d49bbfb1e4f973372460f1c91d23621f8eda9598bdc98ae97044d5361ef)
CREATE TABLE IF NOT EXISTS governance_assess_staging (
  id              CHAR(36)     NOT NULL,
  tenant_id       CHAR(36)     NOT NULL,
  run_id          CHAR(36)     NOT NULL,                       -- groups one assess() call
  framework       VARCHAR(16)  NOT NULL,                       -- DGA|PDPA|ISO27001|NISTCSF|ALL
  scope           VARCHAR(64)  NULL,                           -- optional pillar/family filter
  assessed_by_wf  VARCHAR(64)  NOT NULL DEFAULT 'WF_DG_ASSESS',-- system workflow code (naming standard)
  pillar_scores   JSON         NOT NULL,                       -- [{framework,pillar,score}, ...]
  framework_score DECIMAL(5,2) NOT NULL DEFAULT 0,
  dgscore_preview DECIMAL(5,2) NULL,                           -- full DGSCORE rollup (framework=ALL)
  status          VARCHAR(16)  NOT NULL DEFAULT 'staged',      -- staged|approved|rejected
  approved_by     CHAR(36)     NULL,                           -- users.id of HITL approver
  approved_at     DATETIME     NULL,
  reject_reason   VARCHAR(512) NULL,
  created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_run (run_id),
  KEY idx_tenant_fw (tenant_id, framework, status),
  KEY idx_approver (approved_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
