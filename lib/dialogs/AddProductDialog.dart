import 'dart:ffi';
import 'dart:io';

import 'package:chaynik/models/category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dio/db/category_db.dart';
import '../dio/services/product_service.dart';
import '../repositories/category_repository.dart';
import 'AddCategoryDialog.dart';

void showAddProductDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final ProductService _productService = ProductService();

  String _product_name = '';
  double _product_price = 0.0;

  File? _image;
  final ImagePicker _picker = ImagePicker();


  List<Category> _categories = [];
  String? _selectedCategory;



  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( // 🔹 Используем StatefulBuilder для обновления состояния
        builder: (context, setState) {

          /// 🔹 **Асинхронная загрузка категорий**
          Future<void> _fetchCategories() async {
            List<Category> localCategories = await _categoryRepository.getCategoriesFromLocal();
            setState(() {
              _categories = localCategories;
            }); // Обновляем UI после загрузки
          }


          Future<bool> _requestStoragePermission() async {
            var status = await Permission.manageExternalStorage.request();

            if (status.isGranted) {
              return true; // Разрешение уже предоставлено
            } else if (status.isDenied) {
              status = await Permission.storage.request();
              return status.isGranted;
            } else if (status.isPermanentlyDenied) {
              print("Разрешение навсегда отклонено, откройте настройки приложения.");
              openAppSettings();
              return false;
            }

            return false;
          }


          Future<void> _pickImage() async {
            // Запрашиваем разрешения
            if (await _requestStoragePermission()) {
              final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });
              }
            } else {
              print("Нет разрешения на доступ к галерее");
            }
          }



          /// 🔹 **Загрузка данных, если список категорий пуст**
          if (_categories.isEmpty) {
            _fetchCategories();
          }

          return AlertDialog(
            title: Text("Добавить новый товар"),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Название товара"),
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
                        ..._categories.map((category) => DropdownMenuItem<String>(
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
                          showAddCategoryDialog(context);
                        } else {
                          setState(() {
                            _selectedCategory = value; // 🔹 Обновляем выбранную категорию
                          });
                        }
                      },
                    ),
                    _image != null
                        ? Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover)
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
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Отмена"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    bool success = await _productService.addProduct(
                      _product_name,
                      _product_price,
                      _image!.path,
                      int.parse(_selectedCategory!),
                    );

                    if (success) {
                      print("Продукт успешно добавлен!");
                    } else {
                      print("Ошибка добавления продукта.");
                    }

                    print("Название: $_product_name, Цена: $_product_price, Категория: $_selectedCategory");
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Добавить"),
              ),
            ],
          );
        },
      );
    },
  );

}
