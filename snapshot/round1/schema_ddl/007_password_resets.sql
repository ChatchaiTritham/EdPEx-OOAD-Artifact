-- DDL extracted from 007_password_resets.sql (sha256 9db0e24427b212175912e621fe71e4fbd203c79c727a208f54f6b4ace54b76ef)
CREATE TABLE IF NOT EXISTS password_resets (
    email      VARCHAR(190) NOT NULL,
    token_hash CHAR(64)     NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
