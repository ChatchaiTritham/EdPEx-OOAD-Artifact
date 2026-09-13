-- DDL extracted from 138_autonomous_quality_closed_loop.sql (sha256 3eca452696ea4780e7fb675d14f9b0c75634b1a136eeb52640c1a438b00ab3b3)
CREATE TABLE IF NOT EXISTS qa_continuous_improvement_tickets (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    ticket_code           VARCHAR(50)   NOT NULL,
    trigger_source        ENUM('kpi_deficit','plo_gap','employer_voc','risk_escalation','compliance_gap','manual') NOT NULL,
    source_reference_id   VARCHAR(100)  NULL COMMENT 'รหัส KPI, PLO, หรือ Risk ที่ทริกเกอร์',
    issue_title           VARCHAR(255)  NOT NULL COMMENT 'ประเด็นปัญหาหรือ Gap ที่ตรวจพบอัตโนมัติ',
    root_cause_analysis   TEXT          NULL COMMENT 'การวิเคราะห์สาเหตุที่แท้จริง (5-Whys / Fishbone)',
    improvement_goal      TEXT          NOT NULL COMMENT 'เป้าหมายและผลลัพธ์ที่ต้องการจากการปรับปรุง',
    assigned_owner        VARCHAR(100)  NOT NULL COMMENT 'ผู้รับผิดชอบกระบวนการ',
    plan_description      TEXT          NULL COMMENT 'Plan: แผนการปรับปรุงกระบวนการและมาตรการ',
    do_implementation     TEXT          NULL COMMENT 'Do: การนำแผนไปปฏิบัติจริง',
    check_measurement     TEXT          NULL COMMENT 'Check: ผลการตรวจสอบและตัวเลขวัดซ้ำ',
    act_standardization   TEXT          NULL COMMENT 'Act: การยกระดับเป็นมาตรฐานการทำงานใหม่ (SOP)',
    baseline_value        DECIMAL(10,2) NULL COMMENT 'ค่าเริ่มต้นก่อนปรับปรุง',
    target_value          DECIMAL(10,2) NULL COMMENT 'ค่าเป้าหมาย',
    reassessed_value      DECIMAL(10,2) NULL COMMENT 'ค่าที่วัดซ้ำหลังปรับปรุง',
    status                ENUM('triggered','in_action','verified_resolved','closed') NOT NULL DEFAULT 'triggered',
    due_date              DATE          NULL,
    resolved_at           DATETIME      NULL,
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cit_code (tenant_id, ticket_code),
    KEY idx_cit_stat (status),
    KEY idx_cit_source (trigger_source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qa_pdca_action_logs (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    ticket_id             CHAR(36)      NOT NULL COMMENT 'FK qa_continuous_improvement_tickets.id',
    pdca_stage            ENUM('plan','do','check','act') NOT NULL,
    action_notes          TEXT          NOT NULL,
    metric_snapshot       DECIMAL(10,2) NULL,
    recorded_by           VARCHAR(100)  NOT NULL,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_pdca_ticket (ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
