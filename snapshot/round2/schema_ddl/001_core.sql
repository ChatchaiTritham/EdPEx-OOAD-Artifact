-- DDL extracted from 001_core.sql (sha256 1254668e5412d924519b6c09d15bf4da6c1d33f12fdf12c6eb8cb9d4c7d427d1)
CREATE TABLE IF NOT EXISTS users (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  email         VARCHAR(190) NOT NULL UNIQUE,
  username      VARCHAR(100) NULL,
  password_hash VARCHAR(255) NOT NULL,
  display_name  VARCHAR(190) NOT NULL,
  role_code     VARCHAR(20)  NOT NULL DEFAULT 'viewer',
  is_active     TINYINT(1)   NOT NULL DEFAULT 1,
  last_login_at DATETIME     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS assessments (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  academic_year SMALLINT     NOT NULL,
  title         VARCHAR(190) NOT NULL,
  status        ENUM('draft','in_review','final') NOT NULL DEFAULT 'draft',
  created_by    CHAR(36)     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_year (academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scores (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  assessment_id CHAR(36)     NOT NULL,
  item_code     VARCHAR(8)   NOT NULL,
  score_pct     TINYINT      NOT NULL DEFAULT 0,
  strengths     TEXT         NULL,
  ofi           TEXT         NULL,
  updated_by    CHAR(36)     NULL,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_assessment_item (assessment_id, item_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kpis (
  id                 CHAR(36)     NOT NULL PRIMARY KEY,
  code               VARCHAR(40)  NOT NULL,
  name               VARCHAR(255) NOT NULL,
  category_n         TINYINT      NULL,
  unit               VARCHAR(40)  NULL,
  academic_year      SMALLINT     NOT NULL,
  target_value       DECIMAL(14,2) NULL,
  actual_value       DECIMAL(14,2) NULL,
  letci_level        TINYINT      NULL,
  letci_trend        TINYINT      NULL,
  letci_comparison   TINYINT      NULL,
  letci_integration  TINYINT      NULL,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_code_year (code, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS evidence (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  item_code     VARCHAR(8)   NOT NULL,
  assessment_id CHAR(36)     NULL,
  title         VARCHAR(255) NOT NULL,
  link          VARCHAR(500) NULL,
  file_path     VARCHAR(500) NULL,
  uploaded_by   CHAR(36)     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS improvements (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  item_code     VARCHAR(8)   NOT NULL,
  assessment_id CHAR(36)     NULL,
  description   TEXT         NOT NULL,
  owner_id      CHAR(36)     NULL,
  due_date      DATE         NULL,
  status        ENUM('open','doing','done') NOT NULL DEFAULT 'open',
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_log (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  user_id     CHAR(36)     NULL,
  action      VARCHAR(40)  NOT NULL,
  entity      VARCHAR(40)  NOT NULL,
  entity_id   VARCHAR(40)  NULL,
  detail_json TEXT         NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
