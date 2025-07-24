-- تحديث قاعدة البيانات لإضافة حقول الموقع
USE asha;

-- إضافة حقول الموقع لجدول المستخدمين
ALTER TABLE users 
ADD COLUMN latitude DECIMAL(10,8) NULL COMMENT 'إحداثيات الموقع',
ADD COLUMN longitude DECIMAL(11,8) NULL COMMENT 'إحداثيات الموقع',
ADD COLUMN address TEXT NULL COMMENT 'العنوان النصي',
ADD COLUMN city VARCHAR(100) NULL COMMENT 'المدينة';

-- إضافة حقول الموقع لجدول الخدمات
ALTER TABLE services 
ADD COLUMN original_price DECIMAL(10,2) NULL COMMENT 'السعر الأصلي قبل الخصم',
ADD COLUMN latitude DECIMAL(10,8) NULL COMMENT 'إحداثيات موقع الخدمة',
ADD COLUMN longitude DECIMAL(11,8) NULL COMMENT 'إحداثيات موقع الخدمة',
ADD COLUMN address TEXT NULL COMMENT 'عنوان الخدمة',
ADD COLUMN city VARCHAR(100) NULL COMMENT 'مدينة الخدمة';

-- إنشاء فهارس لتحسين أداء البحث الجغرافي
CREATE INDEX idx_services_location ON services(latitude, longitude);
CREATE INDEX idx_users_location ON users(latitude, longitude);
CREATE INDEX idx_services_price ON services(price);
CREATE INDEX idx_services_category ON services(category_id);

-- إضافة بيانات تجريبية للفئات
INSERT INTO categories (name, description, is_active) VALUES
('تصوير', 'خدمات التصوير الاحترافي للمناسبات', 1),
('تنسيق', 'تنسيق وتجميل المناسبات', 1),
('مطاعم', 'خدمات الطعام والضيافة', 1),
('موسيقى', 'خدمات الموسيقى والترفيه', 1),
('نقل', 'خدمات النقل والمواصلات', 1),
('أزياء', 'خدمات الأزياء والتجميل', 1),
('ديكور', 'خدمات الديكور والتجهيزات', 1),
('أمن', 'خدمات الأمن والحماية', 1);

-- إضافة بيانات تجريبية للمستخدمين مع مواقع في محافظة إب - اليمن
INSERT INTO users (name, email, phone, password, user_type, latitude, longitude, address, city) VALUES
('أحمد محمد', 'ahmed@example.com', '0501234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 13.9667, 44.1833, 'شارع الجمهورية', 'إب'),
('فاطمة علي', 'fatima@example.com', '0502345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 13.9667, 44.1833, 'شارع السوق', 'إب'),
('محمد حسن', 'mohammed@example.com', '0503456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 13.9667, 44.1833, 'شارع الجامعة', 'إب'),
('سارة أحمد', 'sara@example.com', '0504567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 13.9667, 44.1833, 'شارع النزهة', 'إب'),
('علي محمد', 'ali@example.com', '0505678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 13.9667, 44.1833, 'شارع السبعين', 'إب'),
('خالد عبدالله', 'khalid@example.com', '0506789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 13.9667, 44.1833, 'شارع الجمهورية', 'إب'),
('نورا محمد', 'nora@example.com', '0507890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 13.9667, 44.1833, 'شارع السوق', 'إب'),
('عبدالرحمن علي', 'abdulrahman@example.com', '0508901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 13.9667, 44.1833, 'شارع الجامعة', 'إب'),
('ريم أحمد', 'reem@example.com', '0509012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 13.9667, 44.1833, 'شارع النزهة', 'إب'),
('يوسف محمد', 'yousef@example.com', '0500123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 13.9667, 44.1833, 'شارع السبعين', 'إب');

-- إضافة بيانات تجريبية للخدمات مع مواقع وأسعار مختلفة في محافظة إب - اليمن
INSERT INTO services (provider_id, category_id, title, description, price, original_price, latitude, longitude, address, city, is_active) VALUES
(1, 1, 'تصوير أعراس احترافي', 'تصوير احترافي لجميع مراحل العرس مع فريق متخصص', 2000.00, 2500.00, 13.9667, 44.1833, 'شارع الجمهورية', 'إب', 1),
(1, 1, 'تصوير مناسبات', 'تصوير احترافي للمناسبات الخاصة والعائلية', 800.00, NULL, 13.9667, 44.1833, 'شارع الجمهورية', 'إب', 1),
(2, 2, 'تنسيق أعراس فاخر', 'تنسيق احترافي للأعراس مع أحدث التصاميم', 5000.00, 6000.00, 13.9667, 44.1833, 'شارع السوق', 'إب', 1),
(2, 2, 'تنسيق حفلات', 'تنسيق جميل للحفلات والمناسبات', 1500.00, NULL, 13.9667, 44.1833, 'شارع السوق', 'إب', 1),
(3, 3, 'مطعم عائلي', 'خدمات طعام عائلي للمناسبات', 3000.00, 3500.00, 13.9667, 44.1833, 'شارع الجامعة', 'إب', 1),
(3, 3, 'قهوة عربية', 'خدمات القهوة العربية التقليدية', 500.00, NULL, 13.9667, 44.1833, 'شارع الجامعة', 'إب', 1),
(4, 4, 'فرقة موسيقية', 'فرقة موسيقية احترافية للمناسبات', 1200.00, 1500.00, 13.9667, 44.1833, 'شارع النزهة', 'إب', 1),
(4, 4, 'دي جي', 'خدمات الدي جي مع أحدث الأجهزة', 800.00, NULL, 13.9667, 44.1833, 'شارع النزهة', 'إب', 1),
(5, 5, 'نقل VIP', 'خدمات نقل فاخرة للمناسبات', 1000.00, 1200.00, 13.9667, 44.1833, 'شارع السبعين', 'إب', 1),
(5, 5, 'نقل عائلي', 'خدمات نقل عائلية مريحة', 400.00, NULL, 13.9667, 44.1833, 'شارع السبعين', 'إب', 1);

-- إضافة خدمات بمواقع مختلفة لاختبار البحث الجغرافي في محافظة إب - اليمن
INSERT INTO services (provider_id, category_id, title, description, price, original_price, latitude, longitude, address, city, is_active) VALUES
(1, 6, 'أزياء عروس', 'تصميم وخياطة أزياء العروس', 3000.00, NULL, 13.9767, 44.1933, 'شارع القيادة', 'إب', 1),
(2, 7, 'ديكور فاخر', 'ديكور فاخر للمناسبات الكبيرة', 4000.00, 4500.00, 13.9567, 44.1733, 'شارع المطار', 'إب', 1),
(3, 8, 'أمن وحماية', 'خدمات أمن وحماية للمناسبات', 2000.00, NULL, 13.9867, 44.2033, 'شارع المدينة الرياضية', 'إب', 1);

-- إضافة حجوزات تجريبية
INSERT INTO bookings (user_id, service_id, provider_id, booking_date, booking_time, status, total_price, notes) VALUES
(6, 1, 1, '2024-01-15', '18:00:00', 'completed', 2000.00, 'حجز تجريبي'),
(7, 1, 1, '2024-01-20', '19:00:00', 'completed', 2000.00, 'حجز تجريبي'),
(8, 2, 2, '2024-01-25', '20:00:00', 'completed', 5000.00, 'حجز تجريبي'),
(9, 3, 3, '2024-02-01', '17:00:00', 'completed', 3000.00, 'حجز تجريبي'),
(10, 4, 4, '2024-02-05', '21:00:00', 'completed', 1200.00, 'حجز تجريبي');

-- إضافة تقييمات تجريبية
INSERT INTO reviews (user_id, service_id, booking_id, rating, comment) VALUES
(6, 1, 1, 5, 'خدمة ممتازة وتصوير احترافي'),
(7, 1, 2, 4, 'تصوير جميل وسعر مناسب'),
(8, 2, 3, 5, 'تنسيق رائع وألوان جميلة'),
(9, 3, 4, 4, 'طعام لذيذ وخدمة سريعة'),
(10, 4, 5, 5, 'موسيقى جميلة وأجواء رائعة');

-- تحديث متوسط التقييمات
UPDATE services s 
SET rating = (
    SELECT AVG(rating) 
    FROM reviews r 
    WHERE r.service_id = s.id
),
total_ratings = (
    SELECT COUNT(*) 
    FROM reviews r 
    WHERE r.service_id = s.id
); 