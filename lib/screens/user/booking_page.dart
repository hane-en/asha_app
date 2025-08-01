import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/config.dart';
import '../../services/api_service.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingPage({Key? key, required this.service}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _kareemiTransactionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPaymentMethod = Config.paymentMethodCash;
  bool _isLoading = false;
  bool _showKareemiFields = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = Config.paymentMethodCash;
    _updateKareemiFields();
  }

  void _updateKareemiFields() {
    setState(() {
      _showKareemiFields = _selectedPaymentMethod == Config.paymentMethodKareemi;
    });
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الوقت')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final bookingData = {
        'user_id': userId,
        'service_id': widget.service['id'],
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time': _selectedTime!.format(context),
        'total_price': widget.service['price'].toString(),
        'payment_method': _selectedPaymentMethod,
        'note': _noteController.text.trim(),
      };

      // إضافة رقم معاملة الكريمي إذا كانت طريقة الدفع هي البنك
      if (_selectedPaymentMethod == Config.paymentMethodKareemi) {
        if (_kareemiTransactionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى إدخال رقم معاملة الكريمي')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        bookingData['kareemi_transaction_id'] = _kareemiTransactionController.text.trim();
      }

      final response = await ApiService.createBooking(bookingData);

      if (response['success']) {
        // إظهار معلومات بنك الكريمي إذا كانت طريقة الدفع هي البنك
        if (_selectedPaymentMethod == Config.paymentMethodKareemi) {
          _showKareemiInfo(response['data']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحجز بنجاح')),
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'حدث خطأ أثناء إنشاء الحجز')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في الاتصال')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showKareemiInfo(Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('معلومات الدفع عبر بنك الكريمي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم حساب مزود الخدمة: ${bookingData['kareemi_info']['provider_account']}'),
              const SizedBox(height: 8),
              Text('رقم المعاملة: ${bookingData['kareemi_info']['transaction_id']}'),
              const SizedBox(height: 16),
              const Text(
                'تعليمات الدفع:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. قم بتحويل المبلغ إلى الحساب المذكور أعلاه\n'
                '2. احتفظ بإثبات التحويل\n'
                '3. سيتم تأكيد الحجز بعد التحقق من الدفع',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: const Text('تم'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز الخدمة'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الخدمة
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'السعر: ${widget.service['price']} ريال',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // اختيار التاريخ
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('اختر التاريخ'),
                  subtitle: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy/MM/dd', 'ar').format(_selectedDate!)
                        : 'لم يتم اختيار تاريخ',
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),

              // اختيار الوقت
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('اختر الوقت'),
                  subtitle: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'لم يتم اختيار وقت',
                  ),
                  onTap: () => _selectTime(context),
                ),
              ),
              const SizedBox(height: 16),

              // طريقة الدفع
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'طريقة الدفع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...Config.paymentMethods.asMap().entries.map((entry) {
                        final index = entry.key;
                        final method = entry.value;
                        final value = index == 0 ? Config.paymentMethodCash : Config.paymentMethodKareemi;
                        return RadioListTile<String>(
                          title: Text(method),
                          value: value,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedPaymentMethod = newValue!;
                              _updateKareemiFields();
                            });
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      const Text(
                        'يرجى المسارعة لدفع رسوم الحجز خلال 8 ساعات أو سيتم رفض طلبك.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // حقول بنك الكريمي
              if (_showKareemiFields) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات بنك الكريمي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _kareemiTransactionController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'رقم معاملة الكريمي *',
                            hintText: 'أدخل رقم معاملة التحويل',
                            prefixIcon: Icon(Icons.receipt),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'رقم معاملة الكريمي مطلوب';
                            }
                            if (value.length < 6) {
                              return 'رقم المعاملة يجب أن يكون 6 أرقام على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ملاحظة: سيتم عرض رقم حساب مزود الخدمة بعد إنشاء الحجز',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ملاحظات
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملاحظات إضافية (اختياري)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'أضف أي ملاحظات أو متطلبات خاصة...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر الحجز
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'تأكيد الحجز',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _kareemiTransactionController.dispose();
    super.dispose();
  }
}
