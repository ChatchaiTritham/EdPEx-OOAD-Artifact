-- DDL extracted from 123_dob_blind_index.sql (sha256 678faaa3cc53492a154c7859dfc96857db1ddcac09a4018f1ea46be9ca78384d)
ALTER TABLE th_ac_rmutk_ic_students
    ADD COLUMN IF NOT EXISTS date_of_birth_bidx CHAR(64) NULL
        COMMENT 'HMAC-SHA256(normalize(date_of_birth), APP_PDPA_INDEX_KEY) — lookup/dedup, mirrors passport_no_bidx'
        AFTER date_of_birth;

ALTER TABLE th_ac_rmutk_ic_students
    ADD INDEX IF NOT EXISTS idx_students_dob_bidx (date_of_birth_bidx);
