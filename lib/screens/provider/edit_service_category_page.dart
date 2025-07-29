import 'package:flutter/material.dart';
import '../../models/service_category_model.dart';
import '../../services/service_category_service.dart';

class EditServiceCategoryPage extends StatefulWidget {
  final int categoryId;
  final String serviceTitle;

  const EditServiceCategoryPage({
    Key? key,
    required this.categoryId,
    required this.serviceTitle,
  }) : super(key: key);

  @override
  State<EditServiceCategoryPage> createState() =>
      _EditServiceCategoryPageState();
}

class _EditServiceCategoryPageState extends State<EditServiceCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _sizeController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _materialsController = TextEditingController();
  final _additionalFeaturesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  ServiceCategory? _category;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _sizeController.dispose();
    _dimensionsController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    _materialsController.dispose();
    _additionalFeaturesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    try {
      final category = await ServiceCategoryService.getServiceCategory(
        widget.categoryId,
      );

      if (category != null) {
        setState(() {
          _category = category;
          _nameController.text = category.name;
          _descriptionController.text = category.description;
          _priceController.text = category.price.toString();
          _imageController.text = category.image;
          _sizeController.text = category.size ?? '';
          _dimensionsController.text = category.dimensions ?? '';
          _locationController.text = category.location ?? '';
          _quantityController.text = category.quantity.toString();
          _durationController.text = category.duration ?? '';
          _materialsController.text = category.materials ?? '';
          _additionalFeaturesController.text =
              category.additionalFeatures ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فئة الخدمة غير موجودة';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // تجهيز البيانات للتحديث
      final categoryData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image': _imageController.text.trim(),
        'size': _sizeController.text.trim().isEmpty
            ? null
            : _sizeController.text.trim(),
        'dimensions': _dimensionsController.text.trim().isEmpty
            ? null
            : _dimensionsController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'quantity': int.tryParse(_quantityController.text) ?? 1,
        'duration': _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        'materials': _materialsController.text.trim().isEmpty
            ? null
            : _materialsController.text.trim(),
        'additional_features': _additionalFeaturesController.text.trim().isEmpty
            ? null
            : _additionalFeaturesController.text.trim(),
      };

      final response = await ServiceCategoryService.updateServiceCategory(
        widget.categoryId,
        categoryData,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث فئة الخدمة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // إرجاع true للإشارة إلى التحديث
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'فشل في تحديث فئة الخدمة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل فئة الخدمة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading && _category != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _submitForm,
              tooltip: 'حفظ التغييرات',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategory,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : _category == null
          ? const Center(child: Text('فئة الخدمة غير موجودة'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الخدمة
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.business, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.serviceTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تعديل فئة الخدمة',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // المعلومات الأساسية
                    _buildSectionTitle('المعلومات الأساسية'),
                    _buildTextField(
                      controller: _nameController,
                      label: 'اسم فئة الخدمة *',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم فئة الخدمة مطلوب';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'وصف فئة الخدمة *',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'وصف فئة الخدمة مطلوب';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'السعر (ريال) *',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'السعر مطلوب';
                        }
                        if (double.tryParse(value) == null) {
                          return 'السعر يجب أن يكون رقم';
                        }
                        if (double.parse(value) <= 0) {
                          return 'السعر يجب أن يكون أكبر من صفر';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: _imageController,
                      label: 'رابط الصورة',
                      hint: 'https://example.com/image.jpg',
                    ),

                    const SizedBox(height: 16),

                    // المعلومات الإضافية
                    _buildSectionTitle('المعلومات الإضافية'),
                    _buildTextField(
                      controller: _sizeController,
                      label: 'الحجم',
                      hint: 'صغير، متوسط، كبير',
                    ),
                    _buildTextField(
                      controller: _dimensionsController,
                      label: 'الأبعاد',
                      hint: 'الطول × العرض × الارتفاع',
                    ),
                    _buildTextField(
                      controller: _locationController,
                      label: 'الموقع',
                      hint: 'المنطقة أو المدينة',
                    ),
                    _buildTextField(
                      controller: _quantityController,
                      label: 'الكمية',
                      keyboardType: TextInputType.number,
                      hint: '1',
                    ),
                    _buildTextField(
                      controller: _durationController,
                      label: 'المدة',
                      hint: '1 ساعة، 2-3 ساعات',
                    ),
                    _buildTextField(
                      controller: _materialsController,
                      label: 'المواد المستخدمة',
                      maxLines: 2,
                      hint: 'المواد والأدوات المستخدمة',
                    ),
                    _buildTextField(
                      controller: _additionalFeaturesController,
                      label: 'ميزات إضافية',
                      maxLines: 3,
                      hint: 'أي ميزات أو خدمات إضافية',
                    ),

                    const SizedBox(height: 32),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'حفظ التغييرات',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
