<?php
/**
 * جلب التقييمات لخدمة معينة
 * Get reviews for a specific service
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';

// التعامل مع طلب OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // التحقق من وجود معرف الخدمة
    if (!isset($_GET['service_id'])) {
        throw new Exception('Service ID is required');
    }
    
    $service_id = $_GET['service_id'];
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = isset($_GET['limit']) ? max(1, min(50, intval($_GET['limit']))) : 10;
    $offset = ($page - 1) * $limit;
    
    // الحصول على معرف المستخدم (اختياري)
    $user_id = null;
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
        $payload = json_decode(base64_decode($token), true);
        if ($payload && isset($payload['user_id'])) {
            $user_id = $payload['user_id'];
        }
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
    
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("SELECT id, title, provider_id FROM services WHERE id = ? AND is_active = 1");
    $stmt->execute([$service_id]);
    $service = $stmt->fetch();
    
    if (!$service) {
        throw new Exception('Service not found or inactive');
    }
    
    // جلب التقييمات
    $stmt = $pdo->prepare("
        SELECT 
            r.id,
            r.rating,
            r.comment,
            r.created_at,
            r.is_verified,
            u.id as user_id,
            u.name as user_name,
            u.profile_image as user_image
        FROM reviews r
        JOIN users u ON r.user_id = u.id
        WHERE r.service_id = ? AND r.is_verified = 1
        ORDER BY r.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute([$service_id, $limit, $offset]);
    $reviews = $stmt->fetchAll();
    
    // جلب إحصائيات التقييمات
    $stmt = $pdo->prepare("
        SELECT 
            COUNT(*) as total_reviews,
            AVG(rating) as average_rating,
            COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
            COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
            COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
            COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
            COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
        FROM reviews 
        WHERE service_id = ? AND is_verified = 1
    ");
    $stmt->execute([$service_id]);
    $stats = $stmt->fetch();
    
    // جلب إجمالي عدد التقييمات
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM reviews WHERE service_id = ? AND is_verified = 1");
    $stmt->execute([$service_id]);
    $total_reviews = $stmt->fetch()['total'];
    
    // التحقق من أهلية المستخدم للتعليق (إذا كان مسجل دخول)
    $user_eligibility = null;
    if ($user_id) {
        // التحقق من وجود حجز مكتمل
        $stmt = $pdo->prepare("
            SELECT id, status, payment_status, created_at 
            FROM bookings 
            WHERE user_id = ? AND service_id = ? AND status = 'completed' AND payment_status = 'paid'
            ORDER BY created_at DESC 
            LIMIT 1
        ");
        $stmt->execute([$user_id, $service_id]);
        $booking = $stmt->fetch();
        
        // التحقق من وجود تقييم سابق
        $stmt = $pdo->prepare("
            SELECT id, rating, comment, created_at 
            FROM reviews 
            WHERE user_id = ? AND service_id = ?
        ");
        $stmt->execute([$user_id, $service_id]);
        $existing_review = $stmt->fetch();
        
        $user_eligibility = [
            'can_review' => false,
            'reason' => '',
            'booking_info' => $booking,
            'existing_review' => $existing_review
        ];
        
        if (!$booking) {
            $user_eligibility['reason'] = 'يجب عليك حجز الخدمة أولاً حتى تتمكن من التعليق والتقييم';
        } elseif ($existing_review) {
            $user_eligibility['reason'] = 'لقد قمت بتقييم هذه الخدمة مسبقاً';
        } else {
            $user_eligibility['can_review'] = true;
            $user_eligibility['reason'] = 'يمكنك التعليق والتقييم على هذه الخدمة';
        }
    }
    
    // إعداد الاستجابة
    $response = [
        'success' => true,
        'data' => [
            'service_id' => $service_id,
            'reviews' => $reviews,
            'stats' => [
                'total_reviews' => intval($stats['total_reviews']),
                'average_rating' => round(floatval($stats['average_rating']), 1),
                'rating_distribution' => [
                    'five_star' => intval($stats['five_star']),
                    'four_star' => intval($stats['four_star']),
                    'three_star' => intval($stats['three_star']),
                    'two_star' => intval($stats['two_star']),
                    'one_star' => intval($stats['one_star'])
                ]
            ],
            'pagination' => [
                'current_page' => $page,
                'total_pages' => ceil($total_reviews / $limit),
                'total_reviews' => $total_reviews,
                'limit' => $limit
            ],
            'user_eligibility' => $user_eligibility
        ]
    ];
    
    echo json_encode($response);
    
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