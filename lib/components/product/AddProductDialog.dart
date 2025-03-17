import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import '../category/AddCategoryDialog.dart';
import '../../theme/app_colors.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String _productName = '';
  double _productPrice = 0.0;
  String? _selectedCategory;
  File? _image;
  bool _isLoading = false;

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) return true;
    if (status.isDenied) {
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return false;
  }

  Future<void> _pickImage() async {
    try {
      if (!await _requestStoragePermission()) {
        _showError('Нет разрешения на доступ к галерее');
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showError('Выберите категорию');
      return;
    }
    if (_image == null) {
      _showError('Добавьте изображение продукта');
      return;
    }

    setState(() => _isLoading = true);

    try {
      _formKey.currentState!.save();
      await ref.read(productProvider.notifier).addProduct(
            _productName,
            _productPrice,
            _image!.path,
            int.parse(_selectedCategory!),
          );
      if (mounted) context.pop();
    } catch (e) {
      _showError('Ошибка при добавлении продукта');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить новый товар'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildImagePicker(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => context.pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Добавить'),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Название товара',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shopping_bag),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Введите название товара';
        }
        return null;
      },
      onSaved: (value) => _productName = value?.trim() ?? '',
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Цена товара',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите цену';
        }
        if (double.tryParse(value) == null) {
          return 'Введите корректное число';
        }
        return null;
      },
      onSaved: (value) => _productPrice = double.tryParse(value ?? '0') ?? 0.0,
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer(
      builder: (context, ref, _) {
        final categoriesAsync = ref.watch(categoryProvider);

        return categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Категория',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            hint: const Text('Выберите категорию'),
            isExpanded: true,
            menuMaxHeight: 300,
            items: [
              ...categories.map((category) => DropdownMenuItem(
                    value: category.id.toString(),
                    child: Text(
                      category.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              const DropdownMenuItem(
                value: 'add_category',
                child: Text(
                  '➕ Добавить категорию',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'add_category') {
                showAddCategoryDialog(context, ref);
              } else {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Ошибка: $error'),
        );
      },
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Добавить изображение'),
                ],
              ),
      ),
    );
  }
}

void showAddProductDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => const AddProductDialog(),
  );
}
