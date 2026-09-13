-- DDL extracted from 052_area_draft.sql (sha256 e04840cbe795d7a1d75e076a5c7e1d3338b8953ff89c15fe5c6886e33886b724)
ALTER TABLE edpex_area_response
  ADD COLUMN IF NOT EXISTS draft_body   TEXT        NULL AFTER body,
  ADD COLUMN IF NOT EXISTS draft_status VARCHAR(12) NULL AFTER draft_body,   -- pending|approved|rejected
  ADD COLUMN IF NOT EXISTS draft_source VARCHAR(40) NULL AFTER draft_status, -- e.g. rule:area_scaffold_v2
  ADD COLUMN IF NOT EXISTS draft_at     DATETIME    NULL AFTER draft_source;
