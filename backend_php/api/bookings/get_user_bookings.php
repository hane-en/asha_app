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
    
    $status = isset($_GET['status']) ? validateInput($_GET['status']) : null;
    
    $whereConditions = ["b.user_id = ?"];
    $params = [$token->user_id];
    
    if ($status) {
        $whereConditions[] = "b.status = ?";
        $params[] = $status;
    }
    
    $whereClause = implode(" AND ", $whereConditions);
    
    // جلب الحجوزات
    $sql = "
        SELECT b.*, s.title as service_title, s.price as service_price, 
               u.name as provider_name, u.phone as provider_phone,
               c.name as category_name
        FROM bookings b 
        JOIN services s ON b.service_id = s.id 
        JOIN users u ON b.provider_id = u.id 
        JOIN categories c ON s.category_id = c.id 
        WHERE $whereClause 
        ORDER BY b.created_at DESC 
        LIMIT ? OFFSET ?
    ";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $bookings = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "SELECT COUNT(*) as total FROM bookings b WHERE $whereClause";
    $stmt = $pdo->prepare($countSql);
    $stmt->execute(array_slice($params, 0, -2));
    $total = $stmt->fetch()['total'];
    
    jsonResponse([
        'success' => true,
        'data' => $bookings,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get user bookings error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الحجوزات'], 500);
}
?> 