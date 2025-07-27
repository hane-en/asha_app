<?php
/**
 * ملف الفهرس الرئيسي لـ Asha App API
 * يوفر معلومات عن API والـ endpoints المتاحة
 */

require_once 'config.php';

// معلومات API
$apiInfo = [
    'app_name' => APP_NAME,
    'version' => APP_VERSION,
    'api_version' => API_VERSION,
    'description' => 'API لتطبيق خدمات الأعراس والمناسبات',
    'base_url' => getBaseUrl(),
    'documentation' => getBaseUrl() . '/docs.php',
    'status' => 'active',
    'timestamp' => date('Y-m-d H:i:s'),
    'endpoints' => [
        'auth' => [
            'login' => 'POST /api/auth/login.php',
            'register' => 'POST /api/auth/register.php',
            'verify' => 'POST /api/auth/verify.php',
            'forgot_password' => 'POST /api/auth/forgot_password.php',
            'reset_password' => 'POST /api/auth/reset_password.php'
        ],
        'services' => [
            'get_all' => 'GET /api/services/get_all.php',
            'get_by_id' => 'GET /api/services/get_by_id.php?id={id}',
            'create' => 'POST /api/services/create.php [Provider Required]',
            'update' => 'PUT /api/services/update.php [Provider Required]',
            'delete' => 'DELETE /api/services/delete.php [Provider Required]'
        ],
        'categories' => [
            'get_all' => 'GET /api/categories/get_all.php'
        ],
        'bookings' => [
            'create' => 'POST /api/bookings/create.php [Auth Required]',
            'get_user_bookings' => 'GET /api/bookings/get_user_bookings.php [Auth Required]',
            'update_status' => 'PUT /api/bookings/update_status.php [Provider Required]',
            'cancel' => 'PUT /api/bookings/cancel.php [Auth Required]'
        ],
        'favorites' => [
            'toggle' => 'POST /api/favorites/toggle.php [Auth Required]',
            'get_user_favorites' => 'GET /api/favorites/get_user_favorites.php [Auth Required]'
        ],
        'reviews' => [
            'create' => 'POST /api/reviews/create.php [Auth Required]',
            'get_service_reviews' => 'GET /api/reviews/get_service_reviews.php'
        ],
        'notifications' => [
            'get_user_notifications' => 'GET /api/notifications/get_user_notifications.php [Auth Required]',
            'mark_as_read' => 'PUT /api/notifications/mark_as_read.php [Auth Required]'
        ],
        'users' => [
            'get_profile' => 'GET /api/users/get_profile.php [Auth Required]',
            'update_profile' => 'PUT /api/users/update_profile.php [Auth Required]'
        ],
        'provider' => [
            'get_dashboard' => 'GET /api/provider/get_dashboard.php [Provider Required]',
            'get_services' => 'GET /api/provider/get_services.php [Provider Required]',
            'get_bookings' => 'GET /api/provider/get_bookings.php [Provider Required]'
        ],
        'admin' => [
            'get_dashboard' => 'GET /api/admin/get_dashboard.php [Admin Required]',
            'get_users' => 'GET /api/admin/get_users.php [Admin Required]',
            'approve_service' => 'PUT /api/admin/approve_service.php [Admin Required]'
        ]
    ],
    'authentication' => [
        'type' => 'Bearer Token (JWT)',
        'header' => 'Authorization: Bearer {token}',
        'description' => 'يجب إرسال الرمز المميز في رأس Authorization لجميع الطلبات التي تتطلب مصادقة'
    ],
    'response_format' => [
        'success' => [
            'success' => true,
            'message' => 'رسالة النجاح',
            'data' => 'البيانات المطلوبة',
            'timestamp' => 'وقت الاستجابة'
        ],
        'error' => [
            'success' => false,
            'message' => 'رسالة الخطأ',
            'timestamp' => 'وقت الاستجابة'
        ]
    ],
    'status_codes' => [
        200 => 'نجح الطلب',
        201 => 'تم إنشاء المورد بنجاح',
        400 => 'طلب غير صحيح',
        401 => 'غير مصرح',
        403 => 'ممنوع',
        404 => 'غير موجود',
        405 => 'طريقة غير مدعومة',
        500 => 'خطأ في الخادم'
    ]
];

successResponse($apiInfo, 'مرحباً بك في Asha App API');

?>

