<?php
/**
 * API endpoint لجلب جميع الحجوزات
 * GET /api/bookings/get_all.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config.php';
require_once '../../database.php';

try {
    $database = new Database();
    $database->connect();
    
    // جلب جميع الحجوزات مع معلومات الخدمة والمستخدم
    $query = "SELECT 
                b.id, b.service_id, b.user_id, b.booking_date, b.status, b.total_amount,
                b.created_at, b.updated_at,
                s.title as service_title,
                u.name as user_name,
                p.name as provider_name
              FROM bookings b
              LEFT JOIN services s ON b.service_id = s.id
              LEFT JOIN users u ON b.user_id = u.id
              LEFT JOIN users p ON s.provider_id = p.id
              ORDER BY b.created_at DESC";
    
    // إضافة debug
    error_log("Executing bookings query: " . $query);
    
    $bookings = $database->select($query);
    
    if ($bookings === false) {
        throw new Exception('خطأ في جلب الحجوزات من قاعدة البيانات');
    }
    
    // إضافة debug
    error_log("Bookings found: " . count($bookings));
    
    // تحويل البيانات إلى التنسيق المطلوب
    $formattedBookings = [];
    foreach ($bookings as $booking) {
        $formattedBookings[] = [
            'id' => (int)$booking['id'],
            'service_id' => (int)$booking['service_id'],
            'user_id' => (int)$booking['user_id'],
            'booking_date' => $booking['booking_date'],
            'status' => $booking['status'],
            'total_amount' => (float)$booking['total_amount'],
            'service_title' => $booking['service_title'],
            'user_name' => $booking['user_name'],
            'provider_name' => $booking['provider_name'],
            'created_at' => $booking['created_at'],
            'updated_at' => $booking['updated_at']
        ];
    }
    
    $response = [
        'success' => true,
        'message' => 'تم جلب الحجوزات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $formattedBookings,
        'count' => count($formattedBookings)
    ];
    
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $errorResponse = [
        'success' => false,
        'message' => 'خطأ في جلب الحجوزات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [],
        'count' => 0
    ];
    
    http_response_code(500);
    echo json_encode($errorResponse, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
?> 