<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// التعامل مع طلبات OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'api/config/database.php';

try {
    $db = new Database();
    $pdo = $db->getConnection();
    
    if (!$pdo) {
        throw new Exception('فشل في الاتصال بقاعدة البيانات');
    }
    
    // بدء المعاملة
    $pdo->beginTransaction();
    
    $results = [];
    
                    // إضافة فئات تجريبية أولاً
                $categories = [
                    ['قاعات الأفراح', 'قاعات احتفالات وأفراح', 'celebration', '#8e24aa'],
                    ['التصوير', 'خدمات التصوير الاحترافي للمناسبات', 'camera_alt', '#ff9800'],
                    ['الديكور', 'خدمات تزيين المناسبات', 'local_florist', '#4caf50'],
                    ['الجاتوهات', 'جاتوهات وحلويات للمناسبات', 'cake', '#e91e63'],
                    ['الموسيقى', 'خدمات الموسيقى والعزف', 'music_note', '#2196f3'],
                    ['الفساتين', 'فساتين وأزياء المناسبات', 'checkroom', '#9c27b0']
                ];
                
                $stmt = $pdo->prepare("INSERT IGNORE INTO categories (name, description, icon, color, is_active, created_at) VALUES (?, ?, ?, ?, 1, NOW())");
                
                foreach ($categories as $category) {
                    $stmt->execute($category);
                }
                
                $results['categories_added'] = count($categories);
                
                // إضافة مزودين تجريبيين
                $providers = [
                    ['أحمد محمد', 'ahmed@example.com', '0501234567', 'provider', 1, 4.5, 12],
                    ['فاطمة علي', 'fatima@example.com', '0502345678', 'provider', 1, 4.8, 25],
                    ['محمد حسن', 'mohammed@example.com', '0503456789', 'provider', 1, 4.2, 8],
                    ['سارة أحمد', 'sara@example.com', '0504567890', 'provider', 0, 4.0, 5],
                    ['علي محمود', 'ali@example.com', '0505678901', 'provider', 1, 4.7, 18],
                    ['نورا سعيد', 'nora@example.com', '0506789012', 'provider', 1, 4.9, 30],
                    ['خالد عبدالله', 'khalid@example.com', '0507890123', 'provider', 0, 3.8, 3],
                    ['ليلى محمد', 'layla@example.com', '0508901234', 'provider', 1, 4.6, 15],
                    ['عمر يوسف', 'omar@example.com', '0509012345', 'provider', 1, 4.3, 10],
                    ['رنا أحمد', 'rana@example.com', '0500123456', 'provider', 1, 4.4, 22]
                ];
    
    $stmt = $pdo->prepare("INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, created_at) VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?, NOW())");
    
    foreach ($providers as $provider) {
        $password = password_hash('password123', PASSWORD_DEFAULT);
        $stmt->execute([$provider[0], $provider[1], $provider[2], $password, $provider[3], $provider[4], $provider[5], $provider[6]]);
    }
    
    $results['providers_added'] = count($providers);
    
    // إضافة فئات تجريبية
    $categories = [
        ['التصوير', 'خدمات التصوير الاحترافي للمناسبات', 'camera', '#FF6B6B'],
        ['قاعات الأفراح', 'قاعات احتفالات وأفراح', 'celebration', '#4ECDC4'],
        ['الموسيقى', 'خدمات الموسيقى والعزف', 'music', '#45B7D1'],
        ['التزيين', 'خدمات تزيين المناسبات', 'decorations', '#96CEB4'],
        ['الحلويات', 'حلويات ومخبوزات للمناسبات', 'cake', '#FFEAA7'],
        ['الأزياء', 'أزياء وتأجير ملابس', 'fashion', '#DDA0DD']
    ];
    
    $stmt = $pdo->prepare("INSERT IGNORE INTO categories (name, description, icon, color, is_active, created_at) VALUES (?, ?, ?, ?, 1, NOW())");
    
    foreach ($categories as $category) {
        $stmt->execute($category);
    }
    
    $results['categories_added'] = count($categories);
    
    // إضافة خدمات تجريبية
    $services = [
        // خدمات فاطمة علي (قاعات الأفراح)
        [2, 1, 'قاعة أفراح فاخرة', 'قاعة أفراح فاخرة تتسع لـ 200 شخص', 2000.00, 4.8],
        [2, 1, 'قاعة احتفالات صغيرة', 'قاعة احتفالات صغيرة للمناسبات العائلية', 1000.00, 4.7],
        
        // خدمات أحمد محمد (التصوير)
        [1, 2, 'تصوير احترافي للمناسبات', 'تصوير احترافي عالي الجودة لجميع المناسبات', 500.00, 4.5],
        [1, 2, 'تصوير فيديو للمناسبات', 'تصوير فيديو احترافي مع مونتاج', 800.00, 4.6],
        
        // خدمات سارة أحمد (الديكور)
        [4, 3, 'تزيين قاعات الأفراح', 'تزيين احترافي لقاعات الأفراح', 300.00, 4.0],
        [4, 3, 'تزيين مناسبات عائلية', 'تزيين بسيط للمناسبات العائلية', 150.00, 4.2],
        
        // خدمات علي محمود (الجاتوهات)
        [5, 4, 'جاتوهات عيد الميلاد', 'جاتوهات احترافية لعيد الميلاد', 200.00, 4.7],
        [5, 4, 'جاتوهات الأفراح', 'جاتوهات فاخرة لحفلات الأفراح', 300.00, 4.6],
        
        // خدمات محمد حسن (الموسيقى)
        [3, 5, 'عزف موسيقي للمناسبات', 'عزف موسيقي احترافي لجميع المناسبات', 600.00, 4.2],
        [3, 5, 'دجاجي وطرب', 'دجاجي وطرب تقليدي للمناسبات', 400.00, 4.1],
        
        // خدمات نورا سعيد (الفساتين)
        [6, 6, 'تأجير فساتين العروس', 'تأجير فساتين عروس فاخرة', 500.00, 4.9],
        [6, 6, 'تأجير بدلات الرجال', 'تأجير بدلات رسمية للرجال', 200.00, 4.8],
        
        // خدمات خالد عبدالله (التصوير)
        [7, 2, 'تصوير بسيط للمناسبات', 'تصوير بسيط للمناسبات العائلية', 200.00, 3.8],
        
        // خدمات ليلى محمد (الموسيقى)
        [8, 5, 'عزف البيانو', 'عزف البيانو للمناسبات الرومانسية', 700.00, 4.6],
        [8, 5, 'غناء عربي', 'غناء عربي تقليدي للمناسبات', 500.00, 4.5],
        
        // خدمات عمر يوسف (الديكور)
        [9, 3, 'تزيين حدائق', 'تزيين احترافي للحدائق والمناطق الخارجية', 400.00, 4.3],
        
        // خدمات رنا أحمد (الجاتوهات)
        [10, 4, 'جاتوهات غربية', 'جاتوهات غربية متنوعة', 250.00, 4.4],
        [10, 4, 'جاتوهات عربية', 'جاتوهات عربية تقليدية', 180.00, 4.3]
    ];
    
    $stmt = $pdo->prepare("INSERT INTO services (provider_id, category_id, title, description, price, rating, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, 1, NOW())");
    
    foreach ($services as $service) {
        $stmt->execute($service);
    }
    
    $results['services_added'] = count($services);
    
    // إضافة مستخدمين عاديين
    $users = [
        ['مستخدم تجريبي 1', 'user1@example.com', '0501111111'],
        ['مستخدم تجريبي 2', 'user2@example.com', '0502222222'],
        ['مستخدم تجريبي 3', 'user3@example.com', '0503333333']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO users (name, email, phone, password, user_type, is_verified, is_active, rating, total_reviews, created_at) VALUES (?, ?, ?, ?, 'user', 1, 1, 0.0, 0, NOW())");
    
    foreach ($users as $user) {
        $password = password_hash('password123', PASSWORD_DEFAULT);
        $stmt->execute([$user[0], $user[1], $user[2], $password]);
    }
    
    $results['users_added'] = count($users);
    
    // إضافة تقييمات تجريبية
    $reviews = [
        [11, 1, 5, 'تصوير ممتاز وجودة عالية'],
        [11, 3, 4, 'قاعة جميلة وخدمة ممتازة'],
        [12, 2, 5, 'فيديو احترافي جداً'],
        [12, 4, 4, 'قاعة مناسبة للمناسبات العائلية'],
        [13, 5, 4, 'عزف جميل وموسيقى هادئة'],
        [13, 7, 5, 'تزيين رائع ومبدع']
    ];
    
    $stmt = $pdo->prepare("INSERT INTO reviews (user_id, service_id, rating, comment, created_at) VALUES (?, ?, ?, ?, NOW())");
    
    foreach ($reviews as $review) {
        $stmt->execute($review);
    }
    
    $results['reviews_added'] = count($reviews);
    
    // تأكيد المعاملة
    $pdo->commit();
    
    // جلب الإحصائيات النهائية
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE user_type = 'provider' AND is_active = 1");
    $totalProviders = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE user_type = 'user' AND is_active = 1");
    $totalUsers = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM services WHERE is_active = 1");
    $totalServices = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM categories WHERE is_active = 1");
    $totalCategories = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إضافة البيانات التجريبية بنجاح',
        'data' => [
            'results' => $results,
            'statistics' => [
                'total_providers' => (int)$totalProviders,
                'total_users' => (int)$totalUsers,
                'total_services' => (int)$totalServices,
                'total_categories' => (int)$totalCategories
            ]
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    // التراجع عن المعاملة في حالة الخطأ
    if (isset($pdo)) {
        $pdo->rollBack();
    }
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في إضافة البيانات التجريبية: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 