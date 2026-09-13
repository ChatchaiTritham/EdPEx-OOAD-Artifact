-- DDL extracted from 141_executive_cockpit_assessor.sql (sha256 d04544159921b3dec2080116f01984888d2b3ee27f0e87fc9f48a899d52fc643)
CREATE TABLE IF NOT EXISTS `executive_health_snapshots` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `overall_health_score` DECIMAL(4,1) NOT NULL DEFAULT 85.0 COMMENT '0-100 index',
  `health_grade` ENUM('Pinnacle (500+)', 'Excellence (400-499)', 'Proficient (300-399)', 'Developing (<300)') NOT NULL DEFAULT 'Excellence (400-499)',
  `leadership_index` DECIMAL(4,1) NOT NULL DEFAULT 88.0,
  `strategy_alignment_pct` DECIMAL(4,1) NOT NULL DEFAULT 92.0,
  `student_success_index` DECIMAL(4,1) NOT NULL DEFAULT 84.5,
  `academic_letci_score` DECIMAL(4,1) NOT NULL DEFAULT 82.0,
  `workforce_vitality_index` DECIMAL(4,1) NOT NULL DEFAULT 87.0,
  `operational_resilience_pct` DECIMAL(4,1) NOT NULL DEFAULT 90.0,
  `financial_sustainability_score` DECIMAL(4,1) NOT NULL DEFAULT 89.0,
  `governance_integrity_pct` DECIMAL(4,1) NOT NULL DEFAULT 96.0,
  `critical_alerts_count` INT NOT NULL DEFAULT 0,
  `pending_decisions_count` INT NOT NULL DEFAULT 0,
  `ai_executive_summary` TEXT NULL,
  `captured_at` DATETIME NOT NULL,
  INDEX `idx_health_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `executive_decision_items` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `urgency_level` ENUM('Emergency (24h)', 'Strategic High', 'Routine Moderate', 'Low / FYI') NOT NULL DEFAULT 'Strategic High',
  `edpex_category_ref` VARCHAR(50) NOT NULL COMMENT 'e.g. หมวด 1, หมวด 2, หมวด 6',
  `background_context` TEXT NOT NULL,
  `recommended_action` TEXT NOT NULL,
  `decision_status` ENUM('Pending Review', 'Approved by Dean', 'Amended', 'Deferred', 'Declined') NOT NULL DEFAULT 'Pending Review',
  `assigned_executive` VARCHAR(100) NOT NULL DEFAULT 'คณบดี',
  `decision_notes` TEXT NULL,
  `due_date` DATE NULL,
  `decided_at` DATETIME NULL,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_decision_status` (`decision_status`),
  INDEX `idx_urgency` (`urgency_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `assessor_evidence_vault` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `criteria_item` VARCHAR(20) NOT NULL COMMENT 'e.g. 1.1, 1.2, 2.1, 7.1',
  `category_title` VARCHAR(255) NOT NULL,
  `evidence_title` VARCHAR(255) NOT NULL,
  `evidence_type` ENUM('Live Data Stream', 'Official Document', 'Policy / Regulation', 'Audit Report', 'System Log') NOT NULL,
  `system_source_url` VARCHAR(255) NOT NULL,
  `letci_attribute` ENUM('Le (Level)', 'T (Trend)', 'C (Comparison)', 'I (Integration)', 'ADLI Process') NOT NULL,
  `verified_by` VARCHAR(100) NOT NULL DEFAULT 'QA Director',
  `qr_verification_token` VARCHAR(64) NOT NULL UNIQUE,
  `is_assessor_ready` TINYINT(1) NOT NULL DEFAULT 1,
  `last_audited_at` DATETIME NOT NULL,
  INDEX `idx_criteria` (`criteria_item`),
  INDEX `idx_letci_attr` (`letci_attribute`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
