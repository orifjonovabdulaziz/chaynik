import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAddCategoryDialog(BuildContext context) {
  final TextEditingController _categoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Добавить категорию"),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(hintText: "Название категории"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Отмена"),
          ),
          ElevatedButton(
            onPressed: () {

            },
            child: Text("Добавить"),
          ),
        ],
      );
    },
  );
}
