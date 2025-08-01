<?php
/**
 * API endpoint لجلب الإعلانات للجميع (بدون أي تحقق)
 * GET /api/ads/get_simple_ads.php
 */

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
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'طريقة الطلب غير مدعومة',
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    // إعدادات قاعدة البيانات
    $host = '127.0.0.1';
    $dbname = 'asha_app_events';
    $username = 'root';
    $password = '';
    $charset = 'utf8mb4';

    // الاتصال بقاعدة البيانات
    $dsn = "mysql:host=$host;dbname=$dbname;charset=$charset";
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    // جلب الإعلانات النشطة للجميع
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
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $ads = $stmt->fetchAll();
    
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
    
    // رسالة للجميع
    $response = [
        'success' => true,
        'message' => 'تم جلب الإعلانات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => $ads
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $errorResponse = [
        'success' => false,
        'message' => 'حدث خطأ في جلب الإعلانات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => []
    ];
    
    http_response_code(500);
    echo json_encode($errorResponse, JSON_UNESCAPED_UNICODE);
}
?> 