-- DDL extracted from 041_fact_tables_w3w4_remainder.sql (sha256 315ee3918af1237bf3e3d51e39d0ce64c677a0e5436cedf282bfacab2faa5f7b)
CREATE TABLE IF NOT EXISTS fin_budget (
    id              CHAR(36)      NOT NULL,
    tenant_id       CHAR(36)      NOT NULL,
    academic_year   SMALLINT      NOT NULL COMMENT 'engine-managed (mirrors fiscal_year)',
    fiscal_year     SMALLINT      NOT NULL COMMENT 'Buddhist-era budget year',
    category        VARCHAR(40)   NOT NULL COMMENT 'student_dev|research|personnel_dev|operations|capex|other',
    allocated       DECIMAL(16,2) NOT NULL DEFAULT 0,
    spent           DECIMAL(16,2) NULL DEFAULT NULL,
    revenue         DECIMAL(16,2) NULL DEFAULT NULL,
    mission         VARCHAR(40)   NULL DEFAULT NULL COMMENT 'teaching|research|service|admin',
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_fin_year_cat (tenant_id, fiscal_year, category),
    KEY idx_fin_tenant_year (tenant_id, fiscal_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='FINANCE budget rows per fiscal year — feeds หมวด 7.5 finance results';

CREATE TABLE IF NOT EXISTS fact_kpi_safety_incidents (
    id                     CHAR(36)      NOT NULL,
    tenant_id              CHAR(36)      NOT NULL,
    academic_year          SMALLINT      NOT NULL COMMENT 'Buddhist-era year',
    incident_id            VARCHAR(60)   NOT NULL,
    incident_date          VARCHAR(20)   NULL DEFAULT NULL,
    incident_type          VARCHAR(40)   NULL DEFAULT NULL COMMENT 'lost_time|minor|near_miss|property_damage',
    total_incidents_count  INT           NOT NULL DEFAULT 0,
    env_monitoring_score   DECIMAL(10,4) NULL DEFAULT NULL,
    created_at             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_safety_incident (tenant_id, incident_id),
    KEY idx_safety_tenant_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='SAFETY/ENV incident records — feeds หมวด 7.1/7.4 safety results';

CREATE TABLE IF NOT EXISTS student_awards (
    id            CHAR(36)     NOT NULL,
    tenant_id     CHAR(36)     NOT NULL,
    academic_year SMALLINT     NOT NULL COMMENT 'engine-managed (mirrors year)',
    award_id      VARCHAR(60)  NOT NULL,
    year          SMALLINT     NOT NULL COMMENT 'Buddhist-era year',
    student_id    VARCHAR(60)  NULL DEFAULT NULL COMMENT 'pii_class 1 internal id (read endpoint omits)',
    award_level   VARCHAR(40)  NOT NULL COMMENT 'national|international|university|faculty',
    award_name    VARCHAR(190) NOT NULL,
    competition   VARCHAR(190) NULL DEFAULT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_award (tenant_id, award_id),
    KEY idx_award_tenant_year (tenant_id, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='STUDENT_AWARDS — feeds หมวด 7.1 student results';

CREATE TABLE IF NOT EXISTS research_publications (
    id            CHAR(36)     NOT NULL,
    tenant_id     CHAR(36)     NOT NULL,
    academic_year SMALLINT     NOT NULL COMMENT 'engine-managed (mirrors year)',
    pub_id        VARCHAR(60)  NOT NULL,
    year          SMALLINT     NOT NULL COMMENT 'Buddhist-era publication year',
    pub_type      VARCHAR(40)  NOT NULL COMMENT 'journal_article|conference|creative|patent|other',
    indexing      VARCHAR(40)  NULL DEFAULT NULL COMMENT 'scopus|tci1|tci2|wos|none',
    author_unit   VARCHAR(190) NULL DEFAULT NULL,
    trl_level     INT          NULL DEFAULT NULL COMMENT 'TRL 1-9',
    award_level   VARCHAR(40)  NULL DEFAULT NULL COMMENT 'national|international|none',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_pub (tenant_id, pub_id),
    KEY idx_pub_tenant_year (tenant_id, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='RESEARCH publications — feeds หมวด 7.1/7.5 research results';

CREATE TABLE IF NOT EXISTS hr_personnel (
    id               CHAR(36)      NOT NULL,
    tenant_id        CHAR(36)      NOT NULL,
    academic_year    SMALLINT      NOT NULL COMMENT 'Buddhist-era snapshot year',
    staff_id         VARCHAR(60)   NOT NULL COMMENT 'pii_class 1 internal id (read endpoint omits)',
    dept             VARCHAR(190)  NOT NULL,
    position_type    VARCHAR(40)   NOT NULL COMMENT 'faculty|support|admin|executive',
    title            VARCHAR(120)  NULL DEFAULT NULL,
    degree_level     VARCHAR(40)   NULL DEFAULT NULL COMMENT 'bachelor|master|doctoral',
    training_hrs     DECIMAL(10,2) NULL DEFAULT NULL,
    engagement_score DECIMAL(10,4) NULL DEFAULT NULL,
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_staff (tenant_id, staff_id),
    KEY idx_hr_tenant_year (tenant_id, academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='HR personnel — feeds หมวด 7.3 workforce results';

CREATE TABLE IF NOT EXISTS fact_academic_service_projects (
    id                  CHAR(36)      NOT NULL,
    tenant_id           CHAR(36)      NOT NULL,
    academic_year       SMALLINT      NOT NULL COMMENT 'engine-managed (mirrors year)',
    project_id          VARCHAR(60)   NOT NULL,
    year                SMALLINT      NOT NULL COMMENT 'Buddhist-era year',
    project_name        VARCHAR(190)  NOT NULL,
    households          INT           NULL DEFAULT NULL,
    participants        INT           NULL DEFAULT NULL,
    community_innovator INT           NULL DEFAULT NULL,
    sroi_value          DECIMAL(12,4) NULL DEFAULT NULL,
    sdg_tag             VARCHAR(120)  NULL DEFAULT NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_acadsvc_project (tenant_id, project_id),
    KEY idx_acadsvc_tenant_year (tenant_id, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='ACADEMIC_SERVICE community projects — feeds หมวด 7.4/7.5 societal results';
