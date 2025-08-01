<?php
require_once '../../config.php';

header('Content-Type: application/json; charset=utf-8');
setupCORS();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    $pdo = getDatabaseConnection();
    
    $query = "SELECT c.*, 
                     (SELECT COUNT(*) FROM services WHERE category_id = c.id AND is_active = 1) as services_count
              FROM categories c 
              WHERE c.is_active = 1 
              ORDER BY c.sort_order ASC, c.name ASC";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الفئات بنجاح',
        'data' => [
            'categories' => $categories
        ]
    ]);
    
} catch (Exception $e) {
    logError('Get all categories error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 