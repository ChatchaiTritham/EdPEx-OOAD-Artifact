-- DDL extracted from 147_quadruple_helix_ecosystem.sql (sha256 a46f9babf3167f0b0d4185162f420bedf4171e01d98848e4ae756a5e3cf4f7f8)
CREATE TABLE IF NOT EXISTS `edpex_quadruple_helix_alliances` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `alliance_name` VARCHAR(255) NOT NULL,
    `alliance_code` VARCHAR(64) NOT NULL,
    `helix_type` ENUM('government', 'industry', 'civil_society', 'academia') NOT NULL DEFAULT 'industry',
    `primary_organization` VARCHAR(255) NOT NULL,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `strategic_focus` VARCHAR(255) NOT NULL,
    `engagement_level` ENUM('consultative', 'co_design', 'co_investment', 'symbiotic_ecosystem') NOT NULL DEFAULT 'symbiotic_ecosystem',
    `annual_matching_funds` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `status` ENUM('active', 'expanding', 'completed') NOT NULL DEFAULT 'active',
    `contact_lead` VARCHAR(255) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_qh_year` (`academic_year`),
    INDEX `idx_qh_helix` (`helix_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_cocreated_outcomes` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `alliance_id` VARCHAR(64) NULL,
    `outcome_title` VARCHAR(255) NOT NULL,
    `outcome_code` VARCHAR(64) NOT NULL,
    `outcome_type` ENUM('joint_patent', 'workforce_consortium', 'policy_standard', 'community_empowerment', 'commercial_product') NOT NULL DEFAULT 'joint_patent',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `economic_value_created` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `beneficiary_stakeholder_count` INT NOT NULL DEFAULT 0,
    `stakeholder_satisfaction_score` DECIMAL(4, 2) NOT NULL DEFAULT 4.90,
    `verification_evidence` VARCHAR(255) NULL,
    `description` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_co_year` (`academic_year`),
    INDEX `idx_co_type` (`outcome_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
