-- DDL extracted from 023_rebuild_foundation_additive.sql (sha256 3150e021c069f0a799790b7b4ffb4d83b54df7f7cdffabc96280267339d2ccd1)
CREATE TABLE IF NOT EXISTS jwt_revocations (
  jti        CHAR(36)  NOT NULL PRIMARY KEY          COMMENT 'JWT ID claim;

CREATE TABLE IF NOT EXISTS edpex_item_result_link (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  item_code      VARCHAR(8)   NOT NULL               COMMENT 'process item e.g. 1.1, 4.2, 6.1',
  indicator_code VARCHAR(20)  NOT NULL               COMMENT 'cat7 result indicator e.g. 7-1-001',
  rationale      VARCHAR(300) NULL                   COMMENT 'why this process item drives this result indicator',
  sort_order     SMALLINT     NOT NULL DEFAULT 0,
  is_active      TINYINT(1)   NOT NULL DEFAULT 1,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_item_indicator (tenant_id, item_code, indicator_code),
  KEY ix_irl_item      (item_code),
  KEY ix_irl_indicator (indicator_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_op_category_linkage (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  framework_id   CHAR(36)     NOT NULL               COMMENT 'ref_frameworks.id',
  op_group_code  VARCHAR(12)  NOT NULL               COMMENT 'P.1ก / P.2ค etc. — matches ref_op_groups.code',
  category_n     TINYINT      NOT NULL               COMMENT 'EdPEx category 1-7 this OP group informs',
  item_code      VARCHAR(8)   NULL                   COMMENT 'optional: specific item e.g. 1.1, 7.3',
  linkage_type   VARCHAR(20)  NOT NULL DEFAULT 'context' COMMENT 'context | driver | evidence',
  rationale      VARCHAR(300) NULL,
  sort_order     SMALLINT     NOT NULL DEFAULT 0,
  UNIQUE KEY uq_op_cat_link (framework_id, op_group_code, category_n, item_code),
  KEY ix_opcl_cat  (category_n),
  KEY ix_opcl_item (item_code),
  KEY ix_opcl_fw   (framework_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS org_units (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id  CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  code       VARCHAR(20)  NOT NULL,
  name_th    VARCHAR(190) NOT NULL,
  unit_type  ENUM('faculty','department','program','division','other') NOT NULL DEFAULT 'department',
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order SMALLINT     NOT NULL DEFAULT 0,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_orgunit_code (tenant_id, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_understanding_snapshots (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  user_id       CHAR(36)    NOT NULL,
  academic_year SMALLINT    NOT NULL,
  score         TINYINT     NOT NULL DEFAULT 0      COMMENT '0-100 composite understanding score',
  level         VARCHAR(20) NULL                    COMMENT 'beginner|developing|proficient|advanced',
  breadth       TINYINT     NULL                    COMMENT 'number of distinct EdPEx items accessed',
  computed_at   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_uu_user_year (user_id, academic_year),
  KEY ix_uus_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS item_score_narrative (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  assessment_id CHAR(36)    NOT NULL,
  item_code     VARCHAR(8)  NOT NULL,
  source        ENUM('self','panel') NOT NULL DEFAULT 'self' COMMENT 'self=faculty entry, panel=assessor review;

CREATE TABLE IF NOT EXISTS edpex_roadmap_phases (
  id               CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  be_year          SMALLINT     NOT NULL,
  goal             VARCHAR(255) NULL                 COMMENT 'narrative goal for this year e.g. EdPEx 200',
  target_band      VARCHAR(40)  NULL                 COMMENT 'e.g. EdPEx 200, EdPEx 300',
  target_score     SMALLINT     NULL                 COMMENT '0-1000',
  focus_categories VARCHAR(20)  NULL                 COMMENT 'comma-separated category numbers e.g. 1,7',
  sort_order       SMALLINT     NOT NULL DEFAULT 0,
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_rp_year (tenant_id, be_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE assessments          ADD COLUMN IF NOT EXISTS submitted_by CHAR(36) NULL AFTER status;

ALTER TABLE edpex_area_response  ADD COLUMN IF NOT EXISTS assessment_id CHAR(36) NULL;
