-- =====================================================
-- إنشاء قاعدة البيانات كاملة مع البيانات الافتراضية
-- =====================================================

-- إنشاء قاعدة البيانات
CREATE DATABASE IF NOT EXISTS asha_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE asha_app;

-- =====================================================
-- إنشاء الجداول
-- =====================================================

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
    bio TEXT,
    address TEXT,
    city VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- جدول الفئات
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- جدول الخدمات
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    images JSON,
    city VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- جدول الإعلانات
CREATE TABLE IF NOT EXISTS ads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول العروض
CREATE TABLE IF NOT EXISTS offers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- جدول الحجوزات
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    provider_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    total_price DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول التقييمات
CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    provider_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول المفضلات
CREATE TABLE IF NOT EXISTS favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, service_id)
);

-- جدول التعليقات
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('booking', 'service', 'review', 'promotion', 'reminder') DEFAULT 'booking',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- إدخال البيانات الافتراضية
-- =====================================================

-- إدخال مدير افتراضي
INSERT INTO users (id, name, email, phone, password, user_type, is_verified, is_active, created_at) VALUES
(1, 'مدير النظام', 'admin@asha.com', '777000000', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, 1, NOW());

-- إدخال الفئات
INSERT INTO categories (name, description, image, is_active, created_at) VALUES
('تنظيف المنازل', 'خدمات تنظيف شاملة للمنازل والمكاتب', 'cleaning.jpg', 1, NOW()),
('الكهرباء', 'خدمات الكهرباء والصيانة', 'electric.jpg', 1, NOW()),
('السباكة', 'إصلاح وتوصيل السباكة', 'plumbing.jpg', 1, NOW()),
('التصميم الداخلي', 'تصميم داخلي وتأثيث', 'design.jpg', 1, NOW()),
('الحدادة', 'أعمال الحديد والحدادة', 'blacksmith.jpg', 1, NOW()),
('النجارة', 'أعمال الخشب والنجارة', 'carpentry.jpg', 1, NOW()),
('التكييف', 'تركيب وصيانة أجهزة التكييف', 'ac.jpg', 1, NOW()),
('الحدائق', 'تصميم وصيانة الحدائق', 'gardening.jpg', 1, NOW()),
('الأمن والحماية', 'أنظمة الأمن والمراقبة', 'security.jpg', 1, NOW()),
('النقل والشحن', 'خدمات النقل والشحن', 'transport.jpg', 1, NOW());

-- إدخال المستخدمين العاديين
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, created_at) VALUES
('أحمد محمد', 'ahmed@example.com', '777123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('فاطمة علي', 'fatima@example.com', '777123457', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('محمد حسن', 'mohammed@example.com', '777123458', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('سارة أحمد', 'sara@example.com', '777123459', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('علي يوسف', 'ali@example.com', '777123460', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('نور الدين', 'noor@example.com', '777123461', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('ليلى محمد', 'layla@example.com', '777123462', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('خالد عبدالله', 'khalid@example.com', '777123463', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('رنا أحمد', 'rana@example.com', '777123464', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('عمر محمد', 'omar@example.com', '777123465', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW());

-- إدخال مزودي الخدمات
INSERT INTO users (name, email, phone, password, user_type, bio, address, city, is_verified, is_active, created_at) VALUES
('شركة النظافة المثالية', 'cleaning@example.com', '777200001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'خدمات تنظيف شاملة للمنازل والمكاتب', 'شارع الجمهورية، صنعاء', 'صنعاء', 1, 1, NOW()),
('مؤسسة الكهرباء الحديثة', 'electric@example.com', '777200002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'خدمات الكهرباء والصيانة', 'شارع الزبيري، صنعاء', 'صنعاء', 1, 1, NOW()),
('شركة السباكة المتقدمة', 'plumbing@example.com', '777200003', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'إصلاح وتوصيل السباكة', 'شارع القيادة، صنعاء', 'صنعاء', 1, 1, NOW()),
('استوديو التصميم الإبداعي', 'design@example.com', '777200004', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'تصميم داخلي وتأثيث', 'شارع الستين، صنعاء', 'صنعاء', 1, 1, NOW()),
('ورشة الحدادة التقليدية', 'blacksmith@example.com', '777200005', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'أعمال الحديد والحدادة', 'شارع المطار، صنعاء', 'صنعاء', 1, 1, NOW()),
('مؤسسة النجارة الفنية', 'carpentry@example.com', '777200006', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'أعمال الخشب والنجارة', 'شارع حدة، صنعاء', 'صنعاء', 1, 1, NOW()),
('شركة التكييف المركزية', 'ac@example.com', '777200007', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'تركيب وصيانة التكييف', 'شارع التحالف، صنعاء', 'صنعاء', 1, 1, NOW()),
('حدائق اليمن الخضراء', 'gardening@example.com', '777200008', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'تصميم وصيانة الحدائق', 'شارع الوحدة، صنعاء', 'صنعاء', 1, 1, NOW()),
('شركة الأمن والحماية', 'security@example.com', '777200009', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'أنظمة الأمن والمراقبة', 'شارع السبعين، صنعاء', 'صنعاء', 1, 1, NOW()),
('مؤسسة النقل السريع', 'transport@example.com', '777200010', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 'خدمات النقل والشحن', 'شارع المطار، صنعاء', 'صنعاء', 1, 1, NOW());

-- إدخال الخدمات
INSERT INTO services (provider_id, category_id, title, description, price, images, city, is_active, is_verified, created_at) VALUES
(2, 1, 'تنظيف منزل شامل', 'تنظيف شامل للمنزل يشمل جميع الغرف والمطبخ والحمامات', 150.00, '["cleaning1.jpg","cleaning2.jpg"]', 'صنعاء', 1, 1, NOW()),
(2, 1, 'تنظيف المطبخ', 'تنظيف عميق للمطبخ والأجهزة', 80.00, '["kitchen1.jpg","kitchen2.jpg"]', 'صنعاء', 1, 1, NOW()),
(3, 2, 'إصلاح كهربائي منزلي', 'إصلاح جميع مشاكل الكهرباء في المنزل', 200.00, '["electric1.jpg","electric2.jpg"]', 'صنعاء', 1, 1, NOW()),
(8, 7, 'تركيب مكيف سبليت', 'تركيب مكيف سبليت جديد', 300.00, '["ac1.jpg","ac2.jpg"]', 'صنعاء', 1, 1, NOW()),
(4, 3, 'إصلاح تسرب المياه', 'إصلاح تسربات المياه في الحمام والمطبخ', 120.00, '["plumbing1.jpg","plumbing2.jpg"]', 'صنعاء', 1, 1, NOW()),
(5, 4, 'تصميم غرفة معيشة', 'تصميم وتأثيث غرفة المعيشة', 500.00, '["design1.jpg","design2.jpg"]', 'صنعاء', 1, 1, NOW()),
(6, 5, 'صنع باب حديد', 'صنع باب حديد عالي الجودة', 400.00, '["iron1.jpg","iron2.jpg"]', 'صنعاء', 1, 1, NOW()),
(7, 6, 'صنع خزانة خشب', 'صنع خزانة خشب مخصصة', 350.00, '["wood1.jpg","wood2.jpg"]', 'صنعاء', 1, 1, NOW()),
(8, 7, 'صيانة مكيف', 'صيانة وإصلاح أجهزة التكييف', 150.00, '["ac_maintenance1.jpg","ac_maintenance2.jpg"]', 'صنعاء', 1, 1, NOW()),
(9, 8, 'تصميم حديقة منزلية', 'تصميم وزراعة حديقة منزلية', 800.00, '["garden1.jpg","garden2.jpg"]', 'صنعاء', 1, 1, NOW()),
(10, 9, 'تركيب نظام مراقبة', 'تركيب نظام مراقبة كامل للمنزل', 600.00, '["security1.jpg","security2.jpg"]', 'صنعاء', 1, 1, NOW()),
(11, 10, 'شحن أثاث', 'شحن ونقل الأثاث بأمان', 200.00, '["transport1.jpg","transport2.jpg"]', 'صنعاء', 1, 1, NOW()),
(2, 1, 'تنظيف السجاد', 'تنظيف السجاد والموكيت', 100.00, '["carpet1.jpg","carpet2.jpg"]', 'صنعاء', 1, 1, NOW()),
(3, 2, 'إصلاح قاطع كهربائي', 'إصلاح واستبدال قواطع الكهرباء', 80.00, '["breaker1.jpg","breaker2.jpg"]', 'صنعاء', 1, 1, NOW()),
(4, 3, 'تركيب سخان مياه', 'تركيب سخان مياه جديد', 250.00, '["heater1.jpg","heater2.jpg"]', 'صنعاء', 1, 1, NOW());

-- إدخال الإعلانات
INSERT INTO ads (provider_id, title, description, image, is_active, start_date, end_date, created_at) VALUES
(2, 'عرض خاص: تنظيف منزل شامل', 'خصم 20% على تنظيف المنزل الشامل هذا الأسبوع', 'ad_cleaning1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NOW()),
(8, 'تركيب مكيفات بأسعار منافسة', 'تركيب مكيفات سبليت بأسعار مميزة', 'ad_ac1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NOW()),
(3, 'إصلاح كهربائي فوري', 'خدمة إصلاح كهربائي فورية خلال 24 ساعة', 'ad_electric1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY), NOW()),
(5, 'تصميم داخلي مجاني', 'استشارة تصميم داخلي مجانية مع كل مشروع', 'ad_design1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), NOW()),
(4, 'صيانة سباكة عاجلة', 'خدمة سباكة عاجلة متاحة 24/7', 'ad_plumbing1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), NOW()),
(9, 'حدائق منزلية بأقل سعر', 'تصميم حدائق منزلية بأسعار منافسة', 'ad_garden1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(10, 'أنظمة أمن متطورة', 'تركيب أنظمة أمن ومراقبة متطورة', 'ad_security1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), NOW()),
(11, 'نقل أثاث آمن', 'خدمة نقل أثاث آمنة ومضمونة', 'ad_transport1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 12 DAY), NOW());

-- إدخال العروض
INSERT INTO offers (service_id, title, description, discount_percentage, start_date, end_date, is_active, created_at) VALUES
(1, 'عرض الربيع', 'خصم 20% على تنظيف المنزل', 20.00, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, NOW()),
(3, 'عرض الكهرباء', 'خصم 15% على إصلاح الكهرباء', 15.00, NOW(), DATE_ADD(NOW(), INTERVAL 20 DAY), 1, NOW()),
(5, 'عرض السباكة', 'خصم 25% على إصلاح السباكة', 25.00, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 1, NOW()),
(6, 'عرض التصميم', 'استشارة مجانية مع كل مشروع', 0.00, NOW(), DATE_ADD(NOW(), INTERVAL 45 DAY), 1, NOW()),
(8, 'عرض النجارة', 'خصم 10% على أعمال الخشب', 10.00, NOW(), DATE_ADD(NOW(), INTERVAL 25 DAY), 1, NOW()),
(9, 'عرض التكييف', 'صيانة مجانية مع كل تركيب', 0.00, NOW(), DATE_ADD(NOW(), INTERVAL 40 DAY), 1, NOW()),
(10, 'عرض الحدائق', 'خصم 30% على تصميم الحدائق', 30.00, NOW(), DATE_ADD(NOW(), INTERVAL 35 DAY), 1, NOW()),
(11, 'عرض الأمن', 'خصم 20% على أنظمة المراقبة', 20.00, NOW(), DATE_ADD(NOW(), INTERVAL 50 DAY), 1, NOW()),
(12, 'عرض النقل', 'شحن مجاني للطلبات الكبيرة', 0.00, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, NOW()),
(13, 'عرض التنظيف', 'خصم 15% على تنظيف السجاد', 15.00, NOW(), DATE_ADD(NOW(), INTERVAL 18 DAY), 1, NOW());

-- إدخال الحجوزات
INSERT INTO bookings (user_id, service_id, provider_id, booking_date, booking_time, status, total_price, notes, created_at) VALUES
(2, 1, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), '10:00:00', 'pending', 150.00, 'تنظيف منزل 3 غرف', NOW()),
(3, 3, 3, DATE_ADD(NOW(), INTERVAL 1 DAY), '14:00:00', 'confirmed', 200.00, 'إصلاح كهربائي عاجل', NOW()),
(4, 5, 4, DATE_ADD(NOW(), INTERVAL 3 DAY), '09:00:00', 'completed', 120.00, 'إصلاح تسرب في الحمام', NOW()),
(5, 6, 5, DATE_ADD(NOW(), INTERVAL 5 DAY), '16:00:00', 'pending', 500.00, 'تصميم غرفة معيشة', NOW()),
(6, 8, 7, DATE_ADD(NOW(), INTERVAL 4 DAY), '11:00:00', 'confirmed', 350.00, 'صنع خزانة خشب', NOW()),
(7, 9, 8, DATE_ADD(NOW(), INTERVAL 1 DAY), '13:00:00', 'cancelled', 150.00, 'صيانة مكيف', NOW()),
(8, 10, 9, DATE_ADD(NOW(), INTERVAL 7 DAY), '08:00:00', 'pending', 800.00, 'تصميم حديقة منزلية', NOW()),
(9, 11, 10, DATE_ADD(NOW(), INTERVAL 2 DAY), '15:00:00', 'confirmed', 600.00, 'تركيب نظام مراقبة', NOW()),
(10, 12, 11, DATE_ADD(NOW(), INTERVAL 1 DAY), '12:00:00', 'completed', 200.00, 'شحن أثاث', NOW()),
(2, 13, 2, DATE_ADD(NOW(), INTERVAL 3 DAY), '10:30:00', 'pending', 100.00, 'تنظيف السجاد', NOW());

-- إدخال التقييمات
INSERT INTO reviews (user_id, service_id, provider_id, rating, comment, created_at) VALUES
(2, 1, 2, 5, 'خدمة ممتازة، تنظيف شامل ومهنية عالية', NOW()),
(3, 3, 3, 4, 'إصلاح سريع ومهني، أنصح بهم', NOW()),
(4, 5, 4, 5, 'إصلاح دقيق ومضمون، شكراً لكم', NOW()),
(5, 6, 5, 4, 'تصميم جميل ومهني', NOW()),
(6, 8, 7, 5, 'عمل خشب ممتاز وجودة عالية', NOW()),
(7, 9, 8, 3, 'صيانة جيدة ولكن تأخر قليلاً', NOW()),
(8, 10, 9, 5, 'حديقة جميلة وتصميم رائع', NOW()),
(9, 11, 10, 4, 'نظام مراقبة متطور وآمن', NOW()),
(10, 12, 11, 5, 'نقل آمن وسريع، أنصح بهم', NOW()),
(2, 13, 2, 4, 'تنظيف السجاد ممتاز', NOW());

-- إدخال المفضلات
INSERT INTO favorites (user_id, service_id, created_at) VALUES
(2, 1, NOW()),
(2, 3, NOW()),
(3, 5, NOW()),
(4, 6, NOW()),
(5, 8, NOW()),
(6, 9, NOW()),
(7, 10, NOW()),
(8, 11, NOW()),
(9, 12, NOW()),
(10, 13, NOW());

-- إدخال التعليقات
INSERT INTO comments (user_id, service_id, comment, created_at) VALUES
(2, 1, 'متى يمكنني حجز موعد؟', NOW()),
(3, 3, 'هل تقدمون ضمان على الإصلاح؟', NOW()),
(4, 5, 'كم تستغرق عملية الإصلاح؟', NOW()),
(5, 6, 'هل يمكنني رؤية نماذج من أعمالكم؟', NOW()),
(6, 8, 'ما هي أنواع الخشب المتوفرة؟', NOW()),
(7, 9, 'هل تقدمون خدمة الصيانة الدورية؟', NOW()),
(8, 10, 'ما هي النباتات المناسبة للمناخ المحلي؟', NOW()),
(9, 11, 'هل النظام يتضمن تطبيق للهاتف؟', NOW()),
(10, 12, 'هل تغطون جميع مناطق صنعاء؟', NOW()),
(2, 13, 'هل تنظفون السجاد بالبخار؟', NOW());

-- إدخال الإشعارات
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
(2, 'تأكيد الحجز', 'تم تأكيد حجزك لخدمة تنظيف المنزل', 'booking', 0, NOW()),
(3, 'تحديث الحالة', 'تم إصلاح الكهرباء بنجاح', 'service', 0, NOW()),
(4, 'تقييم جديد', 'شكراً لك على تقييمك الإيجابي', 'review', 0, NOW()),
(5, 'عرض خاص', 'خصم 15% على خدمات التصميم', 'promotion', 0, NOW()),
(6, 'تذكير', 'موعد حجزك غداً في الساعة 10:00', 'reminder', 0, NOW()),
(7, 'إلغاء الحجز', 'تم إلغاء حجزك لصيانة المكيف', 'booking', 0, NOW()),
(8, 'تأكيد الحجز', 'تم تأكيد حجزك لتصميم الحديقة', 'booking', 0, NOW()),
(9, 'تحديث الحالة', 'تم تركيب نظام المراقبة بنجاح', 'service', 0, NOW()),
(10, 'تقييم جديد', 'شكراً لك على تقييمك الإيجابي', 'review', 0, NOW()),
(2, 'عرض جديد', 'عرض خاص على تنظيف السجاد', 'promotion', 0, NOW());

-- =====================================================
-- إنشاء الفهارس لتحسين الأداء
-- =====================================================

-- فهارس جدول المستخدمين
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_is_verified ON users(is_verified);
CREATE INDEX idx_users_is_active ON users(is_active);

-- فهارس جدول الخدمات
CREATE INDEX idx_services_provider_id ON services(provider_id);
CREATE INDEX idx_services_category_id ON services(category_id);
CREATE INDEX idx_services_is_active ON services(is_active);
CREATE INDEX idx_services_is_verified ON services(is_verified);
CREATE INDEX idx_services_city ON services(city);

-- فهارس جدول الحجوزات
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_service_id ON bookings(service_id);
CREATE INDEX idx_bookings_provider_id ON bookings(provider_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);

-- فهارس جدول التقييمات
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_service_id ON reviews(service_id);
CREATE INDEX idx_reviews_provider_id ON reviews(provider_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- فهارس جدول الإعلانات
CREATE INDEX idx_ads_provider_id ON ads(provider_id);
CREATE INDEX idx_ads_is_active ON ads(is_active);
CREATE INDEX idx_ads_start_date ON ads(start_date);
CREATE INDEX idx_ads_end_date ON ads(end_date);

-- فهارس جدول العروض
CREATE INDEX idx_offers_service_id ON offers(service_id);
CREATE INDEX idx_offers_is_active ON offers(is_active);
CREATE INDEX idx_offers_start_date ON offers(start_date);
CREATE INDEX idx_offers_end_date ON offers(end_date);

-- فهارس جدول الإشعارات
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- =====================================================
-- رسالة نجاح
-- =====================================================

SELECT 'تم إنشاء قاعدة البيانات والجداول والبيانات الافتراضية بنجاح!' AS message; 