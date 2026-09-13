-- DDL extracted from 036_harvest_map_source_db.sql (sha256 2abf1ef23a662cbf981d2d6623f7429429849cae6293c7044e14aade08f0bc7d)
ALTER TABLE edpex_harvest_map
    ADD COLUMN IF NOT EXISTS source_db ENUM('legacy','arc') NOT NULL DEFAULT 'legacy'
        COMMENT 'legacy=AppDB::legacy() bridge | arc=direct Arc table via AppDB'
        AFTER domain;

ALTER TABLE edpex_harvest_map
    ADD COLUMN IF NOT EXISTS year_column VARCHAR(30) NULL DEFAULT NULL
        COMMENT 'column name for year filter (e.g. academic_year). NULL = no year filter (backward-compat)'
        AFTER source_db;
