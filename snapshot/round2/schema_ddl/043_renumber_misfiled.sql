-- DDL extracted from 043_renumber_misfiled.sql (sha256 f016e1cfcda31e17a21fa4ad125b1f9f0484e463b2f234c674944a465d37395d)
CREATE TABLE IF NOT EXISTS edpex_kpi_quality_backup (
    id             CHAR(36)     NOT NULL,
    batch_id       CHAR(36)     NOT NULL,
    value_id       CHAR(36)     NOT NULL,
    indicator_code VARCHAR(20)  NOT NULL,
    academic_year  SMALLINT     NOT NULL,
    old_quality    VARCHAR(20)  NULL,
    old_source     VARCHAR(200) NULL,
    restored_at    DATETIME     NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY ix_qb_batch (batch_id),
    KEY ix_qb_value (value_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
