<?php
/**
 * معالج الأخطاء المخصص لتطبيق Asha App
 * يوفر معالجة شاملة للأخطاء والاستثناءات
 */

require_once 'config.php';

class ErrorHandler {
    
    /**
     * تسجيل معالج الأخطاء
     */
    public static function register() {
        set_error_handler([self::class, 'handleError']);
        set_exception_handler([self::class, 'handleException']);
        register_shutdown_function([self::class, 'handleShutdown']);
    }

    /**
     * معالجة الأخطاء العادية
     */
    public static function handleError($severity, $message, $file, $line) {
        if (!(error_reporting() & $severity)) {
            return false;
        }

        $errorType = self::getErrorType($severity);
        $errorMessage = "[$errorType] $message in $file on line $line";
        
        self::logError($errorMessage);

        // في بيئة الإنتاج، لا نعرض تفاصيل الأخطاء
        if (self::isProduction()) {
            errorResponse('حدث خطأ في النظام', 500);
        } else {
            errorResponse($errorMessage, 500);
        }
    }

    /**
     * معالجة الاستثناءات
     */
    public static function handleException($exception) {
        $errorMessage = "Uncaught Exception: " . $exception->getMessage() . 
                       " in " . $exception->getFile() . 
                       " on line " . $exception->getLine();
        
        self::logError($errorMessage);
        self::logError("Stack trace: " . $exception->getTraceAsString());

        if (self::isProduction()) {
            errorResponse('حدث خطأ غير متوقع', 500);
        } else {
            errorResponse([
                'message' => $exception->getMessage(),
                'file' => $exception->getFile(),
                'line' => $exception->getLine(),
                'trace' => $exception->getTrace()
            ], 500);
        }
    }

    /**
     * معالجة أخطاء الإغلاق
     */
    public static function handleShutdown() {
        $error = error_get_last();
        
        if ($error && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR, E_PARSE])) {
            $errorMessage = "Fatal Error: {$error['message']} in {$error['file']} on line {$error['line']}";
            self::logError($errorMessage);
            
            if (!headers_sent()) {
                if (self::isProduction()) {
                    errorResponse('حدث خطأ خطير في النظام', 500);
                } else {
                    errorResponse($errorMessage, 500);
                }
            }
        }
    }

    /**
     * معالجة أخطاء قاعدة البيانات
     */
    public static function handleDatabaseError($error, $query = null) {
        $errorMessage = "Database Error: " . $error;
        if ($query) {
            $errorMessage .= " | Query: " . $query;
        }
        
        self::logError($errorMessage);

        if (self::isProduction()) {
            errorResponse('حدث خطأ في قاعدة البيانات', 500);
        } else {
            errorResponse($errorMessage, 500);
        }
    }

    /**
     * معالجة أخطاء التحقق من صحة البيانات
     */
    public static function handleValidationError($errors) {
        if (is_array($errors)) {
            $errorMessage = implode(', ', $errors);
        } else {
            $errorMessage = $errors;
        }

        errorResponse($errorMessage, 400);
    }

    /**
     * معالجة أخطاء المصادقة
     */
    public static function handleAuthError($message = 'غير مصرح') {
        errorResponse($message, 401);
    }

    /**
     * معالجة أخطاء التفويض
     */
    public static function handleAuthorizationError($message = 'ليس لديك صلاحية للوصول') {
        errorResponse($message, 403);
    }

    /**
     * معالجة أخطاء عدم الوجود
     */
    public static function handleNotFoundError($message = 'المورد غير موجود') {
        errorResponse($message, 404);
    }

    /**
     * معالجة أخطاء الطريقة غير المدعومة
     */
    public static function handleMethodNotAllowedError($allowedMethods = []) {
        $message = 'طريقة الطلب غير مدعومة';
        if (!empty($allowedMethods)) {
            $message .= '. الطرق المدعومة: ' . implode(', ', $allowedMethods);
        }
        
        errorResponse($message, 405);
    }

    /**
     * معالجة أخطاء معدل الطلبات
     */
    public static function handleRateLimitError($message = 'تم تجاوز الحد المسموح من الطلبات') {
        errorResponse($message, 429);
    }

    /**
     * معالجة أخطاء رفع الملفات
     */
    public static function handleFileUploadError($errorCode) {
        $messages = [
            UPLOAD_ERR_INI_SIZE => 'حجم الملف يتجاوز الحد المسموح',
            UPLOAD_ERR_FORM_SIZE => 'حجم الملف يتجاوز الحد المحدد في النموذج',
            UPLOAD_ERR_PARTIAL => 'تم رفع الملف جزئياً فقط',
            UPLOAD_ERR_NO_FILE => 'لم يتم رفع أي ملف',
            UPLOAD_ERR_NO_TMP_DIR => 'مجلد الملفات المؤقتة غير موجود',
            UPLOAD_ERR_CANT_WRITE => 'فشل في كتابة الملف',
            UPLOAD_ERR_EXTENSION => 'امتداد PHP أوقف رفع الملف'
        ];

        $message = $messages[$errorCode] ?? 'خطأ غير معروف في رفع الملف';
        errorResponse($message, 400);
    }

    /**
     * تسجيل الأخطاء
     */
    private static function logError($message) {
        $timestamp = date('Y-m-d H:i:s');
        $logMessage = "[$timestamp] $message" . PHP_EOL;
        
        // تسجيل في ملف الأخطاء
        $logFile = 'logs/error.log';
        if (!file_exists(dirname($logFile))) {
            mkdir(dirname($logFile), 0755, true);
        }
        
        file_put_contents($logFile, $logMessage, FILE_APPEND | LOCK_EX);
        
        // تسجيل في سجل PHP إذا كان مفعلاً
        if (function_exists('error_log')) {
            error_log($message);
        }
    }

    /**
     * الحصول على نوع الخطأ
     */
    private static function getErrorType($severity) {
        $errorTypes = [
            E_ERROR => 'Fatal Error',
            E_WARNING => 'Warning',
            E_PARSE => 'Parse Error',
            E_NOTICE => 'Notice',
            E_CORE_ERROR => 'Core Error',
            E_CORE_WARNING => 'Core Warning',
            E_COMPILE_ERROR => 'Compile Error',
            E_COMPILE_WARNING => 'Compile Warning',
            E_USER_ERROR => 'User Error',
            E_USER_WARNING => 'User Warning',
            E_USER_NOTICE => 'User Notice',
            E_STRICT => 'Strict Standards',
            E_RECOVERABLE_ERROR => 'Recoverable Error',
            E_DEPRECATED => 'Deprecated',
            E_USER_DEPRECATED => 'User Deprecated'
        ];

        return $errorTypes[$severity] ?? 'Unknown Error';
    }

    /**
     * التحقق من بيئة الإنتاج
     */
    private static function isProduction() {
        return defined('ENVIRONMENT') && ENVIRONMENT === 'production';
    }

    /**
     * إنشاء معرف فريد للخطأ
     */
    private static function generateErrorId() {
        return uniqid('err_', true);
    }

    /**
     * إرسال تنبيه للمطورين (في بيئة الإنتاج)
     */
    private static function notifyDevelopers($error) {
        // يمكن إضافة منطق إرسال البريد الإلكتروني أو الإشعارات هنا
        // للبساطة، سنتركه فارغاً
    }

    /**
     * تنظيف ملفات السجل القديمة
     */
    public static function cleanOldLogs($days = 30) {
        $logDir = 'logs/';
        if (!is_dir($logDir)) {
            return;
        }

        $files = glob($logDir . '*.log');
        $cutoff = time() - ($days * 24 * 60 * 60);

        foreach ($files as $file) {
            if (filemtime($file) < $cutoff) {
                unlink($file);
            }
        }
    }

    /**
     * الحصول على إحصائيات الأخطاء
     */
    public static function getErrorStats($days = 7) {
        $logFile = 'logs/error.log';
        if (!file_exists($logFile)) {
            return [];
        }

        $lines = file($logFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        $cutoff = time() - ($days * 24 * 60 * 60);
        $stats = [];

        foreach ($lines as $line) {
            if (preg_match('/\[(.*?)\]/', $line, $matches)) {
                $timestamp = strtotime($matches[1]);
                if ($timestamp >= $cutoff) {
                    $date = date('Y-m-d', $timestamp);
                    $stats[$date] = ($stats[$date] ?? 0) + 1;
                }
            }
        }

        return $stats;
    }
}

// تسجيل معالج الأخطاء
ErrorHandler::register();

?>

