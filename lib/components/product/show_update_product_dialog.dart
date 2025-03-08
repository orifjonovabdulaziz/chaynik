import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/product.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import '../category/AddCategoryDialog.dart';

void showUpdateProductDialog(
    BuildContext context, WidgetRef ref, Product product) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Контроллеры для текстовых полей
  final TextEditingController _titleController =
      TextEditingController(text: product.title);
  final TextEditingController _priceController =
      TextEditingController(text: product.price.toString());

  String? _selectedCategory = product.categoryId.toString();
  String? _imagePath; // Для обновления изображения

  File? _image;
  final ImagePicker _picker = ImagePicker();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer(builder: (context, ref, _) {
        final categoriesAsync = ref.watch(categoryProvider);

        return StatefulBuilder(
          builder: (context, setState) {
            Future<bool> _requestStoragePermission() async {
              var status = await Permission.manageExternalStorage.request();

              if (status.isGranted) {
                return true; // Разрешение уже предоставлено
              } else if (status.isDenied) {
                status = await Permission.storage.request();
                return status.isGranted;
              } else if (status.isPermanentlyDenied) {
                print(
                    "Разрешение навсегда отклонено, откройте настройки приложения.");
                openAppSettings();
                return false;
              }

              return false;
            }

            Future<void> _pickImage() async {
              // Запрашиваем разрешения
              if (await _requestStoragePermission()) {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              } else {
                print("Нет разрешения на доступ к галерее");
              }
            }

            return AlertDialog(
              title: const Text(
                'Редактирование продукта',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Название товара",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Введите название";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: "Цена товара",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Введите цену";
                          }
                          if (double.tryParse(value) == null) {
                            return "Введите корректное число";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Категория (Dropdown)
                      categoriesAsync.when(
                        data: (categories) => DropdownButton<String>(
                          value: _selectedCategory,
                          hint: Text("Выберите категорию"),
                          items: [
                            ...categories
                                .map((category) => DropdownMenuItem<String>(
                                      value: category.id.toString(),
                                      child: Text(category.title),
                                    )),
                            DropdownMenuItem<String>(
                              value: "add_category",
                              child: Text(
                                "➕ Добавить категорию",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == "add_category") {
                              showAddCategoryDialog(context, ref);
                            } else {
                              setState(() {
                                _selectedCategory =
                                    value; // 🔹 Обновляем выбранную категорию
                              });
                            }
                          },
                        ),
                        loading: () =>
                            Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            Text('Ошибка загрузки категорий: $error'),
                      ),
                      const SizedBox(height: 10),

                      // Выбор изображения
                      _image != null
                          ? GestureDetector(
                              onTap: _pickImage,
                              child: Image.file(_image!,
                                  height: 200, width: 200, fit: BoxFit.cover),
                            )
                          : GestureDetector(
                              onTap: _pickImage,
                              child: Image.network(product.imageUrl,
                                  height: 200, width: 200, fit: BoxFit.cover)),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(productProvider.notifier).updateProduct(
                            product.id,
                            title: _titleController.text,
                            price: double.parse(_priceController.text),
                            category: int.parse(_selectedCategory!),
                            image: _image!.path, // Если не меняли, останется null
                          );
                      Navigator.of(context).pop();

                      // Показываем снекбар
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Продукт "${_titleController.text}" обновлён'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      });
    },
  );
}
