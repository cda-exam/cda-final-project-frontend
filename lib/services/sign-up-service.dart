import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api-service.dart';

class SignUpService {
  // Clés pour le stockage local
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

  // État de l'authentification
  static bool _isAuthenticated = false;
  static Map<String, dynamic>? _currentUser;
  static String? _currentToken;

  // Getters pour l'état actuel
  static bool get isAuthenticated => _isAuthenticated;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentToken => _currentToken;

  /// Inscription d'un utilisateur
  static Future<Map<String, dynamic>> signup({
    required String nickname,
    required String email,
    required String password,
    String? city,
  }) async {
    try {
      // Préparer les données utilisateur
      Map<String, dynamic> userData = {
        'nickname': nickname,
        'email': email,
        'password': password,
      };

      // Ajouter la ville si fournie
      if (city != null && city.isNotEmpty) {
        userData['city'] = city;
      }

      // Appel à la route register
      final response = await ApiService.post('/register', userData);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Vérification du code email
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      final response = await ApiService.post('/activate/$email', {
        'code': verificationCode,
      });

      // Après vérification réussie, sauvegarder le token et les données utilisateur
      if (response['token'] != null) {
        await _saveToken(response['token']);
      }

      if (response['refreshToken'] != null) {
        await _saveRefreshToken(response['refreshToken']);
      }

      if (response['user'] != null) {
        await _saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Renvoyer un code de vérification
  static Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    try {
      final response = await ApiService.post('/resend-verification', {
        'email': email,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Connexion d'un utilisateur
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/login', {
        'email': email,
        'password': password,
      });

      // Sauvegarder le token et les données utilisateur
      if (response['token'] != null) {
        await _saveToken(response['token']);
      }

      if (response['refreshToken'] != null) {
        await _saveRefreshToken(response['refreshToken']);
      }

      if (response['user'] != null) {
        await _saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion
  static Future<void> logout() async {
    try {
      // Appel au backend pour invalider le token
      if (_currentToken != null) {
        await ApiService.post('/logout', {});
      }
    } catch (e) {
      // Continuer même si l'appel échoue
      debugPrint('Erreur lors de la déconnexion: $e');
    } finally {
      // Nettoyer le stockage local
      await _clearAuthData();
    }
  }

  /// Vérifier si l'utilisateur est connecté au démarrage
  static Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null) {
        _currentToken = token;
        _currentUser = jsonDecode(userData);
        _isAuthenticated = true;

        // Configurer le token dans ApiService
        ApiService.setAuthToken(token);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut auth: $e');
      return false;
    }
  }

  /// Rafraîchir le token d'authentification
  static Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null) {
        await logout();
        return false;
      }

      final response = await ApiService.post('/refresh-token', {
        'refreshToken': refreshToken,
      });

      if (response['token'] != null) {
        await _saveToken(response['token']);
        return true;
      }

      await logout();
      return false;
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement du token: $e');
      await logout();
      return false;
    }
  }

  /// Sauvegarder le token d'authentification
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      _currentToken = token;
      _isAuthenticated = true;

      // Configurer le token dans ApiService
      ApiService.setAuthToken(token);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du token: $e');
      rethrow;
    }
  }

  /// Sauvegarder le refresh token
  static Future<void> _saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du refresh token: $e');
    }
  }

  /// Sauvegarder les données utilisateur
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData));

      _currentUser = userData;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des données utilisateur: $e');
      rethrow;
    }
  }

  /// Nettoyer toutes les données d'authentification
  static Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_refreshTokenKey);

      _currentToken = null;
      _currentUser = null;
      _isAuthenticated = false;

      // Supprimer le token d'ApiService
      ApiService.clearAuthToken();
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des données auth: $e');
    }
  }

  /// Obtenir un message d'erreur utilisateur à partir d'une ApiException
  static String getErrorMessage(ApiException exception) {
    switch (exception.statusCode) {
      case 400:
        return exception.message ?? 'Données invalides';
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès non autorisé';
      case 404:
        return 'Service non disponible';
      case 409:
        return 'Cet email est déjà utilisé';
      case 422:
        return 'Données de validation incorrectes';
      case 429:
        return 'Trop de tentatives. Réessayez plus tard';
      case 500:
        return 'Erreur du serveur. Réessayez plus tard';
      default:
        return exception.message ?? 'Une erreur inattendue s\'est produite';
    }
  }

  /// Mise à jour des données utilisateur
  static Future<void> updateUserData(Map<String, dynamic> newUserData) async {
    try {
      _currentUser = {..._currentUser ?? {}, ...newUserData};
      await _saveUserData(_currentUser!);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des données utilisateur: $e');
      rethrow;
    }
  }

  /// Vérifier si le token est valide
  static Future<bool> isTokenValid() async {
    if (_currentToken == null) return false;

    try {
      // Faire un appel simple pour vérifier la validité du token
      await ApiService.get('/profile');
      return true;
    } catch (e) {
      // Token invalide, essayer de le rafraîchir
      return await refreshToken();
    }
  }
}