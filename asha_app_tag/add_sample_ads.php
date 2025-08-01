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
    
    $results = [];
    
    // حذف الإعلانات القديمة
    $stmt = $pdo->prepare("DELETE FROM ads WHERE id > 0");
    $stmt->execute();
    $results['ads_deleted'] = $stmt->rowCount();
    
    // إعادة تعيين auto increment
    $stmt = $pdo->prepare("ALTER TABLE ads AUTO_INCREMENT = 1");
    $stmt->execute();
    
    // إضافة إعلانات تجريبية
    $ads = [
        [
            'title' => 'جار الله',
            'description' => 'فساتين أنيقة وبأسعار منافسة',
            'provider_name' => 'یمن ساوند',
            'image_url' => 'https://via.placeholder.com/300x200/8e24aa/ffffff?text=جار+الله',
            'is_active' => 1
        ],
        [
            'title' => 'وليد التركي',
            'description' => 'فساتين عصرية ومميزة',
            'provider_name' => 'جار الله',
            'image_url' => 'https://via.placeholder.com/300x200/ff9800/ffffff?text=وليد+التركي',
            'is_active' => 1
        ],
        [
            'title' => 'یمن ساوند',
            'description' => 'صوتیات احترافية للمناسبات',
            'provider_name' => 'وليد التركي',
            'image_url' => 'https://via.placeholder.com/300x200/4caf50/ffffff?text=یمن+ساوند',
            'is_active' => 1
        ],
        [
            'title' => 'فاحة ومميزة',
            'description' => 'جاتوهات فاخرة للمناسبات',
            'provider_name' => 'فاطمة علي',
            'image_url' => 'https://via.placeholder.com/300x200/e91e63/ffffff?text=فاحة+ومميزة',
            'is_active' => 1
        ],
        [
            'title' => 'أحمد التصوير',
            'description' => 'تصوير احترافي للمناسبات',
            'provider_name' => 'أحمد محمد',
            'image_url' => 'https://via.placeholder.com/300x200/2196f3/ffffff?text=أحمد+التصوير',
            'is_active' => 1
        ],
        [
            'title' => 'سارة الديكور',
            'description' => 'تزيين احترافي للمناسبات',
            'provider_name' => 'سارة أحمد',
            'image_url' => 'https://via.placeholder.com/300x200/9c27b0/ffffff?text=سارة+الديكور',
            'is_active' => 1
        ]
    ];
    
    $stmt = $pdo->prepare("INSERT INTO ads (title, description, provider_name, image_url, is_active, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
    
    foreach ($ads as $ad) {
        $stmt->execute([
            $ad['title'],
            $ad['description'],
            $ad['provider_name'],
            $ad['image_url'],
            $ad['is_active']
        ]);
    }
    
    $results['ads_added'] = count($ads);
    
    // جلب الإحصائيات النهائية
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM ads WHERE is_active = 1");
    $totalAds = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
    
    echo json_encode([
        'success' => true,
        'message' => 'تم إضافة الإعلانات التجريبية بنجاح',
        'data' => [
            'results' => $results,
            'statistics' => [
                'total_ads' => (int)$totalAds
            ]
        ]
    ], JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في إضافة الإعلانات: ' . $e->getMessage(),
        'data' => []
    ], JSON_UNESCAPED_UNICODE);
}
?> 