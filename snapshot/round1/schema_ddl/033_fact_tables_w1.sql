-- DDL extracted from 033_fact_tables_w1.sql (sha256 66e7812b7f72f5471a4562e89a13740163eee030223163d42bb58cd2a761fd6e)
CREATE TABLE IF NOT EXISTS fact_governance_metrics (
    id                  CHAR(36)        NOT NULL,
    tenant_id           CHAR(36)        NOT NULL,
    academic_year       SMALLINT        NOT NULL COMMENT 'Buddhist-era year e.g. 2567',
    metric_code         VARCHAR(40)     NOT NULL COMMENT 'ITA|STRAT_KPI_ACHIEVED|AUDIT_RESOLVED|RISK_COVERAGE|LEGAL_COMPLIANCE|PDPA_SCORE|ETHICS_VIOLATIONS|ETHICS_TRAINED|SDG_PROJECTS|LEADERSHIP_TRUST|ITA_COMPLAINTS',
    scope               VARCHAR(30)     NOT NULL DEFAULT 'faculty' COMMENT 'faculty|unit|program',
    score               DECIMAL(10,4)   NULL     DEFAULT NULL COMMENT 'numeric result (score/pct/count per metric type)',
    findings_count      INT             NULL     DEFAULT NULL COMMENT 'number of audit findings (used by AUDIT_RESOLVED)',
    resolved_count      INT             NULL     DEFAULT NULL COMMENT 'number of findings resolved (used by AUDIT_RESOLVED)',
    coverage_pct        DECIMAL(5,2)    NULL     DEFAULT NULL COMMENT 'coverage percent (used by RISK_COVERAGE)',
    strategic_target    INT             NULL     DEFAULT NULL COMMENT 'total KPI targets (used by STRAT_KPI_ACHIEVED)',
    achieved_flag       TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = this metric row counts as achieved',
    notes               TEXT            NULL     DEFAULT NULL,
    data_source         VARCHAR(120)    NULL     DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_gov_metric_year (tenant_id, academic_year, metric_code, scope),
    KEY idx_gov_tenant_year (tenant_id, academic_year),
    KEY idx_gov_metric_code (metric_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Governance metrics (ITA/audit/risk/PDPA/ethics) per year — feeds 7-4-076…7-4-088';

CREATE TABLE IF NOT EXISTS fact_knowledge_assets (
    id                  CHAR(36)        NOT NULL,
    tenant_id           CHAR(36)        NOT NULL,
    academic_year       SMALLINT        NOT NULL COMMENT 'Buddhist-era year — the year this asset was created/registered',
    asset_type          ENUM('CoP','GoodPractice','KM','innovation','other')
                                        NOT NULL DEFAULT 'KM' COMMENT 'CoP=7-1-029 | GoodPractice=7-1-030 | KM=7-1-023 | innovation=7-1-025',
    title               VARCHAR(400)    NOT NULL COMMENT 'name/title of the knowledge asset',
    applied             TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = applied/used in org development',
    cumulative          TINYINT(1)      NOT NULL DEFAULT 0 COMMENT '1 = carries forward to subsequent years (Good Practice / cumulative)',
    description         TEXT            NULL     DEFAULT NULL,
    owner_unit          VARCHAR(120)    NULL     DEFAULT NULL COMMENT 'responsible work unit',
    sdg_tag             VARCHAR(80)     NULL     DEFAULT NULL COMMENT 'e.g. SDG4,SDG17',
    data_source         VARCHAR(120)    NULL     DEFAULT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ka_tenant_year (tenant_id, academic_year),
    KEY idx_ka_type (tenant_id, academic_year, asset_type),
    KEY idx_ka_applied (applied)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Knowledge assets (CoP/GP/KM/innovation) per year — feeds 7-1-023,025,029,030';
