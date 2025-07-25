# دليل البدء السريع - البحث المتقدم

## 🚀 تشغيل النظام المحسن

### الخطوة 1: تحديث قاعدة البيانات
```bash
# تشغيل ملف تحديث قاعدة البيانات (للمرة الأولى)
mysql -u root -p < database/update_location_fields.sql

# أو إذا كانت قاعدة البيانات موجودة بالفعل، استخدم:
mysql -u root -p < database/update_coordinates_to_ib.sql
```

### الخطوة 2: تثبيت التبعيات الجديدة
```bash
flutter pub get
```

### الخطوة 3: تشغيل التطبيق
```bash
flutter run
```

## 🔍 كيفية استخدام البحث المتقدم

### 1. فتح صفحة البحث
- انتقل إلى تبويب "بحث" في التطبيق
- ستجد شريط البحث في أعلى الصفحة

### 2. تفعيل الفلاتر المتقدمة
- اضغط على أيقونة الفلتر (🔍) في شريط العنوان
- ستظهر قائمة الفلاتر المتقدمة

### 3. استخدام فلتر السعر
- اسحب شريط السعر لتحديد النطاق المطلوب
- يمكنك تحديد الحد الأدنى والأقصى للسعر
- مثال: 500 - 3000 ريال

### 4. اختيار الفئة
- اختر فئة محددة من القائمة المنسدلة
- أو اترك "جميع الفئات" للبحث الشامل

### 5. تفعيل البحث الجغرافي
- تأكد من تفعيل GPS في جهازك
- امنح التطبيق إذن الوصول للموقع
- سيتم البحث عن الخدمات القريبة تلقائياً

### 6. اختيار الترتيب
- **الأحدث**: الخدمات المضافة حديثاً
- **السعر**: من الأرخص إلى الأغلى أو العكس
- **التقييم**: حسب تقييم المستخدمين
- **المسافة**: الأقرب لموقعك

### 7. تنفيذ البحث
- اضغط على زر "بحث"
- ستظهر النتائج مع معلومات المسافة والسعر

## 📍 معلومات الموقع

### عرض المسافة
- ستظهر المسافة تحت عنوان الخدمة
- بالكيلومترات أو الأمتار حسب القرب

### حالة GPS
- 🟢 أخضر: GPS مفعل - البحث الجغرافي متاح
- 🔴 أحمر: GPS غير مفعل - البحث النصي فقط

## 💰 معلومات الأسعار

### الأسعار المخفضة
- السعر الأصلي: مشطوب بخط
- السعر الحالي: باللون الأزرق
- نسبة الخصم: تظهر بجانب السعر

### نطاق الأسعار
- يمكن تحديد نطاق من 0 إلى 10,000 ريال
- شريط قابل للسحب لسهولة التحديد

## 🔧 استكشاف الأخطاء الشائعة

### مشكلة: لا تظهر نتائج
**الحل:**
- تأكد من وجود خدمات في قاعدة البيانات
- جرب توسيع نطاق السعر
- تأكد من تفعيل GPS للبحث الجغرافي

### مشكلة: GPS لا يعمل
**الحل:**
- تأكد من تفعيل GPS في إعدادات الجهاز
- امنح التطبيق إذن الوصول للموقع
- تحقق من إعدادات الخصوصية

### مشكلة: بطء في البحث
**الحل:**
- تحقق من سرعة الإنترنت
- تأكد من عمل خادم PHP
- تحقق من إعدادات قاعدة البيانات

## 📱 المميزات الجديدة

### ✅ تم إضافتها
- [x] فلترة حسب نطاق السعر
- [x] البحث الجغرافي بالGPS
- [x] فلترة حسب الفئة
- [x] ترتيب متعدد الخيارات
- [x] عرض المسافة للخدمات
- [x] أسعار مخفضة مع نسبة الخصم
- [x] واجهة مستخدم محسنة
- [x] دعم الأذونات للموقع

### 🔄 التحسينات المستقبلية
- [ ] خريطة تفاعلية
- [ ] إشعارات للخدمات القريبة
- [ ] تقارير إحصائية
- [ ] نظام تقييم متقدم

## 📞 الدعم

إذا واجهت أي مشاكل:
1. تحقق من هذا الدليل
2. راجع ملف README.md
3. تحقق من سجلات الأخطاء
4. تواصل مع فريق الدعم

---

**ملاحظة مهمة**: تأكد من تشغيل ملف `update_location_fields.sql` قبل استخدام المميزات الجديدة. 