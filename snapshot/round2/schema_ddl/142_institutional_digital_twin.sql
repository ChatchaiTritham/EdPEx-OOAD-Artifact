-- DDL extracted from 142_institutional_digital_twin.sql (sha256 e2e127c0dfcaba02d0ebe7105e96b934f5213d2b9da3663568aac80129307c7b)
CREATE TABLE IF NOT EXISTS `institutional_digital_twins` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `twin_version` VARCHAR(50) NOT NULL DEFAULT 'v1.0-SimLive',
  `twin_status` ENUM('Calibrated & Live', 'Simulation Running', 'Drift Detected', 'Under Recalibration') NOT NULL DEFAULT 'Calibrated & Live',
  `resilience_index` DECIMAL(5,2) NOT NULL DEFAULT 91.50 COMMENT '0-100 institutional resilience rating',
  `stress_tolerance_tier` ENUM('Antifragile', 'Highly Robust', 'Moderate Resistance', 'Vulnerable') NOT NULL DEFAULT 'Highly Robust',
  `simulated_headcount` INT NOT NULL DEFAULT 1450,
  `simulated_revenue_mil` DECIMAL(10,2) NOT NULL DEFAULT 185.50,
  `simulated_operating_cost_mil` DECIMAL(10,2) NOT NULL DEFAULT 142.20,
  `faculty_student_ratio` DECIMAL(4,1) NOT NULL DEFAULT 18.5,
  `cyber_physical_health_pct` DECIMAL(5,2) NOT NULL DEFAULT 95.80,
  `last_calibrated_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_twin_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `stress_test_simulations` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `twin_id` VARCHAR(36) NOT NULL,
  `scenario_code` VARCHAR(50) NOT NULL,
  `scenario_name` VARCHAR(255) NOT NULL,
  `stress_category` ENUM('Demographic & Intake Shock', 'Fiscal Deficit & Grant Cut', 'Critical Infrastructure & Cyber Outage', 'Accreditation & Regulatory Freeze', 'Global Geopolitical / Disruption') NOT NULL,
  `shock_severity` ENUM('Mild (-10%)', 'Severe (-30%)', 'Catastrophic Black-Swan (-50%)') NOT NULL DEFAULT 'Severe (-30%)',
  `baseline_metric_val` DECIMAL(10,2) NOT NULL,
  `simulated_stressed_val` DECIMAL(10,2) NOT NULL,
  `variance_pct` DECIMAL(5,2) NOT NULL,
  `recovery_time_months` DECIMAL(4,1) NOT NULL DEFAULT 6.0,
  `pass_fail_status` ENUM('Resilient Pass', 'Conditional Pass', 'Stress Fail') NOT NULL DEFAULT 'Resilient Pass',
  `mitigation_contingency_plan` TEXT NOT NULL,
  `simulated_by` VARCHAR(100) NOT NULL DEFAULT 'Chief Risk & Foresight Officer',
  `executed_at` DATETIME NOT NULL,
  INDEX `idx_scenario` (`scenario_code`),
  INDEX `idx_stress_cat` (`stress_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
