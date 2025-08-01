import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({Key? key}) : super(key: key);

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  List<Map<String, dynamic>> providers = [];
  bool isLoading = false;
  String? errorMessage;
  String connectionStatus = 'لم يتم الاختبار بعد';

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      connectionStatus = 'جاري اختبار الاتصال...';
    });

    try {
      // اختبار الاتصال الأساسي
      final testUrl = '${Config.apiBaseUrl}/api/test_connection.php';
      print('Testing connection to: $testUrl');

      final response = await http
          .get(
            Uri.parse(testUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          connectionStatus = '✅ الاتصال بالخادم يعمل بشكل صحيح';
        });

        // جلب المزودين
        await _loadProviders();
      } else {
        setState(() {
          connectionStatus =
              '❌ فشل في الاتصال بالخادم (Status: ${response.statusCode})';
          errorMessage = 'خطأ في الاتصال بالخادم';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = '❌ خطأ في الاتصال: $e';
        errorMessage = 'خطأ في الاتصال: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadProviders() async {
    try {
      final url = '${Config.apiBaseUrl}/api/providers/get_all_providers.php';
      print('Loading providers from: $url');

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print('Providers response status: ${response.statusCode}');
      print('Providers response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            providers = List<Map<String, dynamic>>.from(
              data['data']['providers'] ?? [],
            );
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'خطأ في جلب المزودين';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'خطأ في الخادم (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في جلب المزودين: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار قاعدة البيانات'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الاتصال
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حالة الاتصال:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      connectionStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: connectionStatus.contains('✅')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // زر إعادة الاختبار
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _testDatabaseConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة اختبار الاتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // نتائج المزودين
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )
                  : providers.isEmpty
                  ? const Center(
                      child: Text(
                        'لا يوجد مزودين في قاعدة البيانات',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المزودين (${providers.length}):',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: providers.length,
                            itemBuilder: (context, index) {
                              final provider = providers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      provider['name']
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '?',
                                    ),
                                  ),
                                  title: Text(
                                    provider['name'] ?? 'بدون اسم',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider['email'] ??
                                            'بدون بريد إلكتروني',
                                      ),
                                      if (provider['phone'] != null)
                                        Text(provider['phone']),
                                      Text(
                                        'التقييم: ${provider['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                      ),
                                      Text(
                                        'عدد الخدمات: ${provider['services_count'] ?? 0}',
                                      ),
                                    ],
                                  ),
                                  trailing: provider['is_verified'] == true
                                      ? const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
