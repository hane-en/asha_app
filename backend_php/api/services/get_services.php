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
    
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $search = isset($_GET['search']) ? validateInput($_GET['search']) : null;
    
    $whereConditions = ["s.is_active = 1"];
    $params = [];
    
    if ($categoryId) {
        $whereConditions[] = "s.category_id = ?";
        $params[] = $categoryId;
    }
    
    if ($search) {
        $whereConditions[] = "(s.title LIKE ? OR s.description LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    
    $whereClause = implode(" AND ", $whereConditions);
    
    // جلب الخدمات
    $sql = "SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone 
            FROM services s 
            JOIN categories c ON s.category_id = c.id 
            JOIN users u ON s.provider_id = u.id 
            WHERE $whereClause 
            ORDER BY s.created_at DESC 
            LIMIT ? OFFSET ?";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $services = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "SELECT COUNT(*) as total FROM services s WHERE $whereClause";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute(array_slice($params, 0, -2));
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
    error_log("Get services error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الخدمات'], 500);
}
?> 