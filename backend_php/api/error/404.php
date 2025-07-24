<?php
header('Content-Type: application/json; charset=utf-8');
http_response_code(404);

echo json_encode([
    'error' => 'API غير موجود',
    'message' => 'المسار المطلوب غير موجود',
    'status' => 404
], JSON_UNESCAPED_UNICODE);
?> 