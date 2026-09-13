-- DDL extracted from 032_cat7_letci_auto_source.sql (sha256 841f2e9ed25fbfa8d80c820e2cfbdbd8616e8475696b1a860326f44e6115db7b)
ALTER TABLE edpex_cat7_kpi_values
    ADD COLUMN IF NOT EXISTS letci_auto_source VARCHAR(200) NULL DEFAULT NULL
        COMMENT 'NULL=human;
