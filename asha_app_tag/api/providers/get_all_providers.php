<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // معاملات الفلترة
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
    $search = isset($_GET['search']) ? trim($_GET['search']) : '';
    $sortBy = isset($_GET['sort_by']) ? $_GET['sort_by'] : 'rating';
    $sortOrder = isset($_GET['sort_order']) ? $_GET['sort_order'] : 'DESC';
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    // بناء الاستعلام الأساسي
    $baseQuery = "SELECT DISTINCT
                    u.id,
                    u.name,
                    u.email,
                    u.phone,
                    u.address,
                    'default_avatar.jpg' as profile_image,
                    u.rating,
                    u.total_reviews,
                    u.is_verified,
                    u.created_at,
                    u.user_type,
                    COUNT(s.id) as services_count,
                    AVG(r.rating) as avg_service_rating,
                    AVG(s.price) as avg_price,
                    COUNT(DISTINCT b.id) as total_bookings,
                    MIN(s.price) as min_price,
                    MAX(s.price) as max_price,
                    COUNT(DISTINCT r.id) as total_reviews_count,
                    AVG(r.rating) as avg_review_rating,
                    GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') as categories
                   FROM users u
                   LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
                   LEFT JOIN categories c ON s.category_id = c.id
                   LEFT JOIN bookings b ON s.id = b.service_id AND b.status != 'cancelled'
                   LEFT JOIN reviews r ON s.id = r.service_id
                   WHERE u.user_type = 'provider' AND u.is_active = 1";
    
    $params = [];
    
    // إضافة فلترة الفئة إذا تم تحديدها
    if ($categoryId) {
        $baseQuery .= " AND s.category_id = ?";
        $params[] = $categoryId;
    }
    
    // إضافة فلترة البحث إذا تم تحديدها
    if ($search) {
        $baseQuery .= " AND (u.name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)";
        $searchParam = "%$search%";
        $params[] = $searchParam;
        $params[] = $searchParam;
        $params[] = $searchParam;
    }
    
    $baseQuery .= " GROUP BY u.id, u.name, u.email, u.phone, u.address, 
                           u.rating, u.total_reviews, u.is_verified, u.created_at, u.user_type";
    
    // إضافة الترتيب
    $orderBy = match($sortBy) {
        'name' => 'u.name',
        'rating' => 'avg_service_rating',
        'services' => 'services_count',
        'price' => 'avg_price',
        'bookings' => 'total_bookings',
        'reviews' => 'total_reviews_count',
        'created' => 'u.created_at',
        default => 'avg_service_rating'
    };
    
    $baseQuery .= " ORDER BY $orderBy $sortOrder";
    
    // إضافة الحد والتحويل
    $baseQuery .= " LIMIT ? OFFSET ?";
    $params[] = $limit;
    $params[] = $offset;
    
    // تنفيذ الاستعلام
    $stmt = $pdo->prepare($baseQuery);
    $stmt->execute($params);
    $providers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // جلب العدد الإجمالي للمزودين (للصفحات)
    $countQuery = "SELECT COUNT(DISTINCT u.id) as total
                   FROM users u
                   LEFT JOIN services s ON u.id = s.provider_id AND s.is_active = 1
                   WHERE u.user_type = 'provider' AND u.is_active = 1";
    
    $countParams = [];
    
    if ($categoryId) {
        $countQuery .= " AND s.category_id = ?";
        $countParams[] = $categoryId;
    }
    
    if ($search) {
        $countQuery .= " AND (u.name LIKE ? OR u.email LIKE ? OR u.phone LIKE ?)";
        $searchParam = "%$search%";
        $countParams[] = $searchParam;
        $countParams[] = $searchParam;
        $countParams[] = $searchParam;
    }
    
    $countStmt = $pdo->prepare($countQuery);
    $countStmt->execute($countParams);
    $totalCount = $countStmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    // تحويل البيانات وتحسينها
    foreach ($providers as &$provider) {
        $provider['rating'] = (float)$provider['rating'];
        $provider['total_reviews'] = (int)$provider['total_reviews'];
        $provider['services_count'] = (int)$provider['services_count'];
        $provider['avg_service_rating'] = (float)$provider['avg_service_rating'];
        $provider['avg_price'] = (float)$provider['avg_price'];
        $provider['total_bookings'] = (int)$provider['total_bookings'];
        $provider['min_price'] = (float)$provider['min_price'];
        $provider['max_price'] = (float)$provider['max_price'];
        $provider['total_reviews_count'] = (int)$provider['total_reviews_count'];
        $provider['avg_review_rating'] = (float)$provider['avg_review_rating'];
        $provider['is_verified'] = (bool)$provider['is_verified'];
        
        // إضافة تقييم افتراضي إذا لم يكن موجوداً
        if ($provider['avg_service_rating'] == 0) {
            $provider['avg_service_rating'] = $provider['rating'] > 0 ? $provider['rating'] : 4.0;
        }
        
        // إضافة سعر افتراضي إذا لم يكن موجوداً
        if ($provider['avg_price'] == 0) {
            $provider['avg_price'] = 100.0;
        }
        
        // إضافة تقييم المراجعات إذا لم يكن موجوداً
        if ($provider['avg_review_rating'] == 0) {
            $provider['avg_review_rating'] = $provider['avg_service_rating'];
        }
        
        // إضافة معلومات إضافية
        $provider['price_range'] = [
            'min' => $provider['min_price'],
            'max' => $provider['max_price'],
            'avg' => $provider['avg_price']
        ];
        
        $provider['rating_info'] = [
            'overall_rating' => $provider['avg_service_rating'],
            'review_rating' => $provider['avg_review_rating'],
            'total_reviews' => $provider['total_reviews_count'],
            'total_bookings' => $provider['total_bookings']
        ];
        
        // تقسيم الفئات إلى مصفوفة
        $provider['categories'] = $provider['categories'] ? explode(', ', $provider['categories']) : [];
    }
    
    // تجهيز البيانات للإرسال
    $response = [
        'success' => true,
        'message' => 'تم جلب مزودي الخدمات بنجاح',
        'data' => [
            'providers' => $providers,
            'total_providers' => (int)$totalCount,
            'filters' => [
                'category_id' => $categoryId,
                'search' => $search,
                'sort_by' => $sortBy,
                'sort_order' => $sortOrder,
                'limit' => $limit,
                'offset' => $offset
            ],
            'pagination' => [
                'current_page' => floor($offset / $limit) + 1,
                'total_pages' => ceil($totalCount / $limit),
                'has_next' => ($offset + $limit) < $totalCount,
                'has_prev' => $offset > 0
            ]
        ],
        'total' => (int)$totalCount
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في جلب مزودي الخدمات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 