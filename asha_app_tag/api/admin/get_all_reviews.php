<?php
// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // جلب جميع التعليقات
    $query = "
        SELECT 
            r.id,
            r.service_id,
            r.user_id,
            r.rating,
            r.comment,
            0 as is_verified,
            r.created_at,
            r.updated_at,
            s.title as service_title,
            COALESCE(u.name, 'غير محدد') as user_name,
            COALESCE(u.email, 'غير محدد') as user_email,
            COALESCE(p.name, 'غير محدد') as provider_name
        FROM reviews r
        LEFT JOIN services s ON r.service_id = s.id
        LEFT JOIN users u ON r.user_id = u.id
        LEFT JOIN users p ON s.provider_id = p.id
        ORDER BY r.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($reviews as &$review) {
        $review['id'] = intval($review['id']);
        $review['service_id'] = intval($review['service_id']);
        $review['user_id'] = intval($review['user_id']);
        $review['rating'] = floatval($review['rating']);
        $review['is_verified'] = boolval($review['is_verified']);
        
        // تحويل التواريخ
        if ($review['created_at']) {
            $review['created_at'] = date('Y-m-d H:i:s', strtotime($review['created_at']));
        }
        if ($review['updated_at']) {
            $review['updated_at'] = date('Y-m-d H:i:s', strtotime($review['updated_at']));
        }
        
        // إضافة معلومات إضافية
        $review['rating_stars'] = str_repeat('⭐', intval($review['rating']));
        $review['verification_status'] = $review['is_verified'] ? 'مؤكد' : 'غير مؤكد';
    }
    
    // إحصائيات
    $total_reviews = count($reviews);
    $verified_reviews = count(array_filter($reviews, function($r) { return $r['is_verified']; }));
    $average_rating = $total_reviews > 0 ? array_sum(array_column($reviews, 'rating')) / $total_reviews : 0;
    
    // توزيع التقييمات
    $rating_distribution = [
        '5_stars' => count(array_filter($reviews, function($r) { return $r['rating'] == 5; })),
        '4_stars' => count(array_filter($reviews, function($r) { return $r['rating'] == 4; })),
        '3_stars' => count(array_filter($reviews, function($r) { return $r['rating'] == 3; })),
        '2_stars' => count(array_filter($reviews, function($r) { return $r['rating'] == 2; })),
        '1_stars' => count(array_filter($reviews, function($r) { return $r['rating'] == 1; }))
    ];
    
    $stats = [
        'total_reviews' => $total_reviews,
        'verified_reviews' => $verified_reviews,
        'unverified_reviews' => $total_reviews - $verified_reviews,
        'average_rating' => round($average_rating, 1),
        'rating_distribution' => $rating_distribution
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب التعليقات بنجاح',
        'data' => $reviews,
        'stats' => $stats
    ], JSON_UNESCAPED_UNICODE);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ عام: ' . $e->getMessage(),
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
}
?> 