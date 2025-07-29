<?php
/**
 * فحص حالة جدول services
 */

require_once 'config.php';
require_once 'database.php';

header('Content-Type: application/json; charset=utf-8');

try {
    $database = new Database();
    $database->connect();

    // فحص إجمالي الخدمات
    $totalQuery = "SELECT COUNT(*) as total FROM services";
    $totalResult = $database->selectOne($totalQuery);
    
    // فحص الخدمات النشطة
    $activeQuery = "SELECT COUNT(*) as total FROM services WHERE is_active = 1";
    $activeResult = $database->selectOne($activeQuery);
    
    // فحص الخدمات الموثقة
    $verifiedQuery = "SELECT COUNT(*) as total FROM services WHERE is_verified = 1";
    $verifiedResult = $database->selectOne($verifiedQuery);
    
    // جلب عينة من الخدمات
    $sampleQuery = "SELECT id, title, is_active, is_verified FROM services LIMIT 5";
    $sampleServices = $database->select($sampleQuery);
    
    $response = [
        'success' => true,
        'data' => [
            'total_services' => $totalResult['total'],
            'active_services' => $activeResult['total'],
            'verified_services' => $verifiedResult['total'],
            'sample_services' => $sampleServices
        ]
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    $response = [
        'success' => false,
        'error' => $e->getMessage()
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
}
?> 