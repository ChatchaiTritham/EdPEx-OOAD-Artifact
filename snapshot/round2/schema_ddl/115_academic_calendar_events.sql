-- DDL extracted from 115_academic_calendar_events.sql (sha256 b1897ccafb87864c7fab705779d35de9fa3b4668b6d9cf0e41b948b2f9a9e3bd)
CREATE TABLE IF NOT EXISTS academic_semesters (
    id                   CHAR(36)      NOT NULL,
    tenant_id            CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    academic_year        INT           NOT NULL COMMENT 'B.E. year e.g. 2569',
    academic_year_ce     INT           NOT NULL COMMENT 'C.E. year e.g. 2026',
    semester             VARCHAR(20)   NOT NULL COMMENT '1 | 2 | summer',
    title_th             VARCHAR(100)  NOT NULL,
    title_en             VARCHAR(100)  NOT NULL,
    title_zh             VARCHAR(100)  NOT NULL,
    start_date           DATE          NOT NULL,
    end_date             DATE          NOT NULL,
    is_current           TINYINT(1)    NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_term (academic_year, semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS academic_calendar_milestones (
    id                   CHAR(36)      NOT NULL,
    semester_id          CHAR(36)      NOT NULL,
    category             VARCHAR(50)   NOT NULL DEFAULT 'registration' COMMENT 'registration | add_drop | tuition | exam | grade | holiday | graduation',
    title_th             VARCHAR(255)  NOT NULL,
    title_en             VARCHAR(255)  NOT NULL,
    title_zh             VARCHAR(255)  NOT NULL,
    start_date           DATE          NOT NULL,
    end_date             DATE          NOT NULL,
    is_deadline          TINYINT(1)    NOT NULL DEFAULT 0,
    severity             VARCHAR(20)   NOT NULL DEFAULT 'normal' COMMENT 'normal | warning | danger | success',
    notes_th             TEXT          NULL,
    notes_en             TEXT          NULL,
    notes_zh             TEXT          NULL,
    display_order        INT           NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_cal_milestones (semester_id, start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS campus_events (
    id                   CHAR(36)      NOT NULL,
    tenant_id            CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    title_th             VARCHAR(255)  NOT NULL,
    title_en             VARCHAR(255)  NOT NULL,
    title_zh             VARCHAR(255)  NOT NULL,
    event_category       VARCHAR(50)   NOT NULL DEFAULT 'academic' COMMENT 'academic | cultural | workshop | career | sports',
    event_date           DATE          NOT NULL,
    start_time           TIME          NOT NULL,
    end_time             TIME          NOT NULL,
    location             VARCHAR(200)  NOT NULL,
    speaker_name         VARCHAR(150)  NULL,
    cover_image_url      VARCHAR(500)  NULL,
    description_th       TEXT          NULL,
    description_en       TEXT          NULL,
    description_zh       TEXT          NULL,
    rsvp_capacity        INT           NOT NULL DEFAULT 100,
    rsvp_count           INT           NOT NULL DEFAULT 0,
    is_public            TINYINT(1)    NOT NULL DEFAULT 1,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS campus_event_rsvps (
    id                   CHAR(36)      NOT NULL,
    event_id             CHAR(36)      NOT NULL,
    attendee_name        VARCHAR(150)  NOT NULL,
    attendee_email       VARCHAR(150)  NOT NULL,
    attendee_phone       VARCHAR(50)   NULL,
    student_code         VARCHAR(30)   NULL,
    registered_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_event_email (event_id, attendee_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
