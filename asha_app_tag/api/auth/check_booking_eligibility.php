<?php
/**
 * ملف التحقق من أهلية المستخدم للحجز
 */

require_once '../config.php';
require_once '../database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$response = [
    'success' => false,
    'message' => '',
    'data' => null
];

try {
    $database = new Database();
    $database->connect();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
        $service_id = isset($_GET['service_id']) ? intval($_GET['service_id']) : 0;
        
        if ($user_id <= 0) {
            throw new Exception('معرف المستخدم غير صحيح');
        }
        
        if ($service_id <= 0) {
            throw new Exception('معرف الخدمة غير صحيح');
        }
        
        // التحقق من وجود المستخدم
        $user_query = "SELECT id, name, email, phone, role, is_active FROM users WHERE id = ?";
        $user_stmt = $database->prepare($user_query);
        $user_stmt->bind_param('i', $user_id);
        $user_stmt->execute();
        $user_result = $user_stmt->get_result();
        
        if ($user_result->num_rows === 0) {
            throw new Exception('المستخدم غير موجود');
        }
        
        $user_data = $user_result->fetch_assoc();
        
        // التحقق من حالة المستخدم
        if (!$user_data['is_active']) {
            throw new Exception('الحساب غير نشط');
        }
        
        // التحقق من وجود الخدمة
        $service_query = "SELECT id, name, price, provider_id, is_active FROM services WHERE id = ?";
        $service_stmt = $database->prepare($service_query);
        $service_stmt->bind_param('i', $service_id);
        $service_stmt->execute();
        $service_result = $service_stmt->get_result();
        
        if ($service_result->num_rows === 0) {
            throw new Exception('الخدمة غير موجودة');
        }
        
        $service_data = $service_result->fetch_assoc();
        
        if (!$service_data['is_active']) {
            throw new Exception('الخدمة غير متاحة للحجز');
        }
        
        // التحقق من أن المستخدم لا يحجز خدمة لنفسه (إذا كان مزود خدمة)
        if ($user_data['role'] === 'provider' && $user_data['id'] == $service_data['provider_id']) {
            throw new Exception('لا يمكنك حجز خدمتك الخاصة');
        }
        
        // التحقق من وجود حجز سابق لنفس الخدمة
        $existing_booking_query = "SELECT id, status FROM bookings 
                                  WHERE user_id = ? AND service_id = ? 
                                  AND status IN ('pending', 'confirmed', 'in_progress')
                                  LIMIT 1";
        $existing_booking_stmt = $database->prepare($existing_booking_query);
        $existing_booking_stmt->bind_param('ii', $user_id, $service_id);
        $existing_booking_stmt->execute();
        $existing_booking_result = $existing_booking_stmt->get_result();
        
        $has_active_booking = $existing_booking_result->num_rows > 0;
        $existing_booking = null;
        
        if ($has_active_booking) {
            $existing_booking = $existing_booking_result->fetch_assoc();
        }
        
        // الحصول على معلومات المزود
        $provider_query = "SELECT id, name, phone, email FROM users WHERE id = ?";
        $provider_stmt = $database->prepare($provider_query);
        $provider_stmt->bind_param('i', $service_data['provider_id']);
        $provider_stmt->execute();
        $provider_result = $provider_stmt->get_result();
        $provider_data = $provider_result->fetch_assoc();
        
        $response['success'] = true;
        $response['message'] = 'تم التحقق من الأهلية بنجاح';
        $response['data'] = [
            'user' => [
                'id' => $user_data['id'],
                'name' => $user_data['name'],
                'email' => $user_data['email'],
                'phone' => $user_data['phone'],
                'role' => $user_data['role']
            ],
            'service' => [
                'id' => $service_data['id'],
                'name' => $service_data['name'],
                'price' => $service_data['price']
            ],
            'provider' => $provider_data,
            'can_book' => !$has_active_booking,
            'has_active_booking' => $has_active_booking,
            'existing_booking' => $existing_booking
        ];
        
    } else {
        throw new Exception('طريقة الطلب غير مدعومة');
    }
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 