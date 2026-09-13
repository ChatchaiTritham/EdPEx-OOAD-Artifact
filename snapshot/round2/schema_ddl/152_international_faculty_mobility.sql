-- DDL extracted from 152_international_faculty_mobility.sql (sha256 387442c246659667002b4c3d745bb1a43047b4950d1d27bdd9431d1ec38b677a)
CREATE TABLE IF NOT EXISTS `edpex_international_faculty_profiles` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `faculty_name` VARCHAR(255) NOT NULL,
    `faculty_code` VARCHAR(64) NOT NULL,
    `nationality` VARCHAR(64) NOT NULL DEFAULT 'United Kingdom',
    `home_institution` VARCHAR(255) NOT NULL,
    `appointment_type` ENUM('full_time_expat', 'visiting_professor', 'adjunct_distinguished_fellow', 'virtual_global_scholar') NOT NULL DEFAULT 'full_time_expat',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `expertise_domain` VARCHAR(255) NOT NULL,
    `visa_work_permit_status` ENUM('fully_compliant', 'renewal_pending', 'processing') NOT NULL DEFAULT 'fully_compliant',
    `expat_wellbeing_score` DECIMAL(4, 2) NOT NULL DEFAULT 92.50,
    `teaching_evaluation_score` DECIMAL(4, 2) NOT NULL DEFAULT 4.90,
    `joint_publications_count` INT NOT NULL DEFAULT 3,
    `status` ENUM('active', 'on_leave', 'completed_term') NOT NULL DEFAULT 'active',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_ifp_year` (`academic_year`),
    INDEX `idx_ifp_nat` (`nationality`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_global_scholar_exchanges` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `faculty_id` VARCHAR(64) NULL,
    `exchange_title` VARCHAR(255) NOT NULL,
    `partner_university` VARCHAR(255) NOT NULL,
    `country` VARCHAR(64) NOT NULL DEFAULT 'United States',
    `mobility_type` ENUM('inbound_visiting', 'outbound_research_fellow', 'joint_lab_residency') NOT NULL DEFAULT 'inbound_visiting',
    `duration_months` INT NOT NULL DEFAULT 3,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `funding_grant_value` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `co_authored_papers` INT NOT NULL DEFAULT 1,
    `status` ENUM('active', 'completed', 'planned') NOT NULL DEFAULT 'active',
    `outcomes_summary` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_gse_year` (`academic_year`),
    INDEX `idx_gse_mob` (`mobility_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
