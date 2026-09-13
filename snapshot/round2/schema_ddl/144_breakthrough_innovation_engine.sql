-- DDL extracted from 144_breakthrough_innovation_engine.sql (sha256 3250927488eec9993cb20e77292cf4ccc4d45c0e77d67e6a30378098e9f49690)
CREATE TABLE IF NOT EXISTS `breakthrough_innovations` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `project_code` VARCHAR(50) NOT NULL UNIQUE,
  `title_th` VARCHAR(255) NOT NULL,
  `title_en` VARCHAR(255) NOT NULL,
  `innovation_tier` ENUM('Radical Breakthrough', 'Disruptive Technology', 'Deep-Tech Platform', 'Sustaining Incremental') NOT NULL DEFAULT 'Deep-Tech Platform',
  `tech_readiness_level` TINYINT NOT NULL DEFAULT 6 COMMENT 'TRL 1-9 (1=Basic Principle to 9=Commercial Flight)',
  `trl_status_label` VARCHAR(100) NOT NULL DEFAULT 'TRL 6: Prototype Demonstrated in Relevant Environment',
  `principal_investigator` VARCHAR(255) NOT NULL,
  `department` VARCHAR(100) NOT NULL,
  `industry_sponsor` VARCHAR(255) NULL,
  `ip_protection_type` ENUM('Invention Patent (สิทธิบัตรการประดิษฐ์)', 'Petty Patent (อนุสิทธิบัตร)', 'Trade Secret & Know-How', 'Copyright (ลิขสิทธิ์ซอฟต์แวร์)') NOT NULL DEFAULT 'Invention Patent (สิทธิบัตรการประดิษฐ์)',
  `ip_registration_number` VARCHAR(100) NULL,
  `estimated_valuation_thb` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `commercialization_pathway` ENUM('University Spin-Off Startup', 'Industry Technology Licensing', 'Joint Venture Consortium', 'Open-Source Enterprise') NOT NULL DEFAULT 'University Spin-Off Startup',
  `commercial_status` ENUM('Ideation & Lab Proof', 'IP Protected & Incubation', 'Pilot Trial with Industry', 'Spin-Off Formed & Scaling', 'Market Royalty Generating') NOT NULL DEFAULT 'Pilot Trial with Industry',
  `sdg_impact_goals` VARCHAR(100) NULL COMMENT 'e.g. SDG 7, SDG 9, SDG 13',
  `created_at` DATETIME NOT NULL,
  `updated_at` DATETIME NULL,
  INDEX `idx_inno_code` (`project_code`),
  INDEX `idx_trl` (`tech_readiness_level`),
  INDEX `idx_commercial_status` (`commercial_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `spinoff_commercialization_pipeline` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `innovation_id` VARCHAR(36) NOT NULL,
  `company_name` VARCHAR(255) NOT NULL,
  `incorporation_number` VARCHAR(100) NULL,
  `founders_and_equity_split` TEXT NOT NULL COMMENT 'University equity % vs Faculty founders %',
  `university_equity_pct` DECIMAL(5,2) NOT NULL DEFAULT 15.00,
  `seed_funding_raised_thb` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `annual_commercial_revenue_thb` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `royalty_paid_to_university_thb` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `jobs_created_count` INT NOT NULL DEFAULT 0,
  `milestone_description` TEXT NOT NULL,
  `status` ENUM('Incubating', 'Incorporated & Active', 'Series Funding', 'Acquired / M&A', 'Dormant') NOT NULL DEFAULT 'Incorporated & Active',
  `academic_year` INT NOT NULL DEFAULT 2569,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_spinoff_inno` (`innovation_id`),
  INDEX `idx_spinoff_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
