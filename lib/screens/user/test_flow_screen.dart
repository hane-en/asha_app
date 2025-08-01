import 'package:flutter/material.dart';
import '../../routes/route_names.dart';

class TestFlowScreen extends StatelessWidget {
  const TestFlowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار التدفق'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختبار التدفق الكامل',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // اختبار التصوير
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('التصوير'),
                subtitle: const Text('اختبار تدفق التصوير'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 3, 'categoryName': 'التصوير'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار قاعات الأفراح
            Card(
              child: ListTile(
                leading: const Icon(Icons.celebration, color: Colors.purple),
                title: const Text('قاعات الأفراح'),
                subtitle: const Text('اختبار تدفق قاعات الأفراح'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {
                      'categoryId': 1,
                      'categoryName': 'قاعات الأفراح',
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار التصوير
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('التصوير'),
                subtitle: const Text('اختبار تدفق التصوير'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 2, 'categoryName': 'التصوير'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار الديكور
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_florist, color: Colors.green),
                title: const Text('الديكور'),
                subtitle: const Text('اختبار تدفق الديكور'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 3, 'categoryName': 'الديكور'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار الجاتوهات
            Card(
              child: ListTile(
                leading: const Icon(Icons.cake, color: Colors.pink),
                title: const Text('الجاتوهات'),
                subtitle: const Text('اختبار تدفق الجاتوهات'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 4, 'categoryName': 'الجاتوهات'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار الموسيقى
            Card(
              child: ListTile(
                leading: const Icon(Icons.music_note, color: Colors.blue),
                title: const Text('الموسيقى'),
                subtitle: const Text('اختبار تدفق الموسيقى'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 5, 'categoryName': 'الموسيقى'},
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // اختبار الفساتين
            Card(
              child: ListTile(
                leading: const Icon(Icons.checkroom, color: Colors.purple),
                title: const Text('الفساتين'),
                subtitle: const Text('اختبار تدفق الفساتين'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.providersByCategory,
                    arguments: {'categoryId': 6, 'categoryName': 'الفساتين'},
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // زر العودة للرئيسية
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.userHome,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text('العودة للرئيسية'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
