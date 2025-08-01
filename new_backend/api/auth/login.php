<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $identifier = sanitizeInput($input['identifier'] ?? '');
    $password = $input['password'] ?? '';
    $userType = sanitizeInput($input['user_type'] ?? 'user');
    
    if (empty($identifier) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'جميع الحقول مطلوبة']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    $stmt = $pdo->prepare("SELECT * FROM users WHERE (email = ? OR phone = ?) AND user_type = ? AND is_active = 1");
    $stmt->execute([$identifier, $identifier, $userType]);
    $user = $stmt->fetch();
    
    if ($user && password_verify($password, $user['password'])) {
        // إنشاء token للمصادقة
        $token = generateJWT($user['id'], $user['user_type']);
        
        echo json_encode([
            'success' => true,
            'message' => 'تم تسجيل الدخول بنجاح',
            'data' => [
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'phone' => $user['phone'],
                    'user_type' => $user['user_type'],
                    'is_verified' => $user['is_verified'],
                    'profile_image' => $user['profile_image'],
                    'created_at' => $user['created_at']
                ],
                'token' => $token
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'بيانات الدخول غير صحيحة']);
    }
    
} catch (Exception $e) {
    logError('Login error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 