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
    
    // التحقق من وجود token في headers
    $headers = getallheaders();
    $token = null;
    
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
        if (strpos($authHeader, 'Bearer ') === 0) {
            $token = substr($authHeader, 7);
        }
    }
    
    // إذا لم يكن هناك token، تحقق من وجود user_id في query parameters
    $userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    
    if (!$token && !$userId) {
        echo json_encode([
            'success' => true,
            'data' => [
                'is_authenticated' => false,
                'user' => null,
                'message' => 'المستخدم غير مسجل دخول'
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $user = null;
    
    if ($token) {
        // التحقق من صحة token (يمكن إضافة منطق JWT هنا)
        $tokenSql = "SELECT 
                        u.id,
                        u.name,
                        u.email,
                        u.phone,
                        u.user_type,
                        u.profile_image,
                        u.is_active,
                        u.created_at
                    FROM users u
                    WHERE u.id = ? AND u.is_active = 1";
        
        $tokenStmt = $pdo->prepare($tokenSql);
        $tokenStmt->execute([$token]); // في الواقع، يجب فك تشفير token أولاً
        $user = $tokenStmt->fetch();
    } elseif ($userId) {
        // التحقق من وجود المستخدم بواسطة ID
        $userSql = "SELECT 
                        id,
                        name,
                        email,
                        phone,
                        user_type,
                        profile_image,
                        is_active,
                        created_at
                    FROM users 
                    WHERE id = ? AND is_active = 1";
        
        $userStmt = $pdo->prepare($userSql);
        $userStmt->execute([$userId]);
        $user = $userStmt->fetch();
    }
    
    if ($user) {
        // تحويل البيانات
        $user['id'] = (int)$user['id'];
        $user['is_active'] = (bool)$user['is_active'];
        $user['created_at'] = date('Y-m-d H:i:s', strtotime($user['created_at']));
        
        echo json_encode([
            'success' => true,
            'data' => [
                'is_authenticated' => true,
                'user' => $user,
                'message' => 'المستخدم مسجل دخول'
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => true,
            'data' => [
                'is_authenticated' => false,
                'user' => null,
                'message' => 'المستخدم غير موجود أو غير نشط'
            ],
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    }
    
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