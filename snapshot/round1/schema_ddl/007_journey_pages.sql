-- DDL extracted from 007_journey_pages.sql (sha256 9c22b2ebc747041612e3d862af1f3256cb056dbbc6e50ab7f971c6547c90c160)
CREATE TABLE IF NOT EXISTS item_feedback (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  assessment_id CHAR(36)    NOT NULL,
  item_code     VARCHAR(8)  NOT NULL,
  strengths     TEXT        NULL,            -- จุดแข็งที่พิจารณาแล้ว
  ofis          TEXT        NULL,            -- โอกาสพัฒนา (feed ⑦)
  comment       TEXT        NULL,            -- ข้อสังเกตรวม / benchmark note
  reviewer_id   CHAR(36)    NULL,
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_feedback (assessment_id, item_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS km_practices (
  id            CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id     CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  title         VARCHAR(190) NOT NULL,
  category_n    TINYINT     NULL,            -- EdPEx หมวด 1-7 ที่เกี่ยวข้อง (NULL = ทั่วไป)
  item_code     VARCHAR(8)  NULL,
  summary       VARCHAR(500) NULL,
  body          TEXT        NULL,
  tags          VARCHAR(190) NULL,
  author_id     CHAR(36)    NULL,
  academic_year SMALLINT    NULL,
  status        ENUM('draft','published') NOT NULL DEFAULT 'published',
  created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_km_cat (category_n),
  KEY idx_km_year (academic_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
