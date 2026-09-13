-- DDL extracted from 126_procurement_asset_lifecycle.sql (sha256 03088832af6990a68977eca8ffefcd12cc1085a30e514b8b1d96cbbd9fdd59d3)
CREATE TABLE IF NOT EXISTS am_procurement_plans (
    id                  CHAR(36)      NOT NULL,
    tenant_id           VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    budget_fiscal_year  SMALLINT UNSIGNED NOT NULL,
    item_description    VARCHAR(500)  NOT NULL,
    category_id         INT UNSIGNED  NULL,
    planned_amount      DECIMAL(14,2) NULL,
    funding_source_id   INT UNSIGNED  NULL,
    planned_quarter     TINYINT UNSIGNED NULL,
    status              ENUM('draft','approved','cancelled') NOT NULL DEFAULT 'draft',
    created_by          CHAR(36)      NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_am_plan_tenant_fy (tenant_id, budget_fiscal_year),
    CONSTRAINT fk_am_plan_category FOREIGN KEY (category_id) REFERENCES am_asset_categories(id),
    CONSTRAINT fk_am_plan_funding  FOREIGN KEY (funding_source_id) REFERENCES am_funding_sources(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_procurement_cases (
    id                  CHAR(36)      NOT NULL,
    tenant_id           VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    plan_id             CHAR(36)      NULL,
    case_no             VARCHAR(100)  NOT NULL,
    procurement_method  ENUM('specific','e_bidding','e_market','selective','other') NOT NULL,
    vendor_name         VARCHAR(255)  NULL,
    contract_no         VARCHAR(100)  NULL,
    contract_amount     DECIMAL(14,2) NULL,
    contract_date       DATE          NULL,
    status              ENUM('pending_delivery','delivered','inspected_pass','inspected_fail',
                              'rejected_return_to_vendor','registered','cancelled')
                              NOT NULL DEFAULT 'pending_delivery',
    created_by          CHAR(36)      NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_case_no (case_no),
    KEY idx_am_case_plan (plan_id),
    KEY idx_am_case_status (status),
    CONSTRAINT fk_am_case_plan FOREIGN KEY (plan_id) REFERENCES am_procurement_plans(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_receiving_inspections (
    id                  CHAR(36) NOT NULL,
    procurement_case_id CHAR(36) NOT NULL,
    inspection_date     DATE     NOT NULL,
    result              ENUM('pass','fail','conditional') NOT NULL,
    condition_note       TEXT NULL,
    created_by           CHAR(36) NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_inspection_case (procurement_case_id),
    CONSTRAINT fk_am_inspection_case FOREIGN KEY (procurement_case_id)
        REFERENCES am_procurement_cases(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_receiving_inspection_members (
    id             CHAR(36)     NOT NULL,
    inspection_id  CHAR(36)     NOT NULL,
    user_id        CHAR(36)     NOT NULL,
    role_in_committee VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_inspection_member (inspection_id, user_id),
    CONSTRAINT fk_am_inspection_member_inspection FOREIGN KEY (inspection_id)
        REFERENCES am_receiving_inspections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_asset_issue_transactions (
    id                   CHAR(36)     NOT NULL,
    asset_id             CHAR(36)     NOT NULL,
    borrower_user_id     CHAR(36)     NOT NULL,
    issued_by_user_id    CHAR(36)     NULL,
    purpose              VARCHAR(255) NULL,
    issued_at            DATE         NOT NULL,
    expected_return_at   DATE         NULL,
    returned_at          DATE         NULL,
    condition_on_return  VARCHAR(255) NULL,
    status               ENUM('issued','returned','overdue') NOT NULL DEFAULT 'issued',
    remarks              TEXT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_am_issue_asset (asset_id),
    KEY idx_am_issue_borrower (borrower_user_id),
    KEY idx_am_issue_status (status),
    CONSTRAINT fk_am_issue_asset FOREIGN KEY (asset_id) REFERENCES am_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_annual_physical_counts (
    id              CHAR(36)    NOT NULL,
    tenant_id       VARCHAR(40) NOT NULL DEFAULT 'utk_ic',
    fiscal_year_be  SMALLINT UNSIGNED NOT NULL,
    status          ENUM('open','closed') NOT NULL DEFAULT 'open',
    started_at      DATE NULL,
    closed_at       DATE NULL,
    created_by      CHAR(36) NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_count_fy (tenant_id, fiscal_year_be)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_physical_count_members (
    id                 CHAR(36)     NOT NULL,
    count_id           CHAR(36)     NOT NULL,
    user_id            CHAR(36)     NOT NULL,
    role_in_committee  VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_count_member (count_id, user_id),
    CONSTRAINT fk_am_count_member_count FOREIGN KEY (count_id)
        REFERENCES am_annual_physical_counts(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_physical_count_lines (
    id                  CHAR(36) NOT NULL,
    count_id            CHAR(36) NOT NULL,
    asset_id            CHAR(36) NOT NULL,
    found_status        ENUM('found','not_found','damaged') NOT NULL,
    counted_by_user_id  CHAR(36) NULL,
    counted_at          DATETIME NULL,
    remark              VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_count_line (count_id, asset_id),
    KEY idx_am_count_line_asset (asset_id),
    CONSTRAINT fk_am_count_line_count FOREIGN KEY (count_id)
        REFERENCES am_annual_physical_counts(id) ON DELETE CASCADE,
    CONSTRAINT fk_am_count_line_asset FOREIGN KEY (asset_id) REFERENCES am_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_disposal_cases (
    id                CHAR(36)    NOT NULL,
    tenant_id         VARCHAR(40) NOT NULL DEFAULT 'utk_ic',
    disposal_method   ENUM('sell','exchange','transfer','convert','destroy') NOT NULL,
    reason            TEXT NULL,
    proposed_by_user_id CHAR(36) NULL,
    proposed_at       DATE NOT NULL,
    approval_status   ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    resolved_at       DATETIME NULL,
    proceeds_amount   DECIMAL(14,2) NULL,
    remarks           TEXT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_am_disposal_status (approval_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_disposal_committee_members (
    id                 CHAR(36)     NOT NULL,
    disposal_case_id   CHAR(36)     NOT NULL,
    user_id            CHAR(36)     NOT NULL,
    role_in_committee  VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_disposal_member (disposal_case_id, user_id),
    CONSTRAINT fk_am_disposal_member_case FOREIGN KEY (disposal_case_id)
        REFERENCES am_disposal_cases(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_disposal_case_votes (
    id                CHAR(36) NOT NULL,
    disposal_case_id  CHAR(36) NOT NULL,
    user_id           CHAR(36) NOT NULL,
    vote              ENUM('approve','reject','abstain') NOT NULL,
    voted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark            VARCHAR(255) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_disposal_vote (disposal_case_id, user_id),
    CONSTRAINT fk_am_disposal_vote_case FOREIGN KEY (disposal_case_id)
        REFERENCES am_disposal_cases(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_disposal_case_assets (
    id                CHAR(36) NOT NULL,
    disposal_case_id  CHAR(36) NOT NULL,
    asset_id          CHAR(36) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_disposal_asset (disposal_case_id, asset_id),
    KEY idx_am_disposal_asset_asset (asset_id),
    CONSTRAINT fk_am_disposal_asset_case FOREIGN KEY (disposal_case_id)
        REFERENCES am_disposal_cases(id) ON DELETE CASCADE,
    CONSTRAINT fk_am_disposal_asset_asset FOREIGN KEY (asset_id)
        REFERENCES am_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE am_assets
    ADD COLUMN IF NOT EXISTS procurement_case_id CHAR(36) NULL AFTER remarks,
    ADD COLUMN IF NOT EXISTS lifecycle_status ENUM(
        'pending_registration','registered','in_use','under_maintenance',
        'flagged_missing','pending_disposal','disposed'
    ) NOT NULL DEFAULT 'registered' AFTER procurement_case_id,
    ADD KEY idx_am_asset_procurement_case (procurement_case_id),
    ADD KEY idx_am_asset_lifecycle_status (lifecycle_status);
