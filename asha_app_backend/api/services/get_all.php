<?php
/**
 * API endpoint لجلب جميع الخدمات
 * GET /api/services/get_all.php
 */

require_once '../../config.php';
require_once '../../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على المعاملات
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : PAGINATION_LIMIT;
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;
$city = isset($_GET['city']) ? sanitizeInput($_GET['city']) : null;
$search = isset($_GET['search']) ? sanitizeInput($_GET['search']) : null;
$min_price = isset($_GET['min_price']) ? (float)$_GET['min_price'] : null;
$max_price = isset($_GET['max_price']) ? (float)$_GET['max_price'] : null;
$is_featured = isset($_GET['is_featured']) ? (bool)$_GET['is_featured'] : null;
$sort_by = isset($_GET['sort_by']) ? sanitizeInput($_GET['sort_by']) : 'created_at';
$sort_order = isset($_GET['sort_order']) ? sanitizeInput($_GET['sort_order']) : 'DESC';

try {
    $database = new Database();
    $database->connect();

    // بناء الاستعلام
    $whereConditions = ['s.is_active = 1', 's.is_verified = 1'];
    $params = [];

    if ($category_id) {
        $whereConditions[] = 's.category_id = :category_id';
        $params['category_id'] = $category_id;
    }

    if ($city) {
        $whereConditions[] = 's.city = :city';
        $params['city'] = $city;
    }

    if ($search) {
        $whereConditions[] = '(s.title LIKE :search OR s.description LIKE :search OR s.tags LIKE :search)';
        $params['search'] = "%{$search}%";
    }

    if ($min_price !== null) {
        $whereConditions[] = 's.price >= :min_price';
        $params['min_price'] = $min_price;
    }

    if ($max_price !== null) {
        $whereConditions[] = 's.price <= :max_price';
        $params['max_price'] = $max_price;
    }

    if ($is_featured !== null) {
        $whereConditions[] = 's.is_featured = :is_featured';
        $params['is_featured'] = $is_featured ? 1 : 0;
    }

    $whereClause = implode(' AND ', $whereConditions);

    // الاستعلام الرئيسي
    $query = "
        SELECT 
            s.*,
            c.name as category_name,
            u.name as provider_name,
            u.rating as provider_rating,
            u.profile_image as provider_image,
            (SELECT COUNT(*) FROM favorites f WHERE f.service_id = s.id) as favorites_count,
            (SELECT AVG(rating) FROM reviews r WHERE r.service_id = s.id) as avg_rating,
            (SELECT COUNT(*) FROM reviews r WHERE r.service_id = s.id) as reviews_count
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE {$whereClause}
        ORDER BY s.{$sort_by} {$sort_order}
        LIMIT :limit OFFSET :offset
    ";

    $offset = ($page - 1) * $limit;
    $params['limit'] = $limit;
    $params['offset'] = $offset;

    $services = $database->select($query, $params);

    // الحصول على العدد الإجمالي
    $countQuery = "
        SELECT COUNT(*) as total
        FROM services s
        WHERE {$whereClause}
    ";
    
    $countParams = $params;
    unset($countParams['limit']);
    unset($countParams['offset']);
    
    $totalResult = $database->selectOne($countQuery, $countParams);
    $total = $totalResult['total'];

    // معالجة البيانات
    foreach ($services as &$service) {
        // تحويل JSON إلى array
        $service['images'] = json_decode($service['images'], true) ?: [];
        $service['specifications'] = json_decode($service['specifications'], true) ?: [];
        $service['tags'] = json_decode($service['tags'], true) ?: [];
        $service['payment_terms'] = json_decode($service['payment_terms'], true) ?: [];
        $service['availability'] = json_decode($service['availability'], true) ?: [];
        
        // تحويل الأرقام
        $service['price'] = (float)$service['price'];
        $service['original_price'] = $service['original_price'] ? (float)$service['original_price'] : null;
        $service['rating'] = (float)$service['rating'];
        $service['avg_rating'] = $service['avg_rating'] ? (float)$service['avg_rating'] : 0;
        $service['provider_rating'] = $service['provider_rating'] ? (float)$service['provider_rating'] : 0;
        
        // تحويل القيم المنطقية
        $service['is_active'] = (bool)$service['is_active'];
        $service['is_verified'] = (bool)$service['is_verified'];
        $service['is_featured'] = (bool)$service['is_featured'];
        $service['deposit_required'] = (bool)$service['deposit_required'];
    }

    $response = [
        'services' => $services,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => ceil($total / $limit),
            'total_items' => (int)$total,
            'items_per_page' => $limit
        ]
    ];

    successResponse($response, 'تم جلب الخدمات بنجاح');

} catch (Exception $e) {
    logError("Get services error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الخدمات', 500);
}

?>

