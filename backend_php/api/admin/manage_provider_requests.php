<?php
require_once '../../config/config.php';
require_once '../../config/database.php';

$token = verifyToken();
if ($token->user_type !== 'admin') {
    jsonResponse(['error' => 'فقط المديرون يمكنهم الوصول لهذا المورد'], 403);
}

$pdo = getDBConnection();
if (!$pdo) {
    jsonResponse(['error' => 'خطأ في الاتصال بقاعدة البيانات'], 500);
}

// جلب طلبات الانضمام
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
        $offset = ($page - 1) * $limit;
        
        $status = isset($_GET['status']) ? validateInput($_GET['status']) : null;
        
        $whereConditions = ["1=1"];
        $params = [];
        
        if ($status) {
            $whereConditions[] = "pr.status = ?";
            $params[] = $status;
        }
        
        $whereClause = implode(" AND ", $whereConditions);
        
        // جلب الطلبات
        $sql = "
            SELECT pr.*, u.name as user_name, u.email as user_email, u.phone as user_phone
            FROM provider_requests pr
            JOIN users u ON pr.user_id = u.id
            WHERE $whereClause
            ORDER BY pr.created_at DESC
            LIMIT ? OFFSET ?
        ";
        
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $requests = $stmt->fetchAll();
        
        // جلب العدد الإجمالي
        $countSql = "SELECT COUNT(*) as total FROM provider_requests pr WHERE $whereClause";
        $stmt = $pdo->prepare($countSql);
        $stmt->execute(array_slice($params, 0, -2));
        $total = $stmt->fetch()['total'];
        
        jsonResponse([
            'success' => true,
            'data' => $requests,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total' => $total,
                'total_pages' => ceil($total / $limit)
            ]
        ]);
        
    } catch (PDOException $e) {
        error_log("Get provider requests error: " . $e->getMessage());
        jsonResponse(['error' => 'خطأ في جلب طلبات الانضمام'], 500);
    }
}

// تحديث حالة الطلب
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['request_id']) || !isset($input['status'])) {
        jsonResponse(['error' => 'معرف الطلب والحالة مطلوبان'], 400);
    }
    
    $requestId = (int)$input['request_id'];
    $status = validateInput($input['status']);
    $adminNotes = isset($input['admin_notes']) ? validateInput($input['admin_notes']) : '';
    
    if (!in_array($status, ['approved', 'rejected'])) {
        jsonResponse(['error' => 'الحالة غير صحيحة'], 400);
    }
    
    try {
        $pdo->beginTransaction();
        
        // تحديث حالة الطلب
        $stmt = $pdo->prepare("
            UPDATE provider_requests 
            SET status = ?, admin_notes = ?, updated_at = NOW() 
            WHERE id = ?
        ");
        $stmt->execute([$status, $adminNotes, $requestId]);
        
        // جلب معلومات الطلب
        $stmt = $pdo->prepare("
            SELECT pr.*, u.name as user_name, u.email as user_email
            FROM provider_requests pr
            JOIN users u ON pr.user_id = u.id
            WHERE pr.id = ?
        ");
        $stmt->execute([$requestId]);
        $request = $stmt->fetch();
        
        if (!$request) {
            $pdo->rollBack();
            jsonResponse(['error' => 'الطلب غير موجود'], 404);
        }
        
        if ($status === 'approved') {
            // تحديث نوع المستخدم إلى مزود خدمة
            $stmt = $pdo->prepare("
                UPDATE users 
                SET user_type = 'provider', is_verified = 1 
                WHERE id = ?
            ");
            $stmt->execute([$request['user_id']]);
            
            // إنشاء إشعار للمستخدم
            $stmt = $pdo->prepare("
                INSERT INTO notifications (user_id, title, message, type) 
                VALUES (?, ?, ?, 'system')
            ");
            $stmt->execute([
                $request['user_id'],
                'تم الموافقة على طلب الانضمام',
                'تم الموافقة على طلبك للانضمام كمزود خدمة. يمكنك الآن إضافة خدماتك.',
                'system'
            ]);
        } else {
            // إنشاء إشعار للمستخدم
            $stmt = $pdo->prepare("
                INSERT INTO notifications (user_id, title, message, type) 
                VALUES (?, ?, ?, 'system')
            ");
            $stmt->execute([
                $request['user_id'],
                'تم رفض طلب الانضمام',
                'للأسف تم رفض طلبك للانضمام كمزود خدمة. يمكنك التواصل مع الإدارة للمزيد من المعلومات.',
                'system'
            ]);
        }
        
        $pdo->commit();
        
        jsonResponse([
            'success' => true,
            'message' => 'تم تحديث حالة الطلب بنجاح'
        ]);
        
    } catch (PDOException $e) {
        $pdo->rollBack();
        error_log("Update provider request error: " . $e->getMessage());
        jsonResponse(['error' => 'خطأ في تحديث حالة الطلب'], 500);
    }
}

jsonResponse(['error' => 'Method not allowed'], 405);
?> 