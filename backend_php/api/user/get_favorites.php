<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();
if ($token->user_type !== 'user') {
    jsonResponse(['error' => 'فقط المستخدمون يمكنهم الوصول للمفضلة'], 403);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;
    
    // جلب الخدمات المفضلة
    $sql = "
        SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone
        FROM favorites f
        JOIN services s ON f.service_id = s.id
        JOIN categories c ON s.category_id = c.id
        JOIN users u ON s.provider_id = u.id
        WHERE f.user_id = ? AND s.is_active = 1
        ORDER BY f.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$token->user_id, $limit, $offset]);
    $favorites = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "
        SELECT COUNT(*) as total 
        FROM favorites f
        JOIN services s ON f.service_id = s.id
        WHERE f.user_id = ? AND s.is_active = 1
    ";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute([$token->user_id]);
    $total = $stmt->fetch()['total'];
    
    jsonResponse([
        'success' => true,
        'data' => $favorites,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get favorites error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب المفضلة'], 500);
}
?> 