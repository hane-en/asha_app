-- إضافة مزودين تجريبيين إلى قاعدة البيانات
-- تأكد من تشغيل هذا الملف بعد إنشاء الجداول

-- إضافة مزودين تجريبيين
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, created_at) VALUES
('أحمد محمد', 'ahmed@example.com', '0501234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.5, 12, NOW()),
('فاطمة علي', 'fatima@example.com', '0502345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.8, 25, NOW()),
('محمد حسن', 'mohammed@example.com', '0503456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.2, 8, NOW()),
('سارة أحمد', 'sara@example.com', '0504567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 0, 1, 4.0, 5, NOW()),
('علي محمود', 'ali@example.com', '0505678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.7, 18, NOW()),
('نورا سعيد', 'nora@example.com', '0506789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.9, 30, NOW()),
('خالد عبدالله', 'khalid@example.com', '0507890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 0, 1, 3.8, 3, NOW()),
('ليلى محمد', 'layla@example.com', '0508901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.6, 15, NOW()),
('عمر يوسف', 'omar@example.com', '0509012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.3, 10, NOW()),
('رنا أحمد', 'rana@example.com', '0500123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.4, 22, NOW());

-- إضافة فئات تجريبية إذا لم تكن موجودة
INSERT IGNORE INTO categories (name, description, icon, color, is_active, created_at) VALUES
('قاعات الأفراح', 'قاعات احتفالات وأفراح', 'celebration', '#8e24aa', 1, NOW()),
('التصوير', 'خدمات التصوير الاحترافي للمناسبات', 'camera_alt', '#ff9800', 1, NOW()),
('الديكور', 'خدمات تزيين المناسبات', 'local_florist', '#4caf50', 1, NOW()),
('الجاتوهات', 'جاتوهات وحلويات للمناسبات', 'cake', '#e91e63', 1, NOW()),
('الموسيقى', 'خدمات الموسيقى والعزف', 'music_note', '#2196f3', 1, NOW()),
('الفساتين', 'فساتين وأزياء المناسبات', 'checkroom', '#9c27b0', 1, NOW());

-- إضافة خدمات تجريبية للمزودين
INSERT INTO services (provider_id, category_id, title, description, price, rating, is_active, created_at) VALUES
-- خدمات فاطمة علي (قاعات الأفراح)
(2, 1, 'قاعة أفراح فاخرة', 'قاعة أفراح فاخرة تتسع لـ 200 شخص', 2000.00, 4.8, 1, NOW()),
(2, 1, 'قاعة احتفالات صغيرة', 'قاعة احتفالات صغيرة للمناسبات العائلية', 1000.00, 4.7, 1, NOW()),

-- خدمات أحمد محمد (التصوير)
(1, 2, 'تصوير احترافي للمناسبات', 'تصوير احترافي عالي الجودة لجميع المناسبات', 500.00, 4.5, 1, NOW()),
(1, 2, 'تصوير فيديو للمناسبات', 'تصوير فيديو احترافي مع مونتاج', 800.00, 4.6, 1, NOW()),

-- خدمات سارة أحمد (الديكور)
(4, 3, 'تزيين قاعات الأفراح', 'تزيين احترافي لقاعات الأفراح', 300.00, 4.0, 1, NOW()),
(4, 3, 'تزيين مناسبات عائلية', 'تزيين بسيط للمناسبات العائلية', 150.00, 4.2, 1, NOW()),

-- خدمات علي محمود (الجاتوهات)
(5, 4, 'جاتوهات عيد الميلاد', 'جاتوهات احترافية لعيد الميلاد', 200.00, 4.7, 1, NOW()),
(5, 4, 'جاتوهات الأفراح', 'جاتوهات فاخرة لحفلات الأفراح', 300.00, 4.6, 1, NOW()),

-- خدمات محمد حسن (الموسيقى)
(3, 5, 'عزف موسيقي للمناسبات', 'عزف موسيقي احترافي لجميع المناسبات', 600.00, 4.2, 1, NOW()),
(3, 5, 'دجاجي وطرب', 'دجاجي وطرب تقليدي للمناسبات', 400.00, 4.1, 1, NOW()),

-- خدمات نورا سعيد (الفساتين)
(6, 6, 'تأجير فساتين العروس', 'تأجير فساتين عروس فاخرة', 500.00, 4.9, 1, NOW()),
(6, 6, 'تأجير بدلات الرجال', 'تأجير بدلات رسمية للرجال', 200.00, 4.8, 1, NOW()),

-- خدمات خالد عبدالله (التصوير)
(7, 2, 'تصوير بسيط للمناسبات', 'تصوير بسيط للمناسبات العائلية', 200.00, 3.8, 1, NOW()),

-- خدمات ليلى محمد (الموسيقى)
(8, 5, 'عزف البيانو', 'عزف البيانو للمناسبات الرومانسية', 700.00, 4.6, 1, NOW()),
(8, 5, 'غناء عربي', 'غناء عربي تقليدي للمناسبات', 500.00, 4.5, 1, NOW()),

-- خدمات عمر يوسف (الديكور)
(9, 3, 'تزيين حدائق', 'تزيين احترافي للحدائق والمناطق الخارجية', 400.00, 4.3, 1, NOW()),

-- خدمات رنا أحمد (الجاتوهات)
(10, 4, 'جاتوهات غربية', 'جاتوهات غربية متنوعة', 250.00, 4.4, 1, NOW()),
(10, 4, 'جاتوهات عربية', 'جاتوهات عربية تقليدية', 180.00, 4.3, 1, NOW());

-- إضافة بعض المستخدمين العاديين
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, created_at) VALUES
('مستخدم تجريبي 1', 'user1@example.com', '0501111111', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, 0.0, 0, NOW()),
('مستخدم تجريبي 2', 'user2@example.com', '0502222222', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, 0.0, 0, NOW()),
('مستخدم تجريبي 3', 'user3@example.com', '0503333333', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, 0.0, 0, NOW());

-- إضافة بعض التقييمات التجريبية
INSERT INTO reviews (user_id, service_id, rating, comment, created_at) VALUES
(11, 1, 5, 'تصوير ممتاز وجودة عالية', NOW()),
(11, 3, 4, 'قاعة جميلة وخدمة ممتازة', NOW()),
(12, 2, 5, 'فيديو احترافي جداً', NOW()),
(12, 4, 4, 'قاعة مناسبة للمناسبات العائلية', NOW()),
(13, 5, 4, 'عزف جميل وموسيقى هادئة', NOW()),
(13, 7, 5, 'تزيين رائع ومبدع', NOW());

-- عرض النتائج
SELECT 'تم إضافة البيانات التجريبية بنجاح' as message;
SELECT COUNT(*) as total_providers FROM users WHERE user_type = 'provider' AND is_active = 1;
SELECT COUNT(*) as total_users FROM users WHERE user_type = 'user' AND is_active = 1;
SELECT COUNT(*) as total_services FROM services WHERE is_active = 1;
SELECT COUNT(*) as total_categories FROM categories WHERE is_active = 1; 