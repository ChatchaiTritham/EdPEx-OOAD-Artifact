-- DDL extracted from 098_mhesi_evidence_links.sql (sha256 77a58d22b70ae1d6b250cad744dc84b74d2507855405fa92ca5d6cd7301dd6e0)
ALTER TABLE student_enrollments
    ADD COLUMN IF NOT EXISTS passport_evidence_url  VARCHAR(500) NULL COMMENT 'external link (e.g. Google Drive), not a locally-held file' AFTER g_code,
    ADD COLUMN IF NOT EXISTS residence_evidence_url VARCHAR(500) NULL COMMENT 'หลักฐานการพำนักอยู่ในราชอาณาจักรไทย — external link' AFTER passport_evidence_url,
    ADD COLUMN IF NOT EXISTS visa_evidence_url       VARCHAR(500) NULL COMMENT 'หลักฐานการตรวจลงตรา VISA — external link' AFTER residence_evidence_url;
