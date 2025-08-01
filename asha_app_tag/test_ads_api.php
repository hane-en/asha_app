<?php
// اختبار API الإعلانات
header('Content-Type: application/json; charset=utf-8');

// محاكاة طلب GET
$_SERVER['REQUEST_METHOD'] = 'GET';

// تضمين ملف API الإعلانات
require_once 'api/ads/get_active_ads.php';
?> 