<?php
// ملف اختبار بسيط للخادم
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'success' => true,
    'message' => 'الخادم يعمل بشكل صحيح',
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => PHP_VERSION,
    'server_info' => [
        'software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        'method' => $_SERVER['REQUEST_METHOD'] ?? 'Unknown',
        'uri' => $_SERVER['REQUEST_URI'] ?? 'Unknown'
    ]
], JSON_UNESCAPED_UNICODE);
?> 