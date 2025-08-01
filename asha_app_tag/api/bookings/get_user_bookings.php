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
    
    // إنشاء جدول الحجوزات إذا لم يكن موجوداً
    $createTable = "CREATE TABLE IF NOT EXISTS bookings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        service_id INT,
        booking_date DATE,
        booking_time TIME,
        status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
        total_amount DECIMAL(10,2),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
    )";
    $conn->exec($createTable);
    
    // إدراج بيانات تجريبية للحجوزات
    $insertBookings = "INSERT IGNORE INTO bookings (user_id, service_id, booking_date, booking_time, status, total_amount, notes) VALUES 
        (1, 1, '2025-08-15', '18:00:00', 'confirmed', 500000.00, 'حفل زفاف'),
        (1, 3, '2025-08-20', '14:00:00', 'pending', 4000.00, 'حلويات مناسبة'),
        (1, 5, '2025-08-25', '16:00:00', 'completed', 500000.00, 'تصوير احترافي')";
    $conn->exec($insertBookings);
    
    // جلب الحجوزات مع معلومات الخدمة والمزود
    $query = "SELECT 
                b.id,
                b.user_id,
                b.service_id,
                b.booking_date,
                b.booking_time,
                b.status,
                b.total_amount,
                b.notes,
                b.created_at,
                s.title as service_title,
                s.description as service_description,
                s.price,
                s.images,
                u.name as provider_name,
                u.id as provider_id,
                c.name as category_name,
                c.id as category_id
              FROM bookings b
              INNER JOIN services s ON b.service_id = s.id
              INNER JOIN users u ON s.provider_id = u.id
              INNER JOIN categories c ON s.category_id = c.id
              WHERE b.user_id = ?
              ORDER BY b.created_at DESC";
    
    $stmt = $conn->prepare($query);
    $stmt->execute([1]); // استخدام user_id = 1 للاختبار
    $bookings = $stmt->fetchAll();
    
    // تحويل البيانات للتأكد من التوافق مع Flutter
    foreach ($bookings as &$booking) {
        $booking['id'] = (int)$booking['id'];
        $booking['user_id'] = (int)$booking['user_id'];
        $booking['service_id'] = (int)$booking['service_id'];
        $booking['provider_id'] = (int)$booking['provider_id'];
        $booking['category_id'] = (int)$booking['category_id'];
        $booking['total_amount'] = (float)$booking['total_amount'];
        $booking['price'] = (float)$booking['price'];
        
        // تحويل الصور من JSON
        if ($booking['images']) {
            $images = json_decode($booking['images'], true);
            $booking['images'] = is_array($images) ? $images : [];
        } else {
            $booking['images'] = [];
        }
    }
    
    echo json_encode([
        'success' => true,
        'data' => $bookings,
        'count' => count($bookings),
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

