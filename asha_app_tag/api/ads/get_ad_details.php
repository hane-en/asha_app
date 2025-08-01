<?php
/**
 * ملف الحصول على تفاصيل الإعلان والانتقال إلى الخدمة
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
        $ad_id = isset($_GET['ad_id']) ? intval($_GET['ad_id']) : 0;
        
        if ($ad_id <= 0) {
            throw new Exception('معرف الإعلان غير صحيح');
        }
        
        // الحصول على تفاصيل الإعلان
        $query = "SELECT a.*, s.id as service_id, s.name as service_name, s.description as service_description, 
                         s.price as service_price, s.image as service_image, s.provider_id,
                         u.name as provider_name, u.phone as provider_phone
                  FROM ads a
                  LEFT JOIN services s ON a.service_id = s.id
                  LEFT JOIN users u ON s.provider_id = u.id
                  WHERE a.id = ? AND a.is_active = 1";
        
        $stmt = $database->prepare($query);
        $stmt->bind_param('i', $ad_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception('الإعلان غير موجود أو غير نشط');
        }
        
        $ad_data = $result->fetch_assoc();
        
        // الحصول على تقييمات الخدمة
        $rating_query = "SELECT AVG(rating) as avg_rating, COUNT(*) as total_reviews
                        FROM reviews r
                        WHERE r.service_id = ?";
        
        $rating_stmt = $database->prepare($rating_query);
        $rating_stmt->bind_param('i', $ad_data['service_id']);
        $rating_stmt->execute();
        $rating_result = $rating_stmt->get_result();
        $rating_data = $rating_result->fetch_assoc();
        
        $ad_data['avg_rating'] = round($rating_data['avg_rating'], 1);
        $ad_data['total_reviews'] = $rating_data['total_reviews'];
        
        $response['success'] = true;
        $response['message'] = 'تم الحصول على تفاصيل الإعلان بنجاح';
        $response['data'] = $ad_data;
        
    } else {
        throw new Exception('طريقة الطلب غير مدعومة');
    }
    
} catch (Exception $e) {
    $response['message'] = $e->getMessage();
    http_response_code(400);
}

echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 