-- DDL extracted from 093_survey_bridge.sql (sha256 25b5a0d586150bbf88d5a03013b208ec0f915dc9bcdceeebd4f48d692ccdd563)
ALTER TABLE customer_voc
  ADD COLUMN IF NOT EXISTS promoted_at DATETIME NULL
    COMMENT 'Set when promoted to fact_satisfaction_responses by surveyVocToFactResponses()';

CREATE OR REPLACE VIEW v_research_per_faculty AS
SELECT
  p.academic_year,
  p.tenant_id,
  COUNT(p.id) / NULLIF(
    (SELECT COUNT(*) FROM fact_hr_personnel h2
      WHERE h2.academic_year = p.academic_year
        AND h2.tenant_id     = p.tenant_id
        AND h2.position_type = 'academic'), 0
  ) AS ratio_value
FROM fact_research_publications p
GROUP BY p.academic_year, p.tenant_id;
