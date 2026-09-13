-- DDL extracted from 146_role_model_knowledge_transfer.sql (sha256 b2b5e2023ca92230bd8fc64fa38aa1faa11d5cd098b0163f6ece495c0de98ab3)
CREATE TABLE IF NOT EXISTS `edpex_role_model_transfers` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `topic_code` VARCHAR(64) NOT NULL,
    `edpex_category` VARCHAR(32) NOT NULL DEFAULT 'Cat 4.2',
    `knowledge_type` ENUM('best_practice', 'case_study', 'mentoring', 'open_curriculum', 'policy_whitepaper') NOT NULL DEFAULT 'best_practice',
    `target_audience` VARCHAR(255) NOT NULL DEFAULT 'Higher Education Institutions & Industry Partners',
    `external_institution_count` INT NOT NULL DEFAULT 1,
    `participants_count` INT NOT NULL DEFAULT 0,
    `satisfaction_score` DECIMAL(4, 2) NOT NULL DEFAULT 4.85,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `lead_faculty_member` VARCHAR(255) NULL,
    `status` ENUM('published', 'scheduled', 'archived') NOT NULL DEFAULT 'published',
    `impact_summary` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_rm_year` (`academic_year`),
    INDEX `idx_rm_cat` (`edpex_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_benchmark_partners` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `partner_name` VARCHAR(255) NOT NULL,
    `partner_type` ENUM('university', 'research_agency', 'industry_leader', 'government_body', 'international_consortium') NOT NULL DEFAULT 'university',
    `country` VARCHAR(64) NOT NULL DEFAULT 'Thailand',
    `collaboration_focus` VARCHAR(255) NOT NULL,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `visits_count` INT NOT NULL DEFAULT 1,
    `benchmarking_rounds` INT NOT NULL DEFAULT 1,
    `mou_status` ENUM('active', 'in_discussion', 'certified_excellence') NOT NULL DEFAULT 'active',
    `notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_bp_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
