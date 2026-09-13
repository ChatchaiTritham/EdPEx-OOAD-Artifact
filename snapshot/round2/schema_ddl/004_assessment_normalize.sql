-- DDL extracted from 004_assessment_normalize.sql (sha256 c9b2ea7b734016b8d42e9fea48d468382193823c29241f30ef2ffbbdc13cfd41)
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS role_id       CHAR(36) NULL AFTER role_code,
  ADD COLUMN IF NOT EXISTS data_class_id CHAR(36) NULL AFTER data_class_max,
  ADD INDEX IF NOT EXISTS ix_users_role (role_id),
  ADD INDEX IF NOT EXISTS ix_users_tenant (tenant_id);

ALTER TABLE assessments
  ADD COLUMN IF NOT EXISTS framework_id CHAR(36) NULL AFTER academic_year,
  ADD INDEX IF NOT EXISTS ix_assess_fw (framework_id);

ALTER TABLE scores
  ADD COLUMN IF NOT EXISTS item_id CHAR(36) NULL AFTER item_code,
  ADD COLUMN IF NOT EXISTS band_id CHAR(36) NULL AFTER band,
  ADD INDEX IF NOT EXISTS ix_scores_item (item_id),
  ADD INDEX IF NOT EXISTS ix_scores_band (band_id);

ALTER TABLE item_responses
  ADD COLUMN IF NOT EXISTS item_id CHAR(36) NULL AFTER item_code,
  ADD INDEX IF NOT EXISTS ix_iresp_item (item_id);

ALTER TABLE op_responses
  ADD COLUMN IF NOT EXISTS op_group_id CHAR(36) NULL AFTER group_code,
  ADD INDEX IF NOT EXISTS ix_oresp_group (op_group_id);

ALTER TABLE evidence
  ADD COLUMN IF NOT EXISTS item_id       CHAR(36) NULL AFTER item_code,
  ADD COLUMN IF NOT EXISTS data_class_id CHAR(36) NULL AFTER data_class,
  ADD INDEX IF NOT EXISTS ix_evi_item (item_id);

ALTER TABLE improvements
  ADD COLUMN IF NOT EXISTS item_id CHAR(36) NULL AFTER item_code,
  ADD INDEX IF NOT EXISTS ix_impr_item (item_id);

CREATE TABLE IF NOT EXISTS score_dimensions (
  id           CHAR(36) NOT NULL PRIMARY KEY,
  score_id     CHAR(36) NOT NULL,
  dimension_id CHAR(36) NOT NULL,                     -- → ref_scoring_dimensions
  level        TINYINT  NOT NULL,                     -- 0..100 for this single dimension
  UNIQUE KEY uq_score_dim (score_id, dimension_id),
  CONSTRAINT fk_sd_score FOREIGN KEY (score_id)     REFERENCES scores(id)                 ON DELETE CASCADE,
  CONSTRAINT fk_sd_dim   FOREIGN KEY (dimension_id) REFERENCES ref_scoring_dimensions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kpi_definitions (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  framework_id CHAR(36)     NULL,
  code         VARCHAR(40)  NOT NULL,
  name         VARCHAR(255) NOT NULL,
  category_id  CHAR(36)     NULL,                     -- → ref_categories
  item_id      CHAR(36)     NULL,                     -- → ref_items (7.x result item)
  unit         VARCHAR(40)  NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_kpidef (tenant_id, code),
  CONSTRAINT fk_kpidef_cat  FOREIGN KEY (category_id) REFERENCES ref_categories(id) ON DELETE SET NULL,
  CONSTRAINT fk_kpidef_item FOREIGN KEY (item_id)     REFERENCES ref_items(id)      ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kpi_values (
  id                CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id         CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  kpi_definition_id CHAR(36)      NOT NULL,
  academic_year     SMALLINT      NOT NULL,
  target_value      DECIMAL(14,2) NULL,
  actual_value      DECIMAL(14,2) NULL,
  letci_band_id     CHAR(36)      NULL,               -- → ref_scoring_bands (LeTCI)
  updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_kpival (kpi_definition_id, academic_year),
  CONSTRAINT fk_kpival_def  FOREIGN KEY (kpi_definition_id) REFERENCES kpi_definitions(id)  ON DELETE CASCADE,
  CONSTRAINT fk_kpival_band FOREIGN KEY (letci_band_id)     REFERENCES ref_scoring_bands(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS kpi_value_dimensions (
  id           CHAR(36) NOT NULL PRIMARY KEY,
  kpi_value_id CHAR(36) NOT NULL,
  dimension_id CHAR(36) NOT NULL,                     -- → ref_scoring_dimensions (LeTCI)
  level        TINYINT  NOT NULL,
  UNIQUE KEY uq_kpi_dim (kpi_value_id, dimension_id),
  CONSTRAINT fk_kvd_val FOREIGN KEY (kpi_value_id) REFERENCES kpi_values(id)            ON DELETE CASCADE,
  CONSTRAINT fk_kvd_dim FOREIGN KEY (dimension_id) REFERENCES ref_scoring_dimensions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dsar_requests (
  id         CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id  CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  subject_id CHAR(36)    NOT NULL,                    -- → users.id (the data subject)
  type       ENUM('access','rectify','erase','withdraw') NOT NULL,
  detail     TEXT        NULL,
  status     ENUM('open','in_progress','done','rejected') NOT NULL DEFAULT 'open',
  handled_by CHAR(36)    NULL,
  handled_at DATETIME    NULL,
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX ix_dsar_subject (subject_id),
  INDEX ix_dsar_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
