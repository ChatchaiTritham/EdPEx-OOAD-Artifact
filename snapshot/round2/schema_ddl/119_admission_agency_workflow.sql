-- DDL extracted from 119_admission_agency_workflow.sql (sha256 7c0692047bba775d40de6ed7443e07b00043fe9516af7710a261fcbf64763e12)
CREATE TABLE IF NOT EXISTS ic_admission_agents (
    id                   CHAR(36)       NOT NULL,
    tenant_id            CHAR(36)       NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    agent_code           VARCHAR(30)    NOT NULL COMMENT 'Unique agent code e.g. AGT-CN-001',
    company_name_en      VARCHAR(255)   NOT NULL,
    company_name_th      VARCHAR(255)   NULL,
    country_code         CHAR(2)        NOT NULL DEFAULT 'CN' COMMENT 'FK ref_country.code',
    business_license_no  VARCHAR(100)   NOT NULL,
    contact_person       VARCHAR(190)   NOT NULL,
    email                VARCHAR(190)   NOT NULL,
    phone                VARCHAR(50)    NOT NULL,
    wechat_or_line       VARCHAR(100)   NULL,
    mou_contract_no      VARCHAR(100)   NULL,
    mou_start_date       DATE           NULL,
    mou_end_date         DATE           NULL,
    mou_evidence_id      CHAR(36)       NULL COMMENT 'FK ic_evidence_document.id',
    status               ENUM('pending','approved','suspended','blacklisted') NOT NULL DEFAULT 'pending',
    rating_score         DECIMAL(3,2)   NOT NULL DEFAULT 5.00,
    notes                TEXT           NULL,
    approved_by          CHAR(36)       NULL COMMENT 'FK users.id',
    approved_at          DATETIME       NULL,
    created_at           DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_agent_code (tenant_id, agent_code),
    KEY idx_agent_status (tenant_id, status),
    KEY idx_agent_country (country_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE ic_admission_applications
    ADD COLUMN IF NOT EXISTS agent_id CHAR(36) NULL COMMENT 'FK ic_admission_agents.id' AFTER applicant_type,
    ADD COLUMN IF NOT EXISTS agent_code VARCHAR(30) NULL COMMENT 'Agent code e.g. AGT-CN-001' AFTER agent_id;

ALTER TABLE ic_admission_applications
    ADD INDEX IF NOT EXISTS idx_adm_agent (agent_id);
