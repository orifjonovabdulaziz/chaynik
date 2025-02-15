import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/category_provider.dart';
import '../repositories/category_repository.dart';

void showAddCategoryDialog(BuildContext context, WidgetRef ref) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _category_name = '';

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
            onPressed: () => context.pop(),
            child: Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await ref
                    .read(categoryProvider.notifier)
                    .addCategory(_category_name);
                print("Категория: $_category_name");
                context.pop();
              }
            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}
