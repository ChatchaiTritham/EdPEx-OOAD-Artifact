-- DDL extracted from 080_cat7_result_domain.sql (sha256 0baf3773592bd20f3c7f846b8f653c37e7d1c11a78b48d4b8bdf692362e6eae4)
ALTER TABLE edpex_cat7_indicator_meta
  ADD COLUMN IF NOT EXISTS result_domain     VARCHAR(120) NULL           AFTER direction;

ALTER TABLE edpex_cat7_indicator_meta
  ADD COLUMN IF NOT EXISTS result_domain_seq SMALLINT NOT NULL DEFAULT 0 AFTER result_domain;
