
<?php
/**
 * API endpoint لجلب الإعلانات النشطة
 * GET /api/ads/get_active_ads.php
 */

require_once '../../config.php';
require_once '../../database.php';

// إعداد CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// معالجة preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من طريقة الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('طريقة الطلب غير مدعومة', 405);
}

try {
    $database = new Database();
    $database->connect();
    
    // جلب الإعلانات النشطة التي لم تنته صلاحيتها بعد
    $query = "
        SELECT 
            a.*,
            u.name as provider_name
        FROM ads a
        LEFT JOIN users u ON a.provider_id = u.id
        WHERE a.is_active = 1 
        AND (a.end_date IS NULL OR a.end_date >= CURDATE()) 
        ORDER BY a.created_at DESC
    ";
    
    $ads = $database->select($query);
    
    if ($ads === false) {
        throw new Exception('خطأ في جلب الإعلانات من قاعدة البيانات');
    }
    
    // معالجة البيانات
    foreach ($ads as &$ad) {
        // تحويل الأرقام
        $ad['id'] = (int)$ad['id'];
        $ad['provider_id'] = $ad['provider_id'] ? (int)$ad['provider_id'] : null;
        $ad['priority'] = isset($ad['priority']) ? (int)$ad['priority'] : 0;
        
        // تحويل القيم المنطقية
        $ad['is_active'] = (bool)$ad['is_active'];
        
        // تحويل التواريخ
        if ($ad['start_date']) {
            $ad['start_date'] = date('Y-m-d H:i:s', strtotime($ad['start_date']));
        }
        if ($ad['end_date']) {
            $ad['end_date'] = date('Y-m-d H:i:s', strtotime($ad['end_date']));
        }
        if ($ad['created_at']) {
            $ad['created_at'] = date('Y-m-d H:i:s', strtotime($ad['created_at']));
        }
        if ($ad['updated_at']) {
            $ad['updated_at'] = date('Y-m-d H:i:s', strtotime($ad['updated_at']));
        }
        
        // تحويل JSON إذا كان موجود
        if (isset($ad['images'])) {
            $ad['images'] = json_decode($ad['images'], true) ?: [];
        }
    }
    
    successResponse($ads, 'تم جلب الإعلانات النشطة بنجاح');
    
} catch (Exception $e) {
    logError("Get active ads error: " . $e->getMessage());
    errorResponse('حدث خطأ أثناء جلب الإعلانات', 500);
}
?>