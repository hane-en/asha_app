<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['email']) || !isset($input['reset_code']) || !isset($input['new_password'])) {
    jsonResponse(['error' => 'جميع الحقول مطلوبة'], 400);
}

$email = validateInput($input['email']);
$resetCode = validateInput($input['reset_code']);
$newPassword = $input['new_password'];

// التحقق من صحة البيانات
if (!validateEmail($email)) {
    jsonResponse(['error' => 'البريد الإلكتروني غير صالح'], 400);
}

if (strlen($newPassword) < 8) {
    jsonResponse(['error' => 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // البحث عن المستخدم والتحقق من رمز إعادة التعيين
    $stmt = $pdo->prepare("SELECT id, reset_code, reset_expiry FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        jsonResponse(['error' => 'البريد الإلكتروني غير موجود'], 404);
    }
    
    if ($user['reset_code'] !== $resetCode) {
        jsonResponse(['error' => 'رمز إعادة التعيين غير صحيح'], 400);
    }
    
    if (strtotime($user['reset_expiry']) < time()) {
        jsonResponse(['error' => 'رمز إعادة التعيين منتهي الصلاحية'], 400);
    }
    
    // تحديث كلمة المرور
    $hashedPassword = hashPassword($newPassword);
    $stmt = $pdo->prepare("UPDATE users SET password = ?, reset_code = NULL, reset_expiry = NULL WHERE id = ?");
    $stmt->execute([$hashedPassword, $user['id']]);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم تغيير كلمة المرور بنجاح'
    ]);
    
} catch (PDOException $e) {
    error_log("Reset password error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إعادة تعيين كلمة المرور'], 500);
}
?> 