-- DDL extracted from 097_faculty_kpi_bank.sql (sha256 be7404e70a82678d77ef9624f0c1e5d0bc49a3f087e1b5ff486d30afdef3e5a2)
CREATE TABLE IF NOT EXISTS edpex_cat7_faculty_indicators (
    id                CHAR(36)      NOT NULL,
    tenant_id         CHAR(36)      NOT NULL,
    seq               INT           NOT NULL COMMENT 'Original xlsx sequence 1-70',
    indicator_name_th VARCHAR(300)  NOT NULL,
    unit              VARCHAR(50)   NOT NULL,
    canonical_code    VARCHAR(20)   NULL
                      COMMENT 'NULL=no-master;
