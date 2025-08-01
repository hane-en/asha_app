-- إضافة مزودي التصوير المفقودين: اشراق و اضواء

-- إضافة مزود اشراق
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, address, created_at) VALUES
('اشراق', 'ashraq@example.com', '0501234568', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.7, 15, 'الرياض، المملكة العربية السعودية', NOW());

-- إضافة مزود اضواء
INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, address, created_at) VALUES
('اضواء', 'adwa@example.com', '0501234569', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider', 1, 1, 4.5, 12, 'جدة، المملكة العربية السعودية', NOW());

-- الحصول على معرفات المزودين المضافين
SET @ashraq_id = LAST_INSERT_ID();
SET @adwa_id = @ashraq_id + 1;

-- الحصول على معرف فئة التصوير
SET @photography_category_id = (SELECT id FROM categories WHERE name = 'التصوير' LIMIT 1);

-- إضافة خدمات اشراق
INSERT INTO services (provider_id, category_id, title, description, price, rating, is_active, created_at) VALUES
(@ashraq_id, @photography_category_id, 'تصوير احترافي للمناسبات', 'تصوير احترافي عالي الجودة لجميع المناسبات مع إضاءة احترافية', 600.00, 4.7, 1, NOW()),
(@ashraq_id, @photography_category_id, 'تصوير فيديو احترافي', 'تصوير فيديو احترافي مع مونتاج وإضاءة متقدمة', 900.00, 4.8, 1, NOW()),
(@ashraq_id, @photography_category_id, 'تصوير الأعراس', 'تصوير احترافي لحفلات الأعراس مع إضاءة احترافية', 1200.00, 4.9, 1, NOW());

-- إضافة خدمات اضواء
INSERT INTO services (provider_id, category_id, title, description, price, rating, is_active, created_at) VALUES
(@adwa_id, @photography_category_id, 'تصوير بسيط للمناسبات', 'تصوير بسيط للمناسبات العائلية مع إضاءة مناسبة', 300.00, 4.5, 1, NOW()),
(@adwa_id, @photography_category_id, 'تصوير فيديو بسيط', 'تصوير فيديو بسيط للمناسبات العائلية', 500.00, 4.4, 1, NOW()),
(@adwa_id, @photography_category_id, 'تصوير الأطفال', 'تصوير احترافي للأطفال مع إضاءة ناعمة', 400.00, 4.6, 1, NOW());

-- إضافة بعض التقييمات التجريبية
INSERT INTO reviews (user_id, service_id, rating, comment, created_at) VALUES
(11, (SELECT id FROM services WHERE provider_id = @ashraq_id AND title = 'تصوير احترافي للمناسبات' LIMIT 1), 5, 'تصوير ممتاز وإضاءة احترافية', NOW()),
(12, (SELECT id FROM services WHERE provider_id = @ashraq_id AND title = 'تصوير فيديو احترافي' LIMIT 1), 5, 'فيديو احترافي جداً مع إضاءة رائعة', NOW()),
(13, (SELECT id FROM services WHERE provider_id = @adwa_id AND title = 'تصوير بسيط للمناسبات' LIMIT 1), 4, 'تصوير جميل وبسيط', NOW());

-- عرض النتائج
SELECT 'تم إضافة مزودي التصوير اشراق و اضواء بنجاح' as message;
SELECT COUNT(*) as total_photography_providers FROM users WHERE user_type = 'provider' AND is_active = 1 AND name IN ('اشراق', 'اضواء');
SELECT COUNT(*) as total_photography_services FROM services WHERE provider_id IN (@ashraq_id, @adwa_id) AND is_active = 1; 