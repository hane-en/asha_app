<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../../config/database.php';

$pdo = getDBConnection();
if (!$pdo) {
    echo json_encode(['success' => false, 'message' => 'فشل الاتصال بقاعدة البيانات']);
    exit;
}

$provider_id = isset($_GET['provider_id']) ? intval($_GET['provider_id']) : 0;
if ($provider_id <= 0) {
    echo json_encode(['success' => false, 'message' => 'معرف المزود غير صحيح']);
    exit;
}

// إحصائيات عامة
$stats = [
    'services' => 0,
    'bookings' => 0,
    'ads' => 0,
    'rating' => 0.0,
];

// عدد الخدمات
$stmt = $pdo->prepare('SELECT COUNT(*) FROM services WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$stats['services'] = $stmt->fetchColumn();

// عدد الحجوزات
$stmt = $pdo->prepare('SELECT COUNT(*) FROM bookings WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$stats['bookings'] = $stmt->fetchColumn();

// عدد الإعلانات
$stmt = $pdo->prepare('SELECT COUNT(*) FROM ads WHERE provider_id = ?');
$stmt->execute([$provider_id]);
$stats['ads'] = $stmt->fetchColumn();

// متوسط التقييمات
$stmt = $pdo->prepare('SELECT AVG(rating) FROM reviews WHERE service_id IN (SELECT id FROM services WHERE provider_id = ?)');
$stmt->execute([$provider_id]);
$stats['rating'] = round(floatval($stmt->fetchColumn()), 2);

// الحجوزات الأخيرة (آخر 5)
$stmt = $pdo->prepare('SELECT s.title AS service, b.booking_date AS date, b.status FROM bookings b JOIN services s ON b.service_id = s.id WHERE b.provider_id = ? ORDER BY b.booking_date DESC LIMIT 5');
$stmt->execute([$provider_id]);
$recent_bookings = $stmt->fetchAll();

echo json_encode([
    'success' => true,
    'stats' => $stats,
    'recent_bookings' => $recent_bookings
]); 