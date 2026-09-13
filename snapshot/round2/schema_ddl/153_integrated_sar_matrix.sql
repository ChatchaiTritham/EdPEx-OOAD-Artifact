-- DDL extracted from 153_integrated_sar_matrix.sql (sha256 ed852b5a92eaaf7040b4694b34940e83af212b6471b162a529335ff0cb1be0d9)
CREATE TABLE IF NOT EXISTS `edpex_integrated_sar_matrix` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `edpex_item_code` VARCHAR(32) NOT NULL,
    `item_title` VARCHAR(255) NOT NULL,
    `category_number` INT NOT NULL,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `connected_modules_json` TEXT NULL,
    `adli_approach_summary` TEXT NULL,
    `adli_deployment_summary` TEXT NULL,
    `adli_learning_summary` TEXT NULL,
    `adli_integration_summary` TEXT NULL,
    `letci_results_summary` TEXT NULL,
    `alignment_gap_flag` TINYINT(1) NOT NULL DEFAULT 0,
    `alignment_gap_details` TEXT NULL,
    `maturity_band` VARCHAR(64) NOT NULL DEFAULT '0-5%',
    `simulated_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `weight_points` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_ism_year` (`academic_year`),
    INDEX `idx_ism_cat` (`category_number`),
    INDEX `idx_ism_item` (`edpex_item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_live_maturity_scores` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `evaluation_phase` VARCHAR(255) NOT NULL DEFAULT 'Live Assessment (Pinnacle 1000)',
    `category_1_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_2_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_3_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_4_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_5_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_6_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `category_7_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `overall_simulated_score` DECIMAL(6, 2) NOT NULL DEFAULT 0.00,
    `systems_integration_index` DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    `active_modules_count` INT NOT NULL DEFAULT 0,
    `evaluator_remarks` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_lms_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
