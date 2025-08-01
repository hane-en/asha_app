<?php
/**
 * جلب جميع الإعلانات النشطة
 * Get all active ads
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config.php';

// التعامل مع طلب OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET,
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    
    // جلب الإعلانات النشطة مع معلومات المزود
    $sql = "
        SELECT 
            a.*,
            u.name as provider_name,
            u.profile_image as provider_image,
            u.rating as provider_rating
        FROM ads a
        LEFT JOIN users u ON a.provider_id = u.id
        WHERE a.is_active = 1
        AND (a.start_date IS NULL OR a.start_date <= CURDATE())
        AND (a.end_date IS NULL OR a.end_date >= CURDATE())
        ORDER BY a.priority DESC, a.created_at DESC
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $ads = $stmt->fetchAll();
    
    // معالجة البيانات
    foreach ($ads as &$ad) {
        // تحويل القيم الرقمية
        $ad['id'] = intval($ad['id']);
        $ad['provider_id'] = $ad['provider_id'] ? intval($ad['provider_id']) : null;
        $ad['priority'] = intval($ad['priority']);
        $ad['provider_rating'] = $ad['provider_rating'] ? floatval($ad['provider_rating']) : null;
        
        // تحويل القيم المنطقية
        $ad['is_active'] = boolval($ad['is_active']);
        
        // إضافة رابط الصورة الكامل
        if (!empty($ad['image'])) {
            $ad['image_url'] = $ad['image'];
        }
        
        // إضافة رابط مزود الخدمة إذا كان موجود
        if ($ad['provider_id']) {
            $ad['provider_link'] = "provider_services.php?provider_id=" . $ad['provider_id'];
        }
    }
    
    // إعداد الاستجابة
    $response = [
        'success' => true,
        'data' => [
            'ads' => $ads,
            'total' => count($ads)
        ]
    ];
    
    echo json_encode($response);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
?> 