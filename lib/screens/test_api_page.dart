import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../test_api_connection.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});
=======
import '../services/unified_data_service.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({Key? key}) : super(key: key);
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
<<<<<<< HEAD
  String _testResults = '';
  bool _isLoading = false;
=======
  List<Map<String, dynamic>> providers = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await UnifiedDataService.getAllProviders();

      if (result['success'] == true) {
        setState(() {
          providers = List<Map<String, dynamic>>.from(
            result['data']['providers'] ?? [],
          );
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'خطأ في جلب المزودين';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في الاتصال: $e';
        isLoading = false;
      });
    }
  }
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('اختبار الاتصال بالـ API'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _runTests,
              child: const Text('تشغيل الاختبارات'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'اضغط على زر الاختبار' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      await ApiConnectionTest.runAllTests();
      setState(() {
        _testResults = '✅ تم تشغيل الاختبارات بنجاح\n';
        _testResults += 'تحقق من console للتفاصيل';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ خطأ في الاختبارات: $e';
        _isLoading = false;
      });
    }
  }
} 
=======
        title: const Text('اختبار جلب المزودين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProviders,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProviders,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : providers.isEmpty
            ? const Center(
                child: Text('لا يوجد مزودين', style: TextStyle(fontSize: 18)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    provider['profile_image'] != null
                                    ? NetworkImage(provider['profile_image'])
                                    : null,
                                child: provider['profile_image'] == null
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider['name'] ?? 'بدون اسم',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider['email'] ?? 'بدون بريد إلكتروني',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (provider['phone'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        provider['phone'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (provider['is_verified'] == true)
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${provider['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.work,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${provider['services_count'] ?? 0} خدمة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (provider['categories'] != null &&
                              (provider['categories'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: (provider['categories'] as List)
                                  .map<Widget>(
                                    (category) => Chip(
                                      label: Text(category),
                                      backgroundColor: Colors.blue[100],
                                      labelStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (provider['price_range'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider['price_range']['min']?.toStringAsFixed(0) ?? '0'} - ${provider['price_range']['max']?.toStringAsFixed(0) ?? '0'} ريال',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProviders,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
