import 'package:chaynik/components/income/AddProductIncomeScreen.dart';
import 'package:chaynik/components/sell/AddProductSellScreen.dart';
import 'package:chaynik/screens/Categories.dart';
import 'package:chaynik/screens/ClientsScreen.dart';
import 'package:chaynik/screens/IncomeHistoryScreen.dart';
import 'package:chaynik/screens/IncomeScreen.dart';
import 'package:chaynik/screens/MarketScreen.dart';
import 'package:chaynik/screens/SoldHistoryScreen.dart';
import 'package:chaynik/screens/SoldScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chaynik/screens/AuthScreen.dart';
import 'package:chaynik/screens/HomeScreen.dart';
import 'package:chaynik/screens/SplashScreen.dart';

import '../screens/Products.dart';
import '../screens/UzumScreen.dart';
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => AuthPage(),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => ProductsScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => CategoriesScreen(),
      ),
      GoRoute(
        path: '/clients',
        name: 'clients',
        builder: (context, state) => ClientsScreen(),
      ),
      GoRoute(
        path: '/sold',
        name: 'sold',
        builder: (context, state) => SoldScreen(),
      ),
      GoRoute(
        path: '/income',
        name: 'income',
        builder: (context, state) => IncomeScreen(),
      ),
      GoRoute(
        path: '/soldhistory',
        name: 'soldhistory',
        builder: (context, state) => SoldHistoryScreen(),
      ),
      GoRoute(
        path: '/incomehistory',
        name: 'incomehistory',
        builder: (context, state) => IncomeHistoryScreen(),
      ),
      GoRoute(
        path: '/addproducttosell',
        name: 'addproducttosell',
        builder: (context, state) => AddProductSellScreen(),
      ),
      GoRoute(
        path: '/addproducttoincome',
        name: 'addproducttoincome',
        builder: (context, state) => AddProductIncomeScreen(),
      ),
      GoRoute(
        path: '/market',
        name: 'market',
        builder: (context, state) => MarketScreen(),
      ),
      GoRoute(
        path: '/uzum/:id',
        name: 'uzum',
        builder: (context, state) {
          final marketId = int.parse(state.pathParameters['id'] ?? '0');
          final marketName = state.extra as String?;
          return UzumScreen(
            marketId: marketId,
            marketName: marketName ?? 'Uzum статистика',
          );
        },
      ),
    ],
    // Добавляем редирект для проверки авторизации
    redirect: (BuildContext context, GoRouterState state) {
      // Получаем текущий путь
      final currentPath = state.matchedLocation;

      // Если это сплэш скрин, не делаем редирект
      if (currentPath == '/') return null;

      // Здесь можно добавить проверку авторизации
      // Например:
      // final isAuth = ref.read(authProvider).isAuthenticated;
      // if (!isAuth && currentPath != '/auth') return '/auth';

      return null;
    },
    // Обработка ошибок навигации
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Страница не найдена: ${state.error}'),
      ),
    ),
  );
});
