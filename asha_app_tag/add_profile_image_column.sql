-- إضافة عمود profile_image إلى جدول users
USE asha_app_events;

-- إضافة عمود profile_image
ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) DEFAULT NULL AFTER website;

-- إضافة عمود cover_image أيضاً
ALTER TABLE users ADD COLUMN cover_image VARCHAR(255) DEFAULT NULL AFTER profile_image;

-- تحديث البيانات الموجودة لتعيين صورة افتراضية
UPDATE users SET profile_image = 'default_avatar.jpg' WHERE profile_image IS NULL;

-- إضافة فهارس للصور
CREATE INDEX idx_profile_image ON users(profile_image);
CREATE INDEX idx_cover_image ON users(cover_image);

-- عرض رسالة نجاح
SELECT 'تم إضافة أعمدة الصور بنجاح' as message; 