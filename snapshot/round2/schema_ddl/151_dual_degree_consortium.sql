-- DDL extracted from 151_dual_degree_consortium.sql (sha256 6f56c3cda13da14657a761bb0edf63b5bcd162f9e0e8ab9c501535ff0ffdd589)
CREATE TABLE IF NOT EXISTS `edpex_dual_degree_programs` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `program_name` VARCHAR(255) NOT NULL,
    `program_code` VARCHAR(64) NOT NULL,
    `partner_university` VARCHAR(255) NOT NULL,
    `partner_country` VARCHAR(64) NOT NULL DEFAULT 'China',
    `collaboration_model` ENUM('2_plus_2', '3_plus_1', '1_plus_1_master', 'joint_supervision_phd') NOT NULL DEFAULT '2_plus_2',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `enrolled_students_count` INT NOT NULL DEFAULT 0,
    `graduated_cohort_count` INT NOT NULL DEFAULT 0,
    `global_employability_rate` DECIMAL(5, 2) NOT NULL DEFAULT 95.50,
    `avg_starting_salary_usd` DECIMAL(10, 2) NOT NULL DEFAULT 2500.00,
    `status` ENUM('active', 'expanding', 'accreditation_review') NOT NULL DEFAULT 'active',
    `curriculum_mou_link` VARCHAR(255) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_ddp_year` (`academic_year`),
    INDEX `idx_ddp_model` (`collaboration_model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_transnational_credit_transfers` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `program_id` VARCHAR(64) NULL,
    `student_code` VARCHAR(64) NOT NULL,
    `student_name` VARCHAR(255) NOT NULL,
    `foreign_institution` VARCHAR(255) NOT NULL,
    `course_name_th` VARCHAR(255) NOT NULL,
    `course_name_foreign` VARCHAR(255) NOT NULL,
    `credits_transferred` INT NOT NULL DEFAULT 3,
    `grade_transferred` VARCHAR(8) NOT NULL DEFAULT 'A',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `equivalency_status` ENUM('certified_seamless', 'conditional_review', 'pending') NOT NULL DEFAULT 'certified_seamless',
    `certified_by` VARCHAR(255) NOT NULL DEFAULT 'คณะกรรมการเทียบโอนผลการเรียนวิทยาลัยนานาชาติ',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_tct_year` (`academic_year`),
    INDEX `idx_tct_code` (`student_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
