import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/AddProductDialog.dart';
import '../provider/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(), // Открывает Drawer
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => showAddProductDialog(context),
            icon: Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.68,
        child: ListView(
            children: [
        SizedBox(
        height: 100,
        child:
        DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text("Shohrux",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    ),
    ListTile(
    leading: Icon(Icons.exit_to_app),
    title: Text("Выйти"),
    onTap: () => _logout(),
    )


    ],
    ),
    ),
    body: Center(child: Text("Главный Экран"))
    ,
    );
  }
}
