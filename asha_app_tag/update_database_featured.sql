-- =====================================================
-- تحديث قاعدة البيانات لإضافة عمود is_featured
-- =====================================================

-- إضافة عمود is_featured إلى جدول الخدمات
ALTER TABLE services 
ADD COLUMN is_featured BOOLEAN DEFAULT FALSE AFTER is_verified,
ADD COLUMN rating DECIMAL(3,2) DEFAULT 0.00 AFTER is_featured,
ADD COLUMN total_reviews INT DEFAULT 0 AFTER rating;

-- إضافة فهرس لعمود is_featured
ALTER TABLE services 
ADD INDEX idx_is_featured (is_featured);

-- إضافة عمود rating و total_reviews إلى جدول المستخدمين إذا لم يكن موجوداً
ALTER TABLE users 
ADD COLUMN rating DECIMAL(3,2) DEFAULT 0.00 AFTER user_type,
ADD COLUMN total_reviews INT DEFAULT 0 AFTER rating;

-- إضافة فهرس لعمود rating في جدول المستخدمين
ALTER TABLE users 
ADD INDEX idx_rating (rating);

-- تحديث بعض الخدمات لتكون مميزة (مثال)
UPDATE services 
SET is_featured = 1 
WHERE id IN (1, 2, 3, 4, 5);

-- تحديث تقييمات افتراضية للخدمات
UPDATE services 
SET rating = 4.5, total_reviews = 10 
WHERE rating = 0;

-- تحديث تقييمات افتراضية للمستخدمين
UPDATE users 
SET rating = 4.5, total_reviews = 10 
WHERE user_type = 'provider' AND rating = 0;

-- التحقق من التحديثات
SELECT 'Database updated successfully!' as status; 