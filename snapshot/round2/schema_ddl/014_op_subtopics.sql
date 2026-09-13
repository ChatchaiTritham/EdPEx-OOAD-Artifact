-- DDL extracted from 014_op_subtopics.sql (sha256 819af2bdff7e060c8a8a539d82fb29a5bf8b75d06aecb08c05de0e9bd53b7523)
ALTER TABLE op_responses
  ADD COLUMN IF NOT EXISTS sub_code VARCHAR(20) NULL AFTER group_code;

ALTER TABLE op_responses DROP INDEX IF EXISTS uq_op;

ALTER TABLE op_responses ADD UNIQUE KEY IF NOT EXISTS uq_op (assessment_id, group_code, sub_code);
