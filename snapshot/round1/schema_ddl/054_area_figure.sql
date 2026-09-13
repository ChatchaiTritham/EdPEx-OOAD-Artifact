-- DDL extracted from 054_area_figure.sql (sha256 dcfd1c02cf81116561b9bd10d7e8e7f22d372968aa31661c0ae25abe16009ec9)
CREATE TABLE IF NOT EXISTS edpex_area_figure (
  id           CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  item_code    VARCHAR(8)   NOT NULL,                 -- 1.1 … 6.2
  area_code    VARCHAR(12)  NOT NULL,                 -- 1.1ก(1)
  title        VARCHAR(300) NULL,                     -- caption after "ภาพที่ <area>-<n>"
  kind         VARCHAR(8)   NOT NULL DEFAULT 'svg',   -- svg | image
  svg_markup   MEDIUMTEXT   NULL,                     -- inline SVG when kind='svg'
  image_path   VARCHAR(500) NULL,                     -- relative/absolute path when kind='image'
  alt          VARCHAR(300) NULL,
  note         VARCHAR(500) NULL,
  draft_status VARCHAR(12)  NULL,                     -- pending|approved (NULL = faculty-authored, live)
  draft_source VARCHAR(40)  NULL,                     -- e.g. rule:area_adli_wheel_v1
  sort_order   SMALLINT     NOT NULL DEFAULT 0,
  updated_by   CHAR(36)     NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY ix_areafig (tenant_id, area_code, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
