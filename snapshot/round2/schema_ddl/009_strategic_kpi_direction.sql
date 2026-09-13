-- DDL extracted from 009_strategic_kpi_direction.sql (sha256 3275cd4d3370a70bf4e82b8978916bf2a37f3f181608b2260b2c6508bdbbbabc)
ALTER TABLE strategic_kpi
  ADD COLUMN IF NOT EXISTS direction ENUM('up','down') NOT NULL DEFAULT 'up' AFTER unit;
