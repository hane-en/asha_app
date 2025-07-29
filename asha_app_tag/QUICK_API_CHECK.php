<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$results = [
    'success' => true,
    'message' => 'فحص سريع للـ API',
    'timestamp' => date('Y-m-d H:i:s'),
    'endpoints' => []
];

// فحص نقاط النهاية الأساسية
$basic_endpoints = [
    'auth/login.php' => 'POST /api/auth/login.php',
    'auth/register.php' => 'POST /api/auth/register.php',
    'auth/verify.php' => 'POST /api/auth/verify.php',
    'auth/forgot_password.php' => 'POST /api/auth/forgot_password.php',
    'auth/reset_password.php' => 'POST /api/auth/reset_password.php',
    'auth/delete_account.php' => 'POST /api/auth/delete_account.php',
    'services/get_all.php' => 'GET /api/services/get_all.php',
    'services/get_by_id.php' => 'GET /api/services/get_by_id.php',
    'services/get_categories.php' => 'GET /api/services/get_categories.php',
    'categories/get_all.php' => 'GET /api/categories/get_all.php',
    'ads/get_active_ads.php' => 'GET /api/ads/get_active_ads.php',
    'bookings/create.php' => 'POST /api/bookings/create.php',
    'bookings/get_user_bookings.php' => 'GET /api/bookings/get_user_bookings.php',
    'favorites/toggle.php' => 'POST /api/favorites/toggle.php',
    'favorites/get_user_favorites.php' => 'GET /api/favorites/get_user_favorites.php',
    'reviews/create.php' => 'POST /api/reviews/create.php',
    'reviews/get_service_reviews.php' => 'GET /api/reviews/get_service_reviews.php',
    'users/get_profile.php' => 'GET /api/users/get_profile.php',
    'users/update_profile.php' => 'PUT /api/users/update_profile.php',
    'provider/get_dashboard.php' => 'GET /api/provider/get_dashboard.php',
    'provider/get_services.php' => 'GET /api/provider/get_services.php',
    'admin/get_dashboard.php' => 'GET /api/admin/get_dashboard.php',
    'admin/get_users.php' => 'GET /api/admin/get_users.php',
    'notifications/get_user_notifications.php' => 'GET /api/notifications/get_user_notifications.php',
    'notifications/mark_as_read.php' => 'PUT /api/notifications/mark_as_read.php',
];

foreach ($basic_endpoints as $filepath => $description) {
    $full_path = "api/{$filepath}";
    $exists = file_exists($full_path);
    
    $results['endpoints'][] = [
        'filepath' => $full_path,
        'description' => $description,
        'exists' => $exists,
        'status' => $exists ? '✅ موجود' : '❌ مفقود'
    ];
}

// إحصائيات
$total = count($basic_endpoints);
$existing = 0;
$missing = 0;

foreach ($results['endpoints'] as $endpoint) {
    if ($endpoint['exists']) {
        $existing++;
    } else {
        $missing++;
    }
}

$results['summary'] = [
    'total' => $total,
    'existing' => $existing,
    'missing' => $missing,
    'completion_percentage' => round(($existing / $total) * 100, 2)
];

echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 