-- DDL extracted from 099_enrollment_section.sql (sha256 3fb269763949c256c3cd3cc752e816b5af754b916d2e259b10a69fc9c79fc514)
ALTER TABLE student_enrollments
    ADD COLUMN IF NOT EXISTS section VARCHAR(60) NULL COMMENT 'ภาค, e.g. ภาคปกติ — distinct from level_section' AFTER level_section;
