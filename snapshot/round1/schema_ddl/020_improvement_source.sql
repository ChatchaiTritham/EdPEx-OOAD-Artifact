-- DDL extracted from 020_improvement_source.sql (sha256 cc3515c91bec2490e839753271af35de214e2bb8a4215efef38e2ce910239aea)
ALTER TABLE improvements
  ADD COLUMN IF NOT EXISTS source     VARCHAR(16) NULL DEFAULT 'manual' AFTER status,  -- manual | gap_kpi | gap_score | gap_op
  ADD COLUMN IF NOT EXISTS priority   VARCHAR(8)  NULL                  AFTER source,   -- high | med | low
  ADD COLUMN IF NOT EXISTS source_ref VARCHAR(64) NULL                  AFTER priority;
