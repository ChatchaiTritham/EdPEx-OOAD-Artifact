-- DDL extracted from 137_institutional_compliance_ethics.sql (sha256 f6f882495ba61cb82526d514171b905ceebe6a702a2e24bdbd4d78c76808e8d0)
CREATE TABLE IF NOT EXISTS gov_compliance_matrix (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    regulatory_domain     ENUM('mhesi_standards','pdpa_privacy','immigration_visa','research_ethics_irb','financial_procurement','occupational_safety') NOT NULL,
    regulation_code       VARCHAR(50)   NOT NULL,
    title                 VARCHAR(255)  NOT NULL COMMENT 'ชื่อกฎหมาย / ข้อบังคับ / มาตรฐาน',
    governing_body        VARCHAR(150)  NOT NULL COMMENT 'หน่วยงานกำกับดูแล e.g. สป.อว., สคส., สตม., วช., กรมบัญชีกลาง',
    key_requirements      TEXT          NOT NULL COMMENT 'ข้อกำหนดและเกณฑ์ที่ต้องปฏิบัติ',
    compliance_status     ENUM('compliant','partially_compliant','non_compliant','under_review') NOT NULL DEFAULT 'compliant',
    evidence_proof        TEXT          NULL COMMENT 'หลักฐานเชิงประจักษ์ / ระบบที่รองรับ',
    last_audited_at       DATETIME      NULL,
    next_audit_due        DATE          NULL,
    responsible_unit      VARCHAR(100)  NOT NULL,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_gov_comp_code (tenant_id, regulation_code),
    KEY idx_comp_domain (regulatory_domain),
    KEY idx_comp_stat (compliance_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS gov_ethics_whistleblower (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    tracking_code         VARCHAR(50)   NOT NULL COMMENT 'รหัสติดตามเรื่องสำหรับผู้แจ้ง',
    incident_category     ENUM('conflict_of_interest','financial_transparency','academic_integrity','harassment_discrimination','pdpa_data_breach','other') NOT NULL DEFAULT 'conflict_of_interest',
    incident_title        VARCHAR(255)  NOT NULL,
    incident_details      TEXT          NOT NULL,
    is_anonymous          TINYINT(1)    NOT NULL DEFAULT 1,
    contact_info_masked   VARCHAR(255)  NULL COMMENT 'ข้อมูลติดต่อเข้ารหัสหรือมาสก์ (ถ้าสมัครใจระบุ)',
    investigation_status  ENUM('received','under_inquiry','investigating','resolved','dismissed') NOT NULL DEFAULT 'received',
    resolution_summary    TEXT          NULL,
    assigned_auditor      VARCHAR(100)  NULL,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ethics_tracking (tenant_id, tracking_code),
    KEY idx_ethics_stat (investigation_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
