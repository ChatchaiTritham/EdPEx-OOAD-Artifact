-- DDL extracted from 040_fact_tables_w4.sql (sha256 7c5ac5eb324be148952f550cad764e5642ea7a35e006af7801476615b0df4809)
CREATE TABLE IF NOT EXISTS fact_research_publications (
    id           CHAR(36)     NOT NULL,
    tenant_id    CHAR(36)     NOT NULL,
    academic_year SMALLINT    NOT NULL COMMENT 'Injected by engine (from batch year)',
    pub_id       VARCHAR(80)  NOT NULL COMMENT 'รหัสผลงาน — uq biz-key per tenant',
    year         SMALLINT     NOT NULL COMMENT 'ปีที่เผยแพร่ (พ.ศ.) — year_column for harvest',
    pub_type     VARCHAR(30)  NOT NULL COMMENT 'journal_article|conference|creative|patent|other',
    indexing     VARCHAR(20)  NULL DEFAULT NULL COMMENT 'scopus|tci1|tci2|wos|none',
    author_unit  VARCHAR(120) NULL DEFAULT NULL COMMENT 'หน่วยงาน/ภาควิชา',
    trl_level    TINYINT      NULL DEFAULT NULL COMMENT 'TRL 1–9',
    award_level  VARCHAR(20)  NULL DEFAULT NULL COMMENT 'national|international|none',
    created_by   CHAR(36)     NULL DEFAULT NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_research_tenant_pub   (tenant_id, pub_id),
    KEY idx_research_year               (tenant_id, year),
    KEY idx_research_academic_year      (tenant_id, academic_year),
    KEY idx_research_pub_type           (pub_type),
    KEY idx_research_indexing           (indexing)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='RESEARCH publications (Arc) — feeds 7-1-008..014;

CREATE TABLE IF NOT EXISTS fact_hr_personnel (
    id               CHAR(36)      NOT NULL,
    tenant_id        CHAR(36)      NOT NULL,
    academic_year    SMALLINT      NOT NULL COMMENT 'Buddhist-era year e.g. 2567',
    staff_id         VARCHAR(40)   NOT NULL COMMENT 'รหัสบุคลากร — class-1 internal ID (not encrypted)',
    dept             VARCHAR(80)   NOT NULL COMMENT 'ภาควิชา/หน่วยงาน',
    position_type    VARCHAR(20)   NOT NULL COMMENT 'faculty|support|admin|executive',
    title            VARCHAR(60)   NULL DEFAULT NULL COMMENT 'ตำแหน่งทางวิชาการ เช่น ผศ.|รศ.|อ.',
    degree_level     VARCHAR(20)   NULL DEFAULT NULL COMMENT 'bachelor|master|doctoral',
    training_hrs     DECIMAL(7,2)  NULL DEFAULT NULL COMMENT 'ชั่วโมงฝึกอบรมต่อปี',
    engagement_score DECIMAL(5,2)  NULL DEFAULT NULL COMMENT 'คะแนนความผูกพัน (0–100 หรือ 0–5)',
    created_by       CHAR(36)      NULL DEFAULT NULL,
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_hr_year_staff          (tenant_id, academic_year, staff_id),
    KEY idx_hr_year                      (tenant_id, academic_year),
    KEY idx_hr_position_type             (position_type),
    KEY idx_hr_degree_level              (degree_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='HR personnel per year (Arc) — feeds 7-3-052..073;
