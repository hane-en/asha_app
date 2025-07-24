<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم إنشاء الحجوزات'], 403);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['service_id']) || !isset($input['booking_date']) || !isset($input['booking_time'])) {
    jsonResponse(['error' => 'جميع الحقول مطلوبة'], 400);
}

$serviceId = (int)$input['service_id'];
$bookingDate = validateInput($input['booking_date']);
$bookingTime = validateInput($input['booking_time']);
$notes = isset($input['notes']) ? validateInput($input['notes']) : '';

// التحقق من صحة التاريخ
if (strtotime($bookingDate) < strtotime(date('Y-m-d'))) {
    jsonResponse(['error' => 'لا يمكن الحجز في تاريخ ماضي'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("
        SELECT s.*, u.id as provider_id 
        FROM services s 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.id = ? AND s.is_active = 1
    ");
    $stmt->execute([$serviceId]);
    $service = $stmt->fetch();
    
    if (!$service) {
        jsonResponse(['error' => 'الخدمة غير موجودة'], 404);
    }
    
    // التحقق من عدم وجود حجز في نفس الوقت
    $stmt = $pdo->prepare("
        SELECT id FROM bookings 
        WHERE service_id = ? AND booking_date = ? AND booking_time = ? AND status IN ('pending', 'confirmed')
    ");
    $stmt->execute([$serviceId, $bookingDate, $bookingTime]);
    if ($stmt->fetch()) {
        jsonResponse(['error' => 'هذا الموعد محجوز بالفعل'], 400);
    }
    
    // إنشاء الحجز
    $stmt = $pdo->prepare("
        INSERT INTO bookings (user_id, service_id, provider_id, booking_date, booking_time, total_price, notes) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        $token->user_id,
        $serviceId,
        $service['provider_id'],
        $bookingDate,
        $bookingTime,
        $service['price'],
        $notes
    ]);
    
    $bookingId = $pdo->lastInsertId();
    
    // إنشاء إشعار للمزود
    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, title, message, type) 
        VALUES (?, ?, ?, 'booking')
    ");
    $stmt->execute([
        $service['provider_id'],
        'حجز جديد',
        'لديك حجز جديد للخدمة: ' . $service['title'],
        'booking'
    ]);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إنشاء الحجز بنجاح',
        'booking_id' => $bookingId
    ]);
    
} catch (PDOException $e) {
    error_log("Create booking error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إنشاء الحجز'], 500);
}
?> 