-- DDL extracted from 006_cat7_into_arc.sql (sha256 cb056da27d84781a8b2d35e43fa6b6e26328e1b81df45c5eb900a49fcb60f3b2)
CREATE TABLE IF NOT EXISTS edpex_cat7_indicators (
    id                CHAR(36)     NOT NULL,
    tenant_id         CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    indicator_code    VARCHAR(20)  NOT NULL,
    sub_item          ENUM('7.1','7.2','7.3','7.4','7.5') NOT NULL,
    pdf_group         VARCHAR(30)  NULL,
    unit              VARCHAR(50)  NOT NULL DEFAULT '',
    indicator_name_th VARCHAR(300) NOT NULL,
    sort_order        SMALLINT     NOT NULL DEFAULT 0,
    is_active         TINYINT(1)   NOT NULL DEFAULT 1,
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cat7_code (indicator_code),
    KEY idx_cat7_sub (sub_item),
    KEY idx_cat7_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_cat7_indicator_meta (
    indicator_code   VARCHAR(20)  NOT NULL,
    tenant_id        CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    direction        ENUM('up','down','none') NOT NULL DEFAULT 'up',
    target_value     FLOAT        NULL,
    benchmark        FLOAT        NULL,
    source_type      VARCHAR(30)  NULL,
    source_table     VARCHAR(200) NULL,
    auto_extract     TINYINT(1)   NOT NULL DEFAULT 0,
    v2_ref_code      VARCHAR(20)  NULL,
    match_confidence DECIMAL(4,3) NULL,
    notes            VARCHAR(500) NULL,
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (indicator_code),
    KEY idx_meta_dir (direction)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_cat7_kpi_values (
    id              CHAR(36)      NOT NULL,
    tenant_id       CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    indicator_code  VARCHAR(20)   NOT NULL,
    academic_year   SMALLINT      NOT NULL,
    period          ENUM('annual','sem1','sem2') NOT NULL DEFAULT 'annual',
    program_key     VARCHAR(40)   NOT NULL DEFAULT '__faculty__',
    actual_value    DECIMAL(15,4) NULL,
    target_value    DECIMAL(15,4) NULL,
    benchmark_value DECIMAL(15,4) NULL,
    unit            VARCHAR(50)   NULL,
    data_source     VARCHAR(300)  NULL,
    data_quality    VARCHAR(20)   NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_val (indicator_code, academic_year, period, program_key),
    KEY idx_val_code (indicator_code),
    KEY idx_val_year (academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
