import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../provider/category_provider.dart';

void showUpdateCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
    ) {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: category.title);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isLoading = false;

          Future<void> updateCategory() async {
            if (!formKey.currentState!.validate()) return;

            setState(() => isLoading = true);

            try {
              await ref.read(categoryProvider.notifier).updateCategory(
                category.id,
                title: titleController.text.trim(),
              );

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Категория "${titleController.text}" обновлена'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(8),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка при обновлении категории: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(8),
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Flexible(child: const Text(
                  'Редактирование категории',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),)

              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.productCount > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'В этой категории ${category.productCount} ${_getProductCountText(category.productCount)}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Название категории",
                      hintText: "Введите название категории",
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Введите название категории";
                      }
                      if (value.trim().length < 2) {
                        return "Название должно содержать минимум 2 символа";
                      }
                      return null;
                    },
                    enabled: !isLoading,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        updateCategory();
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Отмена',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : updateCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Сохранить',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

String _getProductCountText(int count) {
  if (count == 0) return 'продуктов';
  if (count == 1) return 'продукт';
  if (count >= 2 && count <= 4) return 'продукта';
  return 'продуктов';
}