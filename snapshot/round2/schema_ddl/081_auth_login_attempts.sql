-- DDL extracted from 081_auth_login_attempts.sql (sha256 366654328f54373e8b92e77ea161f369d96f86f79b697e0e69804fad13d600fc)
CREATE TABLE IF NOT EXISTS auth_login_attempts (
  id          CHAR(36)     NOT NULL,
  email       VARCHAR(255) NOT NULL DEFAULT '',
  ip          VARCHAR(45)  NOT NULL DEFAULT '',
  ok          TINYINT(1)   NOT NULL DEFAULT 0,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_email_time (email, created_at),
  KEY idx_ip_time (ip, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
