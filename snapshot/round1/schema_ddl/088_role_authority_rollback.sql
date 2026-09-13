-- DDL extracted from 088_role_authority_rollback.sql (sha256 16a24e5d892b63e42b148e79b6d4d90867fc03af5057c434dab820277026c51c)
ALTER TABLE ref_roles DROP COLUMN IF EXISTS authority;

ALTER TABLE ref_roles DROP COLUMN IF EXISTS position_th;
