<?php
/**
 * API endpoint لجلب مفضلات المستخدم
 * GET /api/favorites/get_user_favorites.php
 */

require_once '../../config.php';
require_once '../../database.php';
require_once '../../middleware.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// التحقق من المصادقة
$user = $middleware->requireAuth();

// الحصول على المعاملات
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : PAGINATION_LIMIT;

try {
    $database = new Database();
    $database->connect();

    // الاستعلام الرئيسي
    $query = "
        SELECT 
            f.id as favorite_id,
            f.created_at as favorited_at,
            s.*,
            c.name as category_name,
            u.name as provider_name,
            u.rating as provider_rating,
            u.profile_image as provider_image,
            (SELECT AVG(rating) FROM reviews r WHERE r.service_id = s.id) as avg_rating,
            (SELECT COUNT(*) FROM reviews r WHERE r.service_id = s.id) as reviews_count
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE f.user_id = :user_id AND s.is_active = 1
        ORDER BY f.created_at DESC
        LIMIT :limit OFFSET :offset
    ";

    $offset = ($page - 1) * $limit;
    $params = [
        'user_id' => $user['id'],
        'limit' => $limit,
        'offset' => $offset
    ];

    $favorites = $database->select($query, $params);

    // الحصول على العدد الإجمالي
    $countQuery = "
        SELECT COUNT(*) as total
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        WHERE f.user_id = :user_id AND s.is_active = 1
    ";
    
    $totalResult = $database->selectOne($countQuery, ['user_id' => $user['id']]);
    $total = $totalResult['total'];

    // معالجة البيانات
    foreach ($favorites as &$favorite) {
        // تحويل JSON إلى array
        $favorite['images'] = json_decode($favorite['images'], true) ?: [];
        $favorite['specifications'] = json_decode($favorite['specifications'], true) ?: [];
        $favorite['tags'] = json_decode($favorite['tags'], true) ?: [];
        
        // تحويل الأرقام
        $favorite['price'] = (float)$favorite['price'];
        $favorite['original_price'] = $favorite['original_price'] ? (float)$favorite['original_price'] : null;
        $favorite['rating'] = (float)$favorite['rating'];
        $favorite['avg_rating'] = $favorite['avg_rating'] ? (float)$favorite['avg_rating'] : 0;
        $favorite['provider_rating'] = $favorite['provider_rating'] ? (float)$favorite['provider_rating'] : 0;
        
        // تحويل القيم المنطقية
        $favorite['is_active'] = (bool)$favorite['is_active'];
        $favorite['is_verified'] = (bool)$favorite['is_verified'];
        $favorite['is_featured'] = (bool)$favorite['is_featured'];
        $favorite['deposit_required'] = (bool)$favorite['deposit_required'];
        
        // إضافة معلومات إضافية
        $favorite['is_favorite'] = true; // بالطبع هي مفضلة
    }

    $response = [
        'favorites' => $favorites,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => ceil($total / $limit),
            'total_items' => (int)$total,
            'items_per_page' => $limit
        ]
    ];

    successResponse($response, 'تم جلب المفضلات بنجاح');

} catch (Exception $e) {
    logError("Get user favorites error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب المفضلات', 500);
}

?>

