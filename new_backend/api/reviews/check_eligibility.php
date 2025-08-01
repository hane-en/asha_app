<?php
/**
 * التحقق من أهلية المستخدم للتعليق على خدمة معينة
 * Check user eligibility to review a service
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    // الحصول على معرف المستخدم من الرأس أو المعامل
    $user_id = null;
    
    // التحقق من وجود معرف المستخدم في الرأس
    $headers = getallheaders();
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
        $payload = json_decode(base64_decode($token), true);
        if ($payload && isset($payload['user_id'])) {
            $user_id = $payload['user_id'];
        }
    }
    
    // إذا لم يتم العثور على معرف المستخدم في الرأس، تحقق من المعاملات
    if (!$user_id && isset($_GET['user_id'])) {
        $user_id = $_GET['user_id'];
    }
    
    if (!$user_id) {
        throw new Exception('User ID is required');
    }
    
    // التحقق من وجود معرف الخدمة
    if (!isset($_GET['service_id'])) {
        throw new Exception('Service ID is required');
    }
    
    $service_id = $_GET['service_id'];
    
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
    
    // التحقق من وجود تقييم سابق للمستخدم على هذه الخدمة
    $stmt = $pdo->prepare("
        SELECT id, rating, comment, created_at 
        FROM reviews 
        WHERE user_id = ? AND service_id = ?
    ");
    $stmt->execute([$user_id, $service_id]);
    $existing_review = $stmt->fetch();
    
    // إعداد الاستجابة
    $response = [
        'success' => true,
        'data' => [
            'user_id' => $user_id,
            'service_id' => $service_id,
            'can_review' => false,
            'reason' => '',
            'booking_info' => null,
            'existing_review' => null
        ]
    ];
    
    // التحقق من أهلية التعليق
    if (!$booking) {
        $response['data']['reason'] = 'يجب عليك حجز الخدمة أولاً حتى تتمكن من التعليق والتقييم';
        $response['data']['can_review'] = false;
    } elseif ($existing_review) {
        $response['data']['reason'] = 'لقد قمت بتقييم هذه الخدمة مسبقاً';
        $response['data']['can_review'] = false;
        $response['data']['existing_review'] = $existing_review;
    } else {
        $response['data']['can_review'] = true;
        $response['data']['reason'] = 'يمكنك التعليق والتقييم على هذه الخدمة';
        $response['data']['booking_info'] = $booking;
    }
    
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