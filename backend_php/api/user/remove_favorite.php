<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم حذف خدمات من المفضلة'], 403);
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
    // حذف الخدمة من المفضلة
    $stmt = $pdo->prepare("DELETE FROM favorites WHERE user_id = ? AND service_id = ?");
    $stmt->execute([$token->user_id, $serviceId]);
    
    if ($stmt->rowCount() === 0) {
        jsonResponse(['error' => 'الخدمة غير موجودة في المفضلة'], 404);
    }
    
    jsonResponse([
        'success' => true,
        'message' => 'تم حذف الخدمة من المفضلة بنجاح'
    ]);
    
} catch (PDOException $e) {
    error_log("Remove favorite error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في حذف الخدمة من المفضلة'], 500);
}
?> 