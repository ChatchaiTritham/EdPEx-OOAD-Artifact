-- DDL extracted from 096_community_registry.sql (sha256 885d57afae57832ac533e7fcd0b185277fe6d7acaa7555f8c6b4b25ab07a9b3f)
CREATE TABLE IF NOT EXISTS fact_community_impact (
    id                         CHAR(36)     NOT NULL,
    tenant_id                  CHAR(36)     NOT NULL,
    academic_year              SMALLINT     NOT NULL COMMENT 'Buddhist era AY',
    project_ref                VARCHAR(80)  NOT NULL COMMENT 'Unique project code per year',
    project_name               VARCHAR(300) NOT NULL,
    household_count            INT          NOT NULL DEFAULT 0
                               COMMENT 'Total households participating — denominator 7-4-077',
    household_income_increased INT          NOT NULL DEFAULT 0
                               COMMENT 'Households with net income increased — numerator 7-4-077',
    data_source                VARCHAR(120) NULL,
    notes                      TEXT         NULL,
    created_by                 CHAR(36)     NULL,
    created_at                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_community_proj (tenant_id, academic_year, project_ref)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Community impact projects — numerator/denominator for 7-4-077 household income increase ratio';

ALTER TABLE fact_kpi_student_enrollment
  ADD COLUMN IF NOT EXISTS certified_count     INT NULL
    COMMENT 'Students with professional/competency certification (numerator 7-1-016)',
  ADD COLUMN IF NOT EXISTS future_skills_count INT NULL
    COMMENT 'Students with future skills/digital certification (numerator 7-1-021)';
