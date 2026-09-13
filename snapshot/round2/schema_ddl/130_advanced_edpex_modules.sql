-- DDL extracted from 130_advanced_edpex_modules.sql (sha256 67d7c0ed22f10afd7897ed500dc4e3bb012003b0b6c687e89a37db5dafa7c7fa)
CREATE TABLE IF NOT EXISTS erm_risk_registers (
    id                CHAR(36)      NOT NULL,
    tenant_id         VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    risk_code         VARCHAR(50)   NOT NULL,
    risk_category     ENUM('strategic','operational','financial','compliance_legal','cyber_hazards') NOT NULL,
    risk_title        TEXT          NOT NULL,
    root_cause        TEXT          NULL,
    likelihood_score  TINYINT UNSIGNED NOT NULL DEFAULT 3 COMMENT '1-5 โอกาสเกิด',
    impact_score      TINYINT UNSIGNED NOT NULL DEFAULT 3 COMMENT '1-5 ผลกระทบ',
    risk_score        TINYINT UNSIGNED GENERATED ALWAYS AS (likelihood_score * impact_score) STORED,
    risk_tier         ENUM('low','moderate','high','extreme') NOT NULL DEFAULT 'moderate',
    key_risk_indicator VARCHAR(255) NULL COMMENT 'KRI ตัวชี้วัดความเสี่ยงสำคัญ',
    risk_owner_id     VARCHAR(64)   NULL COMMENT 'FK wf_personnel.id',
    bcp_required      TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'ต้องมีแผนความต่อเนื่องทางธุรกิจหรือไม่',
    bcp_plan_summary  TEXT          NULL COMMENT 'แผนเผชิญเหตุ / ความต่อเนื่องทางธุรกิจ',
    status            ENUM('identified','mitigating','monitored','closed') NOT NULL DEFAULT 'identified',
    fiscal_year       SMALLINT      NOT NULL DEFAULT 2569,
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_erm_code_year (tenant_id, risk_code, fiscal_year),
    KEY idx_erm_tier (risk_tier),
    KEY idx_erm_cat (risk_category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_benchmarks (
    id                CHAR(36)      NOT NULL,
    tenant_id         VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    kpi_code          VARCHAR(50)   NOT NULL COMMENT 'Code matching Cat 7 KPI or strategic KPI',
    benchmark_name    VARCHAR(255)  NOT NULL COMMENT 'e.g. ค่าเฉลี่ยกลุ่ม มทร., ค่าเฉลี่ยประเทศ, สถาบันชั้นนำระดับเอเชีย',
    comparison_type   ENUM('national_average','peer_group','best_in_class','competitor','historical_target') NOT NULL DEFAULT 'peer_group',
    benchmark_value   DECIMAL(12,2) NOT NULL,
    source_agency     VARCHAR(255)  NOT NULL COMMENT 'แหล่งข้อมูลอ้างอิง เช่น สป.อว., THE World Ranking, ผลสำรวจตลาด',
    benchmark_year    SMALLINT      NOT NULL DEFAULT 2569,
    our_actual_value  DECIMAL(12,2) NULL,
    gap_value         DECIMAL(12,2) NULL COMMENT 'our_actual - benchmark_value',
    favorable_status  ENUM('better','on_par','worse') NOT NULL DEFAULT 'on_par',
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_bm_kpi (kpi_code),
    KEY idx_bm_year (benchmark_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS edpex_sar_narrative_drafts (
    id                CHAR(36)      NOT NULL,
    tenant_id         VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    academic_year     SMALLINT      NOT NULL DEFAULT 2569,
    category_n        TINYINT UNSIGNED NOT NULL COMMENT '1-7',
    item_code         VARCHAR(20)   NOT NULL COMMENT 'e.g. 1.1, 2.1, 3.2, 5.1, 6.1, 6.2, 7.1',
    heading_title     VARCHAR(255)  NOT NULL,
    ai_draft_narrative LONGTEXT     NOT NULL COMMENT 'เนื้อหาร่างรายงานประเมินตนเอง สังเคราะห์จากโมดูลจริง',
    evidence_sources  TEXT          NULL COMMENT 'JSON array of linked tables/records used as proof',
    strengths_draft   TEXT          NULL COMMENT 'ร่างจุดแข็ง (Strengths)',
    ofi_draft         TEXT          NULL COMMENT 'ร่างโอกาสพัฒนา (OFI)',
    review_status     ENUM('ai_generated','under_review','approved_hitl','final_published') NOT NULL DEFAULT 'ai_generated',
    reviewed_by       CHAR(36)      NULL,
    reviewed_at       DATETIME      NULL,
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_sar_item_year (tenant_id, academic_year, item_code),
    KEY idx_sar_cat (category_n)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
