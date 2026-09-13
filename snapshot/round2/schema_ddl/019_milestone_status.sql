-- DDL extracted from 019_milestone_status.sql (sha256 97b71382c8755f2401a4a67e5004e351dcba35e4f0a4013f1f111f4df9937057)
CREATE TABLE IF NOT EXISTS edpex_milestone_status (
  id            CHAR(36)     NOT NULL,
  tenant_id     CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  milestone_key VARCHAR(40)  NOT NULL,
  status        VARCHAR(12)  NOT NULL DEFAULT 'pending',  -- pending | in_progress | done
  owner         VARCHAR(190) NULL,                        -- free text (faculty RACI names = §7 confirm)
  note          VARCHAR(500) NULL,
  updated_by    CHAR(36)     NULL,
  updated_at    DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ms_key (tenant_id, milestone_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
