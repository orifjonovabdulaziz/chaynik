import 'package:chaynik/screens/Categories.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chaynik/screens/AuthScreen.dart';
import 'package:chaynik/screens/HomeScreen.dart';
import 'package:chaynik/screens/SplashScreen.dart';

import '../screens/Products.dart';
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
