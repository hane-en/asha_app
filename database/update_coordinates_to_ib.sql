-- تحديث الإحداثيات إلى محافظة إب - اليمن
USE asha;

-- تحديث إحداثيات المستخدمين إلى محافظة إب
UPDATE users SET 
    latitude = 13.9667,
    longitude = 44.1833,
    city = 'إب'
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

-- تحديث عناوين المستخدمين
UPDATE users SET address = 'شارع الثورة' WHERE id = 1;
UPDATE users SET address = 'شارع سوق الجملة' WHERE id = 2;
UPDATE users SET address = 'شارع الجامعة' WHERE id = 3;
UPDATE users SET address = 'شارع المركزي' WHERE id = 4;
UPDATE users SET address = 'شارع تعز' WHERE id = 5;
UPDATE users SET address = 'شارع العدين' WHERE id = 6;
UPDATE users SET address = 'شارع سوق الجملة' WHERE id = 7;
UPDATE users SET address = 'شارع الجامعة' WHERE id = 8;
UPDATE users SET address = 'شارع تعز' WHERE id = 9;
UPDATE users SET address = 'شارع العدين' WHERE id = 10;

-- تحديث إحداثيات الخدمات الأساسية إلى محافظة إب
UPDATE services SET 
    latitude = 13.9667,
    longitude = 44.1833,
    city = 'إب'
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

-- تحديث عناوين الخدمات الأساسية
UPDATE services SET address = 'شارع الجمهورية' WHERE id IN (1, 2);
UPDATE services SET address = 'شارع السوق' WHERE id IN (3, 4);
UPDATE services SET address = 'شارع الجامعة' WHERE id IN (5, 6);
UPDATE services SET address = 'شارع النزهة' WHERE id IN (7, 8);
UPDATE services SET address = 'شارع السبعين' WHERE id IN (9, 10);

-- تحديث إحداثيات الخدمات الإضافية بمواقع مختلفة في إب
UPDATE services SET 
    latitude = 13.9767,
    longitude = 44.1933,
    address = 'شارع المحافظة',
    city = 'إب'
WHERE id = 11;

UPDATE services SET 
    latitude = 13.9567,
    longitude = 44.1733,
    address = 'شارع الثلاثين',
    city = 'إب'
WHERE id = 12;

UPDATE services SET 
    latitude = 13.9867,
    longitude = 44.2033,
    address = 'شارع  المرور',
    city = 'إب'
WHERE id = 13;

-- التحقق من التحديث
SELECT id, name, latitude, longitude, address, city FROM users LIMIT 5;
SELECT id, title, latitude, longitude, address, city FROM services LIMIT 5; 