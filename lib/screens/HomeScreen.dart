import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/shared/drawer.dart';
import '../provider/load_data_provider.dart';
import '../theme/app_colors.dart'; // Создадим файл с цветами

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _synchronizeData() async {
    // Проверяем, не идет ли уже синхронизация
    if (ref.read(loadDataStateProvider).isLoading) return;

    try {
      // Сначала показываем диалог
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SyncProgressDialog(),
      );

      // Затем запускаем синхронизацию
      final repository = ref.read(loadDataRepositoryProvider);
      await ref.read(loadDataStateProvider.notifier).loadData(repository);

      // Проверяем, что виджет все еще в дереве
      if (!mounted) return;

      // Закрываем диалог
      Navigator.of(context).pop();

      // Показываем результат
      final state = ref.read(loadDataStateProvider);
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      } else {
        final results = state.results;
        String message = 'Синхронизация завершена:\n';
        results.forEach((key, value) {
          if (key != 'status' && key != 'message') {
            message += '• $value\n';
          }
        });
        _showSuccessSnackBar(message);
      }
    } catch (e) {
      if (!mounted) return;

      // Закрываем диалог в случае ошибки
      Navigator.of(context).pop();

      _showErrorSnackBar('Ошибка синхронизации: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Главная'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings),
          tooltip: 'Настройки',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildMainContent(),
        _buildSyncButton(),
      ],
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(child: _buildMenuButton(
                    title: 'Продажа',
                    icon: Icons.shopping_cart,
                    color: AppColors.primary,
                    onTap: () => context.go('/sold'),
                  )),
                  Expanded(child: _buildMenuButton(
                    title: 'Приход',
                    icon: Icons.inventory,
                    color: AppColors.success,
                    onTap: () => context.go('/income'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: AppColors.warning,
          child: InkWell(
            onTap: _synchronizeData,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sync, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Синхронизировать',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Выносим диалог в отдельный виджет
class SyncProgressDialog extends StatelessWidget {
  const SyncProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Center(
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Синхронизация данных...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Выносим SnackBar в отдельный виджет
class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    required String message,
    required Color backgroundColor,
    required VoidCallback onDismiss,
    Key? key,
  }) : super(
    key: key,
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: onDismiss,
    ),
  );
}