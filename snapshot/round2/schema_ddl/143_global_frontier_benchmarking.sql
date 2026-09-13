-- DDL extracted from 143_global_frontier_benchmarking.sql (sha256 27b8d1987e893663fbb2aee67499a8cd48be832056590dbb951de671309ef3b2)
CREATE TABLE IF NOT EXISTS `global_frontier_benchmarks` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `academic_year` INT NOT NULL DEFAULT 2569,
  `metric_code` VARCHAR(50) NOT NULL,
  `metric_name_th` VARCHAR(255) NOT NULL,
  `metric_name_en` VARCHAR(255) NOT NULL,
  `edpex_category_ref` VARCHAR(50) NOT NULL COMMENT 'e.g. 7.1, 7.2, 7.3, 7.4, 7.5',
  `utk_actual_value` DECIMAL(10,2) NOT NULL,
  `national_top10_benchmark` DECIMAL(10,2) NOT NULL,
  `global_top10_frontier` DECIMAL(10,2) NOT NULL,
  `unit` VARCHAR(50) NOT NULL DEFAULT '%',
  `higher_is_better` TINYINT(1) NOT NULL DEFAULT 1,
  `gap_to_frontier_pct` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `leadership_position` ENUM('Global Frontier Leader', 'World-Class Competitive', 'National Leader', 'Catching Up') NOT NULL DEFAULT 'World-Class Competitive',
  `best_in_class_institution` VARCHAR(255) NOT NULL COMMENT 'e.g. MIT, TUM, NUS, Stanford',
  `ranking_framework_ref` ENUM('QS World Ranking', 'THE World University', 'AACSB / ABET', 'AUN-QA Tier 1', 'World Intellectual Property') NOT NULL,
  `strategic_closing_initiative` TEXT NOT NULL,
  `audited_at` DATETIME NOT NULL,
  INDEX `idx_metric_code` (`metric_code`),
  INDEX `idx_leadership_pos` (`leadership_position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `world_class_comparators` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `benchmark_id` VARCHAR(36) NOT NULL,
  `comparator_name_en` VARCHAR(255) NOT NULL,
  `country` VARCHAR(100) NOT NULL,
  `world_rank` INT NULL,
  `reported_metric_value` DECIMAL(10,2) NOT NULL,
  `data_vintage_year` INT NOT NULL DEFAULT 2025,
  `official_source_url` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL,
  INDEX `idx_benchmark_fk` (`benchmark_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
