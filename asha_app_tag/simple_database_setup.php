<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

$result = [
    'success' => false,
    'message' => '',
    'details' => []
];

try {
    // الاتصال بـ MySQL بدون تحديد قاعدة بيانات
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
        ]
    );
    
    $result['message'] = 'بدء إنشاء قاعدة البيانات...';
    
    // إنشاء قاعدة البيانات
    $pdo->exec("CREATE DATABASE IF NOT EXISTS asha_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $result['details']['database_created'] = true;
    
    // الاتصال بقاعدة البيانات
    $pdo->exec("USE asha_app");
    $result['details']['database_selected'] = true;
    
    // إنشاء الجداول الأساسية
    $tables = [
        // جدول المستخدمين
        "CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            phone VARCHAR(20),
            password VARCHAR(255) NOT NULL,
            user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
            bio TEXT,
            address TEXT,
            city VARCHAR(100),
            is_verified BOOLEAN DEFAULT FALSE,
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )",
        
        // جدول الفئات
        "CREATE TABLE IF NOT EXISTS categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            image VARCHAR(255),
            is_active BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )",
        
        // جدول الخدمات
        "CREATE TABLE IF NOT EXISTS services (
            id INT AUTO_INCREMENT PRIMARY KEY,
            provider_id INT NOT NULL,
            category_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            description TEXT,
            price DECIMAL(10,2) NOT NULL,
            images JSON,
            city VARCHAR(100),
            is_active BOOLEAN DEFAULT TRUE,
            is_verified BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        )"
    ];
    
    foreach ($tables as $sql) {
        $pdo->exec($sql);
    }
    $result['details']['tables_created'] = true;
    
    // إدخال بيانات افتراضية
    // إضافة فئات
    $categories = [
        ['name' => 'تنظيف المنازل', 'description' => 'خدمات تنظيف شاملة للمنازل والمكاتب'],
        ['name' => 'الكهرباء', 'description' => 'خدمات إصلاح وتوصيل الكهرباء'],
        ['name' => 'السباكة', 'description' => 'خدمات إصلاح وصيانة السباكة'],
        ['name' => 'التصميم الداخلي', 'description' => 'تصميم وتأثيث المنازل'],
        ['name' => 'الحدادة', 'description' => 'أعمال الحديد والحدادة'],
        ['name' => 'النجارة', 'description' => 'أعمال الخشب والنجارة'],
        ['name' => 'التكييف', 'description' => 'تركيب وصيانة أجهزة التكييف'],
        ['name' => 'الحدائق', 'description' => 'تصميم وصيانة الحدائق'],
        ['name' => 'الأمن والحماية', 'description' => 'أنظمة الأمن والمراقبة'],
        ['name' => 'النقل والشحن', 'description' => 'خدمات النقل والشحن']
    ];
    
    foreach ($categories as $category) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO categories (name, description, is_active) VALUES (?, ?, 1)");
        $stmt->execute([$category['name'], $category['description']]);
    }
    $result['details']['categories_added'] = true;
    
    // إضافة مستخدم مدير
    $adminPassword = password_hash('password', PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT IGNORE INTO users (name, email, phone, password, user_type, is_verified, is_active) VALUES (?, ?, ?, ?, 'admin', 1, 1)");
    $stmt->execute(['Admin User', 'admin@asha.com', '777000000', $adminPassword]);
    $result['details']['admin_added'] = true;
    
    // التحقق من البيانات
    $categoryCount = $pdo->query("SELECT COUNT(*) FROM categories WHERE is_active = 1")->fetchColumn();
    $userCount = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    
    $result['success'] = true;
    $result['message'] = 'تم إنشاء قاعدة البيانات بنجاح!';
    $result['details']['category_count'] = $categoryCount;
    $result['details']['user_count'] = $userCount;
    
} catch (Exception $e) {
    $result['success'] = false;
    $result['message'] = 'خطأ في إنشاء قاعدة البيانات: ' . $e->getMessage();
    $result['details']['error'] = $e->getMessage();
}

echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
?> 