-- تفعيل الحسابات الموجودة في قاعدة البيانات
-- تشغيل هذا الملف لحل مشكلة "يرجى تفعيل حسابك"

USE asha_app;

-- تفعيل جميع الحسابات الموجودة
UPDATE users SET is_verified = 1 WHERE is_verified = 0;

-- إضافة بيانات تجريبية مفعلة
INSERT INTO users (
    name, 
    email, 
    phone, 
    password, 
    user_type, 
    is_verified, 
    is_active,
    created_at
) VALUES 
-- مدير النظام
('مدير النظام', 'admin@asha.com', '777777777', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1, 1, NOW()),

-- مزودي الخدمات
('أحمد المصور', 'ahmed@test.com', '777777778', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, NOW()),
('فاطمة المزينة', 'fatima@test.com', '777777779', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, NOW()),

-- مستخدمين عاديين
('محمد أحمد', 'mohammed@test.com', '777777780', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('سارة علي', 'sara@test.com', '777777781', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW()),
('علي حسن', 'ali@test.com', '777777782', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', 1, 1, NOW())

ON DUPLICATE KEY UPDATE 
    is_verified = 1,
    is_active = 1,
    updated_at = NOW();

-- إضافة فئات الخدمات
INSERT INTO categories (name, description, is_active) VALUES 
('التصوير', 'خدمات التصوير الاحترافي للمناسبات', 1),
('التجميل', 'خدمات التجميل والمكياج للمناسبات', 1),
('الضيافة', 'خدمات الضيافة والطعام للمناسبات', 1),
('الموسيقى', 'خدمات الموسيقى والترفيه للمناسبات', 1),
('الزهور', 'خدمات تنسيق الزهور والديكور', 1),
('الملابس', 'خدمات تأجير وبيع الملابس للمناسبات', 1)

ON DUPLICATE KEY UPDATE 
    is_active = 1,
    updated_at = NOW();

-- عرض الحسابات المفعلة
SELECT id, name, email, user_type, is_verified, is_active FROM users WHERE is_verified = 1;

-- عرض الفئات المفعلة
SELECT id, name, is_active FROM categories WHERE is_active = 1; 