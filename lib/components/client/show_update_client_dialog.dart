import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/client.dart';
import '../../provider/client_provider.dart';

void showUpdateClientDialog(
    BuildContext context, WidgetRef ref, Client client) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Контроллеры для текстовых полей
  final TextEditingController _fullNameController =
  TextEditingController(text: client.full_name);
  final TextEditingController _contentController =
  TextEditingController(text: client.content);
  final TextEditingController _debtController =
  TextEditingController(text: client.debt.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Редактирование клиента',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите ФИО";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "Контент",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите контент";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _debtController,
                  decoration: InputDecoration(
                    labelText: "Долг",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Введите долг";
                    }
                    if (double.tryParse(value) == null) {
                      return "Введите корректное число";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref.read(clientProvider.notifier).updateClient(
                  client.id,
                  fullName: _fullNameController.text,
                  content: _contentController.text,
                  debt: double.tryParse(_debtController.text) ?? 0.0,
                );
                Navigator.of(context).pop();

                // Показываем снекбар
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Клиент "${_fullNameController.text}" обновлён'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}