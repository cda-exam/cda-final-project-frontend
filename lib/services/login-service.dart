// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api-service.dart';
//
// class LoginService {
//   // Clés pour le stockage local
//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//   static const String _refreshTokenKey = 'refresh_token';
//
//   // État de l'authentification
//   static bool _isAuthenticated = false;
//   static Map<String, dynamic>? _currentUser;
//   static String? _currentToken;
//
//   // Getters pour l'état actuel
//   static bool get isAuthenticated => _isAuthenticated;
//   static Map<String, dynamic>? get currentUser => _currentUser;
//   static String? get currentToken => _currentToken;
//
//   /// Connexion d'un utilisateur
//   static Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await ApiService.post('/login', {
//         'username': email,
//         'password': password,
//       });
//
//       // Sauvegarder les données d'authentification
//       if (response['token'] != null) {
//         await _saveToken(response['token']);
//       }
//
//       if (response['refreshToken'] != null) {
//         await _saveRefreshToken(response['refreshToken']);
//       }
//
//       if (response['user'] != null) {
//         await _saveUserData(response['user']);
//       }
//
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// Connexion avec token biométrique/Touch ID
//   static Future<Map<String, dynamic>> loginWithBiometrics() async {
//     try {
//       // Récupérer le token stocké pour la biométrie
//       final prefs = await SharedPreferences.getInstance();
//       final biometricToken = prefs.getString('biometric_token');
//
//       if (biometricToken == null) {
//         throw Exception('Aucun token biométrique trouvé');
//       }
//
//       final response = await ApiService.post('/login/biometric', {
//         'biometricToken': biometricToken,
//       });
//
//       // Sauvegarder les nouvelles données d'authentification
//       if (response['token'] != null) {
//         await _saveToken(response['token']);
//       }
//
//       if (response['refreshToken'] != null) {
//         await _saveRefreshToken(response['refreshToken']);
//       }
//
//       if (response['user'] != null) {
//         await _saveUserData(response['user']);
//       }
//
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   /// Déconnexion
//   static Future<void> logout() async {
//     try {
//       // Appel au backend pour invalider le token
//       if (_currentToken != null) {
//         await ApiService.post('/logout', {});
//       }
//     } catch (e) {
//       // Continuer même si l'appel échoue
//       debugPrint('Erreur lors de la déconnexion: $e');
//     } finally {
//       // Nettoyer le stockage local
//       await _clearAuthData();
//     }
//   }
//
//   /// Vérifier si l'utilisateur est connecté au démarrage
//   static Future<bool> checkAuthStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString(_tokenKey);
//       final userData = prefs.getString(_userKey);
//
//       if (token != null && userData != null) {
//         _currentToken = token;
//         _currentUser = jsonDecode(userData);
//         _isAuthenticated = true;
//
//         // Configurer le token dans ApiService
//         ApiService.setAuthToken(token);
//
//         // Vérifier si le token est encore valide
//         final isValid = await _validateToken();
//         if (!isValid) {
//           // Essayer de rafraîchir le token
//           final refreshed = await refreshToken();
//           return refreshed;
//         }
//
//         return true;
//       }
//
//       return false;
//     } catch (e) {
//       debugPrint('Erreur lors de la vérification du statut auth: $e');
//       await _clearAuthData();
//       return false;
//     }
//   }
//
//   /// Rafraîchir le token d'authentification
//   static Future<bool> refreshToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final refreshToken = prefs.getString(_refreshTokenKey);
//
//       if (refreshToken == null) {
//         await logout();
//         return false;
//       }
//
//       final response = await ApiService.post('/auth/refresh', {
//         'refreshToken': refreshToken,
//       });
//
//       if (response['token'] != null) {
//         await _saveToken(response['token']);
//
//         // Mettre à jour le refresh token si fourni
//         if (response['refreshToken'] != null) {
//           await _saveRefreshToken(response['refreshToken']);
//         }
//
//         return true;
//       }
//
//       await logout();
//       return false;
//     } catch (e) {
//       debugPrint('Erreur lors du rafraîchissement du token: $e');
//       await logout();
//       return false;
//     }
//   }
//
//   /// Sauvegarder le token d'authentification
//   static Future<void> _saveToken(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_tokenKey, token);
//
//       _currentToken = token;
//       _isAuthenticated = true;
//
//       // Configurer le token dans ApiService
//       ApiService.setAuthToken(token);
//     } catch (e) {
//       debugPrint('Erreur lors de la sauvegarde du token: $e');
//       rethrow;
//     }
//   }
//
//   /// Sauvegarder le refresh token
//   static Future<void> _saveRefreshToken(String refreshToken) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_refreshTokenKey, refreshToken);
//     } catch (e) {
//       debugPrint('Erreur lors de la sauvegarde du refresh token: $e');
//     }
//   }
//
//   /// Sauvegarder les données utilisateur
//   static Future<void> _saveUserData(Map<String, dynamic> userData) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_userKey, jsonEncode(userData));
//
//       _currentUser = userData;
//     } catch (e) {
//       debugPrint('Erreur lors de la sauvegarde des données utilisateur: $e');
//       rethrow;
//     }
//   }
//
//   /// Valider le token actuel
//   static Future<bool> _validateToken() async {
//     if (_currentToken == null) return false;
//
//     try {
//       // Faire un appel simple pour vérifier la validité du token
//       await ApiService.get('/auth/validate');
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// Nettoyer toutes les données d'authentification
//   static Future<void> _clearAuthData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_tokenKey);
//       await prefs.remove(_userKey);
//       await prefs.remove(_refreshTokenKey);
//       await prefs.remove('biometric_token');
//
//       _currentToken = null;
//       _currentUser = null;
//       _isAuthenticated = false;
//
//       // Supprimer le token d'ApiService
//       ApiService.clearAuthToken();
//     } catch (e) {
//       debugPrint('Erreur lors du nettoyage des données auth: $e');
//     }
//   }
//
//   /// Obtenir un message d'erreur utilisateur à partir d'une ApiException
//   static String getErrorMessage(ApiException exception) {
//     switch (exception.statusCode) {
//       case 400:
//         return exception.message ?? 'Données invalides';
//       case 401:
//         return 'Email ou mot de passe incorrect';
//       case 403:
//         return 'Compte désactivé ou accès refusé';
//       case 404:
//         return 'Compte non trouvé';
//       case 423:
//         return 'Compte temporairement verrouillé';
//       case 429:
//         return 'Trop de tentatives. Réessayez plus tard';
//       case 500:
//         return 'Erreur du serveur. Réessayez plus tard';
//       default:
//         return exception.message ?? 'Une erreur inattendue s\'est produite';
//     }
//   }
//
//   /// Mise à jour des données utilisateur
//   static Future<void> updateUserData(Map<String, dynamic> newUserData) async {
//     try {
//       _currentUser = {..._currentUser ?? {}, ...newUserData};
//       await _saveUserData(_currentUser!);
//     } catch (e) {
//       debugPrint('Erreur lors de la mise à jour des données utilisateur: $e');
//       rethrow;
//     }
//   }
//
//   /// Vérifier si l'authentification biométrique est disponible
//   static Future<bool> isBiometricEnabled() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getString('biometric_token') != null;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// Vérifier si le token est valide
//   static Future<bool> isTokenValid() async {
//     if (_currentToken == null) return false;
//
//     try {
//       // Faire un appel simple pour vérifier la validité du token
//       await ApiService.get('/profile');
//       return true;
//     } catch (e) {
//       // Token invalide, essayer de le rafraîchir
//       return await refreshToken();
//     }
//   }
// }