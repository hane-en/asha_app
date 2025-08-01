<?php
/**
 * جلب جميع خدمات مزود معين
 * Get all services for a specific provider
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';

// التعامل مع طلب OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // التحقق من وجود معرف المزود
    if (!isset($_GET['provider_id'])) {
        throw new Exception('Provider ID is required');
    }
    
    $provider_id = intval($_GET['provider_id']);
    
    // معاملات التصفية والترتيب
    $category_id = isset($_GET['category_id']) ? intval($_GET['category_id']) : null;
    $status = isset($_GET['status']) ? $_GET['status'] : 'active'; // active, inactive, all
    $sort_by = isset($_GET['sort_by']) ? $_GET['sort_by'] : 'created_at'; // created_at, price, rating, title
    $sort_order = isset($_GET['sort_order']) ? $_GET['sort_order'] : 'DESC'; // ASC, DESC
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = isset($_GET['limit']) ? max(1, min(50, intval($_GET['limit']))) : 20;
    $offset = ($page - 1) * $limit;
    
    // التحقق من صحة معاملات الترتيب
    $allowed_sort_fields = ['created_at', 'price', 'rating', 'title', 'booking_count'];
    if (!in_array($sort_by, $allowed_sort_fields)) {
        $sort_by = 'created_at';
    }
    
    if (!in_array(strtoupper($sort_order), ['ASC', 'DESC'])) {
        $sort_order = 'DESC';
    }
    
    // الاتصال بقاعدة البيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET,
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // التحقق من وجود المزود
    $stmt = $pdo->prepare("SELECT id, name, user_type FROM users WHERE id = ? AND user_type = 'provider' AND is_active = 1");
    $stmt->execute([$provider_id]);
    $provider = $stmt->fetch();
    
    if (!$provider) {
        throw new Exception('Provider not found or inactive');
    }
    
    // بناء استعلام SQL
    $where_conditions = ['s.provider_id = ?'];
    $params = [$provider_id];
    
    // إضافة فلتر الفئة
    if ($category_id) {
        $where_conditions[] = 's.category_id = ?';
        $params[] = $category_id;
    }
    
    // إضافة فلتر الحالة
    if ($status === 'active') {
        $where_conditions[] = 's.is_active = 1';
    } elseif ($status === 'inactive') {
        $where_conditions[] = 's.is_active = 0';
    }
    // إذا كان 'all' فلا نضيف فلتر الحالة
    
    $where_clause = implode(' AND ', $where_conditions);
    
    // استعلام جلب الخدمات
    $sql = "
        SELECT 
            s.*,
            c.title as category_name,
            c.description as category_description,
            u.name as provider_name,
            u.rating as provider_rating,
            u.profile_image as provider_image,
            COUNT(DISTINCT b.id) as total_bookings,
            COUNT(DISTINCT r.id) as total_reviews,
            AVG(r.rating) as average_rating
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        LEFT JOIN bookings b ON s.id = b.service_id AND b.status IN ('confirmed', 'completed')
        LEFT JOIN reviews r ON s.id = r.service_id AND r.is_verified = 1
        WHERE $where_clause
        GROUP BY s.id
        ORDER BY s.$sort_by $sort_order
        LIMIT ? OFFSET ?
    ";
    
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $services = $stmt->fetchAll();
    
    // جلب إجمالي عدد الخدمات
    $count_sql = "
        SELECT COUNT(*) as total
        FROM services s
        WHERE $where_clause
    ";
    
    $stmt = $pdo->prepare($count_sql);
    $stmt->execute(array_slice($params, 0, -2)); // إزالة LIMIT و OFFSET
    $total_count = $stmt->fetch()['total'];
    
    // معالجة البيانات
    foreach ($services as &$service) {
        // تحويل الصور من JSON إلى مصفوفة
        if (isset($service['images']) && is_string($service['images'])) {
            $service['images'] = json_decode($service['images'], true) ?: [];
        } else {
            $service['images'] = [];
        }
        
        // تحويل المواصفات من JSON
        if (isset($service['specifications']) && is_string($service['specifications'])) {
            $service['specifications'] = json_decode($service['specifications'], true) ?: null;
        }
        
        // تحويل الكلمات المفتاحية من JSON
        if (isset($service['tags']) && is_string($service['tags'])) {
            $service['tags'] = json_decode($service['tags'], true) ?: [];
        } else {
            $service['tags'] = [];
        }
        
        // تحويل التوفر من JSON
        if (isset($service['availability']) && is_string($service['availability'])) {
            $service['availability'] = json_decode($service['availability'], true) ?: null;
        }
        
        // تحويل شروط الدفع من JSON
        if (isset($service['payment_terms']) && is_string($service['payment_terms'])) {
            $service['payment_terms'] = json_decode($service['payment_terms'], true) ?: null;
        }
        
        // تحويل القيم الرقمية
        $service['id'] = intval($service['id']);
        $service['provider_id'] = intval($service['provider_id']);
        $service['category_id'] = intval($service['category_id']);
        $service['price'] = floatval($service['price']);
        $service['original_price'] = $service['original_price'] ? floatval($service['original_price']) : null;
        $service['duration'] = intval($service['duration']);
        $service['rating'] = floatval($service['rating'] ?? 0);
        $service['total_ratings'] = intval($service['total_ratings']);
        $service['booking_count'] = intval($service['booking_count']);
        $service['favorite_count'] = intval($service['favorite_count']);
        $service['max_guests'] = $service['max_guests'] ? intval($service['max_guests']) : null;
        $service['deposit_amount'] = $service['deposit_amount'] ? floatval($service['deposit_amount']) : null;
        $service['provider_rating'] = $service['provider_rating'] ? floatval($service['provider_rating']) : null;
        $service['total_bookings'] = intval($service['total_bookings']);
        $service['total_reviews'] = intval($service['total_reviews']);
        $service['average_rating'] = $service['average_rating'] ? floatval($service['average_rating']) : 0;
        
        // تحويل القيم المنطقية
        $service['is_active'] = boolval($service['is_active']);
        $service['is_verified'] = boolval($service['is_verified']);
        $service['is_featured'] = boolval($service['is_featured']);
        $service['deposit_required'] = boolval($service['deposit_required']);
    }
    
    // إعداد الاستجابة
    $response = [
        'success' => true,
        'data' => [
            'services' => $services,
            'provider' => [
                'id' => $provider['id'],
                'name' => $provider['name'],
                'user_type' => $provider['user_type']
            ],
            'pagination' => [
                'current_page' => $page,
                'total_pages' => ceil($total_count / $limit),
                'total_services' => $total_count,
                'limit' => $limit,
                'has_next' => $page < ceil($total_count / $limit),
                'has_prev' => $page > 1
            ],
            'filters' => [
                'provider_id' => $provider_id,
                'category_id' => $category_id,
                'status' => $status,
                'sort_by' => $sort_by,
                'sort_order' => $sort_order
            ]
        ]
    ];
    
    echo json_encode($response);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
?> 