import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class ProviderRequestsPage extends StatefulWidget {
  const ProviderRequestsPage({super.key});

  @override
  State<ProviderRequestsPage> createState() => _ProviderRequestsPageState();
}

class _ProviderRequestsPageState extends State<ProviderRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  int _currentPage = 1;
  String? _selectedStatus;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests({bool refresh = false}) async {
    if (refresh) {
      setState(() => _isLoading = true);
      _currentPage = 1;
    }

    try {
      final response = await AdminService.getProviderRequests(
        page: _currentPage,
        status: _selectedStatus,
      );

      if (response['success'] == true) {
        setState(() {
          if (refresh) {
            _requests = List<Map<String, dynamic>>.from(response['data']);
          } else {
            _requests.addAll(List<Map<String, dynamic>>.from(response['data']));
          }
          _stats = response['stats'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleRequest(int requestId, String action) async {
    final adminNotes = await _showNotesDialog(action);
    if (adminNotes == null) return; // User cancelled

    try {
      Map<String, dynamic> response;
      if (action == 'approve') {
        response = await AdminService.approveProviderRequest(
          requestId,
          adminNotes: adminNotes,
        );
      } else {
        response = await AdminService.rejectProviderRequest(
          requestId,
          adminNotes: adminNotes,
        );
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests(refresh: true);
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

  Future<String?> _showNotesDialog(String action) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'approve' ? 'ملاحظات الموافقة' : 'سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اكتب ملاحظاتك هنا (اختياري)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات مزودي الخدمة'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadRequests(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات
          if (_stats != null) _buildStatsCard(),

          // فلاتر
          _buildFilters(),

          // قائمة الطلبات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد طلبات مزودي الخدمة',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestCard(request);
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('الكل', _stats!['total_requests'], Colors.blue),
            _buildStatItem(
              'قيد الانتظار',
              _stats!['pending_requests'],
              Colors.orange,
            ),
            _buildStatItem(
              'تمت الموافقة',
              _stats!['approved_requests'],
              Colors.green,
            ),
            _buildStatItem('مرفوض', _stats!['rejected_requests'], Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'حالة الطلب',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('جميع الطلبات')),
                DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                DropdownMenuItem(
                  value: 'approved',
                  child: Text('تمت الموافقة'),
                ),
                DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _loadRequests(refresh: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'تمت الموافقة';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير محدد';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        title: Text(
          request['user_name'] ?? 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد: ${request['user_email']}'),
            Text('الهاتف: ${request['user_phone']}'),
            if (request['yemeni_account'] != null)
              Text('الحساب اليمني: ${request['yemeni_account']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم العمل: ${request['business_name']}'),
                Text('وصف العمل: ${request['business_description']}'),
                Text('هاتف العمل: ${request['business_phone']}'),
                Text('عنوان العمل: ${request['business_address']}'),
                const SizedBox(height: 8),
                Text(
                  'تاريخ الطلب: ${request['created_at']}',
                  style: const TextStyle(color: Colors.grey),
                ),
                if (request['admin_notes'] != null &&
                    request['admin_notes'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'ملاحظات المشرف: ${request['admin_notes']}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleRequest(request['id'], 'approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleRequest(request['id'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
