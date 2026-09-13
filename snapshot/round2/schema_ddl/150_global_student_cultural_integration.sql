-- DDL extracted from 150_global_student_cultural_integration.sql (sha256 06692129214eee319b8c701533b4488d7349cef81c8a5975fc5ff63d51e9415e)
CREATE TABLE IF NOT EXISTS `edpex_cultural_adaptations` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `student_id` VARCHAR(64) NULL,
    `student_code` VARCHAR(64) NOT NULL,
    `student_name` VARCHAR(255) NOT NULL,
    `nationality` VARCHAR(64) NOT NULL DEFAULT 'Chinese',
    `program_name` VARCHAR(255) NOT NULL,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `semester` VARCHAR(16) NOT NULL DEFAULT '1',
    `adaptation_index` DECIMAL(4, 2) NOT NULL DEFAULT 85.00,
    `thai_language_proficiency` ENUM('beginner', 'intermediate', 'proficient', 'fluent') NOT NULL DEFAULT 'intermediate',
    `wellbeing_status` ENUM('thriving', 'stable', 'support_needed', 'critical_intervention') NOT NULL DEFAULT 'thriving',
    `buddy_assigned` VARCHAR(255) NULL,
    `cultural_activity_points` INT NOT NULL DEFAULT 15,
    `counselor_notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_ca_year` (`academic_year`),
    INDEX `idx_ca_nat` (`nationality`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_global_sponsor_relations` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `sponsor_name` VARCHAR(255) NOT NULL,
    `sponsor_type` ENUM('embassy', 'foreign_university', 'government_scholarship', 'international_foundation') NOT NULL DEFAULT 'embassy',
    `country` VARCHAR(64) NOT NULL DEFAULT 'China',
    `sponsored_students_count` INT NOT NULL DEFAULT 10,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `annual_support_value` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `satisfaction_score` DECIMAL(4, 2) NOT NULL DEFAULT 4.90,
    `partnership_status` ENUM('active', 'expanding', 'in_review') NOT NULL DEFAULT 'active',
    `contact_person` VARCHAR(255) NULL,
    `notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_gsr_year` (`academic_year`),
    INDEX `idx_gsr_type` (`sponsor_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
