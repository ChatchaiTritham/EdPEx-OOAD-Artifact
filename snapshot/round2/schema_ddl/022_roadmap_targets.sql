-- DDL extracted from 022_roadmap_targets.sql (sha256 b8b959ba9f942521bcda93dc53e2a6fb6e84ffa6ae26ce0146f744cbdf76fd9a)
CREATE TABLE IF NOT EXISTS edpex_roadmap_targets (
  id             CHAR(36)     NOT NULL PRIMARY KEY,
  tenant_id      CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
  be_year        SMALLINT     NOT NULL,
  target_score   SMALLINT     NULL,           -- เป้าคะแนนรวมของปีนั้น (0-1000) — NULL = ยังไม่ยืนยัน
  baseline_score SMALLINT     NULL,           -- คะแนนฐานของคณะ ณ ปีนั้น (ถ้าระบุ)
  note           VARCHAR(500) NULL,
  confirmed_by   CHAR(36)     NULL,           -- ผู้บริหารที่ยืนยัน (HITL trail)
  confirmed_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_tenant_year (tenant_id, be_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
