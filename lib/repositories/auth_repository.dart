import 'package:chaynik/repositories/category_repository.dart';
import 'package:chaynik/repositories/product_repository.dart';

import '../dio/db/category_db.dart';
import '../dio/db/client_db.dart';
import '../dio/db/product_db.dart';
import '../dio/services/auth_service.dart';
import '../dio/services/category_service.dart';
import '../dio/services/product_service.dart';
import '../dio/services/shared_prefs_service.dart';
import 'client_repository.dart';

class AuthRepository {
  final ProductRepository _productRepository = ProductRepository();
  final ProductDatabase _productDb = ProductDatabase.instance;

  final CategoryRepository _categoryRepository = CategoryRepository();
  final CategoryDatabase _categoryDatabase = CategoryDatabase.instance;

  final ClientRepository _clientRepository = ClientRepository();
  final ClientDatabase _clientDb = ClientDatabase.instance;

  final AuthService _authService = AuthService();

  Future<String?> login(String email, String password) async {
    try{
      String? token = await _authService.login(email, password);
      if (token != null) {
        await _productRepository.getProductsFromServerAndSave();
        await _categoryRepository.getCategoriesFromServerAndSave();
        await _clientRepository.getClientsFromServerAndSave();
        return token;
      }
    }catch(e){
      print("Ошибка авторизации: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try{
      await _authService.logout();
    }catch(e){
      print("Ошибка выхода из системы: $e");
      rethrow;
    }
    finally{
      await _productDb.deleteAllProducts();
      await _categoryDatabase.deleteAllCategories();
      await _clientDb.deleteAllClients();
      await SharedPrefsService.removeToken();
    }
  }

}