import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/product/AddProductDialog.dart';
import '../components/product/ProductCard.dart';

import '../components/product/show_delete_product_dialog.dart';
import '../components/product/show_update_product_dialog.dart';
import '../components/shared/drawer.dart';
import '../models/category.dart';
import '../provider/category_provider.dart';
import '../provider/product_provider.dart';
import '../theme/app_colors.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(productProvider.notifier).fetchProducts(),
      ref.read(categoryProvider.notifier).fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Продукты'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Меню',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск продуктов...',
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCategoryFilter(),
        _buildProductsList(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(categoryProvider);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Ошибка загрузки категорий',
            style: TextStyle(color: AppColors.error),
          ),
        ),
        data: (categories) => _buildCategoryChips(categories),
      ),
    );
  }

  Widget _buildCategoryChips(List<Category> categories) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFilterChip(
            label: 'Все',
            selected: selectedCategory == null,
            categoryId: null,
          );
        }

        final category = categories[index - 1];
        return _buildFilterChip(
          label: category.title,
          selected: selectedCategory == category.id,
          categoryId: category.id,
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required int? categoryId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) {
          ref.read(selectedCategoryProvider.notifier).state = categoryId;
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Expanded(
      child: filteredProductsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(error.toString()),
        data: (products) {
          if (products.isEmpty) {
            return _buildEmptyView(
              isSearching: _searchController.text.isNotEmpty,
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                categoryName: _getCategoryName(product, categoriesAsync),
                onEdit: () => showUpdateProductDialog(context, ref, product),
                onDelete: () => showDeleteProductDialog(context, ref, product),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки продуктов',
            style: TextStyle(color: AppColors.error),
          ),
          TextButton(
            onPressed: _refreshData,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView({bool isSearching = false}) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Ничего не найдено'
                : selectedCategory != null
                ? 'В этой категории нет продуктов'
                : 'Нет продуктов',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (isSearching)
            Text(
              'Попробуйте изменить параметры поиска',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          if (!isSearching)
            TextButton.icon(
              onPressed: () => showAddProductDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Добавить продукт'),
            ),
        ],
      ),
    );
  }

  String _getCategoryName(
      dynamic product,
      AsyncValue<List<Category>> categoriesAsync,
      ) {
    return categoriesAsync.when(
      loading: () => 'Загрузка...',
      error: (_, __) => 'Ошибка',
      data: (categories) => categories
          .firstWhere(
            (c) => c.id == product.categoryId,
        orElse: () => Category(id: 0, title: 'Неизвестно', productCount: 0),
      )
          .title,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => showAddProductDialog(context, ref),
      icon: const Icon(Icons.add),
      label: const Text('Добавить'),
      tooltip: 'Добавить продукт',
    );
  }
}