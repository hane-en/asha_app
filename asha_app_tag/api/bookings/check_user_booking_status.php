<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $serviceId = isset($_GET['service_id']) ? (int)$_GET['service_id'] : null;
    
    if (!$userId || !$serviceId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'معرف المستخدم ومعرف الخدمة مطلوبان'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود المستخدم
    $userSql = "SELECT id, name FROM users WHERE id = ? AND is_active = 1";
    $userStmt = $pdo->prepare($userSql);
    $userStmt->execute([$userId]);
    $user = $userStmt->fetch();
    
    if (!$user) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'المستخدم غير موجود'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // التحقق من وجود الخدمة
    $serviceSql = "SELECT id, title FROM services WHERE id = ? AND is_active = 1";
    $serviceStmt = $pdo->prepare($serviceSql);
    $serviceStmt->execute([$serviceId]);
    $service = $serviceStmt->fetch();
    
    if (!$service) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'الخدمة غير موجودة'], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // جلب حالة الحجز للمستخدم
    $bookingSql = "SELECT 
                        id,
                        status,
                        booking_date,
                        booking_time,
                        notes,
                        created_at,
                        updated_at
                    FROM bookings 
                    WHERE user_id = ? AND service_id = ?
                    ORDER BY created_at DESC
                    LIMIT 1";
    
    $bookingStmt = $pdo->prepare($bookingSql);
    $bookingStmt->execute([$userId, $serviceId]);
    $booking = $bookingStmt->fetch();
    
    $bookingStatus = null;
    if ($booking) {
        $bookingStatus = [
            'id' => (int)$booking['id'],
            'status' => $booking['status'],
            'booking_date' => $booking['booking_date'],
            'booking_time' => $booking['booking_time'],
            'notes' => $booking['notes'],
            'created_at' => date('Y-m-d H:i:s', strtotime($booking['created_at'])),
            'updated_at' => $booking['updated_at'] ? date('Y-m-d H:i:s', strtotime($booking['updated_at'])) : null
        ];
    }
    
    // التحقق من وجود تقييم للمستخدم
    $reviewSql = "SELECT 
                        id,
                        rating,
                        comment,
                        created_at
                    FROM reviews 
                    WHERE user_id = ? AND service_id = ?";
    
    $reviewStmt = $pdo->prepare($reviewSql);
    $reviewStmt->execute([$userId, $serviceId]);
    $review = $reviewStmt->fetch();
    
    $reviewStatus = null;
    if ($review) {
        $reviewStatus = [
            'id' => (int)$review['id'],
            'rating' => (int)$review['rating'],
            'comment' => $review['comment'],
            'created_at' => date('Y-m-d H:i:s', strtotime($review['created_at']))
        ];
    }
    
    // تحديد ما إذا كان يمكن للمستخدم التقييم
    $canReview = false;
    if ($bookingStatus && $bookingStatus['status'] === 'completed' && !$reviewStatus) {
        $canReview = true;
    }
    
    // تحديد ما إذا كان يمكن للمستخدم الحجز
    $canBook = true;
    if ($bookingStatus && in_array($bookingStatus['status'], ['pending', 'confirmed'])) {
        $canBook = false;
    }
    
    echo json_encode([
        'success' => true,
        'data' => [
            'user' => [
                'id' => (int)$user['id'],
                'name' => $user['name']
            ],
            'service' => [
                'id' => (int)$service['id'],
                'title' => $service['title']
            ],
            'booking_status' => $bookingStatus,
            'review_status' => $reviewStatus,
            'can_review' => $canReview,
            'can_book' => $canBook
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في الخادم: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?> 