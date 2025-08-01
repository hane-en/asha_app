import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final results = await ApiService.getAllServices();
      if (results['success'] && results['data'] != null) {
        final servicesData = results['data'] as List;
        setState(() {
          services = servicesData
              .map((json) => Service.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading services: $e');
      setState(() {
        services = [];
        isLoading = false;
      });
      // لا نعرض رسالة خطأ للمستخدم، فقط نعرض قائمة فارغة
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => true,
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('الرئيسية')),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : services.isEmpty
            ? const Center(child: Text('لا توجد خدمات متاحة'))
            : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(service.title),
                      subtitle: Text(service.description),
                      trailing: Text('${service.price} ريال'),
                      onTap: () {
                        // Navigate to service details
                      },
                    ),
                  );
                },
              ),
      ),
    ),
  );
}
