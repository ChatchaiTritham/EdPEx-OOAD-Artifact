-- DDL extracted from 122_tm30_residence_records.sql (sha256 55c6a0900d523ce3d27828a71d4264b44440f6ac171c9d63d17048cef157893d)
CREATE TABLE IF NOT EXISTS ic_tm30_record (
    id                    CHAR(36)     NOT NULL,
    tenant_id             CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id             CHAR(36)     NULL COMMENT 'FK th_ac_rmutk_ic_students.id, app-level;
