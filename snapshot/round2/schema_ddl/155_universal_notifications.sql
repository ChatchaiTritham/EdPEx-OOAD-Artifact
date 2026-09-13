-- DDL extracted from 155_universal_notifications.sql (sha256 f4c5b7375b9badf324e7f2bb121c8dd9b529806abc8af8defc141cddd0ec2f76)
CREATE TABLE IF NOT EXISTS user_notifications (
    id             CHAR(36)     NOT NULL PRIMARY KEY,
    tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    user_id        CHAR(36)     NULL COMMENT 'FK users.id if known',
    recipient_code VARCHAR(60)  NOT NULL COMMENT 'student_code, staff email, or user identifier',
    title          VARCHAR(255) NOT NULL,
    body           TEXT         NOT NULL,
    category       VARCHAR(50)  NOT NULL DEFAULT 'eservice' COMMENT 'eservice | visa | academic | advisory | system',
    action_url     VARCHAR(255) NULL,
    is_read        TINYINT(1)   NOT NULL DEFAULT 0,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at        DATETIME     NULL,
    KEY idx_notif_recipient (tenant_id, recipient_code, is_read),
    KEY idx_notif_user (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
