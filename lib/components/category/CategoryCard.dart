import 'package:flutter/material.dart';
import '../../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (){}, // Позволяет редактировать при нажатии на карточку
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Иконка категории
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Информация о категории
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category.productCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount} ${_getProductCountText(category.productCount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Кнопки действий
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    tooltip: 'Редактировать',
                    color: Colors.blue,
                    splashRadius: 24,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: category.productCount > 0 ? null : onDelete,
                    tooltip: category.productCount > 0
                        ? 'Нельзя удалить категорию с продуктами'
                        : 'Удалить',
                    color: Colors.red,
                    splashRadius: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProductCountText(int count) {
    if (count == 0) return 'продуктов';
    if (count == 1) return 'продукт';
    if (count >= 2 && count <= 4) return 'продукта';
    return 'продуктов';
  }
}