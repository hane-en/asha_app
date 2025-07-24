<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم إضافة خدمات للمفضلة'], 403);
}

$input = json_decode(file_get_contents('php://input'), true);

// التحقق من البيانات المطلوبة
if (!isset($input['service_id'])) {
    jsonResponse(['error' => 'معرف الخدمة مطلوب'], 400);
}

$serviceId = (int)$input['service_id'];

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    // التحقق من وجود الخدمة
    $stmt = $pdo->prepare("SELECT id FROM services WHERE id = ? AND is_active = 1");
    $stmt->execute([$serviceId]);
    if (!$stmt->fetch()) {
        jsonResponse(['error' => 'الخدمة غير موجودة'], 404);
    }
    
    // التحقق من عدم وجود الخدمة في المفضلة
    $stmt = $pdo->prepare("SELECT id FROM favorites WHERE user_id = ? AND service_id = ?");
    $stmt->execute([$token->user_id, $serviceId]);
    if ($stmt->fetch()) {
        jsonResponse(['error' => 'الخدمة موجودة بالفعل في المفضلة'], 400);
    }
    
    // إضافة الخدمة للمفضلة
    $stmt = $pdo->prepare("INSERT INTO favorites (user_id, service_id) VALUES (?, ?)");
    $stmt->execute([$token->user_id, $serviceId]);
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إضافة الخدمة للمفضلة بنجاح'
    ]);
    
} catch (PDOException $e) {
    error_log("Add to favorites error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في إضافة الخدمة للمفضلة'], 500);
}
?> 