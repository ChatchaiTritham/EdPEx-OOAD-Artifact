-- DDL extracted from 136_knowledge_management_cop.sql (sha256 668d8ae330144599e5026cac5bca3aceecc4ecfb3831e5f1e4ed174028472d6c)
CREATE TABLE IF NOT EXISTS km_knowledge_assets (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    asset_code            VARCHAR(50)   NOT NULL,
    title                 VARCHAR(255)  NOT NULL COMMENT 'ชื่อองค์ความรู้ / แนวปฏิบัติที่ดี (Best Practice)',
    category              ENUM('curriculum_obe','international_students','research_commercial','procurement_finance','it_automation','edpex_tqa') NOT NULL DEFAULT 'curriculum_obe',
    knowledge_type        ENUM('best_practice','lessons_learned','standard_sop','troubleshooting') NOT NULL DEFAULT 'best_practice',
    context_problem       TEXT          NOT NULL COMMENT 'บริบท ปัญหา หรือโจทย์ความท้าทายก่อนการแก้ปัญหา',
    solution_approach     TEXT          NOT NULL COMMENT 'แนวทางหรือขั้นตอนการปฏิบัติที่เป็นเลิศ (SOP / Best Practice Guide)',
    results_impact        TEXT          NOT NULL COMMENT 'ผลลัพธ์เชิงประจักษ์และการนำไปขยายผล',
    author_team           VARCHAR(255)  NOT NULL COMMENT 'เจ้าขององค์ความรู้ / คณะทำงาน',
    keywords              VARCHAR(255)  NULL COMMENT 'คำสำคัญ คั่นด้วยจุลภาค',
    document_url          VARCHAR(255)  NULL COMMENT 'ลิงก์เอกสารคู่มือ / วิดีโออ้างอิง',
    likes_count           INT UNSIGNED  NOT NULL DEFAULT 0,
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_km_code (tenant_id, asset_code),
    KEY idx_km_cat (category),
    KEY idx_km_type (knowledge_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS km_cop_discussions (
    id                    CHAR(36)      NOT NULL,
    tenant_id             VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    asset_id              CHAR(36)      NULL COMMENT 'FK km_knowledge_assets.id (ถ้าเกี่ยวข้อง)',
    topic_title           VARCHAR(255)  NOT NULL,
    message_content       TEXT          NOT NULL,
    contributor_name      VARCHAR(255)  NOT NULL,
    contributor_role      VARCHAR(100)  NOT NULL DEFAULT 'อาจารย์/บุคลากร',
    parent_id             CHAR(36)      NULL COMMENT 'สำหรับตอบกลับกระทู้เดิม',
    created_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_cop_asset (asset_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
