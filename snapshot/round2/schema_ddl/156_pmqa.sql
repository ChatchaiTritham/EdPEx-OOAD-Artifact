-- DDL extracted from 156_pmqa.sql (sha256 b74896547e369b07ed2d4df4f5fa4c4333b89c92ad8391dd672d4c05f3aa0019)
ALTER TABLE qh_framework_profiles
    MODIFY COLUMN framework_code ENUM('EDPEX','AUN_QA','TQF','PMQA') NOT NULL;
