import 'package:cda_final_project_frontend/services/api-service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  static String getErrorMessage(ApiException exception) {
    switch (exception.statusCode) {
      case 400: return 'Données invalides';
      case 401: return 'Email ou mot de passe incorrect';
      case 403: return 'Compte désactivé ou accès refusé';
      case 404: return 'Compte non trouvé';
      case 423: return 'Compte temporairement verrouillé';
      case 429: return 'Trop de tentatives. Réessayez plus tard';
      case 500: return 'Erreur du serveur. Réessayez plus tard';
      default: return exception.message ?? 'Une erreur inattendue s\'est produite';
    }
  }
}