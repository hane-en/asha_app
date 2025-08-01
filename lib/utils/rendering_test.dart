import 'package:flutter/material.dart';

class RenderingTestWidget extends StatelessWidget {
  const RenderingTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار العرض'),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Test container with fixed height
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'اختبار الحاوية الثابتة',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Test list with proper constraints
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'عنصر اختبار ${index + 1}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Test bottom section with fixed height
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.purple,
              child: const Center(
                child: Text(
                  'قسم سفلي ثابت',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 