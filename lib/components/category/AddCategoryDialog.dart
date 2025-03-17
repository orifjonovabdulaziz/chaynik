import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/category_provider.dart';

void showAddCategoryDialog(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  String categoryName = '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Определяем переменную isLoading внутри StatefulBuilder
          bool isLoading = false;

          Future<void> submitForm() async {
            if (!formKey.currentState!.validate()) return;

            setState(() => isLoading = true);

            try {
              formKey.currentState!.save();
              await ref.read(categoryProvider.notifier).addCategory(categoryName);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Категория "$categoryName" успешно добавлена'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              }
            } catch (e) {
              if (context.mounted) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка при добавлении категории: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text("Добавить категорию"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: "Название категории",
                      hintText: "Введите название категории",
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Введите название категории";
                      }
                      if (value.length < 2) {
                        return "Название должно содержать минимум 2 символа";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      categoryName = value?.trim() ?? '';
                    },
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        submitForm();
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => context.pop(),
                child: const Text("Отмена"),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : submitForm,
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Добавить"),
              ),
            ],
          );
        },
      );
    },
  );
}