# إصلاح المفضلة والحجز - السماح للمستخدمين غير المسجلين

## 🔧 التحديثات المطلوبة:

### 1. **السماح بإضافة المفضلة بدون حساب** ❤️

#### الميزة:
- المستخدمون غير المسجلين يمكنهم إضافة الخدمات للمفضلة
- المفضلة المحلية تُحفظ في `SharedPreferences`
- عند تسجيل الدخول، يمكن دمج المفضلة المحلية مع المفضلة على الخادم

#### التنفيذ:
- ✅ إضافة زر المفضلة في صفحة تفاصيل الخدمة
- ✅ حفظ المفضلة المحلية في `local_favorites`
- ✅ عرض رسائل تأكيد للمستخدم
- ✅ تحديث حالة المفضلة في الواجهة

### 2. **إجبار إنشاء حساب عند الحجز** 🔒

#### الميزة:
- المستخدمون غير المسجلين لا يمكنهم الحجز
- عرض رسالة واضحة تطلب تسجيل الدخول
- توجيه المستخدم لصفحة تسجيل الدخول

#### التنفيذ:
- ✅ إضافة زر الحجز في صفحة تفاصيل الخدمة
- ✅ التحقق من حالة تسجيل الدخول
- ✅ عرض نافذة حوار تطلب تسجيل الدخول
- ✅ توجيه المستخدم لصفحة تسجيل الدخول

### 3. **إصلاح صفحة الإشعارات** 🔔

#### المشكلة:
- صفحة الإشعارات تستخدم أسماء طرق خاطئة
- لا يمكن العودة للصفحة الرئيسية من الشريط السفلي

#### الحل:
- ✅ إضافة استيراد `RouteNames` و `route_arguments`
- ✅ إضافة دوال التنقل مع المعاملات المطلوبة
- ✅ تحديث أسماء الطرق في الشريط السفلي

## 📱 الصفحات المحدثة:

### ✅ **1. صفحة تفاصيل الخدمة** (`lib/screens/user/details_page.dart`)
- **التحديثات**:
  - تحويل من `StatelessWidget` إلى `StatefulWidget`
  - إضافة حالة المفضلة (`_isFavorite`)
  - إضافة حالة التحميل (`_isLoading`)
  - إضافة دالة `_checkFavoriteStatus()`
  - إضافة دالة `_toggleFavorite()`
  - إضافة دالة `_bookService()`
  - إضافة أزرار المفضلة والحجز في الواجهة

### ✅ **2. صفحة المفضلة** (`lib/screens/user/favorites_page.dart`)
- **التحديثات**:
  - تحسين دالة `loadFavorites()` للتعامل مع المفضلة المحلية
  - إضافة معالجة الأخطاء
  - إضافة رسائل للمستخدم

### ✅ **3. صفحة الإشعارات** (`lib/screens/user/notifications_page.dart`)
- **التحديثات**:
  - إضافة استيراد `RouteNames` و `route_arguments`
  - إضافة دالة `_getUserId()`
  - إضافة دالة `_navigateToFavorites()`
  - إضافة دالة `_navigateToBookings()`
  - تحديث أسماء الطرق في الشريط السفلي

## 🔄 دوال المفضلة الجديدة:

### **1. دالة التحقق من حالة المفضلة**:
```dart
Future<void> _checkFavoriteStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  if (userId != null) {
    try {
      final favorites = await ApiService.getFavorites(userId);
      setState(() {
        _isFavorite = favorites.any((fav) => fav['id'] == widget.service['id']);
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }
}
```

### **2. دالة تبديل المفضلة**:
```dart
Future<void> _toggleFavorite() async {
  setState(() => _isLoading = true);
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    
    if (userId != null) {
      // المستخدم مسجل دخول
      if (_isFavorite) {
        await ApiService.removeFavorite(userId, widget.service['id']);
      } else {
        await ApiService.addToFavorites(userId, widget.service['id']);
      }
      setState(() => _isFavorite = !_isFavorite);
    } else {
      // المستخدم غير مسجل دخول - حفظ في التخزين المحلي
      final localFavorites = prefs.getStringList('local_favorites') ?? [];
      final serviceId = widget.service['id'].toString();
      
      if (_isFavorite) {
        localFavorites.remove(serviceId);
      } else {
        localFavorites.add(serviceId);
      }
      
      await prefs.setStringList('local_favorites', localFavorites);
      setState(() => _isFavorite = !_isFavorite);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة'),
        backgroundColor: Colors.purple,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### **3. دالة الحجز**:
```dart
void _bookService() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  
  if (userId == null) {
    // المستخدم غير مسجل دخول - إجبار إنشاء حساب
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('يجب تسجيل الدخول أو إنشاء حساب لحجز الخدمة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  } else {
    // المستخدم مسجل دخول - الانتقال لصفحة الحجز
    final serviceModel = ServiceModel(/* تحويل البيانات */);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(service: serviceModel),
      ),
    );
  }
}
```

## 🎯 النتيجة النهائية:

### ✅ **الميزات الجديدة**:
1. **المفضلة للجميع**: يمكن إضافة الخدمات للمفضلة بدون تسجيل دخول
2. **الحجز للمسجلين فقط**: إجبار تسجيل الدخول عند الحجز
3. **التنقل المحسن**: صفحة الإشعارات تعمل بشكل صحيح
4. **تجربة مستخدم محسنة**: رسائل واضحة وتوجيه مناسب

### 📱 **التدفق الجديد**:
1. **مستخدم غير مسجل**:
   - يمكن تصفح الخدمات ✅
   - يمكن إضافة للمفضلة ✅
   - لا يمكن الحجز ❌ (يُطلب تسجيل الدخول)

2. **مستخدم مسجل**:
   - يمكن تصفح الخدمات ✅
   - يمكن إضافة للمفضلة ✅
   - يمكن الحجز ✅

### 🔒 **الأمان**:
- التحقق من تسجيل الدخول قبل الحجز
- حفظ المفضلة المحلية بشكل آمن
- رسائل واضحة للمستخدم

### 🎨 **الواجهة**:
- أزرار واضحة للمفضلة والحجز
- ألوان متسقة (بنفسجي)
- رسائل تأكيد للمستخدم

---

**تاريخ الإصلاح**: يناير 2024
**الإصدار**: 4.5.0
**الحالة**: مكتمل تماماً ✅ 