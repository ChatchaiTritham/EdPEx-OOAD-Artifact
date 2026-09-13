-- DDL extracted from 013_understanding.sql (sha256 8f386b55069a37ea92cfa63f50fa64b16d83fa23ae54b225040ac1cc94316a4d)
ALTER TABLE audit_log
  ADD INDEX IF NOT EXISTS ix_audit_user_year (user_id, created_at);

ALTER TABLE kpis
  ADD COLUMN IF NOT EXISTS entered_by CHAR(36) NULL AFTER actual_value;
