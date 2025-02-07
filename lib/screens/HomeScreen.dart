import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _logout() async {
      await ref.read(authProvider.notifier).logout();
      Navigator.pushReplacementNamed(context, '/auth');
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(onPressed: (){
          _logout();
        }, child: Text('Logout')),
      ),
    );
  }
}

