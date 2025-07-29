<?php
/**
 * API endpoint مبسط جداً لجلب الخدمات
 */

require_once '../../config.php';
require_once '../../database.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();

    // استعلام بسيط جداً بدون parameters
    $query = "SELECT * FROM services ORDER BY created_at DESC LIMIT 20";
    $services = $database->select($query);

    // معالجة بسيطة للبيانات
    if (is_array($services)) {
        foreach ($services as &$service) {
            // تحويل JSON إلى array
            $service['images'] = json_decode($service['images'], true) ?: [];
            $service['specifications'] = json_decode($service['specifications'], true) ?: [];
            $service['tags'] = json_decode($service['tags'], true) ?: [];
            
            // تحويل الأرقام
            $service['price'] = (float)$service['price'];
            $service['original_price'] = $service['original_price'] ? (float)$service['original_price'] : null;
            $service['rating'] = (float)$service['rating'];
            
            // تحويل القيم المنطقية
            $service['is_active'] = (bool)$service['is_active'];
            $service['is_verified'] = (bool)$service['is_verified'];
            $service['is_featured'] = (bool)$service['is_featured'];
            $service['deposit_required'] = (bool)$service['deposit_required'];
        }
    } else {
        $services = [];
    }

    $response = [
        'success' => true,
        'message' => 'تم جلب الخدمات بنجاح',
        'timestamp' => date('Y-m-d H:i:s'),
        'data' => [
            'services' => $services,
            'count' => count($services)
        ]
    ];

    echo json_encode($response, JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    $response = [
        'success' => false,
        'message' => 'حدث خطأ أثناء جلب الخدمات',
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
?> 