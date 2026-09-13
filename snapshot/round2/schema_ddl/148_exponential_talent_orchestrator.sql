-- DDL extracted from 148_exponential_talent_orchestrator.sql (sha256 e960b372a3a42d6bc5bccdfdaeb906a1a3643dc1100118d801883fd1c0074379)
CREATE TABLE IF NOT EXISTS `edpex_talent_orchestrations` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `talent_name` VARCHAR(255) NOT NULL,
    `employee_code` VARCHAR(64) NOT NULL,
    `department` VARCHAR(128) NOT NULL,
    `role_type` ENUM('faculty', 'researcher', 'innovator', 'postdoc', 'technical_expert') NOT NULL DEFAULT 'faculty',
    `future_skill_domain` VARCHAR(255) NOT NULL,
    `readiness_level` ENUM('emerging', 'proficient', 'expert', 'global_fellow') NOT NULL DEFAULT 'expert',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `h_index` INT NOT NULL DEFAULT 0,
    `global_grants_value` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `exponential_impact_score` DECIMAL(4, 2) NOT NULL DEFAULT 85.00,
    `mentorship_status` ENUM('active_mentor', 'mentee', 'program_lead') NOT NULL DEFAULT 'active_mentor',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_to_year` (`academic_year`),
    INDEX `idx_to_dept` (`department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_workforce_agility_metrics` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `quarter` VARCHAR(16) NOT NULL DEFAULT 'Q1',
    `overall_engagement_score` DECIMAL(4, 2) NOT NULL DEFAULT 91.50,
    `wellbeing_index` DECIMAL(4, 2) NOT NULL DEFAULT 88.00,
    `cognitive_agility_score` DECIMAL(4, 2) NOT NULL DEFAULT 86.50,
    `retention_rate_percent` DECIMAL(5, 2) NOT NULL DEFAULT 97.50,
    `high_trust_culture_index` DECIMAL(4, 2) NOT NULL DEFAULT 92.00,
    `evaluated_workforce_count` INT NOT NULL DEFAULT 150,
    `key_interventions` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_wa_year_q` (`academic_year`, `quarter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
