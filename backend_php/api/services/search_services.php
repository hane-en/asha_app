<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

if (!isset($_GET['q'])) {
    jsonResponse(['error' => 'كلمة البحث مطلوبة'], 400);
}

$query = validateInput($_GET['q']);

if (strlen($query) < 2) {
    jsonResponse(['error' => 'كلمة البحث يجب أن تكون حرفين على الأقل'], 400);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;
    
    // البحث في الخدمات
    $sql = "
        SELECT s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.is_active = 1 
        AND (s.title LIKE ? OR s.description LIKE ? OR c.name LIKE ? OR u.name LIKE ?)
        ORDER BY s.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $searchTerm = "%$query%";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$searchTerm, $searchTerm, $searchTerm, $searchTerm, $limit, $offset]);
    $services = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "
        SELECT COUNT(*) as total 
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE s.is_active = 1 
        AND (s.title LIKE ? OR s.description LIKE ? OR c.name LIKE ? OR u.name LIKE ?)
    ";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute([$searchTerm, $searchTerm, $searchTerm, $searchTerm]);
    $total = $stmt->fetch()['total'];
    
    jsonResponse([
        'success' => true,
        'data' => $services,
        'query' => $query,
        'count' => count($services),
        'total' => $total,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Search services error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في البحث'], 500);
}
?> 