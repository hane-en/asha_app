<?php
/**
 * فحص شامل لجميع نقاط النهاية API
 * يتحقق من وجود الملفات وصحتها
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$audit_results = [
    'success' => true,
    'message' => 'فحص شامل لجميع نقاط النهاية API',
    'timestamp' => date('Y-m-d H:i:s'),
    'total_endpoints' => 0,
    'existing_endpoints' => 0,
    'missing_endpoints' => 0,
    'categories' => []
];

// قائمة جميع نقاط النهاية المطلوبة
$required_endpoints = [
    'auth' => [
        'login.php' => 'POST /api/auth/login.php',
        'register.php' => 'POST /api/auth/register.php',
        'verify.php' => 'POST /api/auth/verify.php',
        'forgot_password.php' => 'POST /api/auth/forgot_password.php',
        'reset_password.php' => 'POST /api/auth/reset_password.php',
        'delete_account.php' => 'POST /api/auth/delete_account.php',
    ],
    'services' => [
        'get_all.php' => 'GET /api/services/get_all.php',
        'get_by_id.php' => 'GET /api/services/get_by_id.php',
        'get_categories.php' => 'GET /api/services/get_categories.php',
        'search.php' => 'GET /api/services/search.php',
        'get_provider_services.php' => 'GET /api/services/get_provider_services.php',
        'create.php' => 'POST /api/services/create.php',
        'update.php' => 'PUT /api/services/update.php',
        'delete.php' => 'DELETE /api/services/delete.php',
    ],
    'categories' => [
        'get_all.php' => 'GET /api/categories/get_all.php',
        'get_by_id.php' => 'GET /api/categories/get_by_id.php',
    ],
    'bookings' => [
        'create.php' => 'POST /api/bookings/create.php',
        'get_user_bookings.php' => 'GET /api/bookings/get_user_bookings.php',
        'get_provider_bookings.php' => 'GET /api/bookings/get_provider_bookings.php',
        'update_status.php' => 'PUT /api/bookings/update_status.php',
        'cancel.php' => 'PUT /api/bookings/cancel.php',
    ],
    'favorites' => [
        'toggle.php' => 'POST /api/favorites/toggle.php',
        'get_user_favorites.php' => 'GET /api/favorites/get_user_favorites.php',
    ],
    'reviews' => [
        'create.php' => 'POST /api/reviews/create.php',
        'get_service_reviews.php' => 'GET /api/reviews/get_service_reviews.php',
        'get_user_reviews.php' => 'GET /api/reviews/get_user_reviews.php',
    ],
    'ads' => [
        'get_active_ads.php' => 'GET /api/ads/get_active_ads.php',
        'create.php' => 'POST /api/ads/create.php',
        'update.php' => 'PUT /api/ads/update.php',
        'delete.php' => 'DELETE /api/ads/delete.php',
    ],
    'users' => [
        'get_profile.php' => 'GET /api/users/get_profile.php',
        'update_profile.php' => 'PUT /api/users/update_profile.php',
        'get_provider_info.php' => 'GET /api/users/get_provider_info.php',
    ],
    'provider' => [
        'get_dashboard.php' => 'GET /api/provider/get_dashboard.php',
        'get_services.php' => 'GET /api/provider/get_services.php',
        'get_bookings.php' => 'GET /api/provider/get_bookings.php',
        'get_analytics.php' => 'GET /api/provider/get_analytics.php',
    ],
    'admin' => [
        'get_dashboard.php' => 'GET /api/admin/get_dashboard.php',
        'get_users.php' => 'GET /api/admin/get_users.php',
        'get_services.php' => 'GET /api/admin/get_services.php',
        'get_bookings.php' => 'GET /api/admin/get_bookings.php',
        'approve_service.php' => 'PUT /api/admin/approve_service.php',
        'delete_user.php' => 'DELETE /api/admin/delete_user.php',
        'delete_service.php' => 'DELETE /api/admin/delete_service.php',
    ],
    'notifications' => [
        'get_user_notifications.php' => 'GET /api/notifications/get_user_notifications.php',
        'mark_as_read.php' => 'PUT /api/notifications/mark_as_read.php',
        'send_notification.php' => 'POST /api/notifications/send_notification.php',
    ],
    'offers' => [
        'get_service_offers.php' => 'GET /api/offers/get_service_offers.php',
        'create.php' => 'POST /api/offers/create.php',
        'update.php' => 'PUT /api/offers/update.php',
        'delete.php' => 'DELETE /api/offers/delete.php',
    ],
];

// فحص كل فئة
foreach ($required_endpoints as $category => $endpoints) {
    $category_results = [
        'category' => $category,
        'total' => count($endpoints),
        'existing' => 0,
        'missing' => 0,
        'endpoints' => []
    ];
    
    foreach ($endpoints as $filename => $description) {
        $filepath = "api/{$category}/{$filename}";
        $exists = file_exists($filepath);
        
        $endpoint_info = [
            'filename' => $filename,
            'description' => $description,
            'exists' => $exists,
            'filepath' => $filepath
        ];
        
        if ($exists) {
            $category_results['existing']++;
            $audit_results['existing_endpoints']++;
        } else {
            $category_results['missing']++;
            $audit_results['missing_endpoints']++;
        }
        
        $category_results['endpoints'][] = $endpoint_info;
    }
    
    $audit_results['categories'][] = $category_results;
    $audit_results['total_endpoints'] += count($endpoints);
}

// إضافة ملخص
$audit_results['summary'] = [
    'total_endpoints' => $audit_results['total_endpoints'],
    'existing_endpoints' => $audit_results['existing_endpoints'],
    'missing_endpoints' => $audit_results['missing_endpoints'],
    'completion_percentage' => round(($audit_results['existing_endpoints'] / $audit_results['total_endpoints']) * 100, 2)
];

// فحص قاعدة البيانات
try {
    require_once 'config.php';
    require_once 'database.php';
    
    $database = new Database();
    $database->connect();
    
    // فحص الجداول المطلوبة
    $required_tables = [
        'users', 'categories', 'services', 'bookings', 
        'reviews', 'favorites', 'ads', 'notifications', 
        'offers', 'provider_requests', 'profile_update_requests'
    ];
    
    $database_audit = [
        'connection' => 'success',
        'tables' => []
    ];
    
    foreach ($required_tables as $table) {
        $query = "SHOW TABLES LIKE '$table'";
        $result = $database->select($query);
        $exists = !empty($result);
        
        if ($exists) {
            // فحص عدد السجلات
            $count_query = "SELECT COUNT(*) as count FROM $table";
            $count_result = $database->selectOne($count_query);
            $record_count = $count_result['count'] ?? 0;
        } else {
            $record_count = 0;
        }
        
        $database_audit['tables'][] = [
            'table' => $table,
            'exists' => $exists,
            'record_count' => $record_count
        ];
    }
    
    $audit_results['database'] = $database_audit;
    
} catch (Exception $e) {
    $audit_results['database'] = [
        'connection' => 'failed',
        'error' => $e->getMessage()
    ];
}

echo json_encode($audit_results, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 