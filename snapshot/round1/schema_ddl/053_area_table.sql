-- DDL extracted from 053_area_table.sql (sha256 974c5c11569e4d3089ac92f174b55c731637b5c9483f41bee1251e668e8d2dbd)
CREATE TABLE IF NOT EXISTS edpex_area_table (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  item_code    VARCHAR(8)   NOT NULL,                 -- 1.1 … 6.2 (parent item)
  area_code    VARCHAR(12)  NOT NULL,                 -- 1.1ก(1) (areas[].code in edpex.json)
  title        VARCHAR(300) NULL,                     -- caption after "ตารางที่ <area>-<n>"
  col_headers  JSON         NOT NULL,                 -- ["คอลัมน์1","คอลัมน์2", …]
  row_data     JSON         NOT NULL,                 -- [["a","b"], …] aligned to col_headers
  note         VARCHAR(500) NULL,                     -- source / footnote line
  draft_status VARCHAR(12)  NULL,                     -- pending|approved (HITL;
