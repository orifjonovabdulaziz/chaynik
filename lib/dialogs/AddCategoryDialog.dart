import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../repositories/category_repository.dart';

void showAddCategoryDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CategoryRepository _categoryRepository = CategoryRepository();
  String _category_name= '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Добавить категорию"),
        content: Form(
          key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Название товара"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter some text";
                }
                return null;
              },
              onSaved: (value) {
                _category_name = value ?? '';
              },
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
                bool success = await _categoryRepository.addCategory(_category_name);
                print("Категория: $_category_name");
                Navigator.of(context).pop();
              }
            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}
