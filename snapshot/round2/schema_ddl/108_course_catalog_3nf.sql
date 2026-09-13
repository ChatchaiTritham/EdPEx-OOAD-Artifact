-- DDL extracted from 108_course_catalog_3nf.sql (sha256 d62597d79c951581852c5df6e88e9b720a4dd747f8786a8d6dcdf20dac6bdfb4)
CREATE TABLE IF NOT EXISTS courses (
    id                CHAR(36)     NOT NULL,
    tenant_id         CHAR(36)     NOT NULL DEFAULT '00000000-0000-4000-a000-000000000001',
    course_code       VARCHAR(20)  NOT NULL,
    course_name_th    VARCHAR(255) NULL,
    course_name_en    VARCHAR(255) NULL,
    default_credits   DECIMAL(3,1) NULL,
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_courses_code (tenant_id, course_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE student_courses
    MODIFY COLUMN course_name_th VARCHAR(255) NULL COMMENT 'ชื่อวิชาตามที่พิมพ์ในเอกสารฉบับนี้จริง (OCR/กรอกมือ) — อาจต่างจาก courses.course_name_th ถ้าทะเบียนเปลี่ยนชื่อวิชาทีหลัง หรือ OCR อ่านคลาดเคลื่อน ไม่ใช่สำเนาจาก catalog',
    MODIFY COLUMN course_name_en VARCHAR(255) NULL COMMENT 'ชื่อวิชา (EN) ตามที่พิมพ์ในเอกสารฉบับนี้จริง — เหตุผลเดียวกับ course_name_th';
