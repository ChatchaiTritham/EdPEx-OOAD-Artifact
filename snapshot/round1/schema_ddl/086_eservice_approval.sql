-- DDL extracted from 086_eservice_approval.sql (sha256 9824636c3a92abf6e01232eeb84279e623d010606c89f76f6b8d60366c6d745e)
ALTER TABLE eservice_definition
  ADD COLUMN IF NOT EXISTS approval_chain TEXT NULL AFTER fee;

CREATE TABLE IF NOT EXISTS eservice_approval (
  id          CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id   CHAR(36)     NOT NULL,
  request_id  CHAR(36)     NOT NULL,
  step_no     INT          NOT NULL,
  step_label  VARCHAR(120) NOT NULL,
  decision    ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  decided_by  CHAR(36)     NULL,
  decided_at  DATETIME     NULL,
  note        VARCHAR(512) NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_esappr_req (tenant_id, request_id, step_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
