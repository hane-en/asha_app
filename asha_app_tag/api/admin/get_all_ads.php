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
    
    // جلب جميع الإعلانات
    $query = "
        SELECT 
            a.id,
            a.title,
            a.description,
            a.image,
            '' as link,
            a.is_active,
            a.start_date,
            a.end_date,
            a.created_at,
            a.updated_at,
            COALESCE(u.name, 'غير محدد') as provider_name
        FROM ads a
        LEFT JOIN users u ON a.provider_id = u.id
        ORDER BY a.created_at DESC
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $ads = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // معالجة البيانات
    foreach ($ads as &$ad) {
        $ad['id'] = intval($ad['id']);
        $ad['is_active'] = boolval($ad['is_active']);
        
        // تحويل التواريخ
        if ($ad['created_at']) {
            $ad['created_at'] = date('Y-m-d H:i:s', strtotime($ad['created_at']));
        }
        if ($ad['updated_at']) {
            $ad['updated_at'] = date('Y-m-d H:i:s', strtotime($ad['updated_at']));
        }
        if ($ad['start_date']) {
            $ad['start_date'] = date('Y-m-d', strtotime($ad['start_date']));
        }
        if ($ad['end_date']) {
            $ad['end_date'] = date('Y-m-d', strtotime($ad['end_date']));
        }
        
        // إضافة معلومات إضافية
        $ad['status'] = $ad['is_active'] ? 'نشط' : 'غير نشط';
        
        // التحقق من صلاحية الإعلان
        $current_date = date('Y-m-d');
        if ($ad['end_date'] && $ad['end_date'] < $current_date) {
            $ad['expired'] = true;
            $ad['status'] = 'منتهي الصلاحية';
        } else {
            $ad['expired'] = false;
        }
    }
    
    // إحصائيات
    $total_ads = count($ads);
    $active_ads = count(array_filter($ads, function($ad) { return $ad['is_active']; }));
    $expired_ads = count(array_filter($ads, function($ad) { return $ad['expired']; }));
    
    $stats = [
        'total_ads' => $total_ads,
        'active_ads' => $active_ads,
        'expired_ads' => $expired_ads,
        'inactive_ads' => $total_ads - $active_ads
    ];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم جلب الإعلانات بنجاح',
        'data' => $ads,
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