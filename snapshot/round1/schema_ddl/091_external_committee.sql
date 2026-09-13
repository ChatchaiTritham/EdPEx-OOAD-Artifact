-- DDL extracted from 091_external_committee.sql (sha256 1905c3d49694353d3d37ba8f42bd93fceb2c1da19381cfd8d6064b1d4d20de43)
CREATE TABLE IF NOT EXISTS external_reviewer (
  id             CHAR(36)    NOT NULL PRIMARY KEY,
  user_id        CHAR(36)    NOT NULL,
  tenant_id      CHAR(36)    NOT NULL,
  academic_year  SMALLINT    NOT NULL,                 -- BE year the committee reviews (e.g. 2569)
  valid_until    DATE        NOT NULL,                 -- access denied after this date
  is_revoked     TINYINT(1)  NOT NULL DEFAULT 0,
  created_by     CHAR(36)    NULL,
  created_at     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_access_at DATETIME    NULL,
  UNIQUE KEY uq_reviewer_user_year (user_id, academic_year),
  KEY ix_reviewer_active (tenant_id, is_revoked, valid_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
