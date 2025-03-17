import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Можно добавить действие для просмотра деталей
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductTitle(),
                    const SizedBox(height: 4),
                    _buildCategoryName(),
                    _buildQuantity(),
                    const SizedBox(height: 4),
                    _buildPrice(),
                  ],
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product_${product.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(height: 4),
                  Text(
                    'Ошибка',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTitle() {
    return Text(
      product.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCategoryName() {
    return Row(
      children: [
        const Icon(
          Icons.category_outlined,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            categoryName,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantity() {
    return Row(
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          size: 16,
          color: Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          'Количество: ${product.quantity}',
          style: TextStyle(
            color: Colors.blue[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    final formattedPrice = _formatPrice(product.price);
    return Row(
      children: [
        const Icon(
          Icons.attach_money,
          size: 16,
          color: Colors.green,
        ),
        const SizedBox(width: 4),
        Text(
          '$formattedPrice сум',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: AppColors.primary,
          onPressed: onEdit,
          tooltip: 'Редактировать',
        ),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: AppColors.error,
          onPressed: onDelete,
          tooltip: 'Удалить',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}