<?php
/**
 * ملف تسجيل المستخدمين الجدد
 * User Registration API
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config.php';

// التحقق من نوع الطلب
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    // قراءة البيانات المرسلة
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Invalid JSON data');
    }
    
    // التحقق من البيانات المطلوبة
    $required_fields = ['name', 'email', 'phone', 'password', 'user_type'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            throw new Exception("Field '$field' is required");
        }
    }
    
    // التحقق من نوع المستخدم
    $allowed_user_types = ['user', 'provider', 'admin'];
    if (!in_array($input['user_type'], $allowed_user_types)) {
        throw new Exception('Invalid user type');
    }
    
    // التحقق من صحة البريد الإلكتروني
    if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Invalid email format');
    }
    
    // التحقق من صحة رقم الهاتف
    if (!preg_match('/^[0-9]{9,15}$/', $input['phone'])) {
        throw new Exception('Invalid phone number format');
    }
    
    // التحقق من قوة كلمة المرور
    if (strlen($input['password']) < 6) {
        throw new Exception('Password must be at least 6 characters long');
    }
    
    // التحقق من رقم حساب الكريمي لمزودي الخدمات
    if ($input['user_type'] === 'provider') {
        if (!isset($input['kareemi_account_number']) || empty($input['kareemi_account_number'])) {
            throw new Exception('Kareemi account number is required for providers');
        }
        
        // التحقق من صحة رقم حساب الكريمي - يجب أن يبدأ برقم 3 ويتكون من 10 أرقام بالضبط
        if (!preg_match('/^3[0-9]{9}$/', $input['kareemi_account_number'])) {
            throw new Exception('Kareemi account number must start with 3 and be exactly 10 digits');
        }
    }
    
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
    
    // التحقق من عدم وجود البريد الإلكتروني مسبقاً
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$input['email']]);
    if ($stmt->fetch()) {
        throw new Exception('Email already exists');
    }
    
    // التحقق من عدم وجود رقم الهاتف مسبقاً
    $stmt = $pdo->prepare("SELECT id FROM users WHERE phone = ?");
    $stmt->execute([$input['phone']]);
    if ($stmt->fetch()) {
        throw new Exception('Phone number already exists');
    }
    
    // تشفير كلمة المرور
    $hashed_password = password_hash($input['password'], PASSWORD_DEFAULT);
    
    // إعداد البيانات للإدراج
    $user_data = [
        'name' => trim($input['name']),
        'email' => strtolower(trim($input['email'])),
        'phone' => trim($input['phone']),
        'password' => $hashed_password,
        'user_type' => $input['user_type'],
        'is_verified' => $input['user_type'] === 'admin' ? 1 : 0,
        'is_active' => 1
    ];
    
    // إضافة رقم حساب الكريمي لمزودي الخدمات
    if ($input['user_type'] === 'provider') {
        $user_data['kareemi_account_number'] = trim($input['kareemi_account_number']);
        $user_data['is_yemeni_account'] = 1;
    }
    
    // إدراج المستخدم الجديد
    $columns = implode(', ', array_keys($user_data));
    $placeholders = ':' . implode(', :', array_keys($user_data));
    
    $stmt = $pdo->prepare("INSERT INTO users ($columns) VALUES ($placeholders)");
    $stmt->execute($user_data);
    
    $user_id = $pdo->lastInsertId();
    
    // جلب بيانات المستخدم المُنشأ
    $stmt = $pdo->prepare("SELECT id, name, email, phone, user_type, is_verified, is_active, created_at FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();
    
    // إنشاء JWT token
    $payload = [
        'user_id' => $user['id'],
        'email' => $user['email'],
        'user_type' => $user['user_type'],
        'iat' => time(),
        'exp' => time() + JWT_EXPIRE
    ];
    
    $token = base64_encode(json_encode($payload));
    
    // إرسال الاستجابة
    echo json_encode([
        'success' => true,
        'message' => 'تم التسجيل بنجاح',
        'data' => [
            'user' => $user,
            'token' => $token,
            'expires_in' => JWT_EXPIRE
        ]
    ]);
    
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