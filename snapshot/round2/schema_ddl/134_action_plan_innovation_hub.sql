-- DDL extracted from 134_action_plan_innovation_hub.sql (sha256 94f1651977c5cc72ad6b0974e0119ed44c9caa74df246011366cefcf379ce0c2)
CREATE TABLE IF NOT EXISTS strat_action_plans (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    plan_code             VARCHAR(50)   NOT NULL COMMENT 'รหัสโครงการ e.g. ACT-2569-01',
    strategic_objective   VARCHAR(255)  NOT NULL COMMENT 'วัตถุประสงค์เชิงยุทธศาสตร์ / SO',
    project_name          VARCHAR(255)  NOT NULL COMMENT 'ชื่อโครงการตามแผนปฏิบัติการ',
    lead_owner            VARCHAR(100)  NOT NULL COMMENT 'ผู้รับผิดชอบหลัก',
    budget_allocated      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    budget_spent          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    progress_percent      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'ความก้าวหน้ารวม 0-100%',
    status                ENUM('on_track','delayed','at_risk','completed') NOT NULL DEFAULT 'on_track',
    target_quarter        ENUM('Q1','Q2','Q3','Q4','full_year') NOT NULL DEFAULT 'full_year',
    milestone_summary     TEXT          NULL COMMENT 'ความสำเร็จของ Milestone ล่าสุด',
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_plan_code_yr (tenant_id, plan_code, fiscal_year),
    KEY idx_plan_stat (status),
    KEY idx_plan_yr (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS strat_process_innovations (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    innovation_name       VARCHAR(255)  NOT NULL COMMENT 'ชื่อนวัตกรรมกระบวนการ / เทคโนโลยีดิจิทัล',
    work_process_category VARCHAR(100)  NOT NULL DEFAULT 'Academic & Services' COMMENT 'หมวดกระบวนการทำงาน',
    pain_point_addressed  TEXT          NOT NULL COMMENT 'ปัญหาเดิมหรือจุดบกพร่องก่อนการปรับปรุง',
    innovation_solution   TEXT          NOT NULL COMMENT 'วิธีคิดและนวัตกรรมใหม่ที่นำมาใช้',
    efficiency_gain       VARCHAR(255)  NOT NULL COMMENT 'ผลลัพธ์ประสิทธิภาพ เช่น ลดเวลาลง 75%, ลดต้นทุน 120,000 บาท/ปี',
    awards_recognition    VARCHAR(255)  NULL COMMENT 'รางวัล หรือผลการประเมินการยอมรับระดับชาติ/นานาชาติ',
    initiator_team        VARCHAR(255)  NOT NULL,
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_innov_yr (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
