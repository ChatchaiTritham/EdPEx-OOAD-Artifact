-- DDL extracted from 088_role_authority.sql (sha256 5df48ee44a3ec698c3e8bcffcec9ee0a20eb11e21b4c5c570480ac749d3b9de9)
ALTER TABLE ref_roles
  ADD COLUMN IF NOT EXISTS position_th VARCHAR(160) NOT NULL DEFAULT '' AFTER title_th;

ALTER TABLE ref_roles
  ADD COLUMN IF NOT EXISTS authority   VARCHAR(255) NOT NULL DEFAULT '' AFTER position_th;
