<?php
/**
 * API endpoint مبسط لجلب مفضلات المستخدم (بدون مصادقة)
 * GET /api/favorites/get_user_favorites_simple.php?user_id=1
 */

require_once '../../config.php';
require_once '../../database.php';

// إيقاف عرض الأخطاء
error_reporting(0);
ini_set('display_errors', 0);

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على المعاملات
$userId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;

if (!$userId) {
    errorResponse('معرف المستخدم مطلوب');
}

try {
    $database = new Database();
    $database->connect();

    // التحقق من وجود المستخدم
    $user = $database->selectOne(
        "SELECT id, name FROM users WHERE id = :id",
        ['id' => $userId]
    );

    if (!$user) {
        errorResponse('المستخدم غير موجود', 404);
    }

    // الاستعلام الرئيسي - مبسط
    $query = "
        SELECT 
            f.id as favorite_id,
            s.*,
            c.name as category_name,
            u.name as provider_name
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE f.user_id = :user_id AND s.is_active = 1
        ORDER BY f.created_at DESC
    ";

    $params = [
        'user_id' => $userId
    ];

    $favorites = $database->select($query, $params);

    // التأكد من أن $favorites مصفوفة
    if (!is_array($favorites)) {
        $favorites = [];
    }

    // الحصول على العدد الإجمالي
    $countQuery = "
        SELECT COUNT(*) as total
        FROM favorites f
        LEFT JOIN services s ON f.service_id = s.id
        WHERE f.user_id = :user_id AND s.is_active = 1
    ";
    
    $totalResult = $database->selectOne($countQuery, ['user_id' => $userId]);
    $total = $totalResult['total'];

    // معالجة البيانات
    if (is_array($favorites)) {
        foreach ($favorites as &$favorite) {
            // تحويل JSON إلى array
            $favorite['images'] = json_decode($favorite['images'], true) ?: [];
            $favorite['specifications'] = json_decode($favorite['specifications'], true) ?: [];
            $favorite['tags'] = json_decode($favorite['tags'], true) ?: [];
            
            // تحويل الأرقام
            $favorite['price'] = (float)$favorite['price'];
            $favorite['original_price'] = $favorite['original_price'] ? (float)$favorite['original_price'] : null;
            $favorite['rating'] = (float)$favorite['rating'];
            
            // تحويل القيم المنطقية
            $favorite['is_active'] = (bool)$favorite['is_active'];
            $favorite['is_verified'] = (bool)$favorite['is_verified'];
            $favorite['is_featured'] = (bool)$favorite['is_featured'];
            $favorite['deposit_required'] = (bool)$favorite['deposit_required'];
            
            // إضافة معلومات إضافية
            $favorite['is_favorite'] = true; // بالطبع هي مفضلة
        }
    }

    $response = [
        'success' => true,
        'data' => $favorites,
        'pagination' => [
            'current_page' => $page,
            'total_pages' => ceil($total / $limit),
            'total_items' => (int)$total,
            'items_per_page' => $limit
        ]
    ];

    // إرسال الاستجابة
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;

} catch (Exception $e) {
    logError("Get user favorites error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب المفضلات', 500);
}

?> 