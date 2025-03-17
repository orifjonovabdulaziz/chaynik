import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../provider/client_provider.dart';

void showUpdateClientDialog(BuildContext context, WidgetRef ref, Client client) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final formatter = NumberFormat('#,##0', 'ru_RU');

  // Контроллеры для текстовых полей
  final TextEditingController _fullNameController =
  TextEditingController(text: client.full_name);
  final TextEditingController _contentController =
  TextEditingController(text: client.content);
  final TextEditingController _debtController =
  TextEditingController(text: formatter.format(client.debt));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Flexible(child: const Text(
              'Редактирование клиента',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),),

          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: "ФИО клиента",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите ФИО";
                    }
                    if (value.length < 2) {
                      return "ФИО должно содержать минимум 2 символа";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "Дополнительная информация",
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите информацию";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _debtController,
                  decoration: InputDecoration(
                    labelText: "Долг",
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    suffixText: "сум",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите сумму";
                    }
                    if (double.tryParse(value.replaceAll(',', '')) == null) {
                      return "Введите корректное число";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
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
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Показываем индикатор загрузки
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  await ref.read(clientProvider.notifier).updateClient(
                    client.id,
                    fullName: _fullNameController.text.trim(),
                    content: _contentController.text.trim(),
                    debt: double.parse(
                        _debtController.text.replaceAll(',', '')),
                  );

                  // Закрываем оба диалога
                  Navigator.of(context).pop(); // Закрываем индикатор загрузки
                  Navigator.of(context).pop(); // Закрываем диалог обновления

                  // Показываем уведомление об успехе
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                'Клиент "${_fullNameController.text}" успешно обновлён'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
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
                      content: Text('Ошибка при обновлении клиента: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Сохранить',
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