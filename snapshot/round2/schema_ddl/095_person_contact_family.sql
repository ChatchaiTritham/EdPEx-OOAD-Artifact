-- DDL extracted from 095_person_contact_family.sql (sha256 441c62023aa5f505d9eab4617c82829e473aa3b710a13a522df040c0921a5dac)
ALTER TABLE ic_person
    ADD COLUMN IF NOT EXISTS address_line1       VARCHAR(190) NULL AFTER passport_expiry_date,
    ADD COLUMN IF NOT EXISTS address_line2       VARCHAR(190) NULL COMMENT 'เขต/อำเภอ' AFTER address_line1,
    ADD COLUMN IF NOT EXISTS address_province    VARCHAR(120) NULL AFTER address_line2,
    ADD COLUMN IF NOT EXISTS address_postal_code VARCHAR(20)  NULL AFTER address_province,
    ADD COLUMN IF NOT EXISTS address_country_code CHAR(2)     NULL COMMENT 'FK ref_country.code (app-level)' AFTER address_postal_code,
    ADD COLUMN IF NOT EXISTS phone_mobile        VARCHAR(40)  NULL AFTER address_country_code,
    ADD COLUMN IF NOT EXISTS work_status         ENUM('not_working','working') NULL AFTER phone_mobile,
    ADD COLUMN IF NOT EXISTS work_company        VARCHAR(190) NULL AFTER work_status,
    ADD COLUMN IF NOT EXISTS work_position        VARCHAR(120) NULL AFTER work_company,
    ADD COLUMN IF NOT EXISTS family_income_range VARCHAR(60)  NULL COMMENT 'free-text range as printed by the registrar system, e.g. "150,000-300,000"' AFTER work_position;

ALTER TABLE ic_student_enrollment
    ADD COLUMN IF NOT EXISTS advisor_name         VARCHAR(190) NULL AFTER g_code,
    ADD COLUMN IF NOT EXISTS prior_education_level VARCHAR(120) NULL AFTER advisor_name,
    ADD COLUMN IF NOT EXISTS prior_school         VARCHAR(255) NULL AFTER prior_education_level,
    ADD COLUMN IF NOT EXISTS admit_date           DATE         NULL COMMENT 'exact registrar date, complements admit_year/admit_semester' AFTER prior_school,
    ADD COLUMN IF NOT EXISTS credits_earned       SMALLINT     NULL AFTER admit_date,
    ADD COLUMN IF NOT EXISTS credits_registered   SMALLINT     NULL AFTER credits_earned,
    ADD COLUMN IF NOT EXISTS gpa                  DECIMAL(3,2) NULL AFTER credits_registered;

CREATE TABLE IF NOT EXISTS ic_family_contact (
    id             CHAR(36)     NOT NULL,
    tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id      CHAR(36)     NOT NULL COMMENT 'FK ic_person.id (app-level) — the STUDENT, not this contact',
    role           ENUM('father','mother','guardian','emergency_contact') NOT NULL,
    name           VARCHAR(190) NULL,
    occupation     VARCHAR(190) NULL,
    relationship   VARCHAR(60)  NULL COMMENT 'ความสัมพันธ์กับนักศึกษา ตามที่ระบบต้นทางระบุ (มักซ้ำกับ role)',
    is_deceased    TINYINT(1)   NOT NULL DEFAULT 0,
    phone          VARCHAR(40)  NULL,
    email          VARCHAR(190) NULL,
    address_line1  VARCHAR(190) NULL,
    address_line2  VARCHAR(190) NULL,
    address_province VARCHAR(120) NULL,
    address_postal_code VARCHAR(20) NULL,
    address_country_code CHAR(2) NULL COMMENT 'FK ref_country.code (app-level)',
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_family_contact_role (tenant_id, person_id, role),
    KEY idx_family_contact_person (person_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
