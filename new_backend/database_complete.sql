-- =====================================================
-- قاعدة بيانات تطبيق خدمات الأحداث - ملف شامل وسريع
-- Complete Database for Event Services Application
-- =====================================================

-- إنشاء قاعدة البيانات
CREATE DATABASE IF NOT EXISTS asha_app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE asha_app_db;

-- =====================================================
-- حذف الجداول الموجودة
-- =====================================================
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS ads;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS provider_requests;
DROP TABLE IF EXISTS profile_requests;
DROP TABLE IF EXISTS statistics;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- =====================================================
-- إنشاء الجداول
-- =====================================================

-- جدول المستخدمين
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
    profile_image VARCHAR(500) NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    bio TEXT NULL,
    website VARCHAR(255) NULL,
    address TEXT NULL,
    city VARCHAR(100) DEFAULT 'إب',
    country VARCHAR(100) DEFAULT 'اليمن',
    latitude DECIMAL(10,8) NULL,
    longitude DECIMAL(11,8) NULL,
    kareemi_account_number VARCHAR(20) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_user_type (user_type),
    INDEX idx_is_active (is_active)
);

-- جدول فئات الخدمات
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    icon VARCHAR(100) DEFAULT 'category',
    color VARCHAR(7) DEFAULT '#8e24aa',
    image_url VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active)
);

-- جدول الخدمات
CREATE TABLE services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2) NULL,
    duration INT DEFAULT 60,
    images JSON NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    booking_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    location VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) DEFAULT 'إب',
    country VARCHAR(100) DEFAULT 'اليمن',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_provider_id (provider_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active),
    FULLTEXT idx_search (title, description)
);

-- جدول الحجوزات
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    note TEXT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled', 'rejected') DEFAULT 'pending',
    total_price DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    payment_method ENUM('cash', 'kareemi_bank') NOT NULL,
    kareemi_transaction_id VARCHAR(255) NULL,
    payment_proof VARCHAR(500) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id),
    INDEX idx_status (status)
);

-- جدول المفضلة
CREATE TABLE favorites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_service (user_id, service_id)
);

-- جدول التقييمات
CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    provider_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_service_review (user_id, service_id)
);

-- جدول الإعلانات
CREATE TABLE ads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    provider_id INT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image VARCHAR(500) NOT NULL,
    link VARCHAR(500) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    priority INT DEFAULT 0,
    start_date DATE NULL,
    end_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE SET NULL
);

-- جدول الإشعارات
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('booking', 'payment', 'review', 'system', 'promotion') DEFAULT 'system',
    is_read BOOLEAN DEFAULT FALSE,
    data JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الرسائل
CREATE TABLE messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الدفعات
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'kareemi_bank') NOT NULL,
    kareemi_transaction_id VARCHAR(255) NULL,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الإحصائيات
CREATE TABLE statistics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    total_users INT DEFAULT 0,
    total_providers INT DEFAULT 0,
    total_services INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    total_revenue DECIMAL(12,2) DEFAULT 0.00,
    active_services INT DEFAULT 0,
    pending_bookings INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date (date)
);

-- جدول إعدادات النظام
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- إدراج البيانات الأساسية
-- =====================================================

-- إدراج فئات الخدمات
INSERT INTO categories (name, description, icon, color) VALUES
('التصوير', 'خدمات التصوير الاحترافي للأعراس والمناسبات', 'camera_alt', '#2196f3'),
('فساتين الأفراح', 'تصميم وتفصيل فساتين الأعراس', 'checkroom', '#e91e63'),
('قاعات الأفراح', 'حجز قاعات الأعراس والمناسبات', 'celebration', '#4caf50'),
('المناسبات', 'تنظيم وإدارة المناسبات المختلفة', 'event', '#ff9800'),
('الديكور', 'تنسيق وتزيين قاعات الأعراس', 'palette', '#9c27b0'),
('الموسيقى', 'خدمات الموسيقى والغناء للأعراس', 'music_note', '#795548'),
('الجاتوهات', 'تصميم وتصنيع كيك الأعراس', 'cake', '#607d8b'),
('التجميل', 'خدمات التجميل والعناية للعروس', 'spa', '#f44336'),
('الفيديو', 'تصوير وإنتاج فيديوهات الأعراس', 'videocam', '#3f51b5'),
('الضيافة', 'خدمات الضيافة والاستقبال', 'restaurant', '#009688');

-- إدراج إعدادات النظام
INSERT INTO settings (setting_key, setting_value, setting_type, description) VALUES
('app_name', 'تطبيق خدمات الأحداث', 'string', 'اسم التطبيق'),
('app_version', '1.0.0', 'string', 'إصدار التطبيق'),
('maintenance_mode', 'false', 'boolean', 'وضع الصيانة'),
('max_upload_size', '5242880', 'number', 'الحد الأقصى لحجم الملف (5MB)'),
('allowed_image_types', '["jpg", "jpeg", "png", "webp"]', 'json', 'أنواع الصور المسموحة'),
('booking_advance_days', '30', 'number', 'عدد الأيام المسموح للحجز مسبقاً'),
('commission_percentage', '10', 'number', 'نسبة العمولة من الحجوزات'),
('auto_approve_providers', 'false', 'boolean', 'الموافقة التلقائية على مزودي الخدمة'),
('max_images_per_service', '10', 'number', 'الحد الأقصى لعدد الصور لكل خدمة'),
('review_auto_approve', 'true', 'boolean', 'الموافقة التلقائية على التقييمات');

-- إدراج المستخدم الإداري
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, city, country) VALUES
('مدير النظام', 'admin@asha-app.com', '777000000', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', TRUE, TRUE, 'إب', 'اليمن');

-- إدراج المزودين
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, city, country, bio, rating, review_count) VALUES
('أحمد المصور', 'ahmed@example.com', '777111111', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'مصور محترف للأعراس والمناسبات مع خبرة 10 سنوات', 4.8, 25),
('فاطمة خياطة', 'fatima@example.com', '777222222', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'تصميم وتفصيل فساتين الأعراس بأحدث الموضات', 4.6, 18),
('محمد قاعة', 'mohammed@example.com', '777333333', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'قاعات الأعراس والمناسبات مع خدمات شاملة', 4.7, 32),
('علي ديكور', 'ali@example.com', '777444444', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'تنسيق وتزيين قاعات الأعراس بأحدث التصاميم', 4.5, 15),
('سارة موسيقى', 'sara@example.com', '777555555', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'خدمات الموسيقى والغناء للأعراس مع فرق احترافية', 4.9, 28),
('خالد جاتوهات', 'khalid@example.com', '777666666', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'تصميم وتصنيع كيك الأعراس بأشكال فنية مميزة', 4.4, 12),
('نور التجميل', 'noor@example.com', '777777777', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'خدمات التجميل والعناية للعروس مع أحدث التقنيات', 4.6, 20),
('يوسف فيديو', 'yousef@example.com', '777888888', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'تصوير وإنتاج فيديوهات الأعراس بأحدث المعدات', 4.7, 22),
('ليلى ضيافة', 'laila@example.com', '777999999', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'خدمات الضيافة والاستقبال مع أطباق شهية', 4.5, 16),
('عمر مناسبات', 'omar@example.com', '777101010', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', TRUE, TRUE, 'إب', 'اليمن', 'تنظيم وإدارة المناسبات المختلفة باحترافية عالية', 4.8, 30);

-- إدراج المستخدمين العاديين
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, city, country) VALUES
('أحمد محمد', 'ahmed.user@example.com', '777111111', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', TRUE, TRUE, 'إب', 'اليمن'),
('فاطمة علي', 'fatima.user@example.com', '777222222', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', TRUE, TRUE, 'إب', 'اليمن'),
('محمد أحمد', 'mohammed.user@example.com', '777333333', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', TRUE, TRUE, 'إب', 'اليمن'),
('سارة محمد', 'sara.user@example.com', '777444444', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', TRUE, TRUE, 'إب', 'اليمن'),
('علي حسن', 'ali.user@example.com', '777555555', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', TRUE, TRUE, 'إب', 'اليمن');

-- إدراج الخدمات
INSERT INTO services (provider_id, category_id, title, description, price, original_price, duration, images, is_active, is_verified, location, address, city, country) VALUES
(2, 1, 'تصوير عرس كامل', 'تصوير احترافي لعرس كامل مع ألبوم فاخر و 200 صورة', 1500.00, 2000.00, 480, '["uploads/services/photo1.jpg", "uploads/services/photo2.jpg"]', TRUE, TRUE, 'إب', 'شارع الجمهورية، إب', 'إب', 'اليمن'),
(2, 1, 'تصوير مناسبات', 'تصوير المناسبات المختلفة مع فيديو قصير', 800.00, 1000.00, 240, '["uploads/services/photo3.jpg"]', TRUE, TRUE, 'إب', 'شارع السوق، إب', 'إب', 'اليمن'),
(3, 2, 'فسينة عروس فاخرة', 'تصميم وتفصيل فسينة عروس فاخرة مع التطريز', 3000.00, 3500.00, 1440, '["uploads/services/dress1.jpg", "uploads/services/dress2.jpg"]', TRUE, TRUE, 'إب', 'شارع السوق، إب', 'إب', 'اليمن'),
(3, 2, 'فسينة عروس كلاسيكية', 'فسينة عروس كلاسيكية أنيقة', 2500.00, 3000.00, 1440, '["uploads/services/dress3.jpg"]', TRUE, TRUE, 'إب', 'شارع النصر، إب', 'إب', 'اليمن'),
(4, 3, 'قاعة أعراس فاخرة', 'قاعة أعراس فاخرة مع خدمات شاملة لـ 200 شخص', 5000.00, 6000.00, 1440, '["uploads/services/hall1.jpg", "uploads/services/hall2.jpg"]', TRUE, TRUE, 'إب', 'شارع النصر، إب', 'إب', 'اليمن'),
(4, 3, 'قاعة مناسبات متوسطة', 'قاعة مناسبات متوسطة لـ 100 شخص', 3000.00, 3500.00, 1440, '["uploads/services/hall3.jpg"]', TRUE, TRUE, 'إب', 'شارع السلام، إب', 'إب', 'اليمن'),
(5, 5, 'تنسيق ديكور كامل', 'تنسيق وتزيين ديكور كامل للعرس مع الإضاءة', 2000.00, 2500.00, 720, '["uploads/services/decor1.jpg", "uploads/services/decor2.jpg"]', TRUE, TRUE, 'إب', 'شارع السلام، إب', 'إب', 'اليمن'),
(5, 5, 'ديكور بسيط', 'ديكور بسيط وأنيق للمناسبات الصغيرة', 1200.00, 1500.00, 480, '["uploads/services/decor3.jpg"]', TRUE, TRUE, 'إب', 'شارع الفن، إب', 'إب', 'اليمن'),
(6, 6, 'فرقة موسيقية', 'فرقة موسيقية احترافية للأعراس مع 4 موسيقيين', 1200.00, 1500.00, 480, '["uploads/services/music1.jpg"]', TRUE, TRUE, 'إب', 'شارع الفن، إب', 'إب', 'اليمن'),
(6, 6, 'موسيقى خلفية', 'موسيقى خلفية هادئة للمناسبات', 600.00, 800.00, 240, '["uploads/services/music2.jpg"]', TRUE, TRUE, 'إب', 'شارع الجمهورية، إب', 'إب', 'اليمن'),
(7, 7, 'كيك عرس فاخر', 'كيك عرس فاخر 3 طوابق مع التزيين', 800.00, 1000.00, 1440, '["uploads/services/cake1.jpg", "uploads/services/cake2.jpg"]', TRUE, TRUE, 'إب', 'شارع السوق، إب', 'إب', 'اليمن'),
(7, 7, 'كيك مناسبات', 'كيك مناسبات بسيط وأنيق', 400.00, 500.00, 720, '["uploads/services/cake3.jpg"]', TRUE, TRUE, 'إب', 'شارع النصر، إب', 'إب', 'اليمن'),
(8, 8, 'تجميل عروس كامل', 'تجميل عروس كامل مع المكياج والهيرستايل', 1000.00, 1200.00, 240, '["uploads/services/beauty1.jpg"]', TRUE, TRUE, 'إب', 'شارع السلام، إب', 'إب', 'اليمن'),
(8, 8, 'مكياج عروس', 'مكياج عروس احترافي', 600.00, 700.00, 120, '["uploads/services/beauty2.jpg"]', TRUE, TRUE, 'إب', 'شارع الفن، إب', 'إب', 'اليمن'),
(9, 9, 'فيديو عرس كامل', 'تصوير وإنتاج فيديو عرس كامل مع المونتاج', 2000.00, 2500.00, 480, '["uploads/services/video1.jpg"]', TRUE, TRUE, 'إب', 'شارع الجمهورية، إب', 'إب', 'اليمن'),
(9, 9, 'فيديو قصير', 'فيديو قصير للمناسبات', 800.00, 1000.00, 240, '["uploads/services/video2.jpg"]', TRUE, TRUE, 'إب', 'شارع السوق، إب', 'إب', 'اليمن'),
(10, 10, 'ضيافة كاملة', 'خدمات الضيافة والاستقبال مع قائمة طعام فاخرة', 3000.00, 3500.00, 1440, '["uploads/services/catering1.jpg"]', TRUE, TRUE, 'إب', 'شارع النصر، إب', 'إب', 'اليمن'),
(10, 10, 'ضيافة بسيطة', 'ضيافة بسيطة مع قائمة طعام أساسية', 1500.00, 1800.00, 720, '["uploads/services/catering2.jpg"]', TRUE, TRUE, 'إب', 'شارع السلام، إب', 'إب', 'اليمن'),
(11, 4, 'تنظيم عرس كامل', 'تنظيم وإدارة عرس كامل مع جميع الخدمات', 8000.00, 10000.00, 1440, '["uploads/services/event1.jpg"]', TRUE, TRUE, 'إب', 'شارع الفن، إب', 'إب', 'اليمن'),
(11, 4, 'تنظيم مناسبة', 'تنظيم مناسبة بسيطة مع التنسيق', 2000.00, 2500.00, 720, '["uploads/services/event2.jpg"]', TRUE, TRUE, 'إب', 'شارع الجمهورية، إب', 'إب', 'اليمن');

-- إدراج الإعلانات
INSERT INTO ads (provider_id, title, description, image, is_active, priority) VALUES
(2, 'خصم 20% على تصوير الأعراس', 'عرض خاص على تصوير الأعراس مع ألبوم فاخر', 'uploads/ads/photo_ad.jpg', TRUE, 1),
(3, 'فساتين عروس جديدة', 'مجموعة جديدة من فساتين العروس بأحدث الموضات', 'uploads/ads/dress_ad.jpg', TRUE, 2),
(4, 'قاعات أعراس فاخرة', 'حجز قاعات الأعراس بأسعار مميزة', 'uploads/ads/hall_ad.jpg', TRUE, 3),
(5, 'ديكورات عروس مميزة', 'تنسيق ديكورات عروس مميزة بأحدث التصاميم', 'uploads/ads/decor_ad.jpg', TRUE, 4),
(6, 'فرق موسيقية احترافية', 'فرق موسيقية احترافية للأعراس', 'uploads/ads/music_ad.jpg', TRUE, 5),
(7, 'كيك عرس فاخر', 'كيك عرس فاخر بأشكال فنية مميزة', 'uploads/ads/cake_ad.jpg', TRUE, 6),
(8, 'تجميل عروس احترافي', 'تجميل عروس احترافي مع أحدث التقنيات', 'uploads/ads/beauty_ad.jpg', TRUE, 7),
(9, 'فيديو عرس احترافي', 'تصوير وإنتاج فيديو عرس احترافي', 'uploads/ads/video_ad.jpg', TRUE, 8),
(10, 'ضيافة فاخرة', 'خدمات ضيافة فاخرة مع قوائم طعام مميزة', 'uploads/ads/catering_ad.jpg', TRUE, 9),
(11, 'تنظيم مناسبات', 'تنظيم وإدارة المناسبات باحترافية عالية', 'uploads/ads/event_ad.jpg', TRUE, 10);

-- إدراج الحجوزات
INSERT INTO bookings (user_id, service_id, date, time, note, status, total_price, payment_status, payment_method) VALUES
(12, 1, '2024-03-15', '18:00:00', 'عرس أحمد وفاطمة', 'confirmed', 1500.00, 'paid', 'cash'),
(13, 3, '2024-03-20', '19:00:00', 'فسينة عروس فاخرة', 'confirmed', 3000.00, 'paid', 'kareemi_bank'),
(14, 5, '2024-03-25', '20:00:00', 'قاعة أعراس فاخرة', 'pending', 5000.00, 'pending', 'cash'),
(15, 7, '2024-03-30', '17:00:00', 'تنسيق ديكور كامل', 'confirmed', 2000.00, 'paid', 'kareemi_bank'),
(16, 9, '2024-04-05', '18:30:00', 'فرقة موسيقية', 'completed', 1200.00, 'paid', 'cash');

-- إدراج المفضلة
INSERT INTO favorites (user_id, service_id) VALUES
(12, 1),
(12, 3),
(13, 5),
(14, 7),
(15, 9),
(16, 11);

-- إدراج التقييمات
INSERT INTO reviews (user_id, service_id, provider_id, rating, comment) VALUES
(12, 1, 2, 5, 'خدمة ممتازة وتصوير احترافي جداً'),
(13, 3, 3, 4, 'فسينة جميلة جداً والتفصيل ممتاز'),
(14, 5, 4, 5, 'قاعة فاخرة وخدمة شاملة ممتازة'),
(15, 7, 5, 4, 'ديكور جميل وتنسيق ممتاز'),
(16, 9, 6, 5, 'فرقة موسيقية احترافية وموسيقى رائعة');

-- إدراج الإشعارات
INSERT INTO notifications (user_id, title, message, type) VALUES
(12, 'تأكيد الحجز', 'تم تأكيد حجزك لخدمة التصوير', 'booking'),
(13, 'تحديث الحالة', 'تم تحديث حالة حجزك', 'booking'),
(14, 'مراجعة جديدة', 'لديك مراجعة جديدة على خدمتك', 'review'),
(15, 'عرض خاص', 'خصم 20% على جميع الخدمات', 'promotion'),
(16, 'رسالة جديدة', 'لديك رسالة جديدة من العميل', 'system');

-- إدراج الرسائل
INSERT INTO messages (sender_id, receiver_id, message) VALUES
(12, 2, 'مرحباً، أريد حجز خدمة التصوير'),
(2, 12, 'أهلاً وسهلاً، متى تريد الحجز؟'),
(13, 3, 'هل يمكنني رؤية نماذج من الفساتين؟'),
(3, 13, 'بالطبع، سأرسل لك النماذج'),
(14, 4, 'أريد حجز قاعة لعرس 200 شخص');

-- إدراج الدفعات
INSERT INTO payments (booking_id, user_id, amount, payment_method, status) VALUES
(1, 12, 1500.00, 'cash', 'completed'),
(2, 13, 3000.00, 'kareemi_bank', 'completed'),
(3, 14, 5000.00, 'cash', 'pending'),
(4, 15, 2000.00, 'kareemi_bank', 'completed'),
(5, 16, 1200.00, 'cash', 'completed');

-- إدراج الإحصائيات
INSERT INTO statistics (date, total_users, total_providers, total_services, total_bookings, total_revenue, active_services, pending_bookings) VALUES
('2024-03-01', 5, 10, 18, 5, 12700.00, 18, 1),
('2024-03-02', 5, 10, 18, 5, 12700.00, 18, 1),
('2024-03-03', 5, 10, 18, 5, 12700.00, 18, 1);

-- =====================================================
-- ملاحظات مهمة
-- =====================================================

/*
✅ تم إنشاء قاعدة البيانات بنجاح!
✅ جميع الجداول والبيانات جاهزة
✅ كلمة المرور: password
✅ الحسابات جاهزة للاختبار

الحسابات المتاحة:
- مدير النظام: admin@asha-app.com / 777000000
- مزودين: ahmed@example.com / 777111111
- مستخدمين: ahmed.user@example.com / 777111111
*/ 