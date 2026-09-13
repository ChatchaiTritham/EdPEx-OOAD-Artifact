-- DDL extracted from 116_academic_registration_curriculum.sql (sha256 37d052cc8fcc99b49af08a223d2b5c3e4f1941fd508f96a94ef830bbf0c870bb)
CREATE TABLE IF NOT EXISTS academic_curriculums (
    id                   CHAR(36)      NOT NULL,
    program_code         VARCHAR(30)   NOT NULL,
    program_name_th      VARCHAR(255)  NOT NULL,
    program_name_en      VARCHAR(255)  NOT NULL,
    program_name_zh      VARCHAR(255)  NOT NULL,
    degree_level         VARCHAR(50)   NOT NULL DEFAULT 'Bachelor',
    total_credits        INT           NOT NULL DEFAULT 128,
    is_active            TINYINT(1)    NOT NULL DEFAULT 1,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_curriculum_code (program_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS academic_course_sections (
    id                   CHAR(36)      NOT NULL,
    semester_id          CHAR(36)      NOT NULL,
    course_code          VARCHAR(30)   NOT NULL,
    course_name_th       VARCHAR(255)  NOT NULL,
    course_name_en       VARCHAR(255)  NOT NULL,
    course_name_zh       VARCHAR(255)  NOT NULL,
    credits              INT           NOT NULL DEFAULT 3,
    section_number       VARCHAR(10)   NOT NULL DEFAULT '1',
    instructor_name      VARCHAR(150)  NOT NULL,
    day_of_week          VARCHAR(15)   NOT NULL COMMENT 'Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday',
    start_time           TIME          NOT NULL,
    end_time             TIME          NOT NULL,
    room_number          VARCHAR(50)   NOT NULL DEFAULT 'IC-401',
    max_capacity         INT           NOT NULL DEFAULT 40,
    enrolled_count       INT           NOT NULL DEFAULT 0,
    is_open              TINYINT(1)    NOT NULL DEFAULT 1,
    created_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_sec_course (course_code, section_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_course_registrations (
    id                   CHAR(36)      NOT NULL,
    student_id           CHAR(36)      NULL,
    student_code         VARCHAR(30)   NOT NULL,
    section_id           CHAR(36)      NOT NULL,
    semester_id          CHAR(36)      NOT NULL,
    status               VARCHAR(30)   NOT NULL DEFAULT 'registered' COMMENT 'registered | approved | dropped | withdrawn',
    grade_letter         VARCHAR(5)    NULL COMMENT 'A | B+ | B | C+ | C | D+ | D | F | W | I | S | U',
    grade_point          DECIMAL(3,2)  NULL,
    payment_status       VARCHAR(30)   NOT NULL DEFAULT 'paid' COMMENT 'pending | paid | deferred',
    registered_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_stu_section (student_code, section_id),
    KEY idx_reg_semester (semester_id, student_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
