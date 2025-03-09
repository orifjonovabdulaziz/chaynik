import 'package:chaynik/provider/client_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/client.dart';

void showDeleteClientDialog(BuildContext context, WidgetRef ref, Client client) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Удаление клиента',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы действительно хотите удалить этого клиента?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Информация о клиенте
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                client.full_name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Кнопка отмены
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Кнопка удаления
          TextButton(
            onPressed: () {
              ref.read(clientProvider.notifier).deleteClient(client.id);
              Navigator.of(context).pop();

              // Показываем снекбар с подтверждением
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Клиент "${client.full_name}" удален'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                ),
              );
            },
            child: const Text(
              'Удалить',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}