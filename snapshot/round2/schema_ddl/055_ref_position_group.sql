-- DDL extracted from 055_ref_position_group.sql (sha256 2ac28a3bb0f926f7755de6d76cfa73f2b40c89ad1c34caaa4bf48554a58b35f8)
CREATE TABLE IF NOT EXISTS ref_position_group (
  id          CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id   CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  pattern     VARCHAR(80) NOT NULL,                 -- substring matched (case-sensitive Thai) in the field
  match_field VARCHAR(12) NOT NULL DEFAULT 'position', -- position | title
  std_group   VARCHAR(40) NOT NULL,                 -- ผู้บริหาร/หัวหน้างาน | สายวิชาการ | สายสนับสนุน
  sort_order  SMALLINT    NOT NULL DEFAULT 0,       -- lower = higher priority + display order
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pat (tenant_id, pattern, match_field)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
