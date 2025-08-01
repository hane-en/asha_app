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
    
    $userId = (int)($input['user_id'] ?? 0);
    $verificationCode = sanitizeInput($input['verification_code'] ?? '');
    
    if ($userId <= 0 || empty($verificationCode)) {
        echo json_encode(['success' => false, 'message' => 'جميع الحقول مطلوبة']);
        exit;
    }
    
    $pdo = getDatabaseConnection();
    
    // التحقق من الكود
    $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ? AND verification_code = ? AND is_active = 1");
    $stmt->execute([$userId, $verificationCode]);
    $user = $stmt->fetch();
    
    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'كود التحقق غير صحيح']);
        exit;
    }
    
    // تحديث حالة التحقق
    $stmt = $pdo->prepare("UPDATE users SET is_verified = 1, verification_code = NULL, updated_at = NOW() WHERE id = ?");
    $stmt->execute([$userId]);
    
    // إنشاء token للمصادقة
    $token = generateJWT($user['id'], $user['user_type']);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم التحقق من الحساب بنجاح',
        'data' => [
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone'],
                'user_type' => $user['user_type'],
                'is_verified' => 1,
                'profile_image' => $user['profile_image']
            ],
            'token' => $token
        ]
    ]);
    
} catch (Exception $e) {
    logError('Verify error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 