-- DDL extracted from 111_mou_curriculum_approval.sql (sha256 8165a328c3dbec7061c1beb8594cff2e68d9bc40f66a40fab6f524c2c664dfda)
CREATE TABLE IF NOT EXISTS th_ac_rmutk_ic_mou_agreements (
    id                   CHAR(36)     NOT NULL,
    tenant_id            CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    agreement_code       VARCHAR(60)  NULL COMMENT 'เลขที่ MOU/สัญญาความร่วมมือ ตามที่คู่สัญญา/มหาวิทยาลัยออกให้ ถ้ามี',
    partner_name_th      VARCHAR(255) NULL,
    partner_name_en      VARCHAR(255) NULL,
    partner_country_code VARCHAR(3)   NULL COMMENT 'FK ref_country.code (app-level)',
    agreement_type       VARCHAR(60)  NULL COMMENT 'academic_cooperation | dual_degree | student_exchange | joint_program | other',
    signed_date          DATE         NULL,
    valid_from           DATE         NULL,
    valid_until          DATE         NULL COMMENT 'NULL = ไม่ระบุวันหมดอายุ/ยังไม่ทราบ ไม่ใช่ "ไม่มีกำหนด" โดยอัตโนมัติ',
    approving_body       VARCHAR(190) NULL COMMENT 'หน่วยงานที่อนุมัติ MOU นี้ เช่น สภามหาวิทยาลัย, อว.',
    approval_ref_no      VARCHAR(100) NULL COMMENT 'เลขที่หนังสือ/มติอนุมัติ',
    approval_date        DATE         NULL,
    status                VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT 'active | expired | terminated | unknown',
    evidence_url          VARCHAR(500) NULL COMMENT 'ลิงก์ภายนอก (เช่น Google Drive) ไปยังสำเนา MOU ที่ลงนามแล้ว — ไม่ได้ host ไฟล์เอง เหมือน schema/098',
    notes                 TEXT NULL,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_mou_code (tenant_id, agreement_code),
    KEY idx_mou_status (tenant_id, status),
    KEY idx_mou_partner (tenant_id, partner_name_en)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS th_ac_rmutk_ic_curriculum_approvals (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    curriculum_code     VARCHAR(40)  NULL COMMENT 'รหัสหลักสูตร (สภามหาวิทยาลัย/สป.อว.)',
    curriculum_name_th  VARCHAR(255) NULL,
    curriculum_name_en  VARCHAR(255) NULL,
    degree_level        VARCHAR(40)  NULL COMMENT 'bachelor | master | doctoral',
    approving_body      VARCHAR(190) NULL COMMENT 'เช่น สป.อว. (TQF), สภามหาวิทยาลัย',
    approval_ref_no     VARCHAR(100) NULL,
    approval_date       DATE         NULL,
    valid_until         DATE         NULL COMMENT 'รอบหลักสูตรหมดอายุ (TQF ทบทวนทุก 5 ปี) NULL = ไม่ทราบ/ยังไม่ครบกำหนด',
    tqf_status          VARCHAR(30)  NULL COMMENT 'approved | pending | revoked | unknown',
    evidence_url        VARCHAR(500) NULL COMMENT 'ลิงก์สำเนาหนังสืออนุมัติหลักสูตร (TQF/สภามหาวิทยาลัย)',
    notes                TEXT NULL,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_curriculum_code (tenant_id, curriculum_code),
    KEY idx_curriculum_status (tenant_id, tqf_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE th_ac_rmutk_ic_student_enrollments
    ADD COLUMN IF NOT EXISTS mou_agreement_id CHAR(36) NULL
        COMMENT 'FK th_ac_rmutk_ic_mou_agreements.id (app-level) — MOU ที่เป็นฐานการรับเข้าศึกษาของนักศึกษาคนนี้ ถ้ามี' AFTER registrar_status_evidence_url,
    ADD COLUMN IF NOT EXISTS curriculum_approval_id CHAR(36) NULL
        COMMENT 'FK th_ac_rmutk_ic_curriculum_approvals.id (app-level) — หลักสูตรที่นักศึกษาคนนี้ลงทะเบียนเรียน ผูกสถานะอนุมัติ TQF' AFTER mou_agreement_id;
