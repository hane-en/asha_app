<?php
// إيقاف عرض الأخطاء لمنع ظهور warnings في JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// التحقق من أن الطلب هو POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['ad_id'])) {
        throw new Exception('معرف الإعلان مطلوب');
    }
    
    $adId = intval($input['ad_id']);
    $reason = $input['reason'] ?? 'تم حذف الإعلان من قبل المدير';
    
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4", DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // جلب معلومات الإعلان قبل الحذف
    $stmt = $pdo->prepare("SELECT * FROM ads WHERE id = ?");
    $stmt->execute([$adId]);
    $ad = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$ad) {
        throw new Exception('الإعلان غير موجود');
    }
    
    // بدء المعاملة
    $pdo->beginTransaction();
    
    try {
        // حذف الإعلان
        $stmt = $pdo->prepare("DELETE FROM ads WHERE id = ?");
        $stmt->execute([$adId]);
        
        // إرسال إشعار للمزود (إذا كان هناك نظام إشعارات)
        // يمكن إضافة كود الإشعارات هنا
        
        // تسجيل العملية في سجل النظام
        $stmt = $pdo->prepare("
            INSERT INTO admin_actions (action_type, target_type, target_id, admin_id, details, created_at) 
            VALUES (?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([
            'delete_ad',
            'ad',
            $adId,
            1, // admin_id - يمكن تغييره حسب نظام المصادقة
            json_encode([
                'reason' => $reason,
                'ad_title' => $ad['title'],
                'provider_id' => $ad['provider_id']
            ], JSON_UNESCAPED_UNICODE)
        ]);
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'تم حذف الإعلان بنجاح',
            'data' => [
                'ad_id' => $adId,
                'ad_title' => $ad['title']
            ]
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?> 