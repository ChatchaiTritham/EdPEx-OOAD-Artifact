-- DDL extracted from 140_global_microcredits_alliance.sql (sha256 cbf34287a58f271d92fc5814385407548e3393fdb017c47197a3775c349c6963)
CREATE TABLE IF NOT EXISTS `global_alliance_partners` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `partner_code` VARCHAR(50) NOT NULL,
  `institution_name_th` VARCHAR(255) NOT NULL,
  `institution_name_en` VARCHAR(255) NOT NULL,
  `country` VARCHAR(100) NOT NULL DEFAULT 'Thailand',
  `partnership_tier` ENUM('Strategic Global', 'Bilateral MOU', 'Dual Degree Articulation', 'Industry Consortium') NOT NULL DEFAULT 'Bilateral MOU',
  `ects_transfer_ratio` DECIMAL(3,2) NOT NULL DEFAULT 1.00 COMMENT 'Transfer ratio to UTK credits (e.g., 1.0 or 0.67 ECTS to local credit)',
  `mou_signed_date` DATE NULL,
  `mou_expire_date` DATE NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `contact_person` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_partner_code` (`partner_code`),
  INDEX `idx_partner_tier` (`partnership_tier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `micro_credentials_courses` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `badge_code` VARCHAR(50) NOT NULL UNIQUE,
  `badge_title_th` VARCHAR(255) NOT NULL,
  `badge_title_en` VARCHAR(255) NOT NULL,
  `skill_domain` ENUM('AI & Big Data', 'Green Energy & Sustainability', 'Smart Logistics', 'Cybersecurity & Privacy', 'Global Leadership & Cross-Culture') NOT NULL,
  `equivalent_credits` INT NOT NULL DEFAULT 3,
  `ects_credits` DECIMAL(4,1) NOT NULL DEFAULT 5.0,
  `partner_id` VARCHAR(36) NULL,
  `competency_outcomes` TEXT NOT NULL,
  `verification_url` VARCHAR(255) NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_domain` (`skill_domain`),
  INDEX `idx_partner` (`partner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `credit_bank_transfer_records` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `student_code` VARCHAR(50) NOT NULL,
  `student_name` VARCHAR(255) NOT NULL,
  `department` VARCHAR(100) NOT NULL,
  `badge_id` VARCHAR(36) NOT NULL,
  `target_utk_course_code` VARCHAR(50) NOT NULL,
  `target_utk_course_name` VARCHAR(255) NOT NULL,
  `credits_awarded` INT NOT NULL DEFAULT 3,
  `recognition_type` ENUM('Cross-Border Dual Degree', 'MOOC Micro-Credential', 'Industry Professional Cert', 'Prior Learning RPL') NOT NULL,
  `digital_badge_hash` VARCHAR(128) NULL,
  `approval_status` ENUM('Submitted', 'Faculty Vetted', 'Dean Approved', 'Registry Confirmed', 'Rejected') NOT NULL DEFAULT 'Submitted',
  `evaluator_notes` TEXT NULL,
  `approved_at` DATETIME NULL,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_student_cb` (`student_code`),
  INDEX `idx_status` (`approval_status`),
  INDEX `idx_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
