import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../provider/product_provider.dart';
import '../../theme/app_colors.dart';

class DeleteProductDialog extends ConsumerStatefulWidget {
  final Product product;

  const DeleteProductDialog({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  ConsumerState<DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends ConsumerState<DeleteProductDialog> {
  bool _isDeleting = false;

  Future<void> _deleteProduct() async {
    setState(() => _isDeleting = true);

    try {
      await ref.read(productProvider.notifier).deleteProduct(widget.product.id);
      if (!mounted) return;

      Navigator.of(context).pop();
      _showSuccessMessage();
    } catch (e) {
      setState(() => _isDeleting = false);
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Продукт "${widget.product.title}" удален'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Ошибка при удалении: $error'),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Удаление продукта',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Вы действительно хотите удалить этот продукт?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildProductCard(),
          if (_isDeleting) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Отмена',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_outline, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Удалить',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          _buildProductImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.product.price} сум',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product_${widget.product.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: widget.product.imageUrl,
          width: 60,
          height: 60,
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
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

void showDeleteProductDialog(BuildContext context, WidgetRef ref, Product product) {
  showDialog(
    context: context,
    builder: (_) => DeleteProductDialog(product: product),
  );
}