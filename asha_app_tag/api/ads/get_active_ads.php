<?php
require_once '../config.php';
require_once '../database.php';

if (!headers_sent()) {
    header('Content-Type: application/json; charset=utf-8');
}
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $database = new Database();
    $conn = $database->connect();
    
    if (!$conn) {
        throw new Exception("خطأ في الاتصال بقاعدة البيانات");
    }
    
    // جلب الإعلانات النشطة مع معلومات المزود
    $query = "SELECT 
                a.id,
                a.title,
                a.description,
                a.image,
                a.link_url,
                a.is_active,
                a.is_featured,
                a.start_date,
                a.end_date,
                a.created_at,
                u.name as provider_name,
                u.id as provider_id
              FROM ads a
              LEFT JOIN users u ON a.provider_id = u.id
              WHERE a.is_active = 1
              ORDER BY a.is_featured DESC, a.created_at DESC";
    
    error_log("Ads API: Executing query: $query");
    
    $ads = $database->select($query);
    
    if ($ads === false) {
        throw new Exception('خطأ في جلب الإعلانات من قاعدة البيانات');
    }
    
    error_log("Ads API: Found " . count($ads) . " ads");
    
    // تحويل البيانات للتأكد من التوافق مع Flutter
    foreach ($ads as &$ad) {
        $ad['id'] = (int)$ad['id'];
        $ad['is_active'] = (bool)$ad['is_active'];
        $ad['is_featured'] = (bool)$ad['is_featured'];
        $ad['provider_id'] = $ad['provider_id'] ? (int)$ad['provider_id'] : null;
        $ad['has_link'] = !empty($ad['link_url']);
        
        // إضافة حقول إضافية مطلوبة للتطبيق
        $ad['imageUrl'] = $ad['image'];
        $ad['providerName'] = $ad['provider_name'] ?? 'مزود غير محدد';
    }
    
    successResponse($ads, 'تم جلب الإعلانات بنجاح');
    
} catch (Exception $e) {
    error_log("Ads API Error: " . $e->getMessage());
    logError("Get ads error: " . $e->getMessage());
    errorResponse('خطأ في قاعدة البيانات: ' . $e->getMessage(), 500);
}
?>