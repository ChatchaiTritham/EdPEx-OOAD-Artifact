-- DDL extracted from 117_social_media_omnichannel.sql (sha256 749c42d1d226b59d2e788bf723587502750b26fa08795ab2e5046bb6c62892d2)
CREATE TABLE IF NOT EXISTS social_channel_configs (
    id                   CHAR(36)      NOT NULL,
    tenant_id            CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    platform             VARCHAR(50)   NOT NULL COMMENT 'wechat | line | facebook | youtube | tiktok | linkedin',
    channel_name         VARCHAR(150)  NOT NULL,
    account_id           VARCHAR(150)  NOT NULL,
    public_url           VARCHAR(500)  NOT NULL,
    qr_code_image_url    VARCHAR(500)  NULL,
    is_active            TINYINT(1)    NOT NULL DEFAULT 1,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_platform (tenant_id, platform)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_community_threads (
    id                   CHAR(36)      NOT NULL,
    tenant_id            CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    category             VARCHAR(50)   NOT NULL DEFAULT 'academic' COMMENT 'academic | student_life | housing | career | visa',
    title                VARCHAR(300)  NOT NULL,
    content              LONGTEXT      NOT NULL,
    author_name          VARCHAR(150)  NOT NULL,
    author_avatar_url    VARCHAR(500)  NULL,
    likes_count          INT           NOT NULL DEFAULT 0,
    replies_count        INT           NOT NULL DEFAULT 0,
    is_pinned            TINYINT(1)    NOT NULL DEFAULT 0,
    is_locked            TINYINT(1)    NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_thread_cat (category, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_community_replies (
    id                   CHAR(36)      NOT NULL,
    thread_id            CHAR(36)      NOT NULL,
    author_name          VARCHAR(150)  NOT NULL,
    author_role          VARCHAR(50)   NOT NULL DEFAULT 'student' COMMENT 'student | mentor | instructor | staff',
    content              TEXT          NOT NULL,
    likes_count          INT           NOT NULL DEFAULT 0,
    is_solution          TINYINT(1)    NOT NULL DEFAULT 0,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_reply_thread (thread_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
