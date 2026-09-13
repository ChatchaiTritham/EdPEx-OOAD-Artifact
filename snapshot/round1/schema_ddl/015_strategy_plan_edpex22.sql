-- DDL extracted from 015_strategy_plan_edpex22.sql (sha256 57ac3ee40ffb868d2a4299e4904e3c7264df5f603c9684456c8a0b37efb16c20)
ALTER TABLE action_plan
  ADD COLUMN IF NOT EXISTS horizon       ENUM('short','long') NOT NULL DEFAULT 'short' AFTER title,
  ADD COLUMN IF NOT EXISTS resource_plan VARCHAR(300) NULL AFTER budget,
  ADD COLUMN IF NOT EXISTS modification  VARCHAR(300) NULL AFTER progress_pct;

ALTER TABLE strategic_projection
  ADD COLUMN IF NOT EXISTS horizon      ENUM('short','long') NOT NULL DEFAULT 'short' AFTER budget_year,
  ADD COLUMN IF NOT EXISTS target_value DECIMAL(12,2) NULL AFTER projected_value,
  ADD COLUMN IF NOT EXISTS past_value   DECIMAL(12,2) NULL AFTER benchmark_value;
