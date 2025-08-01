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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'طريقة الطلب غير مدعومة'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('بيانات غير صحيحة');
    }
    
    $name = $input['name'] ?? '';
    $phone = $input['phone'] ?? '';
    $service = $input['service'] ?? '';
    
    if (empty($name) || empty($phone) || empty($service)) {
        throw new Exception('جميع الحقول مطلوبة');
    }
    
    if (strlen($name) < 2) {
        throw new Exception('الاسم يجب أن يكون حرفين على الأقل');
    }
    
    if (strlen($phone) < 10) {
        throw new Exception('رقم الهاتف غير صحيح');
    }
    
    $db = new Database();
    $conn = $db->getConnection();
    
    if (!$conn) {
        throw new Exception("خطأ في الاتصال بقاعدة البيانات");
    }
    
    // إنشاء جدول طلبات الانضمام إذا لم يكن موجوداً
    $createTable = "CREATE TABLE IF NOT EXISTS provider_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        service VARCHAR(255) NOT NULL,
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )";
    $conn->exec($createTable);
    
    // إدراج طلب الانضمام
    $query = "INSERT INTO provider_requests (name, phone, service) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->execute([$name, $phone, $service]);
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إرسال طلب الانضمام بنجاح. سنتواصل معك قريباً.',
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE);
}
?> 