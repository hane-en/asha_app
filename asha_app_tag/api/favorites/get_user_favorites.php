<?php
require_once '../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $db = new Database();
    $conn = $db->getConnection();
    
    if (!$conn) {
        throw new Exception("خطأ في الاتصال بقاعدة البيانات");
    }
    
    // إنشاء جدول المفضلة إذا لم يكن موجوداً
    $createTable = "CREATE TABLE IF NOT EXISTS favorites (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        service_id INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
        UNIQUE KEY unique_user_service (user_id, service_id)
    )";
    $conn->exec($createTable);
    
    // جلب المفضلات مع معلومات الخدمة والمزود
    $query = "SELECT 
                f.id,
                f.user_id,
                f.service_id,
                f.created_at,
                s.title,
                s.description,
                s.price,
                s.images,
                s.city,
                s.is_active,
                u.name as provider_name,
                u.id as provider_id,
                c.name as category_name,
                c.id as category_id
              FROM favorites f
              INNER JOIN services s ON f.service_id = s.id
              INNER JOIN users u ON s.provider_id = u.id
              INNER JOIN categories c ON s.category_id = c.id
              WHERE f.user_id = ? AND s.is_active = 1
              ORDER BY f.created_at DESC";
    
    $stmt = $conn->prepare($query);
    $stmt->execute([1]); // استخدام user_id = 1 للاختبار
    $favorites = $stmt->fetchAll();
    
    // تحويل البيانات للتأكد من التوافق مع Flutter
    foreach ($favorites as &$favorite) {
        $favorite['id'] = (int)$favorite['id'];
        $favorite['user_id'] = (int)$favorite['user_id'];
        $favorite['service_id'] = (int)$favorite['service_id'];
        $favorite['provider_id'] = (int)$favorite['provider_id'];
        $favorite['category_id'] = (int)$favorite['category_id'];
        $favorite['price'] = (float)$favorite['price'];
        $favorite['is_active'] = (bool)$favorite['is_active'];
        
        // تحويل الصور من JSON
        if ($favorite['images']) {
            $images = json_decode($favorite['images'], true);
            $favorite['images'] = is_array($images) ? $images : [];
        } else {
            $favorite['images'] = [];
        }
        
        // إضافة معلومات إضافية
        $favorite['rating'] = 4.5;
        $favorite['reviews_count'] = 10;
        $favorite['bookings_count'] = 5;
    }
    
    echo json_encode([
        'success' => true,
        'data' => $favorites,
        'count' => count($favorites),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?>

