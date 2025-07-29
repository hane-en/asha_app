<?php
/**
 * Middleware للتحقق من المصادقة والتفويض
 */

require_once 'config.php';
require_once 'auth.php';

class Middleware {
    private $auth;

    public function __construct() {
        $this->auth = new Auth();
    }

    /**
     * التحقق من المصادقة
     */
    public function requireAuth() {
        $token = $this->getTokenFromHeader();
        
        if (!$token) {
            errorResponse('رمز المصادقة مطلوب', 401);
        }

        $user = $this->auth->getCurrentUser($token);
        
        if (!$user) {
            errorResponse('رمز المصادقة غير صحيح', 401);
        }

        return $user;
    }

    /**
     * التحقق من نوع المستخدم
     */
    public function requireUserType($requiredType) {
        $user = $this->requireAuth();
        
        if (!$this->auth->hasPermission($user['user_type'], $requiredType)) {
            errorResponse('ليس لديك صلاحية للوصول لهذا المورد', 403);
        }

        return $user;
    }

    /**
     * التحقق من أن المستخدم مزود خدمة
     */
    public function requireProvider() {
        return $this->requireUserType('provider');
    }

    /**
     * التحقق من أن المستخدم مدير
     */
    public function requireAdmin() {
        return $this->requireUserType('admin');
    }

    /**
     * التحقق من ملكية المورد
     */
    public function requireOwnership($resourceUserId, $currentUserId = null) {
        if ($currentUserId === null) {
            $user = $this->requireAuth();
            $currentUserId = $user['id'];
        }

        if ($resourceUserId != $currentUserId) {
            errorResponse('ليس لديك صلاحية للوصول لهذا المورد', 403);
        }

        return true;
    }

    /**
     * الحصول على الرمز المميز من الرأس
     */
    private function getTokenFromHeader() {
        $headers = getallheaders();
        
        if (isset($headers['Authorization'])) {
            $authHeader = $headers['Authorization'];
            if (preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
                return $matches[1];
            }
        }

        return null;
    }

    /**
     * التحقق من المعاملات المطلوبة
     */
    public function validateRequiredParams($data, $requiredParams) {
        foreach ($requiredParams as $param) {
            if (!isset($data[$param]) || empty($data[$param])) {
                errorResponse("المعامل {$param} مطلوب");
            }
        }
        return true;
    }

    /**
     * التحقق من صحة البريد الإلكتروني
     */
    public function validateEmail($email) {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            errorResponse('البريد الإلكتروني غير صحيح');
        }
        return true;
    }

    /**
     * التحقق من صحة رقم الهاتف
     */
    public function validatePhone($phone) {
        if (!preg_match('/^[\+]?[0-9\-\(\)\s]+$/', $phone)) {
            errorResponse('رقم الهاتف غير صحيح');
        }
        return true;
    }

    /**
     * التحقق من قوة كلمة المرور
     */
    public function validatePassword($password) {
        if (strlen($password) < 6) {
            errorResponse('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
        }
        return true;
    }

    /**
     * التحقق من صحة التاريخ
     */
    public function validateDate($date, $format = 'Y-m-d') {
        $d = DateTime::createFromFormat($format, $date);
        if (!$d || $d->format($format) !== $date) {
            errorResponse('تنسيق التاريخ غير صحيح');
        }
        return true;
    }

    /**
     * التحقق من صحة الوقت
     */
    public function validateTime($time, $format = 'H:i') {
        $t = DateTime::createFromFormat($format, $time);
        if (!$t || $t->format($format) !== $time) {
            errorResponse('تنسيق الوقت غير صحيح');
        }
        return true;
    }

    /**
     * التحقق من حد الملف
     */
    public function validateFileSize($fileSize, $maxSize = MAX_FILE_SIZE) {
        if ($fileSize > $maxSize) {
            errorResponse('حجم الملف كبير جداً');
        }
        return true;
    }

    /**
     * التحقق من نوع الملف
     */
    public function validateFileType($fileName, $allowedTypes = ALLOWED_IMAGE_TYPES) {
        $extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
        if (!in_array($extension, $allowedTypes)) {
            errorResponse('نوع الملف غير مدعوم');
        }
        return true;
    }

    /**
     * تسجيل العملية
     */
    public function logActivity($userId, $action, $details = null) {
        $logData = [
            'user_id' => $userId,
            'action' => $action,
            'details' => $details,
            'ip_address' => $_SERVER['REMOTE_ADDR'] ?? null,
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
            'created_at' => date('Y-m-d H:i:s')
        ];

        // يمكن حفظ السجل في قاعدة البيانات أو ملف
        logError("Activity: " . json_encode($logData));
    }

    /**
     * التحقق من معدل الطلبات (Rate Limiting)
     */
    public function checkRateLimit($identifier, $maxRequests = 100, $timeWindow = 3600) {
        // يمكن تطبيق منطق Rate Limiting هنا
        // للبساطة، سنتركه فارغاً
        return true;
    }
}

// إنشاء مثيل من Middleware
$middleware = new Middleware();

?>

