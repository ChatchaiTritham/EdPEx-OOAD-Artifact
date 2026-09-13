-- DDL extracted from 121_admission_mvp_audit_history.sql (sha256 0673a58902e61b321c93e28b7974d95161d7f180b52b7aca9d7d698f8ca54cdf)
CREATE TABLE IF NOT EXISTS ic_admission_status_history (
    id                 CHAR(36) NOT NULL,
    tenant_id          CHAR(36) NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    application_id     CHAR(36) NOT NULL COMMENT 'ic_admission_applications.id (application-level FK)',
    from_status        VARCHAR(40) NULL,
    to_status          VARCHAR(40) NOT NULL,
    reason_code        VARCHAR(80) NULL,
    applicant_message  TEXT NULL COMMENT 'safe, applicant-visible message;
