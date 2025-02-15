import 'dart:ffi';
import 'dart:io';

import 'package:chaynik/models/category.dart';
import 'package:chaynik/models/product.dart';
import 'package:chaynik/provider/product_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dio/db/category_db.dart';
import '../dio/services/product_service.dart';
import '../provider/category_provider.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import 'AddCategoryDialog.dart';

void showAddProductDialog(BuildContext context, WidgetRef ref) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final ProductRepository _productRepository = ProductRepository();

  String _product_name = '';
  double _product_price = 0.0;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer(builder: (context, ref, _) {
        final _categories = ref.watch(categoryProvider);

        return StatefulBuilder(
          // 🔹 Используем StatefulBuilder для обновления состояния
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
              title: Text("Добавить новый товар"),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: "Название товара"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some text";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _product_name = value ?? '';
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Цена товара"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some price";
                          }
                          if (double.tryParse(value) == null) {
                            return "Введите корректное число";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _product_price = double.tryParse(value ?? '0') ?? 0.0;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text("Выберите категорию"),
                        items: [
                          ..._categories
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
                      _image != null
                          ? Image.file(_image!,
                              height: 200, width: 200, fit: BoxFit.cover)
                          : ElevatedButton(
                              onPressed: _pickImage,
                              child: Text("Выбрать изображение"),
                            ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // bool success = await _productRepository.addProduct(
                      //     _product_name,
                      //     _product_price,
                      //     _image!.path,
                      //     int.parse(_selectedCategory!));
                      await ref
                          .read(productProvider.notifier)
                          .addProduct(_product_name, _product_price,
                              _image!.path, int.parse(_selectedCategory!));
                      context.pop();


                      print(
                          "Название: $_product_name, Цена: $_product_price, Категория: $_selectedCategory");
                    }
                  },
                  child: Text("Добавить"),
                ),
              ],
            );
          },
        );
      });
    },
  );
}
