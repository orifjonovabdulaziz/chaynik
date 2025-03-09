import 'package:chaynik/models/client.dart';
import 'package:chaynik/provider/client_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddClientDialog(BuildContext context, WidgetRef ref) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _content = '';
  double _debt = 0.0;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Добавить нового клиента"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "ФИО клиента"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Пожалуйста, введите ФИО";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _fullName = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Контент"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Пожалуйста, введите контент";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _content = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Долг"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Пожалуйста, введите долг";
                    }
                    if (double.tryParse(value) == null) {
                      return "Введите корректное число";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _debt = double.tryParse(value ?? '0') ?? 0.0;
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
            child: Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await ref.read(clientProvider.notifier).addClient(
                    _fullName,
                    _content,
                    _debt);
                Navigator.of(context).pop();
                print("ФИО: $_fullName, Контент: $_content, Долг: $_debt");
              }
            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}