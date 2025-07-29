import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/service_model.dart';

class TestServicesHomeMethod extends StatefulWidget {
  @override
  _TestServicesHomeMethodState createState() => _TestServicesHomeMethodState();
}

class _TestServicesHomeMethodState extends State<TestServicesHomeMethod> {
  String _result = 'بدء الاختبار...';
  bool _isLoading = false;
  List<Service> _services = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختبار جلب الخدمات - طريقة user-home')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testServicesHomeMethod,
              child: Text('اختبار جلب الخدمات'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: Column(
                  children: [
                    Text(_result, style: TextStyle(fontFamily: 'monospace')),
                    SizedBox(height: 16),
                    if (_services.isNotEmpty) ...[
                      Text(
                        'الخدمات المجلوبة:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Card(
                              child: ListTile(
                                title: Text(service.title),
                                subtitle: Text('السعر: ${service.price} ريال'),
                                trailing: Text('التقييم: ${service.rating}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testServicesHomeMethod() async {
    setState(() {
      _isLoading = true;
      _result = 'بدء اختبار جلب الخدمات...\n';
      _services.clear();
    });

    try {
      _result += '🔍 اختبار getServicesWithOffers...\n';

      final result = await ApiService.getServicesWithOffers(
        limit: 10,
        offset: 0,
      );

      _result += '📊 Response: $result\n';

      if (result['services'] is List) {
        final servicesJson = result['services'] as List;
        _result += '📋 Services JSON count: ${servicesJson.length}\n';

        final List<Service> newServices = servicesJson
            .map((json) => Service.fromJson(json))
            .toList();

        _result += '✅ Converted services count: ${newServices.length}\n';

        setState(() {
          _services = newServices;
        });

        if (newServices.isNotEmpty) {
          _result += '📋 أول خدمة: ${newServices.first.title}\n';
          _result += '💰 السعر: ${newServices.first.price} ريال\n';
          _result += '⭐ التقييم: ${newServices.first.rating}\n';
        }
      } else {
        _result += '❌ Invalid services data format\n';
      }
    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() {
      _isLoading = false;
    });
  }
}
