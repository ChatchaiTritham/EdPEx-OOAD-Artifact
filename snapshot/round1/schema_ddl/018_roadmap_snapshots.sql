-- DDL extracted from 018_roadmap_snapshots.sql (sha256 ddaa99f0953dbba1f8c81ee88f42f86e161744b64755bc138938aaf473d8c178)
CREATE TABLE IF NOT EXISTS edpex_maturity_snapshots (
  id              CHAR(36)     NOT NULL,
  tenant_id       CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  be_year         SMALLINT     NOT NULL,
  assessment_date DATE         NULL,
  assessment_type VARCHAR(12)  NOT NULL DEFAULT 'self',   -- self | external | calibration
  overall_score   DECIMAL(7,1) NOT NULL DEFAULT 0,
  overall_band    VARCHAR(16)  NOT NULL DEFAULT '',        -- e.g. 'EdPEx 300'
  status          VARCHAR(10)  NOT NULL DEFAULT 'draft',   -- draft | approved
  note            VARCHAR(500) NULL,
  recorded_by     CHAR(36)     NULL,
  recorded_at     DATETIME     NOT NULL,
  approved_by     CHAR(36)     NULL,
  approved_at     DATETIME     NULL,
  PRIMARY KEY (id),
  KEY ix_ms_year   (be_year),
  KEY ix_ms_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_snapshot_category (
  id          CHAR(36)     NOT NULL,
  snapshot_id CHAR(36)     NOT NULL,
  category_n  TINYINT      NOT NULL,                       -- 1..7
  score       DECIMAL(7,1) NOT NULL DEFAULT 0,
  max_points  SMALLINT     NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY ix_sc_snap (snapshot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
