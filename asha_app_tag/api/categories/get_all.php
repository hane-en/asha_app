<?php
/**
 * API endpoint لجلب جميع الفئات
 * GET /api/categories/get_all.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=utf-8');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// الحصول على المعاملات
$include_services_count = isset($_GET['include_services_count']) ? (bool)$_GET['include_services_count'] : false;

try {
    $database = new Database();
    $database->connect();

    if ($include_services_count) {
        // الاستعلام مع عدد الخدمات
        $query = "
            SELECT 
                c.*,
                COUNT(s.id) as services_count
            FROM categories c
            LEFT JOIN services s ON c.id = s.category_id AND s.is_active = 1 AND s.is_verified = 1
            WHERE c.is_active = 1
            GROUP BY c.id
            ORDER BY c.created_at ASC
        ";
    } else {
        // الاستعلام البسيط
        $query = "
            SELECT * FROM categories 
            WHERE is_active = 1 
            ORDER BY created_at ASC
        ";
    }

    $categories = $database->select($query);

    // معالجة البيانات
    foreach ($categories as &$category) {
        $category['is_active'] = (bool)$category['is_active'];
        if (isset($category['services_count'])) {
            $category['services_count'] = (int)$category['services_count'];
        }
    }

    successResponse($categories, 'تم جلب الفئات بنجاح');

} catch (Exception $e) {
    logError("Get categories error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الفئات', 500);
}

?>

