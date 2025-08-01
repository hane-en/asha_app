<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once '../../config.php';

try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );

    // التحقق من وجود category_id
    if (!isset($_GET['category_id']) || !is_numeric($_GET['category_id'])) {
        throw new Exception('معرف الفئة مطلوب ويجب أن يكون رقماً');
    }

    $categoryId = (int)$_GET['category_id'];

    // جلب المزودين الذين لديهم خدمات في هذه الفئة
    $query = "
        SELECT DISTINCT
            u.id,
            u.name,
            u.bio as description,
            u.profile_image,
            u.rating,
            u.review_count,
            u.is_verified,
            u.is_active,
            u.website,
            u.address,
            u.city,
            u.country,
            u.latitude,
            u.longitude,
            u.created_at,
            u.updated_at,
            COUNT(DISTINCT s.id) as services_count,
            COUNT(DISTINCT b.id) as bookings_count
        FROM users u
        INNER JOIN services s ON u.id = s.provider_id
        LEFT JOIN bookings b ON s.id = b.service_id
        WHERE u.user_type = 'provider'
        AND u.is_active = TRUE
        AND s.category_id = :category_id
        AND s.is_active = TRUE
        GROUP BY u.id
        ORDER BY u.rating DESC, u.review_count DESC
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute(['category_id' => $categoryId]);
    $providers = $stmt->fetchAll();

    // تنسيق البيانات
    $formattedProviders = [];
    foreach ($providers as $provider) {
        $formattedProviders[] = [
            'id' => (int)$provider['id'],
            'name' => $provider['name'],
            'description' => $provider['description'],
            'profile_image' => $provider['profile_image'],
            'rating' => (float)$provider['rating'],
            'review_count' => (int)$provider['review_count'],
            'is_verified' => (bool)$provider['is_verified'],
            'is_active' => (bool)$provider['is_active'],
            'bio' => $provider['description'],
            'website' => $provider['website'],
            'address' => $provider['address'],
            'city' => $provider['city'] ?: 'إب',
            'country' => $provider['country'] ?: 'اليمن',
            'latitude' => $provider['latitude'] ? (float)$provider['latitude'] : null,
            'longitude' => $provider['longitude'] ? (float)$provider['longitude'] : null,
            'created_at' => $provider['created_at'],
            'updated_at' => $provider['updated_at'],
            'services_count' => (int)$provider['services_count'],
            'bookings_count' => (int)$provider['bookings_count'],
        ];
    }

    echo json_encode([
        'success' => true,
        'message' => 'تم جلب المزودين بنجاح',
        'data' => $formattedProviders,
        'count' => count($formattedProviders)
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'خطأ في قاعدة البيانات',
        'error' => DEBUG_MODE ? $e->getMessage() : null
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    error_log("General Error: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
        'error' => DEBUG_MODE ? $e->getMessage() : null
    ], JSON_UNESCAPED_UNICODE);
}
?> 