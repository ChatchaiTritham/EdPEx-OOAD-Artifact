-- DDL extracted from 095_governance_meta.sql (sha256 b4e8969b4d97d87ead212c5c84b49e0875d8b7857278365d9e6dec62973dcf8f)
ALTER TABLE edpex_cat7_indicator_meta
  ADD COLUMN IF NOT EXISTS owner_id CHAR(36) NULL
    COMMENT 'FK edpex_owners.id — RACI Responsible for KPI data collection (populated by admin via ?p=cat7_collect)';

CREATE OR REPLACE VIEW v_pdpa_score AS
  SELECT
    tenant_id,
    ROUND(AVG(score), 2) AS pdpa_score_100
  FROM compliance_maturity
  WHERE framework = 'PDPA'
  GROUP BY tenant_id;
