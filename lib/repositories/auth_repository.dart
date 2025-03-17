
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../dio/services/auth_service.dart';

import 'load_data_repository.dart';

class AuthRepository {


  final AuthService _authService = AuthService();
  final loadDataRepository = LoadDataRepository(ProviderContainer());

  Future<String?> login(String email, String password) async {
    try{
      String? token = await _authService.login(email, password);
      if (token != null) {


        // Загружаем все данные
        await loadDataRepository.loadAllData();
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
      await loadDataRepository.clearAllData();
    }
  }

}