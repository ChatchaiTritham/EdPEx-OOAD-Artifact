-- DDL extracted from 025_import_pipeline.sql (sha256 eca49e25997accf34015db761d918752596e4ea37243276a84b80a4e1c2f1e8c)
CREATE TABLE IF NOT EXISTS ref_import_destination (
  dest_key            VARCHAR(40)  NOT NULL PRIMARY KEY        COMMENT 'client-facing key;

CREATE TABLE IF NOT EXISTS ref_import_column (
  id               CHAR(36)     NOT NULL PRIMARY KEY,
  dest_key         VARCHAR(40)  NOT NULL                       COMMENT 'FK ref_import_destination.dest_key',
  source_header    VARCHAR(120) NOT NULL                       COMMENT 'expected file column header',
  target_column    VARCHAR(64)  NOT NULL                       COMMENT 'real column in target_table',
  data_type        ENUM('int','decimal','date','string','enum','bool') NOT NULL DEFAULT 'string',
  is_key           TINYINT(1)   NOT NULL DEFAULT 0             COMMENT '1 = part of the upsert match key',
  is_required      TINYINT(1)   NOT NULL DEFAULT 0,
  max_length       SMALLINT     NULL,
  validation_regex VARCHAR(200) NULL,
  is_active        TINYINT(1)   NOT NULL DEFAULT 1,
  UNIQUE KEY uq_impcol (dest_key, target_column),
  KEY ix_impcol_dest (dest_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ref_import_column_enum (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  column_id     CHAR(36)    NOT NULL                           COMMENT 'FK ref_import_column.id',
  allowed_value VARCHAR(80) NOT NULL,
  UNIQUE KEY uq_impenum (column_id, allowed_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_job (
  id               CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id        CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  dest_key         VARCHAR(40)  NOT NULL                       COMMENT 'FK ref_import_destination.dest_key',
  source_format    ENUM('csv','xlsx','json') NOT NULL DEFAULT 'csv',
  original_filename VARCHAR(255) NOT NULL,
  storage_path     VARCHAR(255) NULL                           COMMENT 'storage/imports/<id>.<ext>',
  file_sha256      CHAR(64)     NULL                           COMMENT 'integrity + re-upload dedup',
  academic_year    SMALLINT     NULL,
  status           ENUM('uploaded','validating','validated','pending_approval',
                        'approved','committing','committed','rejected','failed')
                   NOT NULL DEFAULT 'uploaded',
  total_rows       INT          NOT NULL DEFAULT 0,
  valid_rows       INT          NOT NULL DEFAULT 0,
  invalid_rows     INT          NOT NULL DEFAULT 0,
  committed_rows   INT          NOT NULL DEFAULT 0,
  uploaded_by      CHAR(36)     NOT NULL                       COMMENT 'users.id',
  uploaded_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  approved_by      CHAR(36)     NULL                           COMMENT 'users.id;

CREATE TABLE IF NOT EXISTS import_staging_row (
  id          CHAR(36) NOT NULL PRIMARY KEY,
  job_id      CHAR(36) NOT NULL                               COMMENT 'FK import_job.id',
  row_num     INT      NOT NULL,
  row_status  ENUM('pending','valid','invalid','committed','skipped') NOT NULL DEFAULT 'pending',
  target_pk   CHAR(36) NULL                                   COMMENT 'id written/upserted on commit',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_stgrow (job_id, row_num),
  KEY ix_stgrow_status (job_id, row_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_staging_cell (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  staging_row_id CHAR(36)     NOT NULL                        COMMENT 'FK import_staging_row.id',
  source_header  VARCHAR(120) NOT NULL,
  cell_value     TEXT         NULL,
  UNIQUE KEY uq_stgcell (staging_row_id, source_header)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_validation_error (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  staging_row_id CHAR(36)     NOT NULL                        COMMENT 'FK import_staging_row.id',
  source_header  VARCHAR(120) NULL                            COMMENT 'NULL = row-level error',
  error_code     VARCHAR(40)  NOT NULL                        COMMENT 'REQUIRED|TYPE|REGEX|ENUM|LENGTH|PDPA|DUP',
  message        VARCHAR(300) NOT NULL,
  created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_verr_row (staging_row_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS import_event (
  id         CHAR(36)     NOT NULL PRIMARY KEY,
  job_id     CHAR(36)     NOT NULL                            COMMENT 'FK import_job.id',
  event      ENUM('created','validated','submitted','approved','rejected','committed','failed') NOT NULL,
  actor_id   CHAR(36)     NULL,
  detail     VARCHAR(400) NULL,
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY ix_evt_job (job_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
