import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/config.dart';

class EditServicePage extends StatefulWidget {
  const EditServicePage({super.key, required this.service});
  final Map<String, dynamic> service;

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();

  File? _selectedImage;
  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = false;
  bool isLoading = false;
  String? currentImagePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }

  void _initializeForm() {
    // تعيين القيم الحالية للخدمة
    _nameController.text =
        widget.service['title'] ?? widget.service['name'] ?? '';
    _priceController.text = (widget.service['price'] ?? 0).toString();
    _descriptionController.text = widget.service['description'] ?? '';
    _locationController.text = widget.service['location'] ?? '';
    _contactPhoneController.text = widget.service['contact_phone'] ?? '';
    _contactEmailController.text = widget.service['contact_email'] ?? '';
    _websiteController.text = widget.service['website'] ?? '';
    _workingHoursController.text = widget.service['working_hours'] ?? '';

    // تعيين الفئة الحالية
    selectedCategory =
        widget.service['category_id']?.toString() ??
        widget.service['category']?.toString();

    // تعيين الصورة الحالية
    if (widget.service['images'] != null) {
      if (widget.service['images'] is String) {
        currentImagePath = widget.service['images'];
      } else if (widget.service['images'] is List &&
          widget.service['images'].isNotEmpty) {
        currentImagePath = widget.service['images'][0];
      }
    }
  }

  // دالة تحميل الفئات
  Future<void> _loadCategories() async {
    setState(() {
      isLoadingCategories = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/services/get_categories.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      print('خطأ في تحميل الفئات: $e');
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

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

  Future<void> _updateService() async {
    // التحقق من الحقول الإجبارية
    if (_nameController.text.isEmpty ||
        selectedCategory == null ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ يرجى ملء جميع الحقول الإجبارية (الاسم، الفئة، السعر)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.apiBaseUrl}/provider/update_service.php'),
      );

      // إضافة معرف الخدمة
      request.fields['service_id'] = widget.service['id'].toString();

      // الحقول الإجبارية
      request.fields['name'] = _nameController.text.trim();
      request.fields['category_id'] = selectedCategory!;
      request.fields['price'] = _priceController.text.trim();

      // الحقول الاختيارية
      if (_descriptionController.text.isNotEmpty) {
        request.fields['description'] = _descriptionController.text.trim();
      }
      if (_locationController.text.isNotEmpty) {
        request.fields['location'] = _locationController.text.trim();
      }
      if (_contactPhoneController.text.isNotEmpty) {
        request.fields['contact_phone'] = _contactPhoneController.text.trim();
      }
      if (_contactEmailController.text.isNotEmpty) {
        request.fields['contact_email'] = _contactEmailController.text.trim();
      }
      if (_websiteController.text.isNotEmpty) {
        request.fields['website'] = _websiteController.text.trim();
      }
      if (_workingHoursController.text.isNotEmpty) {
        request.fields['working_hours'] = _workingHoursController.text.trim();
      }

      // إضافة الصورة الجديدة إذا تم اختيارها
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${data['message'] ?? 'تم تحديث الخدمة بنجاح'}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // إرجاع true للإشارة إلى نجاح التحديث
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${data['message'] ?? 'فشل في تحديث الخدمة'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ في الاتصال: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _websiteController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الخدمة'),
        backgroundColor: Colors.purple,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // العنوان
              const Center(
                child: Text(
                  'تعديل الخدمة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الحقول الإجبارية
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'الحقول الإجبارية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // اسم الخدمة
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'اسم الخدمة *',
                          hintText: 'أدخل اسم الخدمة',
                          prefixIcon: const Icon(Icons.design_services),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'اسم الخدمة مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // قائمة الفئات
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'نوع الفئة *',
                          hintText: 'اختر نوع الفئة',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: isLoadingCategories
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('جاري التحميل...'),
                                    ],
                                  ),
                                ),
                              ]
                            : categories.map((category) {
                                return DropdownMenuItem(
                                  value: category['id'].toString(),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        color: Color.fromARGB(
                                          255,
                                          169,
                                          145,
                                          173,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category['title'],
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        onChanged: isLoadingCategories
                            ? null
                            : (value) =>
                                  setState(() => selectedCategory = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'نوع الفئة مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // السعر
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'السعر *',
                          hintText: 'أدخل السعر بالريال اليمني',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'السعر مطلوب';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يرجى إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // الصورة
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.image, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  'صورة الخدمة',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // عرض الصورة الحالية أو الجديدة
                            if (_selectedImage != null)
                              kIsWeb
                                  ? Image.network(
                                      _selectedImage!.path,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: double.infinity,
                                              height: 200,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                    )
                                  : Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                            else if (currentImagePath != null)
                              Image.network(
                                '${Config.apiBaseUrl.replaceAll('/api', '')}/uploads/services/$currentImagePath',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text('لا يمكن تحميل الصورة الحالية'),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text('لم يتم اختيار صورة جديدة'),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('من المعرض'),
                                    onPressed: _pickImageFromGallery,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade200,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('الكاميرا'),
                                    onPressed: _pickImageFromCamera,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.shade200,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // الحقول الاختيارية
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'معلومات إضافية (اختيارية)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // الوصف
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'وصف الخدمة',
                          hintText: 'أدخل وصف مفصل للخدمة',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // الموقع
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'موقع الخدمة',
                          hintText: 'أدخل العنوان أو الموقع',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // رقم التواصل
                      TextFormField(
                        controller: _contactPhoneController,
                        decoration: InputDecoration(
                          labelText: 'رقم التواصل',
                          hintText: 'أدخل رقم الهاتف',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // البريد الإلكتروني
                      TextFormField(
                        controller: _contactEmailController,
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'أدخل البريد الإلكتروني',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // الموقع الإلكتروني
                      TextFormField(
                        controller: _websiteController,
                        decoration: InputDecoration(
                          labelText: 'الموقع الإلكتروني',
                          hintText: 'أدخل رابط الموقع',
                          prefixIcon: const Icon(Icons.web),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ساعات العمل
                      TextFormField(
                        controller: _workingHoursController,
                        decoration: InputDecoration(
                          labelText: 'ساعات العمل',
                          hintText: 'مثال: من الأحد إلى الخميس 8 ص - 5 م',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // زر التحديث
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.update),
                  label: Text(isLoading ? 'جاري التحديث...' : 'تحديث الخدمة'),
                  onPressed: isLoading ? null : _updateService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade200,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
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
              // أنت بالفعل هنا
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-bookings',
                (route) => false,
              );
              break;
            case 4:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/my-ads',
                (route) => false,
              );
              break;
          }
        },
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
