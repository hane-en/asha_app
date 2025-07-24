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
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = ($page - 1) * $limit;
    
    // معاملات البحث
    $query = isset($_GET['q']) ? validateInput($_GET['q']) : '';
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $minPrice = isset($_GET['min_price']) ? (float)$_GET['min_price'] : null;
    $maxPrice = isset($_GET['max_price']) ? (float)$_GET['max_price'] : null;
    $userLat = isset($_GET['user_lat']) ? (float)$_GET['user_lat'] : null;
    $userLng = isset($_GET['user_lng']) ? (float)$_GET['user_lng'] : null;
    $maxDistance = isset($_GET['max_distance']) ? (float)$_GET['max_distance'] : 50; // بالكيلومترات
    $sortBy = isset($_GET['sort_by']) ? validateInput($_GET['sort_by']) : 'created_at';
    $sortOrder = isset($_GET['sort_order']) ? validateInput($_GET['sort_order']) : 'DESC';
    
    // التحقق من صحة معاملات الترتيب
    $allowedSortFields = ['price', 'rating', 'created_at', 'distance'];
    $allowedSortOrders = ['ASC', 'DESC'];
    
    if (!in_array($sortBy, $allowedSortFields)) {
        $sortBy = 'created_at';
    }
    if (!in_array(strtoupper($sortOrder), $allowedSortOrders)) {
        $sortOrder = 'DESC';
    }
    
    // بناء شروط البحث
    $whereConditions = ["s.is_active = 1"];
    $params = [];
    
    // البحث النصي
    if (!empty($query)) {
        $whereConditions[] = "(s.title LIKE ? OR s.description LIKE ? OR c.name LIKE ? OR u.name LIKE ?)";
        $searchTerm = "%$query%";
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
    }
    
    // فلترة حسب الفئة
    if ($categoryId) {
        $whereConditions[] = "s.category_id = ?";
        $params[] = $categoryId;
    }
    
    // فلترة حسب السعر
    if ($minPrice !== null) {
        $whereConditions[] = "s.price >= ?";
        $params[] = $minPrice;
    }
    if ($maxPrice !== null) {
        $whereConditions[] = "s.price <= ?";
        $params[] = $maxPrice;
    }
    
    $whereClause = implode(" AND ", $whereConditions);
    
    // بناء استعلام SQL مع حساب المسافة إذا كان الموقع متوفر
    $selectFields = "s.*, c.name as category_name, u.name as provider_name, u.phone as provider_phone";
    $orderBy = "s.$sortBy $sortOrder";
    
    if ($userLat !== null && $userLng !== null) {
        // إضافة حساب المسافة باستخدام صيغة Haversine
        $selectFields .= ", (
            6371 * acos(
                cos(radians(?)) * cos(radians(s.latitude)) * 
                cos(radians(s.longitude) - radians(?)) + 
                sin(radians(?)) * sin(radians(s.latitude))
            )
        ) as distance";
        $params[] = $userLat;
        $params[] = $userLng;
        $params[] = $userLat;
        
        // فلترة حسب المسافة
        $whereConditions[] = "s.latitude IS NOT NULL AND s.longitude IS NOT NULL";
        $whereConditions[] = "(
            6371 * acos(
                cos(radians(?)) * cos(radians(s.latitude)) * 
                cos(radians(s.longitude) - radians(?)) + 
                sin(radians(?)) * sin(radians(s.latitude))
            )
        ) <= ?";
        $params[] = $userLat;
        $params[] = $userLng;
        $params[] = $userLat;
        $params[] = $maxDistance;
        
        $whereClause = implode(" AND ", $whereConditions);
        
        // تحديث الترتيب إذا كان حسب المسافة
        if ($sortBy === 'distance') {
            $orderBy = "distance ASC";
        }
    }
    
    // جلب الخدمات
    $sql = "
        SELECT $selectFields
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE $whereClause 
        ORDER BY $orderBy
        LIMIT ? OFFSET ?
    ";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $services = $stmt->fetchAll();
    
    // جلب العدد الإجمالي
    $countSql = "
        SELECT COUNT(*) as total 
        FROM services s 
        JOIN categories c ON s.category_id = c.id 
        JOIN users u ON s.provider_id = u.id 
        WHERE $whereClause
    ";
    
    // إزالة معاملات LIMIT و OFFSET من المعاملات
    array_pop($params); // إزالة offset
    array_pop($params); // إزالة limit
    
    $stmt = $pdo->prepare($countSql);
    $stmt->execute($params);
    $total = $stmt->fetch()['total'];
    
    // إضافة معلومات إضافية للاستجابة
    $response = [
        'success' => true,
        'data' => $services,
        'count' => count($services),
        'total' => $total,
        'filters' => [
            'query' => $query,
            'category_id' => $categoryId,
            'min_price' => $minPrice,
            'max_price' => $maxPrice,
            'user_location' => $userLat && $userLng ? ['lat' => $userLat, 'lng' => $userLng] : null,
            'max_distance' => $maxDistance,
            'sort_by' => $sortBy,
            'sort_order' => $sortOrder
        ],
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ];
    
    jsonResponse($response);
    
} catch (PDOException $e) {
    error_log("Advanced search error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في البحث المتقدم'], 500);
}
?> 