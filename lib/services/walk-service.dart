import 'dart:convert';
import '../models/walk.dart';
import 'api-service.dart';
import 'auth-service.dart';

/// Service pour gérer les promenades
class WalkService {
  static const String _baseUrl = '/walks';

  /// Crée une nouvelle promenade
  static Future<Walk> createWalk(Walk walk, double latitude, double longitude) async {
    try {
      // Récupérer les données d'authentification
      final authData = await AuthService().getStoredAuthData();
      if (authData == null || authData.token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Préparer les données à envoyer
      final Map<String, dynamic> walkData = {
        'date': walk.toJson()['date'],
        'duration': walk.duration,
        'participantsMax': walk.participantsMax,
        'description': walk.description,
        'location': walk.location,
        'startLatitude': latitude,
        'startLongitude': longitude,
      };

      // Appeler l'API
      final response = await ApiService.post(_baseUrl, walkData);
      
      // Convertir la réponse en objet Walk
      return Walk.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère toutes les promenades
  static Future<List<Walk>> getAllWalks() async {
    try {
      final List<dynamic> response = await ApiService.getList(_baseUrl);
      return response.map((json) => Walk.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gestion des erreurs
  static Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return Exception(error.message);
    }
    return Exception('Erreur lors de la communication avec le serveur: ${error.toString()}');
  }
}
