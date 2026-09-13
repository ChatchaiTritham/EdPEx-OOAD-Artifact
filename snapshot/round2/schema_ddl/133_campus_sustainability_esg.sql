-- DDL extracted from 133_campus_sustainability_esg.sql (sha256 0145798ae686c3869568c43f5e6604a1a24422fe43d39e6b706f11772bf58f33)
CREATE TABLE IF NOT EXISTS esg_resource_consumptions (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    record_month          TINYINT       NOT NULL COMMENT '1-12 (มกราคม - ธันวาคม)',
    electricity_kwh       DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'ปริมาณการใช้ไฟฟ้า (กิโลวัตต์-ชั่วโมง)',
    water_m3              DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'ปริมาณการใช้น้ำประปา (ลูกบาศก์เมตร)',
    paper_reams           DECIMAL(8,2)  NOT NULL DEFAULT 0.00 COMMENT 'การใช้กระดาษ (รีม)',
    recycled_waste_kg     DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'ปริมาณขยะรีไซเคิล/คัดแยก (กก.)',
    carbon_emission_tco2e DECIMAL(8,3)  NOT NULL DEFAULT 0.000 COMMENT 'การปล่อยก๊าซเรือนกระจกคำนวณ (ตัน CO2e)',
    notes                 VARCHAR(255)  NULL,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_esg_month (tenant_id, fiscal_year, record_month),
    KEY idx_esg_yr (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS esg_safety_initiatives (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    initiative_name       VARCHAR(255)  NOT NULL COMMENT 'ชื่อโครงการความปลอดภัย / Green Campus / SDG',
    category              ENUM('green_campus','safety_health','energy_saving','sdg_community','zero_waste') NOT NULL DEFAULT 'green_campus',
    target_sdgs           VARCHAR(100)  NOT NULL DEFAULT 'SDG 12, SDG 13' COMMENT 'เป้าหมาย SDGs ที่เกี่ยวข้อง',
    budget_allocated      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    participants_count    INT UNSIGNED  NOT NULL DEFAULT 0 COMMENT 'จำนวนบุคลากร/นักศึกษาที่เข้าร่วม',
    outcome_summary       TEXT          NOT NULL COMMENT 'ผลลัพธ์เชิงประจักษ์และการลดผลกระทบ',
    status                ENUM('planned','in_progress','completed') NOT NULL DEFAULT 'completed',
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_init_yr (fiscal_year),
    KEY idx_init_cat (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
