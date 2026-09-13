-- DDL extracted from 114_mooc_lms_courses.sql (sha256 5be5a818adee9e71bead9e8ed5eebbfe18402cd4aaec0e06585017d08843fda9)
CREATE TABLE IF NOT EXISTS mooc_courses (
    id                   CHAR(36)      NOT NULL,
    tenant_id            CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    course_code          VARCHAR(30)   NOT NULL,
    title_th             VARCHAR(255)  NOT NULL,
    title_en             VARCHAR(255)  NOT NULL,
    title_zh             VARCHAR(255)  NOT NULL,
    slug                 VARCHAR(255)  NOT NULL,
    instructor_name      VARCHAR(150)  NOT NULL,
    category             VARCHAR(100)  NOT NULL DEFAULT 'business' COMMENT 'business | technology | language | tourism',
    level                VARCHAR(30)   NOT NULL DEFAULT 'Beginner' COMMENT 'Beginner | Intermediate | Advanced',
    duration_hours       DECIMAL(4,1)  NOT NULL DEFAULT 10.0,
    total_lessons        INT           NOT NULL DEFAULT 6,
    cover_image_url      VARCHAR(500)  NULL,
    video_preview_url    VARCHAR(500)  NULL,
    description_th       TEXT          NULL,
    description_en       TEXT          NULL,
    description_zh       TEXT          NULL,
    learning_outcomes    JSON          NULL COMMENT 'Array of bullet points',
    certificate_eligible TINYINT(1)    NOT NULL DEFAULT 1,
    passing_score_pct    INT           NOT NULL DEFAULT 70,
    is_published         TINYINT(1)    NOT NULL DEFAULT 1,
    enrollment_count     INT           NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_mooc_code (course_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mooc_lessons (
    id                   CHAR(36)      NOT NULL,
    course_id            CHAR(36)      NOT NULL,
    module_index         INT           NOT NULL DEFAULT 1,
    lesson_order         INT           NOT NULL DEFAULT 1,
    title_th             VARCHAR(255)  NOT NULL,
    title_en             VARCHAR(255)  NOT NULL,
    title_zh             VARCHAR(255)  NOT NULL,
    video_url            VARCHAR(500)  NOT NULL COMMENT 'YouTube / Vimeo / HLS video link',
    duration_minutes     INT           NOT NULL DEFAULT 15,
    content_html_th      LONGTEXT      NULL,
    content_html_en      LONGTEXT      NULL,
    content_html_zh      LONGTEXT      NULL,
    download_url         VARCHAR(500)  NULL,
    is_preview           TINYINT(1)    NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_mooc_course_lesson (course_id, lesson_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mooc_quizzes (
    id                   CHAR(36)      NOT NULL,
    course_id            CHAR(36)      NOT NULL,
    lesson_id            CHAR(36)      NULL,
    title_th             VARCHAR(255)  NOT NULL,
    title_en             VARCHAR(255)  NOT NULL,
    title_zh             VARCHAR(255)  NOT NULL,
    quiz_payload         JSON          NOT NULL COMMENT 'Array of multiple-choice questions & answers',
    passing_pct          INT           NOT NULL DEFAULT 70,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_quiz_course (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mooc_enrollments (
    id                   CHAR(36)      NOT NULL,
    course_id            CHAR(36)      NOT NULL,
    student_id           CHAR(36)      NULL,
    user_email           VARCHAR(150)  NOT NULL,
    user_name            VARCHAR(150)  NOT NULL,
    progress_pct         INT           NOT NULL DEFAULT 0,
    completed_lessons    JSON          NULL COMMENT 'Array of completed lesson_ids',
    quiz_score_pct       INT           NULL,
    is_completed         TINYINT(1)    NOT NULL DEFAULT 0,
    completed_at         DATETIME      NULL,
    enrolled_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_user_course (course_id, user_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mooc_certificates (
    id                   CHAR(36)      NOT NULL,
    enrollment_id        CHAR(36)      NOT NULL,
    course_id            CHAR(36)      NOT NULL,
    recipient_name       VARCHAR(150)  NOT NULL,
    certificate_code     VARCHAR(50)   NOT NULL COMMENT 'e.g. UTKIC-MOOC-2026-XXXXX',
    verification_hash    VARCHAR(64)   NOT NULL,
    issued_at            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cert_code (certificate_code),
    UNIQUE KEY uq_cert_hash (verification_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
