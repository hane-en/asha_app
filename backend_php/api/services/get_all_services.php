<?php
// ملاحظة: يجب أن يكون الحقل is_active=1 في أي خدمة تضاف يدوياً حتى تظهر في التطبيق
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;
    
    // جلب جميع الخدمات
    $sql = "
        SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.is_active = 1
        ORDER BY s.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$limit, $offset]);
    $services = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "SELECT COUNT(*) as total FROM services WHERE is_active = 1";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute();
    $total = $stmt->fetch()['total'];
    
    jsonResponse([
        'success' => true,
        'data' => $services,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get all services error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الخدمات'], 500);
}
?> 