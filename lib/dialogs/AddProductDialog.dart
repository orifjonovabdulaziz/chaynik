import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AddCategoryDialog.dart';

void showAddProductDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _product_name = '';
  double _product_price = 0.0;


  List<String> _categories = ["Категория 1", "Категория 2", "Категория 3"];
  String? _selectedCategory;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( // 🔹 Используем StatefulBuilder для обновления состояния
        builder: (context, setState) {
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
                          value: category,
                          child: Text(category),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
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
