<?php
/**
 * ملف اختبار تسجيل الدخول
 * للتحقق من أن تسجيل الدخول يعمل بشكل صحيح
 */

require_once 'config.php';
require_once 'auth.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$result = [
    'success' => true,
    'message' => 'Login test completed',
    'timestamp' => date('Y-m-d H:i:s'),
    'tests' => []
];

try {
    $auth = new Auth();
    
    // اختبار تسجيل دخول صحيح
    $loginResult = $auth->login('salma12@gmail.com', 'Salmaaaaa1');
    
    if ($loginResult) {
        $result['tests']['correct_login'] = [
            'status' => 'success',
            'message' => 'Correct login successful',
            'user_id' => $loginResult['user']['id'],
            'user_type' => $loginResult['user']['user_type'],
            'token' => substr($loginResult['token'], 0, 50) . '...'
        ];
    } else {
        $result['tests']['correct_login'] = [
            'status' => 'error',
            'message' => 'Correct login failed'
        ];
    }
    
    // اختبار تسجيل دخول خاطئ
    try {
        $wrongLogin = $auth->login('wrong@email.com', 'wrongpassword');
        $result['tests']['wrong_login'] = [
            'status' => 'error',
            'message' => 'Wrong login should have failed but succeeded'
        ];
    } catch (Exception $e) {
        $result['tests']['wrong_login'] = [
            'status' => 'success',
            'message' => 'Wrong login correctly failed: ' . $e->getMessage()
        ];
    }
    
    // اختبار كلمة مرور خاطئة
    try {
        $wrongPassword = $auth->login('salma12@gmail.com', 'wrongpassword');
        $result['tests']['wrong_password'] = [
            'status' => 'error',
            'message' => 'Wrong password should have failed but succeeded'
        ];
    } catch (Exception $e) {
        $result['tests']['wrong_password'] = [
            'status' => 'success',
            'message' => 'Wrong password correctly failed: ' . $e->getMessage()
        ];
    }
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'Login test failed: ' . $e->getMessage();
    $result['tests']['error'] = [
        'status' => 'error',
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ];
}

// إرجاع النتيجة
echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 