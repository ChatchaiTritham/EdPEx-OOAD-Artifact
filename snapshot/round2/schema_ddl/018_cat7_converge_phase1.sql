-- DDL extracted from 018_cat7_converge_phase1.sql (sha256 76a85c8f48aec18abe2943bd835ab9c4083c6da03a6b95e322216fc240cda6d2)
ALTER TABLE edpex_cat7_kpi_values
  ADD COLUMN IF NOT EXISTS letci_level       TINYINT  NULL AFTER benchmark_value,
  ADD COLUMN IF NOT EXISTS letci_trend       TINYINT  NULL AFTER letci_level,
  ADD COLUMN IF NOT EXISTS letci_comparison  TINYINT  NULL AFTER letci_trend,
  ADD COLUMN IF NOT EXISTS letci_integration TINYINT  NULL AFTER letci_comparison,
  ADD COLUMN IF NOT EXISTS verified_by       CHAR(36) NULL AFTER data_source,
  ADD COLUMN IF NOT EXISTS verified_at       DATETIME NULL AFTER verified_by;
