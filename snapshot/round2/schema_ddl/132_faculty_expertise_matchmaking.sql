-- DDL extracted from 132_faculty_expertise_matchmaking.sql (sha256 542b0144f5fe64b8110b0cd21d99bd91ce213f8e3812a9050ef0cd5843683e18)
CREATE TABLE IF NOT EXISTS faculty_expertise_profiles (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    personnel_code        VARCHAR(50)   NOT NULL COMMENT 'รหัสบุคลากร หรือ username',
    academic_title        VARCHAR(50)   NOT NULL DEFAULT 'อาจารย์' COMMENT 'อ., ผศ.ดร., รศ.ดร., ศ.ดร.',
    full_name_th          VARCHAR(255)  NOT NULL,
    full_name_en          VARCHAR(255)  NOT NULL,
    department            VARCHAR(100)  NOT NULL DEFAULT 'International College',
    primary_expertise     VARCHAR(255)  NOT NULL COMMENT 'ความเชี่ยวชาญหลัก e.g. Supply Chain, Digital Marketing, Fintech',
    secondary_expertise   TEXT          NULL COMMENT 'ความเชี่ยวชาญรอง / คำสำคัญ คั่นด้วยจุลภาค',
    research_interests    TEXT          NULL COMMENT 'หัวข้อวิจัยที่กำลังสนใจ',
    consulting_available  TINYINT(1)    NOT NULL DEFAULT 1 COMMENT 'พร้อมรับงานที่ปรึกษา/วิจัยร่วมกับภาคเอกชน',
    scopus_id             VARCHAR(50)   NULL,
    orcid_id              VARCHAR(50)   NULL,
    contact_email         VARCHAR(255)  NOT NULL,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_faculty_code (tenant_id, personnel_code),
    KEY idx_faculty_expertise (primary_expertise)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS industry_collaboration_requests (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    organization_name     VARCHAR(255)  NOT NULL COMMENT 'ชื่อบริษัท / องค์กรผู้ขอความร่วมมือ',
    contact_person        VARCHAR(255)  NOT NULL,
    contact_email         VARCHAR(255)  NOT NULL,
    contact_phone         VARCHAR(50)   NULL,
    project_title         VARCHAR(255)  NOT NULL COMMENT 'หัวข้อโจทย์ปัญหา / โครงการที่ต้องการความร่วมมือ',
    project_scope         TEXT          NOT NULL COMMENT 'รายละเอียดโจทย์ปัญหาและผลผลิตที่คาดหวัง',
    service_type          ENUM('joint_research','consulting','training_workshop','technology_transfer') NOT NULL DEFAULT 'consulting',
    budget_range          VARCHAR(100)  NULL COMMENT 'กรอบงบประมาณโดยประมาณ เช่น 100,000 - 300,000 บาท',
    assigned_expert_id    CHAR(36)      NULL COMMENT 'FK faculty_expertise_profiles.id',
    status                ENUM('submitted','matched','in_progress','completed','cancelled') NOT NULL DEFAULT 'submitted',
    fiscal_year           SMALLINT      NOT NULL DEFAULT 2569,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ind_stat (status),
    KEY idx_ind_yr (fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
