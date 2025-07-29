-- =====================================================
-- بيانات افتراضية شاملة لتطبيق آشا
-- =====================================================

-- تنظيف البيانات الموجودة (اختياري)
-- DELETE FROM bookings;
-- DELETE FROM reviews;
-- DELETE FROM favorites;
-- DELETE FROM services;
-- DELETE FROM ads;
-- DELETE FROM categories;
-- DELETE FROM users WHERE id > 1;

-- =====================================================
-- إضافة فئات الخدمات
-- =====================================================
INSERT INTO categories (name, description, image, is_active, created_at) VALUES
('تنظيف المنازل', 'خدمات تنظيف شاملة للمنازل والشقق', 'cleaning.jpg', 1, NOW()),
('الكهرباء', 'خدمات إصلاح وتوصيل الكهرباء', 'electricity.jpg', 1, NOW()),
('السباكة', 'خدمات إصلاح وصيانة السباكة', 'plumbing.jpg', 1, NOW()),
('التصميم الداخلي', 'تصميم وتأثيث المنازل', 'interior.jpg', 1, NOW()),
('الحدادة', 'أعمال الحديد والحدادة', 'blacksmith.jpg', 1, NOW()),
('النجارة', 'أعمال الخشب والنجارة', 'carpentry.jpg', 1, NOW()),
('التكييف', 'تركيب وصيانة أجهزة التكييف', 'ac.jpg', 1, NOW()),
('الحدائق', 'تصميم وصيانة الحدائق', 'gardening.jpg', 1, NOW()),
('الأمن والحماية', 'أنظمة الأمن والمراقبة', 'security.jpg', 1, NOW()),
('النقل والشحن', 'خدمات النقل والشحن', 'transport.jpg', 1, NOW());

-- =====================================================
-- إضافة مستخدمين (مستخدمين عاديين)
-- =====================================================
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

-- =====================================================
-- إضافة مزودي الخدمات
-- =====================================================
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

-- =====================================================
-- إضافة خدمات
-- =====================================================
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

-- =====================================================
-- إضافة إعلانات
-- =====================================================
INSERT INTO ads (provider_id, title, description, image, is_active, start_date, end_date, created_at) VALUES
(11, 'عرض خاص: تنظيف منزل شامل', 'خصم 20% على تنظيف المنزل الشامل هذا الأسبوع', 'ad_cleaning1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), NOW()),
(17, 'تركيب مكيفات بأسعار منافسة', 'تركيب مكيفات سبليت بأسعار مميزة', 'ad_ac1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 14 DAY), NOW()),
(12, 'إصلاح كهربائي فوري', 'خدمة إصلاح كهربائي فورية خلال 24 ساعة', 'ad_electric1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 10 DAY), NOW()),
(14, 'تصميم داخلي مجاني', 'استشارة تصميم داخلي مجانية مع كل مشروع', 'ad_design1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 21 DAY), NOW()),
(13, 'صيانة سباكة عاجلة', 'خدمة سباكة عاجلة متاحة 24/7', 'ad_plumbing1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), NOW()),
(18, 'حدائق منزلية بأقل سعر', 'تصميم حدائق منزلية بأسعار منافسة', 'ad_garden1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(19, 'أنظمة أمن متطورة', 'تركيب أنظمة أمن ومراقبة متطورة', 'ad_security1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), NOW()),
(20, 'نقل أثاث آمن', 'خدمة نقل أثاث آمنة ومضمونة', 'ad_transport1.jpg', 1, NOW(), DATE_ADD(NOW(), INTERVAL 12 DAY), NOW());

-- =====================================================
-- إضافة حجوزات
-- =====================================================
INSERT INTO bookings (user_id, service_id, provider_id, booking_date, booking_time, status, total_price, notes, created_at) VALUES
(2, 1, 11, DATE_ADD(NOW(), INTERVAL 2 DAY), '10:00:00', 'pending', 150.00, 'تنظيف منزل 3 غرف', NOW()),
(3, 3, 12, DATE_ADD(NOW(), INTERVAL 1 DAY), '14:00:00', 'confirmed', 200.00, 'إصلاح كهربائي عاجل', NOW()),
(4, 5, 13, DATE_ADD(NOW(), INTERVAL 3 DAY), '09:00:00', 'completed', 120.00, 'إصلاح تسرب في الحمام', NOW()),
(5, 6, 14, DATE_ADD(NOW(), INTERVAL 5 DAY), '16:00:00', 'pending', 500.00, 'تصميم غرفة معيشة', NOW()),
(6, 8, 16, DATE_ADD(NOW(), INTERVAL 4 DAY), '11:00:00', 'confirmed', 350.00, 'صنع خزانة خشب', NOW()),
(7, 9, 17, DATE_ADD(NOW(), INTERVAL 1 DAY), '13:00:00', 'cancelled', 150.00, 'صيانة مكيف', NOW()),
(8, 10, 18, DATE_ADD(NOW(), INTERVAL 7 DAY), '08:00:00', 'pending', 800.00, 'تصميم حديقة منزلية', NOW()),
(9, 11, 19, DATE_ADD(NOW(), INTERVAL 2 DAY), '15:00:00', 'confirmed', 600.00, 'تركيب نظام مراقبة', NOW()),
(10, 12, 20, DATE_ADD(NOW(), INTERVAL 1 DAY), '12:00:00', 'completed', 200.00, 'شحن أثاث', NOW()),
(2, 13, 11, DATE_ADD(NOW(), INTERVAL 3 DAY), '10:30:00', 'pending', 100.00, 'تنظيف السجاد', NOW());

-- =====================================================
-- إضافة تقييمات
-- =====================================================
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

-- =====================================================
-- إضافة مفضلات
-- =====================================================
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

-- =====================================================
-- إضافة تعليقات
-- =====================================================
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

-- =====================================================
-- إضافة إشعارات
-- =====================================================
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
-- إضافة عروض خاصة
-- =====================================================
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

-- =====================================================
-- تحديث عدد الخدمات في كل فئة (اختياري)
-- =====================================================
-- يمكن إضافة هذا التحديث لاحقاً إذا تم إضافة عمود services_count للجدول

-- =====================================================
-- رسالة نجاح
-- =====================================================
SELECT 'تم إضافة البيانات الافتراضية بنجاح!' AS message;
SELECT 'عدد الفئات المضافة: ' || (SELECT COUNT(*) FROM categories) AS categories_count;
SELECT 'عدد المستخدمين المضافة: ' || (SELECT COUNT(*) FROM users WHERE user_type = 'user') AS users_count;
SELECT 'عدد مزودي الخدمات المضافة: ' || (SELECT COUNT(*) FROM users WHERE user_type = 'provider') AS providers_count;
SELECT 'عدد الخدمات المضافة: ' || (SELECT COUNT(*) FROM services) AS services_count;
SELECT 'عدد الإعلانات المضافة: ' || (SELECT COUNT(*) FROM ads) AS ads_count;
SELECT 'عدد الحجوزات المضافة: ' || (SELECT COUNT(*) FROM bookings) AS bookings_count;
SELECT 'عدد التقييمات المضافة: ' || (SELECT COUNT(*) FROM reviews) AS reviews_count; 