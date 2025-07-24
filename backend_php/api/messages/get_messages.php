<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(['error' => 'Method not allowed'], 405);
}

$token = verifyToken();

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    $offset = ($page - 1) * $limit;
    
    $otherUserId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    
    if ($otherUserId) {
        // جلب الرسائل مع مستخدم محدد
        $sql = "
            SELECT m.*, 
                   u1.name as sender_name, u1.profile_image as sender_image,
                   u2.name as receiver_name, u2.profile_image as receiver_image
            FROM messages m
            JOIN users u1 ON m.sender_id = u1.id
            JOIN users u2 ON m.receiver_id = u2.id
            WHERE (m.sender_id = ? AND m.receiver_id = ?) 
               OR (m.sender_id = ? AND m.receiver_id = ?)
            ORDER BY m.created_at ASC
            LIMIT ? OFFSET ?
        ";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$token->user_id, $otherUserId, $otherUserId, $token->user_id, $limit, $offset]);
        $messages = $stmt->fetchAll();
        
        // تحديث الرسائل كمقروءة
        $stmt = $pdo->prepare("
            UPDATE messages 
            SET is_read = 1 
            WHERE receiver_id = ? AND sender_id = ? AND is_read = 0
        ");
        $stmt->execute([$token->user_id, $otherUserId]);
        
        // جلب العدد الإجمالي
        $countSql = "
            SELECT COUNT(*) as total 
            FROM messages 
            WHERE (sender_id = ? AND receiver_id = ?) 
               OR (sender_id = ? AND receiver_id = ?)
        ";
        $stmt = $pdo->prepare($countSql);
        $stmt->execute([$token->user_id, $otherUserId, $otherUserId, $token->user_id]);
        $total = $stmt->fetch()['total'];
        
    } else {
        // جلب قائمة المحادثات
        $sql = "
            SELECT 
                CASE 
                    WHEN m.sender_id = ? THEN m.receiver_id
                    ELSE m.sender_id
                END as other_user_id,
                CASE 
                    WHEN m.sender_id = ? THEN u2.name
                    ELSE u1.name
                END as other_user_name,
                CASE 
                    WHEN m.sender_id = ? THEN u2.profile_image
                    ELSE u1.profile_image
                END as other_user_image,
                m.message as last_message,
                m.created_at as last_message_time,
                COUNT(CASE WHEN m.receiver_id = ? AND m.is_read = 0 THEN 1 END) as unread_count
            FROM messages m
            JOIN users u1 ON m.sender_id = u1.id
            JOIN users u2 ON m.receiver_id = u2.id
            WHERE m.sender_id = ? OR m.receiver_id = ?
            GROUP BY other_user_id
            ORDER BY last_message_time DESC
            LIMIT ? OFFSET ?
        ";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$token->user_id, $token->user_id, $token->user_id, $token->user_id, $token->user_id, $limit, $offset]);
        $conversations = $stmt->fetchAll();
        
        // جلب العدد الإجمالي للمحادثات
        $countSql = "
            SELECT COUNT(DISTINCT 
                CASE 
                    WHEN sender_id = ? THEN receiver_id
                    ELSE sender_id
                END
            ) as total
            FROM messages 
            WHERE sender_id = ? OR receiver_id = ?
        ";
        $stmt = $pdo->prepare($countSql);
        $stmt->execute([$token->user_id, $token->user_id, $token->user_id]);
        $total = $stmt->fetch()['total'];
        
        jsonResponse([
            'success' => true,
            'data' => $conversations,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ]
        ]);
        return;
    }
    
    jsonResponse([
        'success' => true,
        'data' => $messages,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total' => $total,
            'total_pages' => ceil($total / $limit)
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Get messages error: " . $e->getMessage());
    jsonResponse(['error' => 'خطأ في جلب الرسائل'], 500);
}
?> 