import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  File? _selectedImage;
  int _selectedIndex = 2;

  Future<void> _pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitService() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى ملء جميع الحقول واختيار صورة')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost/backend_php/add_service.php'),
    );
    request.fields['name'] = _nameController.text;
    request.fields['category'] = _categoryController.text;
    request.files.add(
      await http.MultipartFile.fromPath('image', _selectedImage!.path),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ تم إضافة الخدمة بنجاح')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ فشل في إرسال الخدمة')));
    }
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/provider-home',
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/provider-pending',
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/my-services',
          (route) => false,
        );
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/my-bookings',
          (route) => false,
        );
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(context, '/my-ads', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text('إضافة خدمة', style: TextStyle(color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/provider-home',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'الإشعارات',
            onPressed: () {
              Navigator.pushNamed(context, '/provider-notifications');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'القائمة الجانبية',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الرئيسية'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-home',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('قيد الانتظار'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/provider-pending',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.design_services),
              title: const Text('خدماتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-services',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('حجوزاتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('إعلاناتي'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-ads',
                (route) => false,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الخدمة',
                hintText: 'أدخل اسم الخدمة',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'الفئة',
                hintText: 'أدخل نوع الفئة',
              ),
            ),
            const SizedBox(height: 16),
            _selectedImage == null
                ? const Text('📷 لم يتم اختيار صورة بعد')
                : Image.file(
                    _selectedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('اختيار من المعرض'),
                  onPressed: _pickImageFromGallery,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('فتح الكاميرا'),
                  onPressed: _pickImageFromCamera,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('إرسال الخدمة'),
              onPressed: _submitService,
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'قيد الانتظار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'خدماتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'إعلاناتي',
          ),
        ],
      ),
    ),
  );
}
