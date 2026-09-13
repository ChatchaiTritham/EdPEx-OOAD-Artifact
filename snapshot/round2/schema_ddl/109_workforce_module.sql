-- DDL extracted from 109_workforce_module.sql (sha256 49b5893def2bc427fd7f28b06aaf5d5d0a777387b903b378b123625c3f725cbb)
CREATE TABLE IF NOT EXISTS `wf_personnel` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `tenant_id` VARCHAR(64) DEFAULT 'utkic',
  `personnel_code` VARCHAR(50) NOT NULL UNIQUE,
  `prefix_th` VARCHAR(30) DEFAULT NULL,
  `first_name_th` VARCHAR(100) NOT NULL,
  `last_name_th` VARCHAR(100) NOT NULL,
  `prefix_en` VARCHAR(30) DEFAULT NULL,
  `first_name_en` VARCHAR(100) NOT NULL,
  `last_name_en` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `personnel_type` ENUM('academic', 'support') NOT NULL DEFAULT 'academic',
  `academic_rank` VARCHAR(50) DEFAULT NULL COMMENT 'อาจารย์, ผศ., รศ., ศ.',
  `department` VARCHAR(100) DEFAULT 'วิทยาลัยนานาชาติ',
  `highest_degree` VARCHAR(50) DEFAULT 'ปริญญาเอก',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_wf_type` (`personnel_type`),
  INDEX `idx_wf_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wf_idp_plans` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `tenant_id` VARCHAR(64) DEFAULT 'utkic',
  `personnel_id` VARCHAR(64) NOT NULL,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `competency_domain` ENUM('teaching', 'research', 'digital_ai', 'language', 'leadership', 'specialized') NOT NULL,
  `goal_title` VARCHAR(255) NOT NULL,
  `development_method` VARCHAR(255) DEFAULT 'อบรม/สัมมนา/ปฏิบัติการ',
  `target_completion_date` DATE DEFAULT NULL,
  `planned_hours` INT NOT NULL DEFAULT 20,
  `completed_hours` INT NOT NULL DEFAULT 0,
  `status` ENUM('draft', 'submitted', 'in_progress', 'completed', 'verified') NOT NULL DEFAULT 'submitted',
  `evidence_document_url` VARCHAR(255) DEFAULT NULL,
  `supervisor_notes` TEXT DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_idp_person_year` (`personnel_id`, `academic_year`),
  INDEX `idx_idp_status` (`status`),
  CONSTRAINT `fk_idp_person` FOREIGN KEY (`personnel_id`) REFERENCES `wf_personnel` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wf_workload_entries` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `tenant_id` VARCHAR(64) DEFAULT 'utkic',
  `personnel_id` VARCHAR(64) NOT NULL,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `semester` TINYINT NOT NULL DEFAULT 1,
  `workload_category` ENUM('teaching', 'research', 'academic_service', 'administration', 'student_advising') NOT NULL,
  `activity_name` VARCHAR(255) NOT NULL,
  `hours_per_week` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `standard_workload_units` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_wl_person_term` (`personnel_id`, `academic_year`, `semester`),
  INDEX `idx_wl_cat` (`workload_category`),
  CONSTRAINT `fk_wl_person` FOREIGN KEY (`personnel_id`) REFERENCES `wf_personnel` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `wf_engagement_surveys` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `tenant_id` VARCHAR(64) DEFAULT 'utkic',
  `academic_year` INT NOT NULL DEFAULT 2569,
  `respondent_group` ENUM('academic', 'support') NOT NULL,
  `score_climate` DECIMAL(3,2) NOT NULL COMMENT '1.00-5.00 สภาพแวดล้อมและบรรยากาศ',
  `score_leadership` DECIMAL(3,2) NOT NULL COMMENT '1.00-5.00 การนำและการสนับสนุนของผู้นำ',
  `score_growth` DECIMAL(3,2) NOT NULL COMMENT '1.00-5.00 โอกาสก้าวหน้าและการเรียนรู้',
  `score_wellbeing` DECIMAL(3,2) NOT NULL COMMENT '1.00-5.00 สวัสดิการและสุขภาวะ',
  `score_engagement_overall` DECIMAL(3,2) NOT NULL COMMENT '1.00-5.00 ความผูกพันต่อองค์กรโดยรวม',
  `feedback_text` TEXT DEFAULT NULL,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_surv_year_grp` (`academic_year`, `respondent_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
