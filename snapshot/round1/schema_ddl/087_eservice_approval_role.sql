-- DDL extracted from 087_eservice_approval_role.sql (sha256 eddb0f151109acf74dd37696c0aeb5a15510b46086d57576d1518bb06314b488)
ALTER TABLE eservice_approval
  ADD COLUMN IF NOT EXISTS step_min_role VARCHAR(40) NULL AFTER step_label;
