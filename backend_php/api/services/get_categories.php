<?php
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
    // جلب جميع الفئات النشطة
    $sql = "
        SELECT c.*, COUNT(s.id) as services_count
        FROM categories c 
        LEFT JOIN services s ON c.id = s.category_id AND s.is_active = 1
        WHERE c.is_active = 1
        GROUP BY c.id
        ORDER BY c.name ASC
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $categories = $stmt->fetchAll();
    
    jsonResponse([
        'success' => true,
        'data' => $categories,
        'count' => count($categories)
    ]);
    
} catch (PDOException $e) {
    error_log("Get categories error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الفئات'], 500);
}
?> 