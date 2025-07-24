<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم إضافة تقييمات'], 403);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['service_id']) || !isset($input['booking_id']) || !isset($input['rating'])) {
    jsonResponse(['error' => 'جميع الحقول مطلوبة'], 400);
}

$serviceId = (int)$input['service_id'];
$bookingId = (int)$input['booking_id'];
$rating = (int)$input['rating'];
$comment = isset($input['comment']) ? validateInput($input['comment']) : '';

// التحقق من صحة البيانات
if ($rating < 1 || $rating > 5) {
    jsonResponse(['error' => 'التقييم يجب أن يكون بين 1 و 5'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من أن الحجز موجود ومكتمل
    $stmt = $pdo->prepare("
        SELECT id FROM bookings 
        WHERE id = ? AND user_id = ? AND service_id = ? AND status = 'completed'
    ");
    $stmt->execute([$bookingId, $token->user_id, $serviceId]);
    if (!$stmt->fetch()) {
        jsonResponse(['error' => 'الحجز غير موجود أو لم يكتمل بعد'], 404);
    }
    
    // التحقق من عدم وجود تقييم سابق
    $stmt = $pdo->prepare("
        SELECT id FROM reviews 
        WHERE user_id = ? AND service_id = ? AND booking_id = ?
    ");
    $stmt->execute([$token->user_id, $serviceId, $bookingId]);
    if ($stmt->fetch()) {
        jsonResponse(['error' => 'لديك تقييم لهذا الحجز بالفعل'], 400);
    }
    
    $pdo->beginTransaction();
    
    // إضافة التقييم
    $stmt = $pdo->prepare("
        INSERT INTO reviews (user_id, service_id, booking_id, rating, comment) 
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->execute([$token->user_id, $serviceId, $bookingId, $rating, $comment]);
    
    // تحديث إحصائيات التقييم للخدمة
    $stmt = $pdo->prepare("
        UPDATE services 
        SET rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE service_id = ?
        ),
        total_ratings = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE service_id = ?
        )
        WHERE id = ?
    ");
    $stmt->execute([$serviceId, $serviceId, $serviceId]);
    
    $pdo->commit();
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إضافة التقييم بنجاح'
    ]);
    
} catch (PDOException $e) {
    $pdo->rollBack();
    error_log("Add review error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إضافة التقييم'], 500);
}
?> 