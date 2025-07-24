<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();

$input = json_decode(file_get_contents('php://input'), true);

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    if (isset($input['notification_id'])) {
        // تحديد إشعار واحد كمقروء
        $notificationId = (int)$input['notification_id'];
        
        $stmt = $pdo->prepare("
            UPDATE notifications 
            SET is_read = 1 
            WHERE id = ? AND user_id = ?
        ");
        $stmt->execute([$notificationId, $token->user_id]);
        
        if ($stmt->rowCount() === 0) {
            jsonResponse(['error' => 'الإشعار غير موجود'], 404);
        }
        
        jsonResponse([
            'success' => true,
            'message' => 'تم تحديد الإشعار كمقروء'
        ]);
        
    } else {
        // تحديد جميع الإشعارات كمقروءة
        $stmt = $pdo->prepare("
            UPDATE notifications 
            SET is_read = 1 
            WHERE user_id = ? AND is_read = 0
        ");
        $stmt->execute([$token->user_id]);
        
        jsonResponse([
            'success' => true,
            'message' => 'تم تحديد جميع الإشعارات كمقروءة'
        ]);
    }
    
} catch (PDOException $e) {
    error_log("Mark as read error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في تحديث حالة الإشعارات'], 500);
}
?> 