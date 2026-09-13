-- DDL extracted from 021_area_response.sql (sha256 0e65a06e1b9a0fa4701e96ebca6d986c57408e0ff146a5564de2bb01cb604c5e)
CREATE TABLE IF NOT EXISTS edpex_area_response (
  id          CHAR(36)    NOT NULL PRIMARY KEY,
  tenant_id   CHAR(36)    NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  item_code   VARCHAR(8)  NOT NULL,         -- e.g. 1.1, 4.2
  area_code   VARCHAR(12) NOT NULL,         -- e.g. 1.1ก, 4.2ข (areas[].code in edpex.json)
  body        TEXT        NULL,             -- the faculty's approach/deployment narrative for this area
  updated_by  CHAR(36)    NULL,
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_area (tenant_id, item_code, area_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
