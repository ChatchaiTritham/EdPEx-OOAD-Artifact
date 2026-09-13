-- DDL extracted from 094_finance_mission.sql (sha256 3629eaa551cca929d5fd29fa1b8ec91deef89855bf635256b0247791331a5e3b)
ALTER TABLE fin_budget
  MODIFY COLUMN mission ENUM('teaching','research','service','admin') NULL
    COMMENT 'Mission per HITL H1 (category→mission map: student_dev=teaching, research=research, personnel_dev/operations/capex/other=admin)';

ALTER TABLE fact_kpi_student_enrollment
  ADD COLUMN IF NOT EXISTS plan_target     INT NULL
    COMMENT 'Planned intake for the cohort (denominator 7-5-093: enrolled/plan_target)',
  ADD COLUMN IF NOT EXISTS plan_enrollment INT NULL
    COMMENT 'Planned retention for the cohort (denominator 7-5-095: enrolled/plan_enrollment)';

ALTER TABLE fact_academic_service_projects
  ADD COLUMN IF NOT EXISTS beneficiary_count INT NULL DEFAULT 0
    COMMENT 'Income-generating service beneficiaries (feeds KPI 7-5-097 via SUM)';

CREATE OR REPLACE VIEW v_fin_surplus AS
  SELECT
    fiscal_year,
    tenant_id,
    academic_year,
    SUM(COALESCE(revenue, 0) - COALESCE(spent, 0)) AS surplus_value
  FROM fin_budget
  GROUP BY fiscal_year, tenant_id, academic_year;

CREATE OR REPLACE VIEW v_fin_revenue_ratio AS
  SELECT
    fiscal_year,
    tenant_id,
    academic_year,
    SUM(CASE WHEN mission = 'teaching'  THEN COALESCE(revenue, 0) ELSE 0 END)
      / NULLIF(SUM(COALESCE(revenue, 0)), 0) AS teaching_share,
    SUM(CASE WHEN mission = 'research'  THEN COALESCE(revenue, 0) ELSE 0 END)
      / NULLIF(SUM(COALESCE(revenue, 0)), 0) AS research_share,
    SUM(CASE WHEN mission = 'service'   THEN COALESCE(revenue, 0) ELSE 0 END)
      / NULLIF(SUM(COALESCE(revenue, 0)), 0) AS service_share,
    SUM(CASE WHEN mission = 'admin'     THEN COALESCE(revenue, 0) ELSE 0 END)
      / NULLIF(SUM(COALESCE(revenue, 0)), 0) AS admin_share
  FROM fin_budget
  GROUP BY fiscal_year, tenant_id, academic_year;
