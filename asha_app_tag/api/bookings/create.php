<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

// التحقق من أن الطلب هو POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'طريقة الطلب غير مسموحة'], JSON_UNESCAPED_UNICODE);
    exit();
}

// قراءة البيانات المرسلة
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'بيانات غير صحيحة'], JSON_UNESCAPED_UNICODE);
    exit();
}

$userId = $input['user_id'] ?? null;
$serviceId = $input['service_id'] ?? null;
$bookingDate = $input['booking_date'] ?? null;
$bookingTime = $input['booking_time'] ?? null;
$notes = $input['notes'] ?? '';

// التحقق من البيانات المطلوبة
if (!$userId || !$serviceId || !$bookingDate) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'معرف المستخدم ومعرف الخدمة وتاريخ الحجز مطلوبة'], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // التحقق من وجود المستخدم
    $userStmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND is_active = 1");
    $userStmt->execute([$userId]);
    if (!$userStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'المستخدم غير موجود'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود الخدمة
    $serviceStmt = $pdo->prepare("SELECT id FROM services WHERE id = ? AND is_active = 1");
    $serviceStmt->execute([$serviceId]);
    if (!$serviceStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من عدم وجود حجز مسبق في نفس التاريخ والوقت
    $existingStmt = $pdo->prepare("
        SELECT id FROM bookings 
        WHERE service_id = ? AND booking_date = ? AND booking_time = ? 
        AND status IN ('pending', 'confirmed')
    ");
    $existingStmt->execute([$serviceId, $bookingDate, $bookingTime]);
    if ($existingStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'هذا الموعد محجوز مسبقاً'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // إنشاء الحجز
    $insertStmt = $pdo->prepare("
        INSERT INTO bookings (user_id, service_id, booking_date, booking_time, notes, status, created_at) 
        VALUES (?, ?, ?, ?, ?, 'pending', NOW())
    ");
    
    $result = $insertStmt->execute([$userId, $serviceId, $bookingDate, $bookingTime, $notes]);
    
    if ($result) {
        $bookingId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'تم إنشاء الحجز بنجاح',
            'data' => [
                'booking_id' => $bookingId,
                'status' => 'pending'
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في إنشاء الحجز');
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?>

