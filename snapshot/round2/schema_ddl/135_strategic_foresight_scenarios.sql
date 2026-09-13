-- DDL extracted from 135_strategic_foresight_scenarios.sql (sha256 edfb3608c68bbac818f194256654dff56eb2a26f7894b8d71b3aec1f6f802070)
CREATE TABLE IF NOT EXISTS strat_foresight_signals (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    signal_code           VARCHAR(50)   NOT NULL,
    signal_category       ENUM('demographic','technological_ai','economic_labor','geopolitical_policy','environmental') NOT NULL,
    trend_title           VARCHAR(255)  NOT NULL COMMENT 'หัวข้อแนวโน้มหรือสัญญาณการเปลี่ยนแปลง',
    description           TEXT          NOT NULL COMMENT 'รายละเอียดการเปลี่ยนแปลงที่ตรวจพบ',
    time_horizon          ENUM('short_1y','medium_3y','long_5y') NOT NULL DEFAULT 'medium_3y' COMMENT 'กรอบเวลาที่คาดว่าจะเกิดผลกระทบ',
    impact_level          ENUM('low','moderate','high','transformational') NOT NULL DEFAULT 'high',
    strategic_implication TEXT          NOT NULL COMMENT 'นัยยะเชิงกลยุทธ์ต่อวิทยาลัย/หลักสูตร',
    status                ENUM('watching','acting','integrated') NOT NULL DEFAULT 'watching',
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_foresight_code (tenant_id, signal_code),
    KEY idx_signal_cat (signal_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS strat_scenario_models (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    scenario_type         ENUM('best_case','base_case','worst_case') NOT NULL,
    target_year           SMALLINT      NOT NULL COMMENT 'ปีการศึกษาคาดการณ์ เช่น 2570, 2571, 2572',
    projected_intake_intl INT UNSIGNED  NOT NULL DEFAULT 0 COMMENT 'คาดการณ์จำนวนนักศึกษาต่างชาติแรกเข้า',
    projected_intake_thai INT UNSIGNED  NOT NULL DEFAULT 0 COMMENT 'คาดการณ์จำนวนนักศึกษาไทยแรกเข้า',
    projected_tuition_thb DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT 'คาดการณ์รายได้ค่าธรรมเนียมการศึกษา (บาท)',
    key_assumptions       TEXT          NOT NULL COMMENT 'สมมติฐานหลักของฉากทัศน์นี้',
    contingency_strategy  TEXT          NOT NULL COMMENT 'กลยุทธ์รองรับ / แผนสำรองเผชิญเหตุ (Contingency Plan)',
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_scenario_type_yr (tenant_id, scenario_type, target_year),
    KEY idx_scen_yr (target_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
