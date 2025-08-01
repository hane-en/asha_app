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

// التحقق من البيانات المطلوبة
if (!$userId || !$serviceId) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'معرف المستخدم ومعرف الخدمة مطلوبان'], JSON_UNESCAPED_UNICODE);
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
    
    // التحقق من وجود المفضلة
    $favoriteStmt = $pdo->prepare("SELECT id FROM favorites WHERE user_id = ? AND service_id = ?");
    $favoriteStmt->execute([$userId, $serviceId]);
    $existingFavorite = $favoriteStmt->fetch();
    
    if ($existingFavorite) {
        // إزالة من المفضلة
        $deleteStmt = $pdo->prepare("DELETE FROM favorites WHERE user_id = ? AND service_id = ?");
        $result = $deleteStmt->execute([$userId, $serviceId]);
        
        if ($result) {
            echo json_encode([
                'success' => true,
                'message' => 'تم إزالة الخدمة من المفضلة',
                'data' => [
                    'is_favorite' => false,
                    'action' => 'removed'
                ],
                'timestamp' => date('Y-m-d H:i:s')
            ], JSON_UNESCAPED_UNICODE);
        } else {
            throw new Exception('فشل في إزالة الخدمة من المفضلة');
        }
    } else {
        // إضافة إلى المفضلة
        $insertStmt = $pdo->prepare("INSERT INTO favorites (user_id, service_id, created_at) VALUES (?, ?, NOW())");
        $result = $insertStmt->execute([$userId, $serviceId]);
        
        if ($result) {
            echo json_encode([
                'success' => true,
                'message' => 'تم إضافة الخدمة إلى المفضلة',
                'data' => [
                    'is_favorite' => true,
                    'action' => 'added'
                ],
                'timestamp' => date('Y-m-d H:i:s')
            ], JSON_UNESCAPED_UNICODE);
        } else {
            throw new Exception('فشل في إضافة الخدمة إلى المفضلة');
        }
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

