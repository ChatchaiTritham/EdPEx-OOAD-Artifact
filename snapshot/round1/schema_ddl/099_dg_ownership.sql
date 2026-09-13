-- DDL extracted from 099_dg_ownership.sql (sha256 4ff7a83d55e75060fd4ef985a8c9fbbe19ea56fbd62924fa32ae8c04c8deed54)
ALTER TABLE edpex_owners
  ADD COLUMN IF NOT EXISTS department VARCHAR(120) NULL
    COMMENT 'Org unit (QA/Research/Finance) RACI grouping',
  ADD COLUMN IF NOT EXISTS email VARCHAR(190) NULL
    COMMENT 'Future DG-4 relay;

CREATE TABLE IF NOT EXISTS edpex_kpi_raci (
    id             CHAR(36)    NOT NULL  COMMENT 'appUuid() PK',
    tenant_id      CHAR(36)    NOT NULL  DEFAULT '00000000-0000-4000-a000-000000000001',
    indicator_code VARCHAR(20) NOT NULL  COMMENT 'FK edpex_cat7_indicators',
    owner_id       CHAR(36)    NOT NULL  COMMENT 'FK edpex_owners.id',
    raci_role      ENUM('R','A','C','I') NOT NULL
                               COMMENT 'DG-1: A=executive+manage_admin;

ALTER TABLE edpex_milestone_status
  ADD COLUMN IF NOT EXISTS owner_id CHAR(36) NULL
    COMMENT 'FK edpex_owners.id;
