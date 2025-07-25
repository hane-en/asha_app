# شرح هيكل مجلد backend_php/api ووظيفة كل ملف

## auth/
- **register.php**: تسجيل مستخدم جديد (user أو provider).
- **login.php**: تسجيل الدخول للمستخدمين.
- **reset_password.php**: إعادة تعيين كلمة المرور.
- **forgot_password.php**: إرسال رابط/رمز استرجاع كلمة المرور.
- **admin_login.php**: تسجيل دخول المسؤول.
- **provider_login.php**: تسجيل دخول مزود الخدمة.

## user/
- **join_provider.php**: انضمام مستخدم كمزود خدمة.
- **get_favorites.php**: جلب قائمة المفضلة للمستخدم.
- **add_to_favorites.php**: إضافة خدمة إلى المفضلة.
- **remove_favorite.php / remove_from_favorites.php**: إزالة خدمة من المفضلة.

## services/
- **get_categories.php**: جلب جميع التصنيفات.
- **add_category.php**: إضافة تصنيف جديد.
- **get_services.php / get_all_services.php**: جلب جميع الخدمات.
- **get_service_details.php / get_service.php**: تفاصيل خدمة معينة.
- **search_services.php / advanced_search.php**: البحث عن خدمات.
- **services_by_category.php**: جلب خدمات حسب التصنيف.

## reviews/
- **add_review.php**: إضافة تقييم/مراجعة لخدمة.

## provider/
- **add_service.php**: إضافة خدمة جديدة من مزود.
- **get_provider_stats.php**: إحصائيات مزود الخدمة.
- **add_daily_stats_report.php**: إضافة تقرير يومي للإحصائيات.
- **get_provider_reports.php**: جلب تقارير مزود الخدمة.

## notifications/
- **get_notifications.php**: جلب الإشعارات للمستخدم.
- **mark_as_read.php**: تعليم الإشعارات كمقروءة.

## messages/
- **get_messages.php**: جلب الرسائل بين المستخدمين.
- **send_message.php**: إرسال رسالة بين المستخدمين.

## bookings/
- **create_booking.php**: إنشاء حجز جديد.
- **get_user_bookings.php**: جلب حجوزات المستخدم.

## admin/
- **get_dashboard_stats.php**: جلب إحصائيات لوحة تحكم الإدارة.
- **manage_provider_requests.php**: إدارة طلبات انضمام مزودي الخدمة.

## error/
- **404.php / 500.php**: صفحات أخطاء مخصصة (غير موجود/خطأ داخلي).

---

كل مجلد يمثل نوعاً من الوظائف (مصادقة، خدمات، مستخدمين، إدارة...) وكل ملف هو endpoint يُستدعى من التطبيق أو لوحة التحكم.

هذا الملف يساعد أي مطور backend جديد على فهم بنية المشروع بسرعة. 