<?php
// =====================================================
// إعدادات قاعدة البيانات
// =====================================================

class Database {
    private $host = 'localhost';
    private $db_name = 'asha_app_events';
    private $username = 'root';
    private $password = '';
    private $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                array(
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
                )
            );
        } catch(PDOException $exception) {
            // لا نطبع أي شيء هنا لتجنب إخراج إضافي
            return null;
        }

        return $this->conn;
    }

    public function closeConnection() {
        $this->conn = null;
    }
}

// =====================================================
// دوال مساعدة
// =====================================================

function response($data, $status = 200) {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
}

function error($message, $status = 400) {
    response(['error' => $message], $status);
}

function success($data = null, $message = 'تم بنجاح') {
    $response = ['success' => true, 'message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    response($response);
}

function validateRequired($data, $fields) {
    foreach ($fields as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            error("الحقل '$field' مطلوب");
        }
    }
}

function sanitizeInput($data) {
    if (is_array($data)) {
        return array_map('sanitizeInput', $data);
    }
    return htmlspecialchars(strip_tags(trim($data)));
}

function generateToken($length = 32) {
    return bin2hex(random_bytes($length));
}

function hashPassword($password) {
    return password_hash($password, PASSWORD_DEFAULT);
}

function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

function getCurrentUser() {
    $headers = getallheaders();
    $token = null;
    
    if (isset($headers['Authorization'])) {
        $token = str_replace('Bearer ', '', $headers['Authorization']);
    }
    
    if (!$token) {
        return null;
    }
    
    $db = new Database();
    $conn = $db->getConnection();
    
    $query = "SELECT * FROM users WHERE verification_code = ? AND is_active = 1";
    $stmt = $conn->prepare($query);
    $stmt->execute([$token]);
    
    return $stmt->fetch();
}

function requireAuth() {
    $user = getCurrentUser();
    if (!$user) {
        error('غير مصرح لك بالوصول', 401);
    }
    return $user;
}

function requireProvider() {
    $user = requireAuth();
    if ($user['user_type'] !== 'provider') {
        error('يجب أن تكون مزود خدمة', 403);
    }
    return $user;
}

function requireAdmin() {
    $user = requireAuth();
    if ($user['user_type'] !== 'admin') {
        error('يجب أن تكون مدير', 403);
    }
    return $user;
}

// =====================================================
// إعدادات CORS
// =====================================================

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// =====================================================
// إعدادات المنطقة الزمنية
// =====================================================

date_default_timezone_set('Asia/Aden');

// =====================================================
// إعدادات الأمان
// =====================================================

ini_set('display_errors', 0);
error_reporting(E_ALL);

// =====================================================
// دوال التحقق من الصلاحيات
// =====================================================

function canReview($userId, $serviceId) {
    $db = new Database();
    $conn = $db->getConnection();
    
    // التحقق من وجود حجز مكتمل للخدمة
    $query = "SELECT COUNT(*) as count FROM bookings 
              WHERE user_id = ? AND service_id = ? AND status = 'completed'";
    $stmt = $conn->prepare($query);
    $stmt->execute([$userId, $serviceId]);
    $result = $stmt->fetch();
    
    return $result['count'] > 0;
}

function canBook($userId) {
    $db = new Database();
    $conn = $db->getConnection();
    
    // التحقق من وجود حساب للمستخدم
    $query = "SELECT COUNT(*) as count FROM users WHERE id = ? AND is_active = 1";
    $stmt = $conn->prepare($query);
    $stmt->execute([$userId]);
    $result = $stmt->fetch();
    
    return $result['count'] > 0;
}

function isServiceAvailable($serviceId, $date, $time) {
    $db = new Database();
    $conn = $db->getConnection();
    
    // التحقق من توفر الخدمة في التاريخ والوقت المحددين
    $query = "SELECT COUNT(*) as count FROM bookings 
              WHERE service_id = ? AND booking_date = ? AND booking_time = ? 
              AND status IN ('pending', 'confirmed')";
    $stmt = $conn->prepare($query);
    $stmt->execute([$serviceId, $date, $time]);
    $result = $stmt->fetch();
    
    return $result['count'] == 0;
}

// =====================================================
// دوال إضافية
// =====================================================

function formatPrice($price) {
    return number_format($price, 0, '.', ',') . ' ريال';
}

function formatDate($date) {
    return date('Y-m-d', strtotime($date));
}

function formatDateTime($datetime) {
    return date('Y-m-d H:i:s', strtotime($datetime));
}

function getDistance($lat1, $lon1, $lat2, $lon2) {
    $theta = $lon1 - $lon2;
    $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
    $dist = acos($dist);
    $dist = rad2deg($dist);
    $miles = $dist * 60 * 1.1515;
    return $miles * 1.609344; // تحويل إلى كيلومترات
}

function sendNotification($userId, $title, $message, $type = 'system') {
    $db = new Database();
    $conn = $db->getConnection();
    
    $query = "INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    return $stmt->execute([$userId, $title, $message, $type]);
}

function updateServiceRating($serviceId) {
    $db = new Database();
    $conn = $db->getConnection();
    
    // حساب متوسط التقييم للخدمة
    $query = "SELECT AVG(rating) as avg_rating, COUNT(*) as count FROM reviews WHERE service_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->execute([$serviceId]);
    $result = $stmt->fetch();
    
    // تحديث متوسط التقييم في جدول الخدمات
    $updateQuery = "UPDATE services SET rating_avg = ?, rating_count = ? WHERE id = ?";
    $updateStmt = $conn->prepare($updateQuery);
    return $updateStmt->execute([$result['avg_rating'], $result['count'], $serviceId]);
}
?> 