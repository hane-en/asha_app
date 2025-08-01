<?php
/**
 * إضافة تقييم جديد لخدمة معينة
 * Add new review for a service
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';

// التعامل مع طلب OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // قراءة البيانات المرسلة
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON data');
    }
    
    // التحقق من البيانات المطلوبة
    $required_fields = ['user_id', 'service_id', 'rating'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Field '$field' is required");
        }
    }
    
    $user_id = $input['user_id'];
    $service_id = $input['service_id'];
    $rating = $input['rating'];
    $comment = $input['comment'] ?? '';
    
    // التحقق من صحة التقييم
    if (!is_numeric($rating) || $rating < 1 || $rating > 5) {
        throw new Exception('Rating must be between 1 and 5');
    }
    
    // الاتصال بقاعدة البيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET,
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // التحقق من وجود المستخدم
    $stmt = $pdo->prepare("SELECT id, name, user_type FROM users WHERE id = ? AND is_active = 1");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();
    
    if (!$user) {
        throw new Exception('User not found or inactive');
    }
    
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("SELECT id, title, provider_id FROM services WHERE id = ? AND is_active = 1");
    $stmt->execute([$service_id]);
    $service = $stmt->fetch();
    
    if (!$service) {
        throw new Exception('Service not found or inactive');
    }
    
    // التحقق من وجود حجز مكتمل للمستخدم على هذه الخدمة
    $stmt = $pdo->prepare("
        SELECT id, status, payment_status, created_at 
        FROM bookings 
        WHERE user_id = ? AND service_id = ? AND status = 'completed' AND payment_status = 'paid'
        ORDER BY created_at DESC 
        LIMIT 1
    ");
    $stmt->execute([$user_id, $service_id]);
    $booking = $stmt->fetch();
    
    if (!$booking) {
        throw new Exception('يجب عليك حجز الخدمة أولاً حتى تتمكن من التعليق والتقييم');
    }
    
    // التحقق من وجود تقييم سابق للمستخدم على هذه الخدمة
    $stmt = $pdo->prepare("
        SELECT id, rating, comment, created_at 
        FROM reviews 
        WHERE user_id = ? AND service_id = ?
    ");
    $stmt->execute([$user_id, $service_id]);
    $existing_review = $stmt->fetch();
    
    if ($existing_review) {
        throw new Exception('لقد قمت بتقييم هذه الخدمة مسبقاً');
    }
    
    // بدء المعاملة
    $pdo->beginTransaction();
    
    try {
        // إضافة التقييم الجديد
        $stmt = $pdo->prepare("
            INSERT INTO reviews (user_id, service_id, provider_id, rating, comment, is_verified) 
            VALUES (?, ?, ?, ?, ?, 1)
        ");
        $stmt->execute([$user_id, $service_id, $service['provider_id'], $rating, $comment]);
        
        $review_id = $pdo->lastInsertId();
        
        // تحديث متوسط التقييم للخدمة
        $stmt = $pdo->prepare("
            UPDATE services 
            SET rating = (
                SELECT AVG(rating) 
                FROM reviews 
                WHERE service_id = ? AND is_verified = 1
            ),
            total_ratings = (
                SELECT COUNT(*) 
                FROM reviews 
                WHERE service_id = ? AND is_verified = 1
            )
            WHERE id = ?
        ");
        $stmt->execute([$service_id, $service_id, $service_id]);
        
        // تحديث متوسط التقييم لمزود الخدمة
        $stmt = $pdo->prepare("
            UPDATE users 
            SET rating = (
                SELECT AVG(s.rating) 
                FROM services s 
                WHERE s.provider_id = ? AND s.is_active = 1
            ),
            review_count = (
                SELECT COUNT(r.id) 
                FROM reviews r 
                JOIN services s ON r.service_id = s.id 
                WHERE s.provider_id = ? AND r.is_verified = 1
            )
            WHERE id = ?
        ");
        $stmt->execute([$service['provider_id'], $service['provider_id'], $service['provider_id']]);
        
        // إرسال إشعار لمزود الخدمة
        $stmt = $pdo->prepare("
            INSERT INTO notifications (user_id, title, message, type, data) 
            VALUES (?, ?, ?, 'review', ?)
        ");
        $notification_data = [
            'review_id' => $review_id,
            'service_id' => $service_id,
            'rating' => $rating,
            'reviewer_name' => $user['name']
        ];
        $stmt->execute([
            $service['provider_id'],
            'تقييم جديد لخدمتك',
            "حصلت على تقييم جديد من {$user['name']} على خدمة {$service['title']}",
            json_encode($notification_data)
        ]);
        
        // تأكيد المعاملة
        $pdo->commit();
        
        // جلب التقييم المُنشأ
        $stmt = $pdo->prepare("
            SELECT r.*, u.name as user_name, u.profile_image as user_image
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            WHERE r.id = ?
        ");
        $stmt->execute([$review_id]);
        $review = $stmt->fetch();
        
        // إرسال الاستجابة
        echo json_encode([
            'success' => true,
            'message' => 'تم إضافة التقييم بنجاح',
            'data' => [
                'review' => $review,
                'booking_info' => $booking
            ]
        ]);
        
    } catch (Exception $e) {
        // التراجع عن المعاملة في حالة حدوث خطأ
        $pdo->rollBack();
        throw $e;
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
?> 