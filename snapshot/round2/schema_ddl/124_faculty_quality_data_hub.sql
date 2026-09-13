-- DDL extracted from 124_faculty_quality_data_hub.sql (sha256 d18d95b6091110366b93a3016ab2ebce303f697ba73f53427fabd5ac34605580)
CREATE TABLE IF NOT EXISTS qh_org_units (
    id              CHAR(36)     NOT NULL,
    tenant_id       CHAR(36)     NOT NULL,
    parent_id       CHAR(36)     NULL,
    unit_type       ENUM('institution','faculty','department','centre') NOT NULL,
    unit_code       VARCHAR(50)  NOT NULL,
    name_th         VARCHAR(255) NOT NULL,
    name_en         VARCHAR(255) NOT NULL DEFAULT '',
    source_system   VARCHAR(80)  NULL,
    source_key      VARCHAR(120) NULL,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_unit_code (tenant_id, unit_type, unit_code),
    KEY idx_qh_unit_parent (tenant_id, parent_id),
    KEY idx_qh_unit_source (tenant_id, source_system, source_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_programmes (
    id              CHAR(36)     NOT NULL,
    tenant_id       CHAR(36)     NOT NULL,
    org_unit_id     CHAR(36)     NULL,
    programme_code  VARCHAR(50)  NOT NULL,
    name_th         VARCHAR(255) NOT NULL,
    name_en         VARCHAR(255) NOT NULL DEFAULT '',
    degree_level    VARCHAR(50)  NOT NULL DEFAULT '',
    source_system   VARCHAR(80)  NULL,
    source_key      VARCHAR(120) NULL,
    status          ENUM('draft','active','retired') NOT NULL DEFAULT 'draft',
    owner_user_id   CHAR(36)     NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_programme_code (tenant_id, programme_code),
    KEY idx_qh_programme_unit (tenant_id, org_unit_id),
    KEY idx_qh_programme_source (tenant_id, source_system, source_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_curriculum_versions (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    programme_id        CHAR(36)     NOT NULL,
    version_code        VARCHAR(80)  NOT NULL,
    effective_from      DATE         NULL,
    effective_to        DATE         NULL,
    tqf_reference       VARCHAR(120) NULL,
    total_credits       DECIMAL(5,1) NULL,
    status              ENUM('draft','under_review','published','retired') NOT NULL DEFAULT 'draft',
    source_system       VARCHAR(80)  NULL,
    source_key          VARCHAR(120) NULL,
    owner_user_id       CHAR(36)     NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_curriculum_version (tenant_id, programme_id, version_code),
    KEY idx_qh_curriculum_status (tenant_id, status),
    KEY idx_qh_curriculum_source (tenant_id, source_system, source_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_outcomes (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    curriculum_version_id CHAR(36)   NOT NULL,
    outcome_type        ENUM('PLO','CLO') NOT NULL,
    outcome_code        VARCHAR(80)  NOT NULL,
    description_th      TEXT         NOT NULL,
    description_en      TEXT         NULL,
    course_code         VARCHAR(50)  NULL,
    sort_order          SMALLINT     NOT NULL DEFAULT 0,
    status              ENUM('draft','published','retired') NOT NULL DEFAULT 'draft',
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_outcome (tenant_id, curriculum_version_id, outcome_type, outcome_code),
    KEY idx_qh_outcome_course (tenant_id, course_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_evidence_items (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    evidence_type       VARCHAR(80)  NOT NULL,
    title               VARCHAR(500) NOT NULL,
    data_class          ENUM('L1','L2','L3','L4') NOT NULL DEFAULT 'L1',
    source_system       VARCHAR(80)  NULL,
    source_key          VARCHAR(120) NULL,
    storage_ref         VARCHAR(500) NULL COMMENT 'authorised object/document reference;

CREATE TABLE IF NOT EXISTS qh_kpi_observations (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    indicator_code      VARCHAR(80)  NOT NULL,
    academic_year       SMALLINT     NOT NULL,
    period_code         VARCHAR(40)  NOT NULL DEFAULT 'annual',
    programme_id        CHAR(36)     NULL,
    value_decimal       DECIMAL(18,4) NULL,
    value_text          VARCHAR(500) NULL,
    unit                VARCHAR(80)  NULL,
    source_system       VARCHAR(80)  NOT NULL,
    source_key          VARCHAR(120) NULL,
    calculation_version VARCHAR(80)  NULL,
    data_quality        ENUM('draft','entered','synced','verified','rejected') NOT NULL DEFAULT 'draft',
    supersedes_id       CHAR(36)     NULL,
    verified_by_user_id CHAR(36)     NULL,
    verified_at         DATETIME     NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_kpi_observation (tenant_id, indicator_code, academic_year, period_code, programme_id, source_system, source_key),
    KEY idx_qh_kpi_lookup (tenant_id, academic_year, indicator_code, data_quality),
    KEY idx_qh_kpi_supersedes (tenant_id, supersedes_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_framework_profiles (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    framework_code      ENUM('EDPEX','AUN_QA','TQF') NOT NULL,
    edition             VARCHAR(80)  NOT NULL,
    title_th            VARCHAR(255) NOT NULL,
    status              ENUM('draft','active','retired') NOT NULL DEFAULT 'draft',
    effective_from      DATE         NULL,
    effective_to        DATE         NULL,
    source_url          VARCHAR(500) NULL,
    owner_user_id       CHAR(36)     NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_framework_profile (tenant_id, framework_code, edition),
    KEY idx_qh_framework_status (tenant_id, framework_code, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_framework_requirements (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    framework_profile_id CHAR(36)    NOT NULL,
    requirement_code    VARCHAR(80)  NOT NULL,
    parent_code         VARCHAR(80)  NULL,
    title_th            VARCHAR(500) NOT NULL,
    title_en            VARCHAR(500) NULL,
    requirement_type    ENUM('evidence','kpi','outcome','narrative','mixed') NOT NULL DEFAULT 'mixed',
    is_required         TINYINT(1)   NOT NULL DEFAULT 1,
    sort_order          SMALLINT     NOT NULL DEFAULT 0,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_requirement (tenant_id, framework_profile_id, requirement_code),
    KEY idx_qh_requirement_parent (tenant_id, framework_profile_id, parent_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_framework_bindings (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    requirement_id      CHAR(36)     NOT NULL,
    binding_type        ENUM('evidence','kpi','outcome','programme','curriculum') NOT NULL,
    target_id           CHAR(36)     NULL,
    target_business_key VARCHAR(160) NULL,
    binding_status      ENUM('draft','active','retired') NOT NULL DEFAULT 'draft',
    notes               TEXT         NULL,
    created_by_user_id  CHAR(36)     NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_qh_framework_binding (tenant_id, requirement_id, binding_type, target_business_key),
    KEY idx_qh_binding_target (tenant_id, binding_type, target_id),
    KEY idx_qh_binding_status (tenant_id, binding_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_review_tasks (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    task_type           ENUM('evidence_review','kpi_verification','framework_review','curriculum_review') NOT NULL,
    subject_type        VARCHAR(80)  NOT NULL,
    subject_id          CHAR(36)     NOT NULL,
    assignee_user_id    CHAR(36)     NULL,
    status              ENUM('open','in_review','returned','approved','rejected','cancelled') NOT NULL DEFAULT 'open',
    due_at              DATETIME     NULL,
    reason_code         VARCHAR(80)  NULL,
    correlation_id      CHAR(36)     NOT NULL,
    created_by_user_id  CHAR(36)     NULL,
    decided_by_user_id  CHAR(36)     NULL,
    decided_at          DATETIME     NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_qh_review_queue (tenant_id, status, assignee_user_id, due_at),
    KEY idx_qh_review_subject (tenant_id, subject_type, subject_id),
    KEY idx_qh_review_correlation (tenant_id, correlation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS qh_approval_events (
    id                  CHAR(36)     NOT NULL,
    tenant_id           CHAR(36)     NOT NULL,
    review_task_id      CHAR(36)     NULL,
    subject_type        VARCHAR(80)  NOT NULL,
    subject_id          CHAR(36)     NOT NULL,
    decision            ENUM('submitted','returned','approved','rejected','superseded') NOT NULL,
    reason_code         VARCHAR(80)  NULL,
    comment_text        TEXT         NULL,
    evidence_snapshot   JSON         NULL,
    actor_user_id       CHAR(36)     NULL,
    correlation_id      CHAR(36)     NOT NULL,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_qh_approval_subject (tenant_id, subject_type, subject_id, created_at),
    KEY idx_qh_approval_task (tenant_id, review_task_id, created_at),
    KEY idx_qh_approval_correlation (tenant_id, correlation_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
