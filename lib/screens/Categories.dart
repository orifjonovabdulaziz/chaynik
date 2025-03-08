import 'package:chaynik/components/category/AddCategoryDialog.dart';
import 'package:chaynik/components/category/CategoryCard.dart';
import 'package:chaynik/components/category/show_update_category_dialog.dart';
import 'package:chaynik/components/shared/drawer.dart';
import 'package:chaynik/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/category/show_delete_category_dialog.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Категории"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(categoryProvider.notifier).fetchCategories();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
              data: (categories) {
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                          category: category,
                          onEdit: () {
                            showUpdateCategoryDialog(context, ref, category);
                          },
                          onDelete: () {
                            showDeleteCategoryDialog(context, ref, category);
                          });
                    });
              },
            ),
          ),
          const SizedBox(height: 100)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
