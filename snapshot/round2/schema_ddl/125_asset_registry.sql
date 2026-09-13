-- DDL extracted from 125_asset_registry.sql (sha256 9877a8f0c9168f4f4fae3017cd955f60f297ab51e953b24ae7f5d45bb29629f3)
CREATE TABLE IF NOT EXISTS am_asset_categories (
    id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name    VARCHAR(150) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_category_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_funding_sources (
    id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name    VARCHAR(150) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_funding_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_acquisition_methods (
    id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name    VARCHAR(150) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_method_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_assets (
    id                          CHAR(36)      NOT NULL,
    tenant_id                   VARCHAR(40)   NOT NULL DEFAULT 'utk_ic',
    asset_code                  VARCHAR(255)  NOT NULL,
    item_no                     INT UNSIGNED  NULL,
    category_id                 INT UNSIGNED  NULL,
    asset_name                  VARCHAR(500)  NOT NULL,
    specification               VARCHAR(500)  NULL,
    model                       VARCHAR(255)  NULL,
    is_below_threshold          TINYINT(1)    NOT NULL DEFAULT 0,
    budget_fiscal_year          SMALLINT UNSIGNED NULL,
    acquisition_date            DATE          NULL,
    quantity                    DECIMAL(10,2) NULL,
    unit                        VARCHAR(50)   NULL,
    unit_price                  DECIMAL(14,2) NULL,
    total_value                 DECIMAL(14,2) NULL,
    useful_life_years           TINYINT UNSIGNED NULL,
    depreciation_rate_percent   DECIMAL(5,2)  NULL,
    location                    VARCHAR(255)  NULL,
    responsible_unit            VARCHAR(255)  NULL,
    vendor_name                 VARCHAR(255)  NULL,
    funding_source_id           INT UNSIGNED  NULL,
    acquisition_method_id       INT UNSIGNED  NULL,
    po_number                   VARCHAR(100)  NULL,
    document_category           VARCHAR(100)  NULL,
    remarks                     TEXT          NULL,
    source_file                 VARCHAR(150)  NULL,
    source_sheet                VARCHAR(150)  NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_asset_code (asset_code),
    KEY idx_am_asset_tenant (tenant_id),
    KEY idx_am_asset_category (category_id),
    KEY idx_am_asset_funding (funding_source_id),
    KEY idx_am_asset_method (acquisition_method_id),
    KEY idx_am_asset_fy (budget_fiscal_year),
    CONSTRAINT fk_am_asset_category FOREIGN KEY (category_id) REFERENCES am_asset_categories(id),
    CONSTRAINT fk_am_asset_funding  FOREIGN KEY (funding_source_id) REFERENCES am_funding_sources(id),
    CONSTRAINT fk_am_asset_method   FOREIGN KEY (acquisition_method_id) REFERENCES am_acquisition_methods(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_asset_depreciation_entries (
    id                          CHAR(36) NOT NULL,
    asset_id                    CHAR(36) NOT NULL,
    fiscal_year_be               SMALLINT UNSIGNED NOT NULL,
    entry_date                   DATE NULL,
    document_no                  VARCHAR(100) NULL,
    description                  VARCHAR(500) NULL,
    quantity                     DECIMAL(10,2) NULL,
    unit                         VARCHAR(50) NULL,
    unit_price                   DECIMAL(14,2) NULL,
    total_value                  DECIMAL(14,2) NULL,
    useful_life_years            TINYINT UNSIGNED NULL,
    depreciation_rate_percent    DECIMAL(5,2) NULL,
    annual_depreciation          DECIMAL(14,2) NULL,
    accumulated_depreciation     DECIMAL(14,2) NULL,
    net_book_value               DECIMAL(14,2) NULL,
    age_years                    TINYINT UNSIGNED NULL,
    age_months                   TINYINT UNSIGNED NULL,
    change_note                  VARCHAR(255) NULL,
    disposal_doc_no              VARCHAR(100) NULL,
    source                        ENUM('register','depreciation_report') NOT NULL DEFAULT 'register',
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_am_dep_entry (asset_id, fiscal_year_be, source),
    KEY idx_am_dep_asset (asset_id),
    CONSTRAINT fk_am_dep_asset FOREIGN KEY (asset_id) REFERENCES am_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS am_asset_maintenance_history (
    id                CHAR(36) NOT NULL,
    asset_id          CHAR(36) NOT NULL,
    seq_no            INT UNSIGNED NULL,
    maintenance_date  DATE NULL,
    description       TEXT NULL,
    quantity          VARCHAR(50) NULL,
    remarks           TEXT NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_am_maint_asset (asset_id),
    CONSTRAINT fk_am_maint_asset FOREIGN KEY (asset_id) REFERENCES am_assets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
