<?php
// ملف اختبار الـ APIs
header('Content-Type: application/json; charset=utf-8');

echo json_encode([
    'status' => 'success',
    'message' => 'Backend API يعمل بنجاح!',
    'timestamp' => date('Y-m-d H:i:s'),
    'available_apis' => [
        'auth' => [
            'POST /api/auth/register.php',
            'POST /api/auth/login.php',
            'POST /api/auth/provider_login.php',
            'POST /api/auth/admin_login.php'
        ],
        'services' => [
            'GET /api/services/get_categories.php',
            'GET /api/services/get_services.php',
            'GET /api/services/get_service_details.php'
        ],
        'bookings' => [
            'POST /api/bookings/create_booking.php',
            'GET /api/bookings/get_user_bookings.php'
        ],
        'admin' => [
            'GET /api/admin/get_dashboard_stats.php',
            'GET/PUT /api/admin/manage_provider_requests.php'
        ]
    ]
], JSON_UNESCAPED_UNICODE);
?> 