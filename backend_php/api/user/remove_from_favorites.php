<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم حذف خدمات من المفضلة'], 403);
}

$serviceId = isset($_GET['service_id']) ? (int)$_GET['service_id'] : 0;

if (!$serviceId) {
    jsonResponse(['error' => 'معرف الخدمة مطلوب'], 400);
}

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
        'message' => 'تم حذف الخدمة من المفضلة بنجاح'
    ]);
    
} catch (PDOException $e) {
    error_log("Remove from favorites error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في حذف الخدمة من المفضلة'], 500);
}
?> 