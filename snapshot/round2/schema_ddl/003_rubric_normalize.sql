-- DDL extracted from 003_rubric_normalize.sql (sha256 6f708c562633026dc00724aa9166115c9379ca9de1a37e6de6a93bcc72044907)
CREATE TABLE IF NOT EXISTS tenants (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  code       VARCHAR(40)  NOT NULL,
  name       VARCHAR(190) NOT NULL,
  subdomain  VARCHAR(80)  NULL,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tenant_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_roles (
  id       CHAR(36)    NOT NULL PRIMARY KEY,
  code     VARCHAR(20) NOT NULL,
  rank     TINYINT     NOT NULL,
  title_th VARCHAR(80) NOT NULL,
  UNIQUE KEY uq_role_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_capabilities (
  id       CHAR(36)    NOT NULL PRIMARY KEY,
  code     VARCHAR(40) NOT NULL,
  title_th VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_cap_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_role_capabilities (
  role_id       CHAR(36) NOT NULL,
  capability_id CHAR(36) NOT NULL,
  PRIMARY KEY (role_id, capability_id),
  CONSTRAINT fk_rc_role FOREIGN KEY (role_id)       REFERENCES ref_roles(id)        ON DELETE CASCADE,
  CONSTRAINT fk_rc_cap  FOREIGN KEY (capability_id) REFERENCES ref_capabilities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_data_classes (
  id       CHAR(36)   NOT NULL PRIMARY KEY,
  code     VARCHAR(4) NOT NULL,            -- L1..L4
  level    TINYINT    NOT NULL,
  title_th VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_dc_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_frameworks (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  code       VARCHAR(20)  NOT NULL,        -- EdPEx
  edition    VARCHAR(20)  NOT NULL,        -- 2567-2570
  max_points SMALLINT     NOT NULL DEFAULT 1000,
  source     VARCHAR(255) NULL,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_framework (code, edition)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_core_values (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  framework_id CHAR(36)     NOT NULL,
  ordinal      TINYINT      NOT NULL,
  text_th      VARCHAR(190) NOT NULL,
  UNIQUE KEY uq_cv (framework_id, ordinal),
  CONSTRAINT fk_cv_fw FOREIGN KEY (framework_id) REFERENCES ref_frameworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_categories (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  framework_id  CHAR(36)     NOT NULL,
  n             TINYINT      NOT NULL,                 -- 1..7
  key_slug      VARCHAR(40)  NOT NULL,                 -- leadership, results, ...
  title         VARCHAR(190) NOT NULL,
  points        SMALLINT     NOT NULL,
  scoring_code  VARCHAR(8)   NOT NULL,                 -- ADLI | LeTCI (→ ref_scoring_schemes.code)
  cat_type      ENUM('process','results') NOT NULL,
  sort          TINYINT      NOT NULL DEFAULT 0,
  UNIQUE KEY uq_cat (framework_id, n),
  CONSTRAINT fk_cat_fw FOREIGN KEY (framework_id) REFERENCES ref_frameworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_items (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  category_id CHAR(36)     NOT NULL,
  code        VARCHAR(8)   NOT NULL,                   -- 1.1 .. 7.5
  title       VARCHAR(255) NOT NULL,
  points      SMALLINT     NOT NULL,
  sort        TINYINT      NOT NULL DEFAULT 0,
  UNIQUE KEY uq_item (category_id, code),
  CONSTRAINT fk_item_cat FOREIGN KEY (category_id) REFERENCES ref_categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_scoring_schemes (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  framework_id CHAR(36)     NOT NULL,
  code         VARCHAR(8)   NOT NULL,                  -- ADLI | LeTCI
  name         VARCHAR(120) NOT NULL,
  applies_to   VARCHAR(120) NULL,
  source       VARCHAR(120) NULL,
  UNIQUE KEY uq_scheme (framework_id, code),
  CONSTRAINT fk_scheme_fw FOREIGN KEY (framework_id) REFERENCES ref_frameworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_scoring_dimensions (
  id        CHAR(36)     NOT NULL PRIMARY KEY,
  scheme_id CHAR(36)     NOT NULL,
  ordinal   TINYINT      NOT NULL,                     -- 1..4
  code      VARCHAR(4)   NOT NULL,                     -- A/D/L/I or Le/T/C/I
  name_th   VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_dim (scheme_id, ordinal),
  CONSTRAINT fk_dim_scheme FOREIGN KEY (scheme_id) REFERENCES ref_scoring_schemes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_scoring_bands (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  scheme_id   CHAR(36)     NOT NULL,
  ordinal     TINYINT      NOT NULL,                   -- 1..6 (ascending)
  range_label VARCHAR(12)  NOT NULL,                   -- '0-5%', '90-100%'
  low_pct     TINYINT      NOT NULL,
  high_pct    TINYINT      NOT NULL,
  label       VARCHAR(120) NOT NULL,
  descr       TEXT         NULL,
  UNIQUE KEY uq_band (scheme_id, ordinal),
  CONSTRAINT fk_band_scheme FOREIGN KEY (scheme_id) REFERENCES ref_scoring_schemes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_band_choices (
  id      CHAR(36) NOT NULL PRIMARY KEY,
  band_id CHAR(36) NOT NULL,
  percent TINYINT  NOT NULL,                           -- discrete choice (0,5,10,..,100)
  UNIQUE KEY uq_choice (band_id, percent),
  CONSTRAINT fk_choice_band FOREIGN KEY (band_id) REFERENCES ref_scoring_bands(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_op_sections (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  framework_id CHAR(36)     NOT NULL,
  code         VARCHAR(12)  NOT NULL,                  -- P.1, P.2
  title        VARCHAR(190) NOT NULL,
  sort         TINYINT      NOT NULL DEFAULT 0,
  UNIQUE KEY uq_op_sec (framework_id, code),
  CONSTRAINT fk_opsec_fw FOREIGN KEY (framework_id) REFERENCES ref_frameworks(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_op_groups (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  section_id CHAR(36)     NOT NULL,
  code       VARCHAR(12)  NOT NULL,                    -- P.1ก, P.2ค
  title      VARCHAR(190) NOT NULL,
  sort       TINYINT      NOT NULL DEFAULT 0,
  UNIQUE KEY uq_op_grp (section_id, code),
  CONSTRAINT fk_opgrp_sec FOREIGN KEY (section_id) REFERENCES ref_op_sections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_op_group_items (
  id        CHAR(36)     NOT NULL PRIMARY KEY,
  group_id  CHAR(36)     NOT NULL,
  text_th   VARCHAR(255) NOT NULL,
  sort      TINYINT      NOT NULL DEFAULT 0,
  CONSTRAINT fk_opitem_grp FOREIGN KEY (group_id) REFERENCES ref_op_groups(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
