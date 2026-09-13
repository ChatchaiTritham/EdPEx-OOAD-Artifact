-- DDL extracted from 017_op_group_code.sql (sha256 8ce795c773fcb4e625f72b14f254e5bc5b0725e9764805f963cfb474df7460b8)
ALTER TABLE ref_op_group_items
  ADD COLUMN IF NOT EXISTS group_code VARCHAR(12) NULL AFTER group_id;

ALTER TABLE ref_op_group_items
  ADD INDEX IF NOT EXISTS idx_op_item_gcode (group_code);
