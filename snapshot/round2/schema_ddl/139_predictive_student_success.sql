-- DDL extracted from 139_predictive_student_success.sql (sha256 a68171a23a74e3b8c938c3d49469ea84af45c82bf2be3a26dacba5e65bb59be4)
CREATE TABLE IF NOT EXISTS student_propensity_models (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  academic_year INT NOT NULL DEFAULT 2569,
  semester TINYINT NOT NULL DEFAULT 1,
  student_id VARCHAR(36) NOT NULL,
  student_code VARCHAR(50) NOT NULL,
  student_name VARCHAR(255) NOT NULL,
  department VARCHAR(100) NOT NULL,
  current_gpa DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  accumulated_credits INT NOT NULL DEFAULT 0,
  expected_credits INT NOT NULL DEFAULT 120,
  attendance_rate DECIMAL(5,2) NOT NULL DEFAULT 100.00 COMMENT 'Class attendance %',
  lms_engagement_score DECIMAL(5,2) NOT NULL DEFAULT 80.00 COMMENT '0-100 LMS activity metric',
  assignment_lag_days DECIMAL(4,1) NOT NULL DEFAULT 0.0 COMMENT 'Average days late submitting work',
  graduation_propensity_pct DECIMAL(5,2) NOT NULL DEFAULT 85.00 COMMENT '0-100% chance to graduate on time',
  propensity_tier ENUM('High Propensity', 'Moderate Risk', 'High Risk', 'Critical Early-Exit') NOT NULL DEFAULT 'High Propensity',
  primary_risk_driver VARCHAR(255) NULL,
  prescribed_strategy TEXT NULL,
  calculated_at DATETIME NOT NULL,
  INDEX idx_std_code (student_code),
  INDEX idx_tier (propensity_tier),
  INDEX idx_year_sem (academic_year, semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_prescriptive_interventions (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  model_id VARCHAR(36) NOT NULL,
  student_code VARCHAR(50) NOT NULL,
  intervention_category ENUM('Academic Tutoring', 'Study Roadmap Re-alignment', 'Financial Counseling', 'Emotional & Well-being Referral', 'Micro-internship Coaching') NOT NULL,
  prescribed_action TEXT NOT NULL,
  assigned_mentor_or_unit VARCHAR(255) NOT NULL,
  status ENUM('Prescribed', 'In Progress', 'Completed', 'Dismissed') NOT NULL DEFAULT 'Prescribed',
  outcome_feedback TEXT NULL,
  target_completion_date DATE NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  INDEX idx_intervention_std (student_code),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
