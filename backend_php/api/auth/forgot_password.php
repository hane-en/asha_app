<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['email'])) {
    jsonResponse(['error' => 'البريد الإلكتروني مطلوب'], 400);
}

$email = validateInput($input['email']);

// التحقق من صحة البيانات
if (!validateEmail($email)) {
    jsonResponse(['error' => 'البريد الإلكتروني غير صالح'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // البحث عن المستخدم
    $stmt = $pdo->prepare("SELECT id, name FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();
    
    if (!$user) {
        jsonResponse(['error' => 'البريد الإلكتروني غير موجود'], 404);
    }
    
    // إنشاء رمز إعادة تعيين كلمة المرور
    $resetCode = rand(100000, 999999);
    $resetExpiry = date('Y-m-d H:i:s', strtotime('+1 hour'));
    
    // حفظ رمز إعادة التعيين (يمكن استخدام جدول منفصل أو حقل في جدول المستخدمين)
    $stmt = $pdo->prepare("UPDATE users SET reset_code = ?, reset_expiry = ? WHERE id = ?");
    $stmt->execute([$resetCode, $resetExpiry, $user['id']]);
    
    // إرسال رمز إعادة التعيين عبر البريد الإلكتروني
    // في التطبيق الحقيقي، استخدم مكتبة لإرسال البريد الإلكتروني
    $to = $email;
    $subject = "إعادة تعيين كلمة المرور - " . APP_NAME;
    $message = "مرحباً " . $user['name'] . ",\n\n";
    $message .= "رمز إعادة تعيين كلمة المرور الخاص بك هو: " . $resetCode . "\n\n";
    $message .= "هذا الرمز صالح لمدة ساعة واحدة فقط.\n";
    $message .= "إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني.\n\n";
    $message .= "شكراً لك,\n";
    $message .= APP_NAME;
    
    $headers = "From: noreply@" . $_SERVER['HTTP_HOST'] . "\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
    
    // mail($to, $subject, $message, $headers);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        'reset_code' => $resetCode // في التطبيق الحقيقي، لا ترسل الرمز في الاستجابة
    ]);
    
} catch (PDOException $e) {
    error_log("Forgot password error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إرسال رمز إعادة التعيين'], 500);
}
?> 