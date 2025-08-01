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
$rating = $input['rating'] ?? null;
$comment = $input['comment'] ?? '';

// التحقق من البيانات المطلوبة
if (!$userId || !$serviceId || !$rating) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'معرف المستخدم ومعرف الخدمة والتقييم مطلوبة'], JSON_UNESCAPED_UNICODE);
    exit();
}

// التحقق من صحة التقييم
if ($rating < 1 || $rating > 5) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'التقييم يجب أن يكون بين 1 و 5'], JSON_UNESCAPED_UNICODE);
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
    
    // التحقق من وجود حجز مكتمل للخدمة
    $bookingStmt = $pdo->prepare("
        SELECT id FROM bookings 
        WHERE user_id = ? AND service_id = ? AND status = 'completed'
    ");
    $bookingStmt->execute([$userId, $serviceId]);
    if (!$bookingStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'يجب أن تكون قد استخدمت الخدمة لتتمكن من تقييمها'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من عدم وجود تقييم مسبق
    $existingStmt = $pdo->prepare("SELECT id FROM reviews WHERE user_id = ? AND service_id = ?");
    $existingStmt->execute([$userId, $serviceId]);
    if ($existingStmt->fetch()) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'لقد قمت بتقييم هذه الخدمة مسبقاً'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // إنشاء التقييم
    $insertStmt = $pdo->prepare("
        INSERT INTO reviews (user_id, service_id, rating, comment, created_at) 
        VALUES (?, ?, ?, ?, NOW())
    ");
    
    $result = $insertStmt->execute([$userId, $serviceId, $rating, $comment]);
    
    if ($result) {
        $reviewId = $pdo->lastInsertId();
        
        // تحديث متوسط التقييم للخدمة
        $updateStmt = $pdo->prepare("
            UPDATE services 
            SET rating_avg = (
                SELECT AVG(rating) FROM reviews WHERE service_id = ?
            ),
            rating_count = (
                SELECT COUNT(*) FROM reviews WHERE service_id = ?
            )
            WHERE id = ?
        ");
        $updateStmt->execute([$serviceId, $serviceId, $serviceId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'تم إنشاء التقييم بنجاح',
            'data' => [
                'review_id' => $reviewId,
                'rating' => $rating,
                'comment' => $comment
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في إنشاء التقييم');
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