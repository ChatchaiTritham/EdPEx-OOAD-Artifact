-- DDL extracted from 145_ecosystem_netzero_impact.sql (sha256 f24f2735abb47de692101aceea02ff522c0b832e1048b925f3858560873e9c9f)
CREATE TABLE IF NOT EXISTS `net_zero_carbon_offsets` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `quarter` VARCHAR(10) NOT NULL DEFAULT 'Q1',
  `scope1_direct_emissions_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000 COMMENT 'Direct fuel/generators',
  `scope2_indirect_emissions_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000 COMMENT 'Purchased electricity',
  `scope3_value_chain_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000 COMMENT 'Commuting, procurement, travel',
  `gross_carbon_emissions_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000,
  `renewable_energy_generated_kwh` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `carbon_offset_certified_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000 COMMENT 'T-VER / I-REC certified credits',
  `net_carbon_balance_tco2e` DECIMAL(10,3) NOT NULL DEFAULT 0.000,
  `net_zero_progress_pct` DECIMAL(5,2) NOT NULL DEFAULT 75.00,
  `verification_body` VARCHAR(255) NOT NULL DEFAULT 'องค์การบริหารจัดการก๊าซเรือนกระจก (อบก. TGO)',
  `offset_registry_certificate` VARCHAR(100) NULL,
  `recorded_at` DATETIME NOT NULL,
  INDEX `idx_nz_year` (`academic_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `circular_value_chain_projects` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `project_code` VARCHAR(50) NOT NULL UNIQUE,
  `project_title_th` VARCHAR(255) NOT NULL,
  `project_title_en` VARCHAR(255) NOT NULL,
  `circular_strategy` ENUM('Circular Waste-to-Resource', 'Renewable Energy Microgrid', 'Green Digital Logistics', 'Water Reclamation & Closed-Loop', 'Sustainable Food & Bio-Economy') NOT NULL,
  `community_or_partner_beneficiary` VARCHAR(255) NOT NULL,
  `waste_diverted_kg` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Waste prevented from landfill',
  `resource_savings_thb` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `sroi_social_return_ratio` DECIMAL(4,2) NOT NULL DEFAULT 2.50 COMMENT 'SROI ratio e.g. 1 THB invested generates 2.8 THB value',
  `total_community_impact_thb` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `status` ENUM('Piloting', 'Active Operation', 'Scaling Across Campus', 'Sustained Institutionalized') NOT NULL DEFAULT 'Active Operation',
  `academic_year` INT NOT NULL DEFAULT 2569,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_cvc_strategy` (`circular_strategy`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
