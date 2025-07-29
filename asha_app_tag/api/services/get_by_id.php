<?php
/**
 * API endpoint لجلب خدمة بالمعرف
 * GET /api/services/get_by_id.php?id=1
 */

require_once '../../config.php';
require_once '../../database.php';

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

// التحقق من وجود المعرف
if (!isset($_GET['id']) || empty($_GET['id'])) {
    errorResponse('معرف الخدمة مطلوب');
}

$serviceId = (int)$_GET['id'];

try {
    $database = new Database();
    $database->connect();

    // الاستعلام الرئيسي
    $query = "
        SELECT 
            s.*,
            c.name as category_name,
            c.description as category_description,
            u.name as provider_name,
            u.email as provider_email,
            u.phone as provider_phone,
            u.rating as provider_rating,
            u.review_count as provider_review_count,
            u.profile_image as provider_image,
            u.bio as provider_bio,
            u.website as provider_website,
            u.address as provider_address,
            u.city as provider_city,
            (SELECT COUNT(*) FROM favorites f WHERE f.service_id = s.id) as favorites_count,
            (SELECT AVG(rating) FROM reviews r WHERE r.service_id = s.id) as avg_rating,
            (SELECT COUNT(*) FROM reviews r WHERE r.service_id = s.id) as reviews_count
        FROM services s
        LEFT JOIN categories c ON s.category_id = c.id
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE s.id = :id AND s.is_active = 1
    ";

    $service = $database->selectOne($query, ['id' => $serviceId]);

    if (!$service) {
        errorResponse('الخدمة غير موجودة', 404);
    }

    // جلب العروض المتاحة للخدمة
    $offersQuery = "
        SELECT * FROM offers 
        WHERE service_id = :service_id 
        AND is_active = 1 
        AND (end_date IS NULL OR end_date >= CURDATE())
        ORDER BY created_at DESC
    ";
    $offers = $database->select($offersQuery, ['service_id' => $serviceId]);

    // جلب التقييمات الأخيرة
    $reviewsQuery = "
        SELECT 
            r.*,
            u.name as user_name,
            u.profile_image as user_image
        FROM reviews r
        LEFT JOIN users u ON r.user_id = u.id
        WHERE r.service_id = :service_id
        ORDER BY r.created_at DESC
        LIMIT 10
    ";
    $reviews = $database->select($reviewsQuery, ['service_id' => $serviceId]);

    // جلب الخدمات المشابهة
    $similarQuery = "
        SELECT 
            s.id, s.title, s.price, s.images, s.rating, s.city,
            u.name as provider_name
        FROM services s
        LEFT JOIN users u ON s.provider_id = u.id
        WHERE s.category_id = :category_id 
        AND s.id != :service_id 
        AND s.is_active = 1 
        AND s.is_verified = 1
        ORDER BY s.rating DESC, s.created_at DESC
        LIMIT 5
    ";
    $similarServices = $database->select($similarQuery, [
        'category_id' => $service['category_id'],
        'service_id' => $serviceId
    ]);

    // معالجة البيانات
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
    $service['deposit_amount'] = $service['deposit_amount'] ? (float)$service['deposit_amount'] : null;
    
    // تحويل القيم المنطقية
    $service['is_active'] = (bool)$service['is_active'];
    $service['is_verified'] = (bool)$service['is_verified'];
    $service['is_featured'] = (bool)$service['is_featured'];
    $service['deposit_required'] = (bool)$service['deposit_required'];

    // معالجة العروض
    foreach ($offers as &$offer) {
        $offer['discount_percentage'] = $offer['discount_percentage'] ? (float)$offer['discount_percentage'] : null;
        $offer['discount_amount'] = $offer['discount_amount'] ? (float)$offer['discount_amount'] : null;
        $offer['is_active'] = (bool)$offer['is_active'];
    }

    // معالجة التقييمات
    foreach ($reviews as &$review) {
        $review['rating'] = (int)$review['rating'];
    }

    // معالجة الخدمات المشابهة
    foreach ($similarServices as &$similar) {
        $similar['images'] = json_decode($similar['images'], true) ?: [];
        $similar['price'] = (float)$similar['price'];
        $similar['rating'] = (float)$similar['rating'];
    }

    $response = [
        'service' => $service,
        'offers' => $offers,
        'reviews' => $reviews,
        'similar_services' => $similarServices
    ];

    successResponse($response, 'تم جلب تفاصيل الخدمة بنجاح');

} catch (Exception $e) {
    logError("Get service by ID error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب تفاصيل الخدمة', 500);
}

?>

