<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;
    
    // جلب الإشعارات
    $sql = "
        SELECT id, title, message, type, is_read, created_at
        FROM notifications 
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$token->user_id, $limit, $offset]);
    $notifications = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "SELECT COUNT(*) as total FROM notifications WHERE user_id = ?";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute([$token->user_id]);
    $total = $stmt->fetch()['total'];
    
    // جلب عدد الإشعارات غير المقروءة
    $unreadSql = "SELECT COUNT(*) as unread FROM notifications WHERE user_id = ? AND is_read = 0";
    $stmt = $pdo->prepare($unreadSql);
    $stmt->execute([$token->user_id]);
    $unread = $stmt->fetch()['unread'];
    
    jsonResponse([
        'success' => true,
        'data' => $notifications,
        'unread_count' => $unread,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get notifications error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الإشعارات'], 500);
}
?> 