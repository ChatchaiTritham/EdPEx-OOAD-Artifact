-- DDL extracted from 107_student_contact_channels.sql (sha256 5dc6714db094021848993ad2a18ce274b0ce9e6f0aa4a3a1b304c69f2a1ad82f)
ALTER TABLE students
    ADD COLUMN IF NOT EXISTS email VARCHAR(190) NULL COMMENT 'นักศึกษาเอง (ไม่ใช่ผู้ปกครอง — นั่นคือ family_contacts.email)' AFTER phone_mobile;

CREATE TABLE IF NOT EXISTS student_contact_channels (
    id           CHAR(36)     NOT NULL,
    tenant_id    CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    person_id    CHAR(36)     NOT NULL COMMENT 'FK students.id (app-level)',
    channel_type ENUM('line','wechat','dingtalk','whatsapp','telegram','kakaotalk','zalo','facebook','instagram','other') NOT NULL,
    channel_value VARCHAR(190) NOT NULL COMMENT 'LINE ID / WeChat ID / DingTalk ID / phone number for WhatsApp, etc. — format varies by channel_type, not normalized',
    label        VARCHAR(60)  NULL COMMENT 'free-text platform name when channel_type=other, e.g. "Zalo", "Viber"',
    is_primary   TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'ช่องทางหลักที่ติดต่อได้จริง เมื่อมีมากกว่า 1 ช่องทาง',
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_contact_channel (tenant_id, person_id, channel_type),
    KEY idx_contact_channels_person (person_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
