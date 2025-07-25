import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';
import '../../widgets/service_card.dart';
import 'details_page.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key, required this.category});
  final String category;

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_home',
          (route) => false,
        );
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('خدمات: $category'),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: FutureBuilder<List<ServiceModel>>(
            future: ApiService.getServicesByCategory(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد خدمات في هذا القسم',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              final services = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCard(
                    service: service,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsPage(
                            service: {
                              'name': service.name,
                              'description': service.description,
                              'image': service.image,
                              'price': service.price,
                              'provider_name': service.providerName,
                            },
                          ),
                        ),
                      );
                    },
                    onCall: service.providerPhone != null
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('جاري الاتصال...'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                          }
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
}
