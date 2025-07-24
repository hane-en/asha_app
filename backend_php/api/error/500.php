<?php
header('Content-Type: application/json; charset=utf-8');
http_response_code(500);

echo json_encode([
    'error' => 'خطأ في الخادم',
    'message' => 'حدث خطأ داخلي في الخادم',
    'status' => 500
], JSON_UNESCAPED_UNICODE);
?> 