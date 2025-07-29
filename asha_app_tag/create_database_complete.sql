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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_is_active (is_active)
);

-- جدول الفئات
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_active (is_active)
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
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_provider_id (provider_id),
    INDEX idx_category_id (category_id),
    INDEX idx_is_active (is_active),
    INDEX idx_city (city)
);

-- جدول فئات الخدمة
CREATE TABLE IF NOT EXISTS service_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image VARCHAR(255),
    size VARCHAR(100),
    dimensions VARCHAR(100),
    location VARCHAR(255),
    quantity INT DEFAULT 1,
    duration VARCHAR(100),
    materials TEXT,
    additional_features TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_service_id (service_id),
    INDEX idx_is_active (is_active),
    INDEX idx_price (price)
);

-- جدول الإعلانات
CREATE TABLE IF NOT EXISTS ads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_provider_id (provider_id),
    INDEX idx_is_active (is_active),
    INDEX idx_dates (start_date, end_date)
);

-- جدول العروض
CREATE TABLE IF NOT EXISTS offers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_service_id (service_id),
    INDEX idx_is_active (is_active),
    INDEX idx_dates (start_date, end_date)
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
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id),
    INDEX idx_provider_id (provider_id),
    INDEX idx_status (status),
    INDEX idx_booking_date (booking_date)
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
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id),
    INDEX idx_provider_id (provider_id),
    INDEX idx_rating (rating)
);

-- جدول المفضلات
CREATE TABLE IF NOT EXISTS favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    service_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_service (user_id, service_id),
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id)
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
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_service_id (service_id)
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type ENUM('booking', 'service', 'review', 'promotion', 'reminder') DEFAULT 'booking',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type)
);

-- =====================================================
-- إدخال البيانات الافتراضية
-- =====================================================

-- إضافة مستخدم المدير
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, created_at) VALUES
('Admin User', 'admin@asha.com', '777000000', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, 1, NOW());

-- إضافة فئات
INSERT INTO categories (name, description, image, is_active, created_at) VALUES
('تنظيف المنازل', 'خدمات تنظيف شاملة للمنازل والمكاتب', 'cleaning.jpg', 1, NOW()),
('الكهرباء', 'خدمات إصلاح وتوصيل الكهرباء', 'electricity.jpg', 1, NOW()),
('السباكة', 'خدمات إصلاح وصيانة السباكة', 'plumbing.jpg', 1, NOW()),
('التصميم الداخلي', 'تصميم وتأثيث المنازل', 'interior.jpg', 1, NOW()),
('الحدادة', 'أعمال الحديد والحدادة', 'blacksmith.jpg', 1, NOW()),
('النجارة', 'أعمال الخشب والنجارة', 'carpentry.jpg', 1, NOW()),
('التكييف', 'تركيب وصيانة أجهزة التكييف', 'ac.jpg', 1, NOW()),
('الحدائق', 'تصميم وصيانة الحدائق', 'gardening.jpg', 1, NOW()),
('الأمن والحماية', 'أنظمة الأمن والمراقبة', 'security.jpg', 1, NOW()),
('النقل والشحن', 'خدمات النقل والشحن', 'transport.jpg', 1, NOW());

-- إضافة مستخدمين عاديين
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

-- إضافة مزودي الخدمات
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

-- إضافة الخدمات
INSERT INTO services (provider_id, category_id, title, description, price, images, city, is_active, is_verified, created_at) VALUES
(11, 1, 'تنظيف منزل شامل', 'تنظيف شامل للمنزل يشمل جميع الغرف والمطبخ والحمامات', 150.00, '["cleaning1.jpg","cleaning2.jpg"]', 'صنعاء', 1, 1, NOW()),
(11, 1, 'تنظيف المطبخ', 'تنظيف عميق للمطبخ والأجهزة', 80.00, '["kitchen1.jpg","kitchen2.jpg"]', 'صنعاء', 1, 1, NOW()),
(12, 2, 'إصلاح كهربائي منزلي', 'إصلاح جميع مشاكل الكهرباء في المنزل', 200.00, '["electric1.jpg","electric2.jpg"]', 'صنعاء', 1, 1, NOW()),
(17, 7, 'تركيب مكيف سبليت', 'تركيب مكيف سبليت جديد', 300.00, '["ac1.jpg","ac2.jpg"]', 'صنعاء', 1, 1, NOW()),
(13, 3, 'إصلاح تسرب المياه', 'إصلاح تسربات المياه في الحمام والمطبخ', 120.00, '["plumbing1.jpg","plumbing2.jpg"]', 'صنعاء', 1, 1, NOW()),
(14, 4, 'تصميم غرفة معيشة', 'تصميم وتأثيث غرفة المعيشة', 500.00, '["design1.jpg","design2.jpg"]', 'صنعاء', 1, 1, NOW()),
(15, 5, 'صنع باب حديد', 'صنع باب حديد عالي الجودة', 400.00, '["iron1.jpg","iron2.jpg"]', 'صنعاء', 1, 1, NOW()),
(16, 6, 'صنع خزانة خشب', 'صنع خزانة خشب مخصصة', 350.00, '["wood1.jpg","wood2.jpg"]', 'صنعاء', 1, 1, NOW()),
(17, 7, 'صيانة مكيف', 'صيانة وإصلاح أجهزة التكييف', 150.00, '["ac_maintenance1.jpg","ac_maintenance2.jpg"]', 'صنعاء', 1, 1, NOW()),
(18, 8, 'تصميم حديقة منزلية', 'تصميم وزراعة حديقة منزلية', 800.00, '["garden1.jpg","garden2.jpg"]', 'صنعاء', 1, 1, NOW()),
(19, 9, 'تركيب نظام مراقبة', 'تركيب نظام مراقبة كامل للمنزل', 600.00, '["security1.jpg","security2.jpg"]', 'صنعاء', 1, 1, NOW()),
(20, 10, 'شحن أثاث', 'شحن ونقل الأثاث بأمان', 200.00, '["transport1.jpg","transport2.jpg"]', 'صنعاء', 1, 1, NOW()),
(11, 1, 'تنظيف السجاد', 'تنظيف السجاد والموكيت', 100.00, '["carpet1.jpg","carpet2.jpg"]', 'صنعاء', 1, 1, NOW()),
(12, 2, 'إصلاح قاطع كهربائي', 'إصلاح واستبدال قواطع الكهرباء', 80.00, '["breaker1.jpg","breaker2.jpg"]', 'صنعاء', 1, 1, NOW()),
(13, 3, 'تركيب سخان مياه', 'تركيب سخان مياه جديد', 250.00, '["heater1.jpg","heater2.jpg"]', 'صنعاء', 1, 1, NOW());

-- إضافة فئات الخدمة
INSERT INTO service_categories (service_id, name, description, price, image, size, dimensions, location, quantity, duration, materials, additional_features, is_active, created_at) VALUES
-- فئات خدمة تنظيف المنزل الشامل
(1, 'تنظيف غرف النوم', 'تنظيف شامل لغرف النوم مع تغيير الملاءات', 50.00, 'bedroom_cleaning.jpg', 'متوسط', '3 غرف', 'صنعاء', 1, '2-3 ساعات', 'منظفات آمنة، مكنسة كهربائية', 'تغيير الملاءات، تنظيف النوافذ', 1, NOW()),
(1, 'تنظيف المطبخ', 'تنظيف عميق للمطبخ والأجهزة', 60.00, 'kitchen_cleaning.jpg', 'كبير', 'مطبخ كامل', 'صنعاء', 1, '3-4 ساعات', 'منظفات قوية، فرشاة خاصة', 'تنظيف الثلاجة، تنظيف الفرن', 1, NOW()),
(1, 'تنظيف الحمامات', 'تنظيف وتعقيم الحمامات', 40.00, 'bathroom_cleaning.jpg', 'صغير', '2 حمام', 'صنعاء', 1, '1-2 ساعة', 'منظفات معقمة، فرشاة', 'تعقيم شامل، تنظيف المرحاض', 1, NOW()),

-- فئات خدمة تنظيف المطبخ
(2, 'تنظيف الأجهزة', 'تنظيف جميع أجهزة المطبخ', 40.00, 'appliances_cleaning.jpg', 'متوسط', 'جميع الأجهزة', 'صنعاء', 1, '2 ساعة', 'منظفات خاصة', 'تنظيف الثلاجة، الميكروويف، الفرن', 1, NOW()),
(2, 'تنظيف الخزائن', 'تنظيف خزائن المطبخ من الداخل', 30.00, 'cabinets_cleaning.jpg', 'صغير', 'خزائن المطبخ', 'صنعاء', 1, '1 ساعة', 'منظفات خفيفة', 'ترتيب المحتويات', 1, NOW()),
(2, 'تنظيف الأرضية', 'تنظيف أرضية المطبخ', 20.00, 'floor_cleaning.jpg', 'متوسط', 'أرضية المطبخ', 'صنعاء', 1, '30 دقيقة', 'منظف أرضيات', 'تنظيف البلاط', 1, NOW()),

-- فئات خدمة إصلاح الكهرباء
(3, 'إصلاح القواطع', 'إصلاح واستبدال قواطع الكهرباء', 80.00, 'breaker_repair.jpg', 'صغير', 'لوحة الكهرباء', 'صنعاء', 1, '1-2 ساعة', 'قواطع جديدة، أسلاك', 'فحص شامل للكهرباء', 1, NOW()),
(3, 'إصلاح المآخذ', 'إصلاح واستبدال مآخذ الكهرباء', 60.00, 'socket_repair.jpg', 'صغير', 'المآخذ المعطلة', 'صنعاء', 1, '1 ساعة', 'مآخذ جديدة، أسلاك', 'تأمين المآخذ', 1, NOW()),
(3, 'تركيب إضاءة', 'تركيب إضاءة جديدة', 100.00, 'lighting_installation.jpg', 'متوسط', 'غرف المنزل', 'صنعاء', 1, '2-3 ساعات', 'أضواء جديدة، أسلاك', 'تصميم الإضاءة', 1, NOW()),

-- فئات خدمة تركيب المكيف
(4, 'مكيف سبليت 1.5 طن', 'تركيب مكيف سبليت 1.5 طن', 300.00, 'ac_1.5ton.jpg', 'متوسط', 'غرفة واحدة', 'صنعاء', 1, '3-4 ساعات', 'مكيف سبليت، أنابيب', 'ضمان سنة، صيانة مجانية', 1, NOW()),
(4, 'مكيف سبليت 2 طن', 'تركيب مكيف سبليت 2 طن', 400.00, 'ac_2ton.jpg', 'كبير', 'غرفة كبيرة', 'صنعاء', 1, '4-5 ساعات', 'مكيف سبليت، أنابيب', 'ضمان سنة، صيانة مجانية', 1, NOW()),
(4, 'مكيف سبليت 3 طن', 'تركيب مكيف سبليت 3 طن', 500.00, 'ac_3ton.jpg', 'كبير جداً', 'صالة أو مكتب', 'صنعاء', 1, '5-6 ساعات', 'مكيف سبليت، أنابيب', 'ضمان سنة، صيانة مجانية', 1, NOW()),

-- فئات خدمة إصلاح السباكة
(5, 'إصلاح تسرب الحمام', 'إصلاح تسربات المياه في الحمام', 80.00, 'bathroom_leak.jpg', 'صغير', 'الحمام', 'صنعاء', 1, '1-2 ساعة', 'مواد إصلاح، أدوات', 'فحص شامل للسباكة', 1, NOW()),
(5, 'إصلاح تسرب المطبخ', 'إصلاح تسربات المياه في المطبخ', 60.00, 'kitchen_leak.jpg', 'صغير', 'المطبخ', 'صنعاء', 1, '1 ساعة', 'مواد إصلاح، أدوات', 'فحص شامل للسباكة', 1, NOW()),
(5, 'إصلاح المرحاض', 'إصلاح مشاكل المرحاض', 40.00, 'toilet_repair.jpg', 'صغير', 'المرحاض', 'صنعاء', 1, '30 دقيقة', 'قطع غيار، أدوات', 'ضمان الإصلاح', 1, NOW()),

-- فئات خدمة التصميم الداخلي
(6, 'تصميم غرفة معيشة', 'تصميم وتأثيث غرفة المعيشة', 500.00, 'living_room_design.jpg', 'كبير', 'غرفة المعيشة', 'صنعاء', 1, 'أسبوع', 'أثاث، ديكورات', 'استشارة مجانية، رسم تخطيطي', 1, NOW()),
(6, 'تصميم غرفة نوم', 'تصميم وتأثيث غرفة النوم', 400.00, 'bedroom_design.jpg', 'متوسط', 'غرفة النوم', 'صنعاء', 1, '5 أيام', 'أثاث، ديكورات', 'استشارة مجانية، رسم تخطيطي', 1, NOW()),
(6, 'تصميم المطبخ', 'تصميم وتأثيث المطبخ', 600.00, 'kitchen_design.jpg', 'كبير', 'المطبخ', 'صنعاء', 1, 'أسبوعين', 'خزائن، أجهزة', 'استشارة مجانية، رسم تخطيطي', 1, NOW()),

-- فئات خدمة الحدادة
(7, 'باب حديد عادي', 'صنع باب حديد عادي', 400.00, 'iron_door_basic.jpg', 'متوسط', 'باب عادي', 'صنعاء', 1, '3-4 أيام', 'حديد، زجاج', 'طلاء، تركيب', 1, NOW()),
(7, 'باب حديد فاخر', 'صنع باب حديد فاخر مع زخارف', 600.00, 'iron_door_luxury.jpg', 'كبير', 'باب فاخر', 'صنعاء', 1, '5-7 أيام', 'حديد فاخر، زجاج', 'زخارف، طلاء فاخر', 1, NOW()),
(7, 'نافذة حديد', 'صنع نافذة حديد', 200.00, 'iron_window.jpg', 'صغير', 'نافذة', 'صنعاء', 1, '2-3 أيام', 'حديد، زجاج', 'طلاء، تركيب', 1, NOW()),

-- فئات خدمة النجارة
(8, 'خزانة ملابس', 'صنع خزانة ملابس مخصصة', 350.00, 'wardrobe.jpg', 'كبير', 'خزانة ملابس', 'صنعاء', 1, '5-7 أيام', 'خشب جيد، إكسسوارات', 'تصميم مخصص، تركيب', 1, NOW()),
(8, 'خزانة مطبخ', 'صنع خزانة مطبخ مخصصة', 400.00, 'kitchen_cabinet.jpg', 'كبير', 'خزائن المطبخ', 'صنعاء', 1, '7-10 أيام', 'خشب مقاوم، إكسسوارات', 'تصميم مخصص، تركيب', 1, NOW()),
(8, 'طاولة طعام', 'صنع طاولة طعام', 250.00, 'dining_table.jpg', 'متوسط', 'طاولة طعام', 'صنعاء', 1, '3-4 أيام', 'خشب جيد', 'تصميم مخصص، تركيب', 1, NOW()),

-- فئات خدمة صيانة المكيف
(9, 'صيانة دورية', 'صيانة دورية للمكيف', 150.00, 'ac_maintenance.jpg', 'متوسط', 'جميع أنواع المكيفات', 'صنعاء', 1, '1-2 ساعة', 'مواد تنظيف، قطع غيار', 'ضمان الصيانة', 1, NOW()),
(9, 'إصلاح عطل', 'إصلاح أعطال المكيف', 200.00, 'ac_repair.jpg', 'متوسط', 'جميع أنواع المكيفات', 'صنعاء', 1, '2-3 ساعات', 'قطع غيار، أدوات', 'ضمان الإصلاح', 1, NOW()),
(9, 'تنظيف المكيف', 'تنظيف شامل للمكيف', 100.00, 'ac_cleaning.jpg', 'صغير', 'جميع أنواع المكيفات', 'صنعاء', 1, '1 ساعة', 'مواد تنظيف', 'ضمان التنظيف', 1, NOW()),

-- فئات خدمة تصميم الحدائق
(10, 'حديقة صغيرة', 'تصميم حديقة صغيرة', 800.00, 'small_garden.jpg', 'صغير', '50 متر مربع', 'صنعاء', 1, 'أسبوع', 'نباتات، تربة، أحجار', 'تصميم مخصص، زراعة', 1, NOW()),
(10, 'حديقة متوسطة', 'تصميم حديقة متوسطة', 1200.00, 'medium_garden.jpg', 'متوسط', '100 متر مربع', 'صنعاء', 1, 'أسبوعين', 'نباتات، تربة، أحجار، أثاث', 'تصميم مخصص، زراعة، أثاث', 1, NOW()),
(10, 'حديقة كبيرة', 'تصميم حديقة كبيرة', 2000.00, 'large_garden.jpg', 'كبير', '200 متر مربع', 'صنعاء', 1, '3 أسابيع', 'نباتات، تربة، أحجار، أثاث، إضاءة', 'تصميم مخصص، زراعة، أثاث، إضاءة', 1, NOW()),

-- فئات خدمة أنظمة المراقبة
(11, 'نظام مراقبة أساسي', 'تركيب نظام مراقبة أساسي', 600.00, 'basic_security.jpg', 'متوسط', '4 كاميرات', 'صنعاء', 1, '1 يوم', 'كاميرات، جهاز تسجيل', 'ضمان سنة، صيانة مجانية', 1, NOW()),
(11, 'نظام مراقبة متقدم', 'تركيب نظام مراقبة متقدم', 1000.00, 'advanced_security.jpg', 'كبير', '8 كاميرات', 'صنعاء', 1, '2 يوم', 'كاميرات HD، جهاز تسجيل، تطبيق', 'ضمان سنة، صيانة مجانية، تطبيق', 1, NOW()),
(11, 'نظام مراقبة فاخر', 'تركيب نظام مراقبة فاخر', 1500.00, 'luxury_security.jpg', 'كبير جداً', '12 كاميرا', 'صنعاء', 1, '3 أيام', 'كاميرات 4K، جهاز تسجيل، تطبيق، إنذار', 'ضمان سنة، صيانة مجانية، تطبيق، إنذار', 1, NOW()),

-- فئات خدمة النقل والشحن
(12, 'شحن أثاث منزلي', 'شحن أثاث منزلي', 200.00, 'furniture_transport.jpg', 'كبير', 'أثاث منزل كامل', 'صنعاء', 1, '1 يوم', 'شاحنة، عمال، أدوات', 'تأمين الشحن، تركيب', 1, NOW()),
(12, 'شحن أجهزة', 'شحن أجهزة منزلية', 150.00, 'appliances_transport.jpg', 'متوسط', 'أجهزة منزلية', 'صنعاء', 1, 'نصف يوم', 'شاحنة، عمال، أدوات', 'تأمين الشحن، تركيب', 1, NOW()),
(12, 'شحن مواد بناء', 'شحن مواد بناء', 300.00, 'construction_transport.jpg', 'كبير جداً', 'مواد بناء', 'صنعاء', 1, '1-2 يوم', 'شاحنة كبيرة، عمال', 'تأمين الشحن، تفريغ', 1, NOW()),

-- فئات خدمة تنظيف السجاد
(13, 'تنظيف سجاد بالبخار', 'تنظيف سجاد بالبخار', 100.00, 'steam_carpet.jpg', 'متوسط', 'سجاد المنزل', 'صنعاء', 1, '2-3 ساعات', 'جهاز بخار، منظفات', 'تعقيم، إزالة البقع', 1, NOW()),
(13, 'تنظيف موكيت', 'تنظيف موكيت', 80.00, 'carpet_cleaning.jpg', 'متوسط', 'موكيت المنزل', 'صنعاء', 1, '2 ساعة', 'جهاز تنظيف، منظفات', 'إزالة البقع، تعطير', 1, NOW()),
(13, 'تنظيف سجاد فاخر', 'تنظيف سجاد فاخر', 150.00, 'luxury_carpet.jpg', 'كبير', 'سجاد فاخر', 'صنعاء', 1, '3-4 ساعات', 'جهاز بخار متطور، منظفات خاصة', 'تعقيم، إزالة البقع، حماية', 1, NOW()),

-- فئات خدمة إصلاح قاطع كهربائي
(14, 'إصلاح قاطع منزلي', 'إصلاح قاطع كهربائي منزلي', 80.00, 'home_breaker.jpg', 'صغير', 'لوحة الكهرباء', 'صنعاء', 1, '1 ساعة', 'قاطع جديد، أدوات', 'فحص شامل، ضمان', 1, NOW()),
(14, 'إصلاح قاطع تجاري', 'إصلاح قاطع كهربائي تجاري', 120.00, 'commercial_breaker.jpg', 'متوسط', 'لوحة كهرباء تجارية', 'صنعاء', 1, '2 ساعة', 'قاطع تجاري، أدوات', 'فحص شامل، ضمان', 1, NOW()),
(14, 'تركيب قاطع جديد', 'تركيب قاطع كهربائي جديد', 100.00, 'new_breaker.jpg', 'صغير', 'لوحة الكهرباء', 'صنعاء', 1, '1-2 ساعة', 'قاطع جديد، أسلاك', 'تركيب، ضمان', 1, NOW()),

-- فئات خدمة تركيب سخان مياه
(15, 'سخان مياه كهربائي', 'تركيب سخان مياه كهربائي', 250.00, 'electric_heater.jpg', 'متوسط', 'سخان مياه', 'صنعاء', 1, '2-3 ساعات', 'سخان مياه، أنابيب', 'تركيب، ضمان سنة', 1, NOW()),
(15, 'سخان مياه غاز', 'تركيب سخان مياه غاز', 300.00, 'gas_heater.jpg', 'متوسط', 'سخان مياه غاز', 'صنعاء', 1, '3-4 ساعات', 'سخان مياه غاز، أنابيب', 'تركيب، ضمان سنة', 1, NOW()),
(15, 'سخان مياه شمسي', 'تركيب سخان مياه شمسي', 500.00, 'solar_heater.jpg', 'كبير', 'سخان مياه شمسي', 'صنعاء', 1, '4-5 ساعات', 'سخان شمسي، أنابيب', 'تركيب، ضمان سنة', 1, NOW());

-- إضافة إعلانات
INSERT INTO ads (provider_id, title, description, image, is_active, start_date, end_date, created_at) VALUES
(11, 'عرض خاص: تنظيف منزل شامل', 'خصم 20% على تنظيف المنزل الشامل هذا الأسبوع', 'ad_cleaning1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NOW()),
(17, 'تركيب مكيفات بأسعار منافسة', 'تركيب مكيفات سبليت بأسعار مميزة', 'ad_ac1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NOW()),
(12, 'إصلاح كهربائي فوري', 'خدمة إصلاح كهربائي فورية خلال 24 ساعة', 'ad_electric1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY), NOW()),
(14, 'تصميم داخلي مجاني', 'استشارة تصميم داخلي مجانية مع كل مشروع', 'ad_design1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), NOW()),
(13, 'صيانة سباكة عاجلة', 'خدمة سباكة عاجلة متاحة 24/7', 'ad_plumbing1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), NOW()),
(18, 'حدائق منزلية بأقل سعر', 'تصميم حدائق منزلية بأسعار منافسة', 'ad_garden1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(19, 'أنظمة أمن متطورة', 'تركيب أنظمة أمن ومراقبة متطورة', 'ad_security1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), NOW()),
(20, 'نقل أثاث آمن', 'خدمة نقل أثاث آمنة ومضمونة', 'ad_transport1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 12 DAY), NOW());

-- إضافة عروض خاصة
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

-- إضافة حجوزات
INSERT INTO bookings (user_id, service_id, provider_id, booking_date, booking_time, status, total_price, payment_status, notes, created_at) VALUES
(2, 1, 11, DATE_ADD(NOW(), INTERVAL 2 DAY), '10:00:00', 'pending', 150.00, 'pending', 'تنظيف منزل 3 غرف', NOW()),
(3, 3, 12, DATE_ADD(NOW(), INTERVAL 1 DAY), '14:00:00', 'confirmed', 200.00, 'paid', 'إصلاح كهربائي عاجل', NOW()),
(4, 5, 13, DATE_ADD(NOW(), INTERVAL 3 DAY), '09:00:00', 'completed', 120.00, 'paid', 'إصلاح تسرب في الحمام', NOW()),
(5, 6, 14, DATE_ADD(NOW(), INTERVAL 5 DAY), '16:00:00', 'pending', 500.00, 'pending', 'تصميم غرفة معيشة', NOW()),
(6, 8, 16, DATE_ADD(NOW(), INTERVAL 4 DAY), '11:00:00', 'confirmed', 350.00, 'paid', 'صنع خزانة خشب', NOW()),
(7, 9, 17, DATE_ADD(NOW(), INTERVAL 1 DAY), '13:00:00', 'cancelled', 150.00, 'refunded', 'صيانة مكيف', NOW()),
(8, 10, 18, DATE_ADD(NOW(), INTERVAL 7 DAY), '08:00:00', 'pending', 800.00, 'pending', 'تصميم حديقة منزلية', NOW()),
(9, 11, 19, DATE_ADD(NOW(), INTERVAL 2 DAY), '15:00:00', 'confirmed', 600.00, 'paid', 'تركيب نظام مراقبة', NOW()),
(10, 12, 20, DATE_ADD(NOW(), INTERVAL 1 DAY), '12:00:00', 'completed', 200.00, 'paid', 'شحن أثاث', NOW()),
(2, 13, 11, DATE_ADD(NOW(), INTERVAL 3 DAY), '10:30:00', 'pending', 100.00, 'pending', 'تنظيف السجاد', NOW());

-- إضافة تقييمات
INSERT INTO reviews (user_id, service_id, provider_id, rating, comment, created_at) VALUES
(2, 1, 11, 5, 'خدمة ممتازة، تنظيف شامل ومهنية عالية', NOW()),
(3, 3, 12, 4, 'إصلاح سريع ومهني، أنصح بهم', NOW()),
(4, 5, 13, 5, 'إصلاح دقيق ومضمون، شكراً لكم', NOW()),
(5, 6, 14, 4, 'تصميم جميل ومهني', NOW()),
(6, 8, 16, 5, 'عمل خشب ممتاز وجودة عالية', NOW()),
(7, 9, 17, 3, 'صيانة جيدة ولكن تأخر قليلاً', NOW()),
(8, 10, 18, 5, 'حديقة جميلة وتصميم رائع', NOW()),
(9, 11, 19, 4, 'نظام مراقبة متطور وآمن', NOW()),
(10, 12, 20, 5, 'نقل آمن وسريع، أنصح بهم', NOW()),
(2, 13, 11, 4, 'تنظيف السجاد ممتاز', NOW());

-- إضافة مفضلات
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

-- إضافة تعليقات
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

-- إضافة إشعارات
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
-- رسالة نجاح
-- =====================================================
SELECT 'تم إنشاء قاعدة البيانات والجداول والبيانات الافتراضية بنجاح!' AS message;
SELECT 'عدد الفئات المضافة: ' || (SELECT COUNT(*) FROM categories) AS categories_count;
SELECT 'عدد المستخدمين المضافة: ' || (SELECT COUNT(*) FROM users WHERE user_type = 'user') AS users_count;
SELECT 'عدد مزودي الخدمات المضافة: ' || (SELECT COUNT(*) FROM users WHERE user_type = 'provider') AS providers_count;
SELECT 'عدد الخدمات المضافة: ' || (SELECT COUNT(*) FROM services) AS services_count;
SELECT 'عدد الإعلانات المضافة: ' || (SELECT COUNT(*) FROM ads) AS ads_count;
SELECT 'عدد العروض المضافة: ' || (SELECT COUNT(*) FROM offers) AS offers_count;
SELECT 'عدد الحجوزات المضافة: ' || (SELECT COUNT(*) FROM bookings) AS bookings_count;
SELECT 'عدد التقييمات المضافة: ' || (SELECT COUNT(*) FROM reviews) AS reviews_count;
SELECT 'عدد المفضلات المضافة: ' || (SELECT COUNT(*) FROM favorites) AS favorites_count;
SELECT 'عدد التعليقات المضافة: ' || (SELECT COUNT(*) FROM comments) AS comments_count;
SELECT 'عدد الإشعارات المضافة: ' || (SELECT COUNT(*) FROM notifications) AS notifications_count; 
SELECT 'عدد فئات الخدمة المضافة: ' || (SELECT COUNT(*) FROM service_categories) AS service_categories_count; 