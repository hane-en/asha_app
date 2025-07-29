import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  State<PaymentManagementPage> createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  List<Map<String, dynamic>> _pendingPayments = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isLoading = true);
      _currentPage = 1;
    }

    try {
      final response = await AdminService.getPendingPayments(
        page: _currentPage,
        limit: _perPage,
      );

      if (response['success'] == true) {
        setState(() {
          if (refresh) {
            _pendingPayments = List<Map<String, dynamic>>.from(
              response['data'] ?? [],
            );
          } else {
            _pendingPayments.addAll(
              List<Map<String, dynamic>>.from(response['data'] ?? []),
            );
          }
          _stats = response['stats'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _pendingPayments = [];
          _stats = {};
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _pendingPayments = [];
        _stats = {};
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _verifyPayment(int bookingId, String status) async {
    try {
      final response = await AdminService.verifyPayment(
        bookingId: bookingId,
        status: status,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingPayments(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showVerificationDialog(int bookingId, String status) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'verified' ? 'تأكيد الدفع' : 'رفض الدفع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status == 'verified'
                  ? 'هل أنت متأكد من تأكيد الدفع؟'
                  : 'هل أنت متأكد من رفض الدفع؟',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyPayment(bookingId, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'verified' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(status == 'verified' ? 'تأكيد' : 'رفض'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدفعات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPendingPayments(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات
          if (_stats != null) _buildStatsCard(),

          // قائمة الحجوزات المعلقة
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pendingPayments.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد دفعات معلقة',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _pendingPayments.length,
                    itemBuilder: (context, index) {
                      final payment = _pendingPayments[index];
                      return _buildPaymentCard(payment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات الدفعات المعلقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'المعلقة',
                  _stats!['total_pending'],
                  Colors.orange,
                ),
                _buildStatItem(
                  'المبلغ الإجمالي',
                  '${_stats!['total_amount']} ريال',
                  Colors.blue,
                ),
                _buildStatItem(
                  'منتهية الصلاحية',
                  _stats!['expired_count'],
                  Colors.red,
                ),
                _buildStatItem(
                  'متأخرة',
                  _stats!['overdue_count'],
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final isExpired = payment['is_expired'] == true;
    final hoursSinceBooking = payment['hours_since_booking'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          payment['service_title'] ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستخدم: ${payment['user_name']}'),
            Text('المزود: ${payment['provider_name']}'),
            Text('المبلغ: ${payment['total_price']} ريال'),
            if (isExpired)
              const Text(
                'منتهية الصلاحية',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (hoursSinceBooking > 24)
              const Text(
                'متأخرة',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isExpired ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isExpired ? 'منتهية' : 'معلقة',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الحجز: ${payment['booking_id']}'),
                Text('التاريخ: ${payment['booking_date']}'),
                Text('الوقت: ${payment['booking_time']}'),
                Text('رقم هاتف المستخدم: ${payment['user_phone']}'),
                Text('رقم هاتف المزود: ${payment['provider_phone']}'),
                if (payment['kuraimi_account'] != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'معلومات الحساب البنكي:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('رقم الحساب: ${payment['kuraimi_account']}'),
                  Text('صاحب الحساب: ${payment['kuraimi_account_holder']}'),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isExpired
                            ? null
                            : () => _showVerificationDialog(
                                payment['booking_id'],
                                'verified',
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('تأكيد الدفع'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showVerificationDialog(
                          payment['booking_id'],
                          'rejected',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('رفض الدفع'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
