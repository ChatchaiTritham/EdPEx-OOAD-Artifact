-- DDL extracted from 103_graduate_local_evidence.sql (sha256 2ab27578af9b5712a16b80a2f02564b9ddb9038e1c3f36d1d382e212e535630b)
ALTER TABLE graduates
    ADD COLUMN IF NOT EXISTS local_evidence_path VARCHAR(255) NULL COMMENT 'filename under storage/evidence/graduate_publications/, e.g. <student_code>.pdf' AFTER publication_url;
