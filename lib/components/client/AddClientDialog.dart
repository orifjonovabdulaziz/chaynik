import 'package:chaynik/models/client.dart';
import 'package:chaynik/provider/client_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddClientDialog(BuildContext context, WidgetRef ref) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _content = '';
  double _debt = 0.0;
  final TextEditingController _debtController = TextEditingController(text: '0');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Добавить нового клиента",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
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
                      return "Пожалуйста, введите ФИО";
                    }
                    if (value.length < 2) {
                      return "ФИО должно содержать минимум 2 символа";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _fullName = value?.trim() ?? '';
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                      return "Пожалуйста, введите информацию";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _content = value?.trim() ?? '';
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
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Пожалуйста, введите сумму";
                    }
                    if (double.tryParse(value) == null) {
                      return "Введите корректное число";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _debt = double.tryParse(value ?? '0') ?? 0.0;
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
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Показываем индикатор загрузки
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                try {
                  await ref.read(clientProvider.notifier).addClient(
                    _fullName,
                    _content,
                    _debt,
                  );

                  // Закрываем индикатор загрузки и диалог
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  // Показываем уведомление об успехе
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Клиент $_fullName успешно добавлен'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  // Закрываем индикатор загрузки
                  Navigator.of(context).pop();

                  // Показываем ошибку
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка при добавлении клиента: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Добавить"),
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