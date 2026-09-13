-- DDL extracted from 082_eservice_core.sql (sha256 f4387dff11e75df69fc1193b1a780d8ee424a67418749bd1a8769ba07504c679)
CREATE TABLE IF NOT EXISTS cms_page (
  id           CHAR(36)      NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)      NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  slug         VARCHAR(120)  NOT NULL,
  kind         ENUM('landing','news','about','policy') NOT NULL DEFAULT 'news',
  title        VARCHAR(255)  NOT NULL,
  summary      VARCHAR(500)  NULL,
  body         MEDIUMTEXT    NULL,
  published_at DATETIME      NULL,                 -- NULL = draft (not shown publicly)
  sort_order   SMALLINT      NOT NULL DEFAULT 0,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at   DATETIME      NULL,
  UNIQUE KEY uq_cms_slug (tenant_id, slug),
  KEY ix_cms_kind (tenant_id, kind, published_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS unit_profile (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  org_unit_ref  CHAR(36)     NULL,                 -- org_units.id (optional link)
  vision        TEXT         NULL,
  mission       TEXT         NULL,
  structure_json JSON        NULL,                 -- org chart / units
  contact_json  JSON         NULL,                 -- public contact block (no PII of individuals)
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_unit_tenant (tenant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS eservice_definition (
  id               CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  code             VARCHAR(40)  NOT NULL,
  name             VARCHAR(190) NOT NULL,
  category         VARCHAR(60)  NULL,
  description      TEXT         NULL,
  fields_json      JSON         NULL,              -- intake form schema (non-PII field defs)
  sla_days         SMALLINT     NOT NULL DEFAULT 7,
  work_process_ref CHAR(36)     NULL,              -- work_processes.id (process linkage for evidence)
  is_active        TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order       SMALLINT     NOT NULL DEFAULT 0,
  created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_esd_code (tenant_id, code),
  KEY ix_esd_active (tenant_id, is_active, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS eservice_request (
  id            CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  def_ref       CHAR(36)     NOT NULL,             -- eservice_definition.id
  ref_no        VARCHAR(24)  NOT NULL,             -- public tracking code
  academic_year SMALLINT     NOT NULL,
  status        ENUM('submitted','in_progress','done','rejected') NOT NULL DEFAULT 'submitted',
  contact_enc   TEXT         NULL,                 -- requester contact, appEncryptPII()
  payload_json  JSON         NULL,                 -- non-PII form answers
  sla_due_at    DATETIME     NULL,
  submitted_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at     DATETIME     NULL,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at    DATETIME     NULL,
  UNIQUE KEY uq_esr_ref (tenant_id, ref_no),
  KEY ix_esr_def (def_ref, status),
  KEY ix_esr_year (tenant_id, academic_year, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS public_intake_log (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  channel      VARCHAR(40)  NOT NULL DEFAULT 'web',
  intake_type  ENUM('complaint','voc','eservice') NOT NULL DEFAULT 'complaint',
  payload_json JSON         NOT NULL,              -- non-PII submission body
  contact_enc  TEXT         NULL,                  -- submitter contact, appEncryptPII()
  ip           VARCHAR(45)  NULL,                  -- throttle + provenance (not shown publicly)
  status       ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  canonical_id CHAR(36)     NULL,                  -- id of the canonical row created on promote
  reviewed_by  CHAR(36)     NULL,                  -- users.id of HITL approver
  reviewed_at  DATETIME     NULL,
  reject_reason VARCHAR(512) NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY ix_pil_status (tenant_id, status, created_at),
  KEY ix_pil_ip (ip, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
