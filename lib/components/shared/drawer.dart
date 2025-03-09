import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../provider/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _logout() async {
      await ref.read(authProvider.notifier).logout();
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.68,
      child: ListView(
        children: [
          SizedBox(
            height: 100,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Shohrux",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text("Главный экран"),
            onTap: () {
              context.go('/home');
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text("Мои Товары"),
            onTap: () {
              context.go('/products');
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.category_outlined),
            title: Text("Мои Категории"),
            onTap: () {
              context.go("/categories");
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.people_alt_outlined),
            title: Text("Клиенты"),
            onTap: () {
              context.go("/clients");
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_downward),
            title: Text("Приход"),
            onTap: () {
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_upward),
            title: Text("Продажа"),
            onTap: () {
              context.go("/sold");
              Navigator.pop(context); // Закрываем drawer после нажатия
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Выйти"),
            onTap: () {
              Navigator.pop(context); // Закрываем drawer перед выходом
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
