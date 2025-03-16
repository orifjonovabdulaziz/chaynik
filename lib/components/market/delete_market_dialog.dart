import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/market.dart';
import '../../provider/market_provider.dart';

class DeleteMarketDialog extends ConsumerWidget {
  final Market market;

  const DeleteMarketDialog({
    Key? key,
    required this.market,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text(
        'Удаление магазина',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вы действительно хотите удалить магазин "${market.name}"?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Это действие нельзя будет отменить.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
          onPressed: () async {
            final success =
            await ref.read(marketProvider.notifier).deleteMarket(market.id);

            if (context.mounted) {
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Магазин "${market.name}" удален'
                        : 'Ошибка при удалении магазина',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text(
            'Удалить',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Функция-помощник для показа диалога
void showDeleteMarketDialog(BuildContext context, Market market) {
  showDialog(
    context: context,
    builder: (BuildContext context) => DeleteMarketDialog(market: market),
  );
}