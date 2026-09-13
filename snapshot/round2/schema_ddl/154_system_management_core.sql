-- DDL extracted from 154_system_management_core.sql (sha256 42fc53ce3cecd9ff74b9bfa28965f314d08665ea84be1d9ffee2d75be8a47e88)
CREATE TABLE IF NOT EXISTS `system_settings` (
    `setting_key` VARCHAR(64) NOT NULL PRIMARY KEY,
    `setting_group` VARCHAR(32) NOT NULL DEFAULT 'general',
    `setting_value` TEXT NULL,
    `value_type` ENUM('string', 'number', 'boolean', 'json') NOT NULL DEFAULT 'string',
    `title_th` VARCHAR(255) NOT NULL,
    `description_th` TEXT NULL,
    `is_public` TINYINT(1) NOT NULL DEFAULT 0,
    `updated_by` VARCHAR(64) NULL,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_st_group` (`setting_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `system_integrations` (
    `id` VARCHAR(64) NOT NULL PRIMARY KEY,
    `integration_name` VARCHAR(128) NOT NULL,
    `integration_type` ENUM('api_key', 'webhook', 'sis_bridge', 'mhesi_sync', 'oauth_provider') NOT NULL,
    `target_endpoint` VARCHAR(500) NULL,
    `api_key_hash` VARCHAR(128) NULL,
    `api_key_prefix` VARCHAR(16) NULL,
    `secret_token` VARCHAR(255) NULL,
    `status` ENUM('active', 'inactive', 'testing', 'error') NOT NULL DEFAULT 'active',
    `sync_direction` ENUM('inbound', 'outbound', 'bidirectional') NOT NULL DEFAULT 'inbound',
    `rate_limit_per_min` INT NOT NULL DEFAULT 120,
    `last_sync_at` DATETIME NULL,
    `last_error_message` TEXT NULL,
    `meta_json` TEXT NULL,
    `created_by` VARCHAR(64) NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_int_type` (`integration_type`),
    INDEX `idx_int_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
