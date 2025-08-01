<?php
// إنشاء الجداول يدوياً
$host = 'localhost';
$username = 'root';
$password = '';

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO("mysql:host=$host;dbname=asha_app_events;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "تم الاتصال بقاعدة البيانات بنجاح\n";
    
    // إنشاء جدول الفئات
    $sql = "CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        image VARCHAR(255),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_is_active (is_active)
    )";
    $pdo->exec($sql);
    echo "تم إنشاء جدول الفئات\n";
    
    // إنشاء جدول المستخدمين
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) UNIQUE,
        password VARCHAR(255) NOT NULL,
        user_type ENUM('user', 'provider', 'admin') DEFAULT 'user',
        bio TEXT,
        address TEXT,
        city VARCHAR(100),
        is_verified BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        verification_code VARCHAR(255),
        reset_code VARCHAR(255),
        last_login_at TIMESTAMP NULL,
        website VARCHAR(255),
        latitude DECIMAL(10,8),
        longitude DECIMAL(11,8),
        user_category VARCHAR(100),
        is_yemeni_account BOOLEAN DEFAULT FALSE,
        INDEX idx_email (email),
        INDEX idx_phone (phone),
        INDEX idx_user_type (user_type),
        INDEX idx_is_active (is_active),
        INDEX idx_city (city)
    )";
    $pdo->exec($sql);
    echo "تم إنشاء جدول المستخدمين\n";
    
    // إنشاء جدول الخدمات
    $sql = "CREATE TABLE IF NOT EXISTS services (
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
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
        INDEX idx_provider_id (provider_id),
        INDEX idx_category_id (category_id),
        INDEX idx_is_active (is_active),
        INDEX idx_city (city)
    )";
    $pdo->exec($sql);
    echo "تم إنشاء جدول الخدمات\n";
    
    // إدراج بيانات الفئات
    $categories = [
        ['قاعات الأفراح', 'قاعات احتفالات وأفراح', 'wedding_halls.jpg'],
        ['الموسيقى والصوت', 'خدمات الموسيقى والصوتيات', 'music_sound.jpg'],
        ['التصوير', 'خدمات التصوير الاحترافي', 'photography.jpg'],
        ['التزيين والديكور', 'خدمات التزيين والديكور', 'decoration.jpg'],
        ['الحلويات', 'حلويات المناسبات', 'sweets.jpg'],
        ['الأزياء', 'فساتين وأزياء المناسبات', 'fashion.jpg']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO categories (name, description, image) VALUES (?, ?, ?)");
    foreach ($categories as $category) {
        $stmt->execute($category);
    }
    echo "تم إدراج بيانات الفئات\n";
    
    // إدراج بيانات المستخدمين
    $users = [
        ['Admin User', 'admin@asha.com', '777000000', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'],
        ['قاعة الزين', 'alzeen@gamil.com', '777111333', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['قاعة قصر غمدان', 'kasrgmdan@gmail.com', '775432123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['إشراق السالمي', 'eshraq@gmail.com', '789765432', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['أضواء فوتو', 'adhwaa@gmail.com', '786789890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['سونا كيك', 'sonacake@gmail.com', '712345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['نوركيك', 'noorcake@gmail.com', '711234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['بارتي كوين', 'barty@gmail.com', '78621678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['ضوء القمر', 'dowaa@gmail.com', '732123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['جار الله', 'gar@gmail.com', '7821234543', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['وليد التركي', 'waleed@gmail.com', '701234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider'],
        ['يمن ساوند', 'yemensound@gmail.com', '711234654', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'provider']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO users (name, email, phone, password, user_type) VALUES (?, ?, ?, ?, ?)");
    foreach ($users as $user) {
        $stmt->execute($user);
    }
    echo "تم إدراج بيانات المستخدمين\n";
    
    // إدراج بيانات الخدمات
    $services = [
        [2, 1, 'قاعة الزين', 'قاعة تلبي كل المناسبات', 500000.00, 'إب'],
        [3, 1, 'قاعة قصر غمدان', 'من أكير القاعات في محافظة إب', 600000.00, 'إب'],
        [6, 5, 'سونا كيك', 'حلويات مناسبتك علينا', 4000.00, 'إب'],
        [7, 5, 'نور كيك', 'لتلبية جميع متطلبات توزيعات المناسبات', 2000.00, 'إب'],
        [5, 3, 'أضواء فوتو', 'لتصوير كل المناسبات والأفراح', 500000.00, 'إب'],
        [4, 3, 'إشراق السالمي', 'تصويرجميع المناسبات', 3000.00, 'إب'],
        [8, 4, 'بارتي كوين', 'لتزين واضافة البهجة إلى جميع المناسبات', 20000.00, 'إب'],
        [9, 4, 'ضوء القمر', 'كل لمسة جميلة نحن عنوانها', 300000.00, 'إب'],
        [11, 2, 'يمن ساوند', 'لإحياء كل المناسبات', 500000.00, 'إب'],
        [10, 6, 'وليد التركي', 'لجميع فساتين المناسبات والأفراح', 100000.00, 'إب'],
        [12, 6, 'جار الله', 'الجمال عندنا', 20000.00, 'إب']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO services (provider_id, category_id, title, description, price, city) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($services as $service) {
        $stmt->execute($service);
    }
    echo "تم إدراج بيانات الخدمات\n";
    
    echo "تم إنشاء جميع الجداول والبيانات بنجاح!\n";
    
} catch(PDOException $e) {
    echo "خطأ في الاتصال: " . $e->getMessage() . "\n";
} catch(Exception $e) {
    echo "خطأ: " . $e->getMessage() . "\n";
}
?> 