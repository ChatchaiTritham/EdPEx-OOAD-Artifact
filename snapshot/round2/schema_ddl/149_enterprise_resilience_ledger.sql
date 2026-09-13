-- DDL extracted from 149_enterprise_resilience_ledger.sql (sha256 d28302d0922d70875e8955785659321a05a032ecc554929f9167d11230a8ba0c)
CREATE TABLE IF NOT EXISTS `edpex_enterprise_resilience_plans` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `plan_name` VARCHAR(255) NOT NULL,
    `resilience_domain` ENUM('financial_sovereignty', 'operational_immunity', 'cyber_cognitive_defense', 'academic_supply_chain') NOT NULL DEFAULT 'financial_sovereignty',
    `academic_year` INT NOT NULL DEFAULT 2569,
    `immunity_score` DECIMAL(4, 2) NOT NULL DEFAULT 94.50,
    `sovereign_endowment_fund` DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    `runway_months` INT NOT NULL DEFAULT 36,
    `stress_resistance_grade` ENUM('AAA', 'AA', 'A', 'BBB') NOT NULL DEFAULT 'AAA',
    `status` ENUM('active', 'review_pending', 'enhanced') NOT NULL DEFAULT 'active',
    `description` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_erp_year` (`academic_year`),
    INDEX `idx_erp_domain` (`resilience_domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `edpex_sovereign_sustainability_audits` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `academic_year` INT NOT NULL DEFAULT 2569,
    `quarter` VARCHAR(16) NOT NULL DEFAULT 'Q1',
    `revenue_diversification_ratio` DECIMAL(5, 2) NOT NULL DEFAULT 42.50,
    `fiscal_health_index` DECIMAL(4, 2) NOT NULL DEFAULT 96.00,
    `strategic_initiative_roi` DECIMAL(5, 2) NOT NULL DEFAULT 185.00,
    `regulatory_compliance_percent` DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    `audit_authority` VARCHAR(255) NOT NULL DEFAULT 'คณะกรรมการตรวจสอบประจำมหาวิทยาลัย & สตง.',
    `audit_verdict` ENUM('exemplary_pinnacle', 'fully_compliant', 'minor_observation') NOT NULL DEFAULT 'exemplary_pinnacle',
    `audit_notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ssa_year_q` (`academic_year`, `quarter`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
