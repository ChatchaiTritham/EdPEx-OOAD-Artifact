-- DDL extracted from 084_app_settings.sql (sha256 57d54cf3cbe58032e023746f5811da2c653281e5514f806b0f56674a0cad715e)
CREATE TABLE IF NOT EXISTS app_settings (
  id         CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_key VARCHAR(40) NOT NULL DEFAULT 'sciutk',
  skey       VARCHAR(64) NOT NULL,            -- e.g. faculty, university, abbrev, email_domain, name,
  sval       TEXT        NULL,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_setting (tenant_key, skey)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
