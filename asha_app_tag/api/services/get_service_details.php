<?php
/**
 * ملف الحصول على تفاصيل الخدمة مع التقييمات والتعليقات
 */

require_once '../config.php';
require_once '../database.php';

// إعداد CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$response = [
    'success' => false,
    'message' => '',
    'data' => null
];

try {
    $database = new Database();
    $database->connect();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $service_id = isset($_GET['service_id']) ? intval($_GET['service_id']) : 0;
        $user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
        
        if ($service_id <= 0) {
            throw new Exception('معرف الخدمة غير صحيح');
        }
        
        // الحصول على تفاصيل الخدمة
        $service_query = "SELECT s.*, c.name as category_name, c.id as category_id,
                                u.name as provider_name, u.phone as provider_phone, 
                                u.email as provider_email, COALESCE(u.profile_image, 'default_avatar.jpg') as provider_image,
                                u.is_verified as provider_verified
                         FROM services s
                         LEFT JOIN categories c ON s.category_id = c.id
                         LEFT JOIN users u ON s.provider_id = u.id
                         WHERE s.id = ? AND s.is_active = 1";
        
        $service_stmt = $database->prepare($service_query);
        $service_stmt->bind_param('i', $service_id);
        $service_stmt->execute();
        $service_result = $service_stmt->get_result();
        
        if ($service_result->num_rows === 0) {
            throw new Exception('الخدمة غير موجودة أو غير نشطة');
        }
        
        $service_data = $service_result->fetch_assoc();
        
        // الحصول على التقييمات والتعليقات
        $reviews_query = "SELECT r.*, u.name as user_name, u.profile_image as user_image
                         FROM reviews r
                         LEFT JOIN users u ON r.user_id = u.id
                         WHERE r.service_id = ?
                         ORDER BY r.created_at DESC
                         LIMIT 20";
        
        $reviews_stmt = $database->prepare($reviews_query);
        $reviews_stmt->bind_param('i', $service_id);
        $reviews_stmt->execute();
        $reviews_result = $reviews_stmt->get_result();
        
        $reviews = [];
        while ($row = $reviews_result->fetch_assoc()) {
            $reviews[] = $row;
        }
        
        // الحصول على إحصائيات التقييم
        $rating_stats_query = "SELECT 
                                 AVG(rating) as avg_rating,
                                 COUNT(*) as total_reviews,
                                 COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
                                 COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
                                 COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
                                 COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
                                 COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star
                              FROM reviews
                              WHERE service_id = ?";
        
        $rating_stats_stmt = $database->prepare($rating_stats_query);
        $rating_stats_stmt->bind_param('i', $service_id);
        $rating_stats_stmt->execute();
        $rating_stats_result = $rating_stats_stmt->get_result();
        $rating_stats = $rating_stats_result->fetch_assoc();
        
        $rating_stats['avg_rating'] = round($rating_stats['avg_rating'], 1);
        
        // التحقق من حالة المفضلة للمستخدم
        $is_favorite = false;
        if ($user_id > 0) {
            $favorite_query = "SELECT id FROM favorites WHERE user_id = ? AND service_id = ?";
            $favorite_stmt = $database->prepare($favorite_query);
            $favorite_stmt->bind_param('ii', $user_id, $service_id);
            $favorite_stmt->execute();
            $favorite_result = $favorite_stmt->get_result();
            $is_favorite = $favorite_result->num_rows > 0;
        }
        
        // التحقق من إمكانية التعليق (يجب أن يكون المستخدم قد حجز الخدمة وأكملها)
        $can_review = false;
        if ($user_id > 0) {
            $booking_check_query = "SELECT id FROM bookings 
                                   WHERE user_id = ? AND service_id = ? AND status = 'completed'
                                   LIMIT 1";
            $booking_check_stmt = $database->prepare($booking_check_query);
            $booking_check_stmt->bind_param('ii', $user_id, $service_id);
            $booking_check_stmt->execute();
            $booking_check_result = $booking_check_stmt->get_result();
            $can_review = $booking_check_result->num_rows > 0;
        }
        
        // التحقق من وجود تقييم سابق من المستخدم
        $user_has_reviewed = false;
        if ($user_id > 0) {
            $user_review_query = "SELECT id FROM reviews WHERE user_id = ? AND service_id = ?";
            $user_review_stmt = $database->prepare($user_review_query);
            $user_review_stmt->bind_param('ii', $user_id, $service_id);
            $user_review_stmt->execute();
            $user_review_result = $user_review_stmt->get_result();
            $user_has_reviewed = $user_review_result->num_rows > 0;
        }
        
        $response['success'] = true;
        $response['message'] = 'تم الحصول على تفاصيل الخدمة بنجاح';
        $response['data'] = [
            'service' => $service_data,
            'reviews' => $reviews,
            'rating_stats' => $rating_stats,
            'is_favorite' => $is_favorite,
            'can_review' => $can_review,
            'user_has_reviewed' => $user_has_reviewed,
            'total_reviews' => count($reviews)
        ];
        
    } else {
        throw new Exception('طريقة الطلب غير مدعومة');
    }
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 