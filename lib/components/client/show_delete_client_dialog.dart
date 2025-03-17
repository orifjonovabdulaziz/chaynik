import 'package:chaynik/provider/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';

void showDeleteClientDialog(BuildContext context, WidgetRef ref, Client client) {
  final isNegative = client.debt < 0;
  final formatter = NumberFormat('#,##0', 'ru_RU');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Удаление клиента',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вы действительно хотите удалить этого клиента?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Информация о клиенте
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          client.full_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (client.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.note, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            client.content,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isNegative ? Icons.warning : Icons.check_circle,
                        size: 20,
                        color: isNegative ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Долг: ${formatter.format(client.debt)} сум',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isNegative ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Это действие нельзя будет отменить!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Кнопка отмены
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
          // Кнопка удаления
          ElevatedButton(
            onPressed: () async {
              // Показываем индикатор загрузки
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              try {
                await ref.read(clientProvider.notifier).deleteClient(client.id);

                // Закрываем оба диалога
                Navigator.of(context).pop(); // Закрываем индикатор загрузки
                Navigator.of(context).pop(); // Закрываем диалог удаления

                // Показываем снекбар с подтверждением
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Клиент "${client.full_name}" успешно удален'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } catch (e) {
                // Закрываем индикатор загрузки
                Navigator.of(context).pop();

                // Показываем ошибку
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка при удалении клиента: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      );
    },
  );
}