import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/product.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import '../category/AddCategoryDialog.dart';
import '../../theme/app_colors.dart';

class UpdateProductDialog extends ConsumerStatefulWidget {
  final Product product;

  const UpdateProductDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  ConsumerState<UpdateProductDialog> createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends ConsumerState<UpdateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedCategory;
  File? _image;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _priceController.text = widget.product.price.toString();
    _selectedCategory = widget.product.categoryId.toString();

    _titleController.addListener(_checkChanges);
    _priceController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges = _titleController.text != widget.product.title ||
        _priceController.text != widget.product.price.toString() ||
        _selectedCategory != widget.product.categoryId.toString() ||
        _image != null;

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
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
        setState(() {
          _image = File(pickedFile.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения');
    }
  }

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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showError('Выберите категорию');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(productProvider.notifier).updateProduct(
        widget.product.id,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text),
        category: int.parse(_selectedCategory!),
        image: _image?.path,
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccess('Продукт "${_titleController.text}" обновлён');
      }
    } catch (e) {
      _showError('Ошибка при обновлении продукта');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Редактирование продукта',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildImagePicker(),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading || !_hasChanges ? null : _updateProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Сохранить'),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Название товара',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.shopping_bag),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Введите название товара';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Цена товара',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.attach_money),
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
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer(
      builder: (context, ref, _) {
        final categoriesAsync = ref.watch(categoryProvider);

        return categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Категория',

              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.category),
            ),
            isExpanded: true,
            menuMaxHeight: 300,
            items: [
              ...categories.map((category) => DropdownMenuItem(
                value: category.id.toString(),
                child: Text(category.title, overflow: TextOverflow.ellipsis,),
              )),
              const DropdownMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Добавить категорию',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value == 'add_category') {
                showAddCategoryDialog(context, ref);
              } else {
                setState(() {
                  _selectedCategory = value;
                  _hasChanges = true;
                });
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
            : CachedNetworkImage(
          imageUrl: widget.product.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

void showUpdateProductDialog(BuildContext context, WidgetRef ref, Product product) {
  showDialog(
    context: context,
    builder: (_) => UpdateProductDialog(product: product),
  );
}