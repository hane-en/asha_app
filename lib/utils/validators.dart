import '../config/config.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Check if email is valid (returns boolean)
  static bool isValidEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  // Phone validation (يمني: 9 أرقام تبدأ بـ 77 أو 78 أو 70 أو 71 أو 73)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // تنظيف الرقم من الأحرف غير الرقمية
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final pattern = RegExp(r'^(77|78|70|71|73)[0-9]{7}$');
    if (!pattern.hasMatch(cleanValue)) {
      return 'رقم الهاتف اليمني يجب أن يتكون من 9 أرقام ويبدأ بـ 77 أو 78 أو 70 أو 71 أو 73';
    }
    return null;
  }

  // Check if phone is valid (returns boolean)
  static bool isValidPhone(String value) {
    // تنظيف الرقم من الأحرف غير الرقمية
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    final pattern = RegExp(r'^(77|78|70|71|73)[0-9]{7}$');
    return pattern.hasMatch(cleanValue);
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (value.length > 50) {
      return 'كلمة المرور يجب أن تكون أقل من 50 حرف';
    }

    return null;
  }

  // Strong password validation
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!RegExp('[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // if (!RegExp('[a-z]').hasMatch(value)) {
    //   return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    // }

    if (!RegExp('[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    //   return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    // }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    if (value.length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }

    // Check for valid Arabic and English characters
    final nameRegex = RegExp(
      r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFFa-zA-Z\s]+$',
    );
    if (!nameRegex.hasMatch(value)) {
      return 'الاسم يحتوي على أحرف غير صحيحة';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }

    if (value.length < 10) {
      return 'العنوان يجب أن يكون 10 أحرف على الأقل';
    }

    if (value.length > 200) {
      return 'العنوان يجب أن يكون أقل من 200 حرف';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'السعر مطلوب';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'السعر غير صحيح';
    }

    if (price < 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }

    if (price > 1000000) {
      return 'السعر يجب أن يكون أقل من 1,000,000 ريال';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'الوصف مطلوب';
    }

    if (value.length < 10) {
      return 'الوصف يجب أن يكون 10 أحرف على الأقل';
    }

    if (value.length > 500) {
      return 'الوصف يجب أن يكون أقل من 500 حرف';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  // Verification code validation
  static String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }

    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }

    try {
      DateTime.parse(value);
    } catch (e) {
      return 'التاريخ غير صحيح';
    }

    return null;
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'الوقت مطلوب';
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'الوقت غير صحيح';
    }

    return null;
  }

  // Duration validation (in minutes)
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'المدة مطلوبة';
    }

    final duration = int.tryParse(value);
    if (duration == null) {
      return 'المدة غير صحيحة';
    }

    if (duration < 15) {
      return 'المدة يجب أن تكون 15 دقيقة على الأقل';
    }

    if (duration > 1440) {
      // 24 hours
      return 'المدة يجب أن تكون أقل من 24 ساعة';
    }

    return null;
  }

  // Guest count validation
  static String? validateGuestCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'عدد الضيوف مطلوب';
    }

    final count = int.tryParse(value);
    if (count == null) {
      return 'عدد الضيوف غير صحيح';
    }

    if (count < 1) {
      return 'عدد الضيوف يجب أن يكون واحد على الأقل';
    }

    if (count > 1000) {
      return 'عدد الضيوف يجب أن يكون أقل من 1000';
    }

    return null;
  }

  // File validation
  static String? validateFile(String? value, {int maxSizeInMB = 5}) {
    if (value == null || value.isEmpty) {
      return null; // File is optional
    }

    // Check file extension
    final allowedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'pdf',
      'doc',
      'docx',
    ];
    final extension = value.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'نوع الملف غير مسموح به';
    }

    return null;
  }

  // Postal code validation (Saudi)
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Postal code is optional
    }

    final postalRegex = RegExp(r'^[1-9][0-9]{4}$');
    if (!postalRegex.hasMatch(value)) {
      return 'الرمز البريدي غير صحيح';
    }

    return null;
  }

  // ID number validation (Saudi)
  static String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // ID number is optional
    }

    final idRegex = RegExp(r'^[1-2][0-9]{9}$');
    if (!idRegex.hasMatch(value)) {
      return 'رقم الهوية غير صحيح';
    }

    return null;
  }

  // Bank account validation
  static String? validateBankAccount(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bank account is optional
    }

    final accountRegex = RegExp(r'^[0-9]{10,20}$');
    if (!accountRegex.hasMatch(value)) {
      return 'رقم الحساب البنكي غير صحيح';
    }

    return null;
  }

  // Credit card validation (Luhn algorithm)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Credit card is optional
    }

    // Remove spaces and dashes
    final cleanCard = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleanCard)) {
      return 'رقم البطاقة غير صحيح';
    }

    // Luhn algorithm check
    if (!_isValidLuhn(cleanCard)) {
      return 'رقم البطاقة غير صحيح';
    }

    return null;
  }

  // CVV validation
  static String? validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return null; // CVV is optional
    }

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'رمز الأمان غير صحيح';
    }

    return null;
  }

  // Expiry date validation
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Expiry date is optional
    }

    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'تاريخ انتهاء الصلاحية غير صحيح';
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000;

    final now = DateTime.now();
    final expiryDate = DateTime(year, month);

    if (expiryDate.isBefore(now)) {
      return 'تاريخ انتهاء الصلاحية منتهي';
    }

    return null;
  }

  // Form validation helper
  static Map<String, String> validateForm(Map<String, String> fields) {
    final errors = <String, String>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      String? error;

      switch (fieldName) {
        case 'email':
          error = validateEmail(value);
          break;
        case 'phone':
          error = validatePhone(value);
          break;
        case 'password':
          error = validatePassword(value);
          break;
        case 'name':
          error = validateName(value);
          break;
        case 'address':
          error = validateAddress(value);
          break;
        case 'price':
          error = validatePrice(value);
          break;
        case 'description':
          error = validateDescription(value);
          break;
        case 'verification_code':
          error = validateVerificationCode(value);
          break;
        case 'date':
          error = validateDate(value);
          break;
        case 'time':
          error = validateTime(value);
          break;
        case 'duration':
          error = validateDuration(value);
          break;
        case 'guest_count':
          error = validateGuestCount(value);
          break;
        case 'url':
          error = validateUrl(value);
          break;
        case 'postal_code':
          error = validatePostalCode(value);
          break;
        case 'id_number':
          error = validateIdNumber(value);
          break;
        case 'bank_account':
          error = validateBankAccount(value);
          break;
        case 'credit_card':
          error = validateCreditCard(value);
          break;
        case 'cvv':
          error = validateCvv(value);
          break;
        case 'expiry_date':
          error = validateExpiryDate(value);
          break;
      }

      if (error != null) {
        errors[fieldName] = error;
      }
    }

    return errors;
  }

  // Luhn algorithm implementation
  static bool _isValidLuhn(String cardNumber) {
    var sum = 0;
    var isEven = false;

    for (var i = cardNumber.length - 1; i >= 0; i--) {
      var digit = int.parse(cardNumber[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }
}
