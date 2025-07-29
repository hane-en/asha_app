# تحميل الخطوط العربية

## الخطوات المطلوبة:

### 1. تحميل خطوط Noto Sans Arabic
اذهب إلى: https://fonts.google.com/noto/specimen/Noto+Sans+Arabic
- انقر على "Download family"
- استخرج الملفات
- انسخ `NotoSansArabic-Regular.ttf` و `NotoSansArabic-Bold.ttf` إلى مجلد `assets/fonts/`

### 2. تحميل خطوط Cairo
اذهب إلى: https://fonts.google.com/specimen/Cairo
- انقر على "Download family"
- استخرج الملفات
- انسخ `Cairo-Regular.ttf` و `Cairo-Bold.ttf` إلى مجلد `assets/fonts/`

### 3. أو استخدم الروابط المباشرة:
```bash
# إنشاء مجلد الخطوط
mkdir -p assets/fonts

# تحميل خطوط Noto Sans Arabic
curl -o assets/fonts/NotoSansArabic-Regular.ttf "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-Regular.ttf"
curl -o assets/fonts/NotoSansArabic-Bold.ttf "https://github.com/google/fonts/raw/main/ofl/notosansarabic/NotoSansArabic-Bold.ttf"

# تحميل خطوط Cairo
curl -o assets/fonts/Cairo-Regular.ttf "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Regular.ttf"
curl -o assets/fonts/Cairo-Bold.ttf "https://github.com/google/fonts/raw/main/ofl/cairo/Cairo-Bold.ttf"
```

### 4. بعد تحميل الخطوط:
```bash
flutter clean
flutter pub get
flutter run
```

## ملاحظة:
إذا لم تتمكن من تحميل الخطوط، يمكنك استخدام الخطوط الافتراضية في النظام أو إزالة إعدادات الخطوط من `pubspec.yaml` مؤقتاً. 