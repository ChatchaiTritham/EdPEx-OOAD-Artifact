-- DDL extracted from 101_dg_benchmark.sql (sha256 94a4dab4aaa6c38000fd41b91ec5b284c32a67e69ce60233e9c9a93effac8baf)
CREATE TABLE IF NOT EXISTS edpex_comparison_sources (
    id          CHAR(36)     NOT NULL  COMMENT 'appUuid() PK',
    tenant_id   CHAR(36)     NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    source_code VARCHAR(40)  NOT NULL,
    source_name VARCHAR(300) NOT NULL,
    source_type ENUM('peer_institution','national_target','standard','self_target') NOT NULL,
    description VARCHAR(500)     NULL,
    url         VARCHAR(300)     NULL,
    data_year   SMALLINT         NULL,
    is_active   TINYINT(1)   NOT NULL  DEFAULT 1,
    created_by  CHAR(36)     NOT NULL,
    created_at  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_source_code (tenant_id, source_code),
    KEY idx_source_type (tenant_id, source_type, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_benchmark_entries (
    id             CHAR(36)      NOT NULL  COMMENT 'appUuid() PK',
    tenant_id      CHAR(36)      NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    indicator_code VARCHAR(20)   NOT NULL  COMMENT 'FK edpex_cat7_indicators',
    source_id      CHAR(36)      NOT NULL  COMMENT 'FK edpex_comparison_sources.id',
    academic_year  SMALLINT      NOT NULL  COMMENT 'Buddhist-era AY',
    benchmark_type ENUM('comparison','target','threshold') NOT NULL,
    value          DECIMAL(15,4) NOT NULL,
    unit           VARCHAR(50)   NOT NULL  COMMENT 'Hard-validated vs edpex_cat7_indicators.unit',
    notes          VARCHAR(500)      NULL,
    entered_by     CHAR(36)      NOT NULL,
    entered_at     DATETIME      NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    approved_by    CHAR(36)          NULL  COMMENT 'FK users.id;
