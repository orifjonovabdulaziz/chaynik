import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import '../../provider/category_provider.dart';

void showUpdateCategoryDialog(
    BuildContext context, WidgetRef ref, Category category) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Контроллеры для текстовых полей
  final TextEditingController _titleController =
      TextEditingController(text: category.title);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Редактирование категории',
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
                    labelText: "Название категории",
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
                const SizedBox(height: 10)
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref.read(categoryProvider.notifier).updateCategory(
                      category.id,
                      title: _titleController.text,
                    );
                Navigator.of(context).pop();

                // Показываем снекбар
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Продукт "${_titleController.text}" обновлён'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
