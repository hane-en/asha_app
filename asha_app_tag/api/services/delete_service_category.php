<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';
require_once '../../database.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'طريقة الطلب غير مسموحة',
        'data' => null
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // قراءة البيانات المرسلة
    $input = json_decode(file_get_contents('php://input'), true);
    
    // التحقق من وجود معرف فئة الخدمة
    if (!isset($input['id']) || empty($input['id'])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'معرف فئة الخدمة مطلوب',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    $category_id = intval($input['id']);
    
    // التحقق من وجود فئة الخدمة
    $stmt = $pdo->prepare("
        SELECT 
            sc.*,
            s.title as service_title,
            u.name as provider_name
        FROM service_categories sc
        INNER JOIN services s ON sc.service_id = s.id
        INNER JOIN users u ON s.provider_id = u.id
        WHERE sc.id = ?
    ");
    $stmt->execute([$category_id]);
    $category = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$category) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'فئة الخدمة غير موجودة',
            'data' => null
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    // حذف فئة الخدمة
    $stmt = $pdo->prepare("DELETE FROM service_categories WHERE id = ?");
    $result = $stmt->execute([$category_id]);
    
    if ($result) {
        echo json_encode([
            'success' => true,
            'message' => 'تم حذف فئة الخدمة بنجاح',
            'data' => [
                'id' => $category_id,
                'name' => $category['name'],
                'service_title' => $category['service_title'],
                'provider_name' => $category['provider_name']
            ]
        ], JSON_UNESCAPED_UNICODE);
    } else {
        throw new Exception('فشل في حذف فئة الخدمة');
    }
    
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