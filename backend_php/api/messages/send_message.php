<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['receiver_id']) || !isset($input['message'])) {
    jsonResponse(['error' => 'معرف المستلم والرسالة مطلوبان'], 400);
}

$receiverId = (int)$input['receiver_id'];
$message = validateInput($input['message']);

// التحقق من صحة البيانات
if (strlen($message) < 1) {
    jsonResponse(['error' => 'الرسالة لا يمكن أن تكون فارغة'], 400);
}

if ($receiverId === $token->user_id) {
    jsonResponse(['error' => 'لا يمكنك إرسال رسالة لنفسك'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من وجود المستلم
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ? AND is_active = 1");
    $stmt->execute([$receiverId]);
    if (!$stmt->fetch()) {
        jsonResponse(['error' => 'المستلم غير موجود'], 404);
    }
    
    // إرسال الرسالة
    $stmt = $pdo->prepare("
        INSERT INTO messages (sender_id, receiver_id, message) 
        VALUES (?, ?, ?)
    ");
    $stmt->execute([$token->user_id, $receiverId, $message]);
    
    $messageId = $pdo->lastInsertId();
    
    // إنشاء إشعار للمستلم
    $stmt = $pdo->prepare("
        INSERT INTO notifications (user_id, title, message, type) 
        VALUES (?, ?, ?, 'system')
    ");
    $stmt->execute([
        $receiverId,
        'رسالة جديدة',
        'لديك رسالة جديدة من مستخدم آخر',
        'system'
    ]);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إرسال الرسالة بنجاح',
        'message_id' => $messageId
    ]);
    
} catch (PDOException $e) {
    error_log("Send message error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إرسال الرسالة'], 500);
}
?> 