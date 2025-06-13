import 'dart:convert';

import 'package:cda_final_project_frontend/models/user.dart';
import 'package:cda_final_project_frontend/services/api-service.dart';
import 'package:cda_final_project_frontend/models/auth-result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cda_final_project_frontend/exceptions/auth-exception.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  // ÉTAPE 1 : Login (récupère juste le token)
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/login', {
        'username': username,
        'password': password,
      });

      // Votre API renvoie quelque chose comme :
      // { "token": "Bearer eyJ..." } ou juste "eyJ..." en string
      String token = response['bearer'] ?? response.toString();

      return token;
    } on ApiException catch (e) {
      throw AuthException(AuthException.getErrorMessage(e));
    } catch (e) {
      throw AuthException('Erreur de connexion inattendue');
    }
  }

  // ÉTAPE 2 : Récupérer les données utilisateur avec le token
  Future<User> fetchUserProfile(String token) async {
    try {
      // Configurer le token pour cet appel
      ApiService.setAuthToken(token);

      // Appeler votre endpoint de profil
      // Adaptez l'endpoint selon votre API : /profile, /me, /user/current, etc.
      final response = await ApiService.get('/auth/current');

      return User.fromJson(response);
    } on ApiException catch (e) {
      throw AuthException(AuthException.getErrorMessage(e));
    } catch (e) {
      throw AuthException('Erreur lors de la récupération du profil');
    }
  }

  // CONNEXION COMPLÈTE (token + user)
  Future<AuthResult> loginComplete({
    required String username,
    required String password,
  }) async {
    try {
      // Étape 1 : Récupérer le token
      final token = await login(username: username, password: password);

      // Étape 2 : Récupérer les données utilisateur
      final user = await fetchUserProfile(token);

      return AuthResult.success(user: user, token: token);
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Erreur de connexion inattendue');
    }
  }

  // VALIDATION DU TOKEN (vérifie si le token est encore valide)
  Future<bool> validateToken(String token) async {
    try {
      ApiService.setAuthToken(token);
      // Faire un appel simple pour vérifier la validité
      await ApiService.get('/auth/validate');
      return true;
    } catch (e) {
      return false;
    }
  }

  // STOCKAGE LOCAL
  Future<void> saveAuthData({
    required String token,
    required User user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<({String? token, User? user})> getStoredAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (token != null && userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        return (token: token, user: user);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
    return (token: null, user: null);
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_refreshTokenKey);
    ApiService.clearAuthToken();
  }
}