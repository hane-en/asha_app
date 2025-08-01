<?php
// إنشاء جدول الإعلانات
$host = 'localhost';
$username = 'root';
$password = '';

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO("mysql:host=$host;dbname=asha_app_events;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "تم الاتصال بقاعدة البيانات بنجاح\n";
    
    // إنشاء جدول الإعلانات
    $sql = "CREATE TABLE IF NOT EXISTS ads (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        image VARCHAR(255),
        link_url VARCHAR(255),
        provider_id INT,
        is_active BOOLEAN DEFAULT TRUE,
        is_featured BOOLEAN DEFAULT FALSE,
        start_date DATE,
        end_date DATE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE SET NULL,
        INDEX idx_is_active (is_active),
        INDEX idx_is_featured (is_featured),
        INDEX idx_provider_id (provider_id)
    )";
    $pdo->exec($sql);
    echo "تم إنشاء جدول الإعلانات\n";
    
    // إدراج بيانات الإعلانات
    $ads = [
        ['إعلان خاص', 'إعلان تجريبي للتطبيق', 'ad1.jpg', 'https://example.com', 2, true, true, '2025-01-01', '2025-12-31'],
        ['عرض خاص', 'عروض حصرية للمناسبات', 'ad2.jpg', 'https://example.com', 3, true, true, '2025-01-01', '2025-12-31'],
        ['خدمات مميزة', 'أفضل الخدمات في المنطقة', 'ad3.jpg', 'https://example.com', 4, true, true, '2025-01-01', '2025-12-31']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO ads (title, description, image, link_url, provider_id, is_active, is_featured, start_date, end_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($ads as $ad) {
        $stmt->execute($ad);
    }
    echo "تم إدراج بيانات الإعلانات\n";
    
    echo "تم إنشاء جدول الإعلانات بنجاح!\n";
    
} catch(PDOException $e) {
    echo "خطأ في الاتصال: " . $e->getMessage() . "\n";
} catch(Exception $e) {
    echo "خطأ: " . $e->getMessage() . "\n";
}
?> 