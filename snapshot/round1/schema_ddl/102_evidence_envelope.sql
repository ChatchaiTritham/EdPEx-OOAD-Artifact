-- DDL extracted from 102_evidence_envelope.sql (sha256 c4bf9916d26e4c7363e5bbb71a1efe741e98a038ed19adf4c587f50bfcd69c0a)
ALTER TABLE fact_governance_metrics
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fgm_evidence (evidence_id);

ALTER TABLE fact_knowledge_assets
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fka_evidence (evidence_id);

ALTER TABLE fact_graduate_employment
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fge_evidence (evidence_id);

ALTER TABLE fact_satisfaction_responses
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fsr_evidence (evidence_id);

ALTER TABLE fact_research_publications
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_frp_evidence (evidence_id);

ALTER TABLE research_publications
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_rp_evidence (evidence_id);

ALTER TABLE fact_hr_personnel
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fhp_evidence (evidence_id);

ALTER TABLE fin_budget
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_finb_evidence (evidence_id);

ALTER TABLE fact_kpi_safety_incidents
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fksi_evidence (evidence_id);

ALTER TABLE fact_academic_service_projects
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fasp_evidence (evidence_id);

ALTER TABLE it_security_incidents
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_itsi_evidence (evidence_id);

ALTER TABLE fact_kpi_student_enrollment
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fkse_evidence (evidence_id);

ALTER TABLE fact_curriculum_status
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fcs_evidence (evidence_id);

ALTER TABLE fact_community_impact
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_fci_evidence (evidence_id);

ALTER TABLE student_awards
  ADD COLUMN IF NOT EXISTS source_channel VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS source_ref     VARCHAR(190) NULL,
  ADD COLUMN IF NOT EXISTS evidence_url   VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS evidence_id    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS verify_status  VARCHAR(12)  NULL,
  ADD COLUMN IF NOT EXISTS recorded_by    CHAR(36)     NULL,
  ADD COLUMN IF NOT EXISTS recorded_at    DATETIME     NULL,
  ADD INDEX IF NOT EXISTS ix_sa_evidence (evidence_id);
