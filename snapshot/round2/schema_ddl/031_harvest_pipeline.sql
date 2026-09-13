-- DDL extracted from 031_harvest_pipeline.sql (sha256 3d88f3eddf5b22656c843203ec572687fea90cd00c6624ca1628961a57e70bf2)
CREATE TABLE IF NOT EXISTS edpex_harvest_map (
    id               CHAR(36)      NOT NULL,
    tenant_id        CHAR(36)      NOT NULL,
    indicator_code   VARCHAR(20)   NOT NULL COMMENT 'matches edpex_cat7_indicators.indicator_code',
    domain           VARCHAR(40)   NOT NULL COMMENT 'RESEARCH|HR|FINANCE|ACADEMIC_SERVICE',
    source_table     VARCHAR(80)   NOT NULL COMMENT 'legacy table name (must be in AppDB::LEGACY_TABLES)',
    source_column    VARCHAR(80)   NOT NULL,
    agg              VARCHAR(20)   NOT NULL COMMENT 'count|sum|avg|pct_filled|ratio|pct_rows|pct_cat',
    denom_column     VARCHAR(80)   NULL     DEFAULT NULL,
    filter_col       VARCHAR(80)   NULL     DEFAULT NULL,
    filter_val       VARCHAR(200)  NULL     DEFAULT NULL,
    unit             VARCHAR(40)   NULL     DEFAULT NULL,
    label            VARCHAR(200)  NULL     DEFAULT NULL COMMENT 'human-readable description',
    is_active        TINYINT(1)   NOT NULL DEFAULT 1,
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_harvest_map_code_tenant (indicator_code, tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_harvest_staging (
    id               CHAR(36)      NOT NULL,
    tenant_id        CHAR(36)      NOT NULL,
    run_id           CHAR(36)      NOT NULL COMMENT 'UUID grouping rows in one preview run',
    indicator_code   VARCHAR(20)   NOT NULL,
    domain           VARCHAR(40)   NOT NULL,
    academic_year    SMALLINT      NOT NULL,
    computed_value   DECIMAL(15,4) NULL     DEFAULT NULL,
    letci_level      TINYINT       NULL     DEFAULT NULL COMMENT 'auto-derived 0-5 or NULL if no target/data',
    letci_trend      TINYINT       NULL     DEFAULT NULL COMMENT '1=down/2=flat/3=up or NULL if <3 years',
    delta            DECIMAL(15,4) NULL     DEFAULT NULL COMMENT 'computed_value - current canonical value',
    status           ENUM('preview','approved','rejected') NOT NULL DEFAULT 'preview',
    source_label     VARCHAR(200)  NULL     DEFAULT NULL COMMENT 'e.g. research_publications.id:count',
    current_value    DECIMAL(15,4) NULL     DEFAULT NULL COMMENT 'canonical value at preview time',
    approved_by      CHAR(36)      NULL     DEFAULT NULL,
    approved_at      DATETIME      NULL     DEFAULT NULL,
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_staging_run   (run_id),
    KEY idx_staging_code_year (indicator_code, academic_year, tenant_id),
    KEY idx_staging_domain_status (domain, status, tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
