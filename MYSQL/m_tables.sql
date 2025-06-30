CREATE TABLE mt_program_types (
    tid TINYINT UNSIGNED PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Unified programs view table
-- Acts as a directory of all program types to show in the user interface
CREATE TABLE dt_programs (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_type ENUM(
        'learning',
        'interview',
        'screening',
        'mock_interview'
    ) NOT NULL,
    program_tid BIGINT UNSIGNED NOT NULL COMMENT 'ID in the respective type table',
    title VARCHAR(100) NOT NULL,
    description TEXT,
    creator_tid BIGINT UNSIGNED NOT NULL,
    image_path VARCHAR(255),
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    location VARCHAR(100),
    price DECIMAL(10, 2) DEFAULT 0.00,
    sponsored BOOLEAN NOT NULL DEFAULT FALSE,
    difficulty_level VARCHAR(20),
    rating DECIMAL(3, 2) DEFAULT 0.00,
    enrollment_count INT UNSIGNED DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_type_tid (program_type, program_tid),
    INDEX idx_creator_tid (creator_tid),
    INDEX idx_is_public (is_public)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Program ratings and reviews
CREATE TABLE dt_program_ratings (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_tid BIGINT UNSIGNED NOT NULL,
    user_tid BIGINT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL COMMENT 'Rating from 1-5',
    review TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_tid (program_tid),
    INDEX idx_user_tid (user_tid),
    UNIQUE KEY uk_program_user (program_tid, user_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- Categories 
-- ============================================================================
-- Program categories
CREATE TABLE mt_program_categories (
    tid SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    parent_tid SMALLINT UNSIGNED COMMENT 'For hierarchical categories',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_parent_tid (parent_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Program category assignments
CREATE TABLE dt_program_category_assignments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_tid BIGINT UNSIGNED NOT NULL,
    category_tid SMALLINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_program_tid (program_tid),
    INDEX idx_category_tid (category_tid),
    UNIQUE KEY uk_program_category (program_tid, category_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- Master Data Tables 
-- ============================================================================
-- Languages table
CREATE TABLE mt_languages (
    tid SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code CHAR(2) NOT NULL UNIQUE COMMENT 'ISO 639-1 language code',
    name VARCHAR(50) NOT NULL,
    native_name VARCHAR(50)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Currencies table
CREATE TABLE mt_currencies (
    tid SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code CHAR(3) NOT NULL UNIQUE COMMENT 'ISO 4217 currency code',
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5) NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- User types table
CREATE TABLE mt_user_types (
    tid TINYINT UNSIGNED PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(100)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- Initial Common Data
-- ============================================================================
-- Insert program types
INSERT INTO mt_program_types (tid, name, description)
VALUES (
        1,
        'Learning',
        'Educational programs and courses'
    ),
    (2, 'Interview', 'Company interview assessments'),
    (
        3,
        'Screening',
        'Pre-interview screening assessments'
    ),
    (
        4,
        'Mock Interview',
        'Practice interviews for individuals'
    );
-- Insert some common program categories
INSERT INTO mt_program_categories (name, description)
VALUES (
        'Technology',
        'Technology and IT related programs'
    ),
    (
        'Business',
        'Business, management and leadership programs'
    ),
    ('Design', 'Design, UX/UI and creative programs'),
    (
        'Marketing',
        'Marketing, advertising and communication programs'
    ),
    (
        'Data Science',
        'Data science, analytics and machine learning'
    );
-- Insert common languages
INSERT INTO mt_languages (code, name, native_name)
VALUES ('en', 'English', 'English'),
    ('es', 'Spanish', 'Español'),
    ('fr', 'French', 'Français'),
    ('de', 'German', 'Deutsch'),
    ('zh', 'Chinese', '中文'),
    ('ja', 'Japanese', '日本語'),
    ('hi', 'Hindi', 'हिन्दी');
-- Insert common currencies
INSERT INTO mt_currencies (code, name, symbol)
VALUES ('USD', 'US Dollar', '$'),
    ('EUR', 'Euro', '€'),
    ('GBP', 'British Pound', '£'),
    ('INR', 'Indian Rupee', '₹'),
    ('JPY', 'Japanese Yen', '¥');
-- Insert user types
INSERT INTO mt_user_types (tid, name, description)
VALUES (
        1,
        'Individual',
        'Individual users with Google login, resume, profile picture'
    ),
    (2, 'Company', 'Company users with email/password login, company info');