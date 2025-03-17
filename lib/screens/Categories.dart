import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/category/AddCategoryDialog.dart';
import '../components/category/CategoryCard.dart';
import '../components/category/show_delete_category_dialog.dart';
import '../components/category/show_update_category_dialog.dart';
import '../components/shared/drawer.dart';
import '../provider/category_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(categorySearchQueryProvider.notifier).state = _searchController.text;
  }

  Future<void> _refreshData() async {
    await ref.read(categoryProvider.notifier).fetchCategories();
  }

  Widget _buildCategoriesList(List<dynamic> categories) {
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
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty
                ? Icons.search_off
                : Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Категории не найдены'
                : 'Нет категорий',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Попробуйте изменить параметры поиска',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Ошибка: $error'),
          TextButton(
            onPressed: _refreshData,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategoriesAsync = ref.watch(filteredCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Категории"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск категорий...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: filteredCategoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error.toString()),
                data: (categories) {
                  if (categories.isEmpty) {
                    // Для пустого состояния нужно обернуть в ScrollView,
                    // чтобы RefreshIndicator работал
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyState(),
                        ),
                      ],
                    );
                  }
                  return _buildCategoriesList(categories);
                },
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}