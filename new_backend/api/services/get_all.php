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
    
    // معاملات البحث والتصفية
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $search = sanitizeInput($_GET['search'] ?? '');
    $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
    $limit = isset($_GET['limit']) ? min(50, max(1, (int)$_GET['limit'])) : 20;
    $offset = ($page - 1) * $limit;
    
    // بناء الاستعلام
    $whereConditions = ["s.is_active = 1"];
    $params = [];
    
    if ($categoryId) {
        $whereConditions[] = "s.category_id = ?";
        $params[] = $categoryId;
    }
    
    if ($search) {
        $whereConditions[] = "(s.title LIKE ? OR s.description LIKE ? OR c.name LIKE ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
        $params[] = $searchParam;
    }
    
    $whereClause = implode(' AND ', $whereConditions);
    
    // استعلام العد
    $countQuery = "SELECT COUNT(*) FROM services s 
                   LEFT JOIN categories c ON s.category_id = c.id 
                   WHERE $whereClause";
    $stmt = $pdo->prepare($countQuery);
    $stmt->execute($params);
    $totalCount = $stmt->fetchColumn();
    
    // استعلام البيانات
    $query = "SELECT s.*, c.name as category_name, u.name as provider_name,
                     (SELECT AVG(rating) FROM reviews WHERE service_id = s.id) as avg_rating,
                     (SELECT COUNT(*) FROM reviews WHERE service_id = s.id) as review_count,
                     (SELECT COUNT(*) FROM favorites WHERE service_id = s.id) as favorite_count
              FROM services s 
              LEFT JOIN categories c ON s.category_id = c.id
              LEFT JOIN users u ON s.provider_id = u.id
              WHERE $whereClause
              ORDER BY s.created_at DESC
              LIMIT ? OFFSET ?";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $services = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($services as &$service) {
        $service['avg_rating'] = $service['avg_rating'] ? round($service['avg_rating'], 1) : 0;
        $service['price'] = (float)$service['price'];
        $service['is_favorite'] = false; // سيتم تحديثه لاحقاً إذا كان المستخدم مسجل دخول
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الخدمات بنجاح',
        'data' => [
            'services' => $services,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total' => $totalCount,
                'total_pages' => ceil($totalCount / $limit)
            ]
        ]
    ]);
    
} catch (Exception $e) {
    logError('Get all services error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'خطأ في الخادم']);
}
?> 