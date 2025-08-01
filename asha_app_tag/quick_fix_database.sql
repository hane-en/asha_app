-- إصلاح سريع لقاعدة البيانات
USE asha_app_events;

-- التحقق من وجود العمود
SELECT COUNT(*) as column_exists 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'asha_app_events' 
AND TABLE_NAME = 'users' 
AND COLUMN_NAME = 'profile_image';

-- إضافة العمود إذا لم يكن موجوداً
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image VARCHAR(255) DEFAULT NULL AFTER website;

-- إضافة عمود cover_image أيضاً
ALTER TABLE users ADD COLUMN IF NOT EXISTS cover_image VARCHAR(255) DEFAULT NULL AFTER profile_image;

-- تحديث البيانات الموجودة
UPDATE users SET profile_image = 'default_avatar.jpg' WHERE profile_image IS NULL;

-- عرض رسالة نجاح
SELECT 'تم إصلاح قاعدة البيانات بنجاح' as message; 