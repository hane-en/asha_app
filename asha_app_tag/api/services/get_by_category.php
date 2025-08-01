<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../config/database.php';
require_once '../../config/cors.php';

try {
    // التحقق من وجود category_name
    if (!isset($_GET['category_name'])) {
        throw new Exception('اسم الفئة مطلوب');
    }

    $categoryName = trim($_GET['category_name']);

    if (empty($categoryName)) {
        throw new Exception('اسم الفئة غير صحيح');
    }

    // استعلام لجلب الخدمات حسب الفئة
    $sql = "SELECT 
                s.id,
                s.title,
                s.description,
                s.price,
                s.rating,
                s.images,
                s.city,
                s.is_active,
                s.created_at,
                u.id as provider_id,
                u.name as provider_name,
                u.rating as provider_rating,
                u.profile_image as provider_image,
                c.id as category_id,
                c.name as category_name
            FROM services s
            INNER JOIN users u ON s.provider_id = u.id
            INNER JOIN categories c ON s.category_id = c.id
            WHERE c.name = ?
            AND s.is_active = 1
            AND u.is_active = 1
            ORDER BY s.rating DESC, s.created_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$categoryName]);
    $services = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // تحويل البيانات وتحسينها
    foreach ($services as &$service) {
        // تحويل القيم الرقمية
        $service['id'] = intval($service['id']);
        $service['price'] = floatval($service['price']);
        $service['rating'] = floatval($service['rating']);
        $service['provider_id'] = intval($service['provider_id']);
        $service['provider_rating'] = floatval($service['provider_rating']);
        $service['category_id'] = intval($service['category_id']);
        $service['is_active'] = boolval($service['is_active']);

        // تحويل الصور من JSON
        if ($service['images']) {
            $images = json_decode($service['images'], true);
            if (is_array($images)) {
                $service['images'] = array_map(function($image) {
                    return Config::BASE_URL . '/uploads/services/' . $image;
                }, $images);
            } else {
                $service['images'] = [];
            }
        } else {
            $service['images'] = [];
        }

        // إضافة رابط صورة المزود الكامل
        if ($service['provider_image'] && $service['provider_image'] !== 'default_avatar.jpg') {
            $service['provider_image'] = Config::BASE_URL . '/uploads/profiles/' . $service['provider_image'];
        } else {
            $service['provider_image'] = Config::BASE_URL . '/uploads/profiles/default_avatar.jpg';
        }
    }

    // إرجاع النتيجة
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الخدمات بنجاح',
        'data' => $services,
        'category' => [
            'name' => $categoryName,
            'count' => count($services)
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات',
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 