-- DDL extracted from 129_research_academic_services.sql (sha256 90c54ff7f08e99a96cc2d3423cb73522907ad8d48b4d874c82d45c11c81ef560)
CREATE TABLE IF NOT EXISTS rs_projects (
    id                        CHAR(36)      NOT NULL,
    tenant_id                 VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    project_code              VARCHAR(50)   NOT NULL,
    title_th                  TEXT          NOT NULL,
    title_en                  TEXT          NULL,
    principal_investigator_id VARCHAR(64)   NOT NULL COMMENT 'FK wf_personnel.id',
    funding_source_type       ENUM('internal','external_national','international','industry') NOT NULL DEFAULT 'internal',
    funding_agency_name       VARCHAR(255)  NULL,
    budget_allocated          DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    fiscal_year               SMALLINT      NOT NULL DEFAULT 2569,
    status                    ENUM('proposal','approved','in_progress','completed','extended','cancelled') NOT NULL DEFAULT 'in_progress',
    start_date                DATE          NULL,
    end_date                  DATE          NULL,
    created_at                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_rs_project_code (tenant_id, project_code),
    KEY idx_rs_proj_pi (principal_investigator_id),
    KEY idx_rs_proj_fy (fiscal_year),
    KEY idx_rs_proj_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rs_publications (
    id                   CHAR(36)      NOT NULL,
    tenant_id            VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    project_id           CHAR(36)      NULL COMMENT 'FK rs_projects.id',
    personnel_id         VARCHAR(64)   NOT NULL COMMENT 'FK wf_personnel.id',
    publication_type     ENUM('scopus_q1','scopus_q2','scopus_q3','scopus_q4','tci_1','tci_2','patent','petty_patent','copyright','intl_proceeding') NOT NULL DEFAULT 'scopus_q2',
    title                TEXT          NOT NULL,
    journal_or_publisher VARCHAR(255)  NULL,
    publication_year     SMALLINT      NOT NULL DEFAULT 2569,
    doi                  VARCHAR(150)  NULL,
    citations_count      INT UNSIGNED  NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_rs_pub_person (personnel_id),
    KEY idx_rs_pub_type (publication_type),
    KEY idx_rs_pub_year (publication_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rs_academic_services (
    id                        CHAR(36)      NOT NULL,
    tenant_id                 VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    service_code              VARCHAR(50)   NOT NULL,
    project_title             TEXT          NOT NULL,
    project_lead_id           VARCHAR(64)   NOT NULL COMMENT 'FK wf_personnel.id',
    target_community          VARCHAR(255)  NOT NULL,
    service_type              ENUM('training_consulting','community_development','policy_advocacy','commercial_transfer') NOT NULL DEFAULT 'training_consulting',
    participants_count        INT UNSIGNED  NOT NULL DEFAULT 0,
    satisfaction_score        DECIMAL(3,2)  NOT NULL DEFAULT 4.50,
    social_impact_description TEXT          NULL,
    revenue_generated         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    academic_year             SMALLINT      NOT NULL DEFAULT 2569,
    created_at                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_rs_svc_code (tenant_id, service_code),
    KEY idx_rs_svc_lead (project_lead_id),
    KEY idx_rs_svc_year (academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
