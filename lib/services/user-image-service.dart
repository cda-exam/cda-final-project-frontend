import 'dart:io';
import 'dart:convert';
import 'package:cda_final_project_frontend/services/api-service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserImageService {
  static const String baseUrl = '/user-images';

  /// Récupère l'URL complète de l'image de profil à partir de son ID
  static String getProfileImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      return ''; // Retourne une chaîne vide si pas d'ID d'image
    }
    
    // Construit l'URL complète pour l'image
    return '${ApiService.baseUrl}$baseUrl/$imageId';
  }
  
  /// Vérifie si l'utilisateur a une image de profil valide
  static bool hasProfileImage(String? imageId) {
    return imageId != null && imageId.isNotEmpty;
  }
  
  /// Upload une image de profil et retourne l'ID de l'image stockée
  static Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Créer une requête multipart
      final uri = Uri.parse('${ApiService.baseUrl}$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Récupérer le token depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Ajouter les headers nécessaires
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      // Ajouter le token d'authentification si disponible
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Déterminer le type MIME de l'image
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';
      
      // Ajouter le fichier à la requête
      final multipartFile = await http.MultipartFile.fromPath(
        'image',  // Nom du paramètre attendu par le backend
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
      
      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Vérifier la réponse
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['id'] != null) {
          return responseData['id'];
        } else {
          throw Exception('ID d\'image non trouvé dans la réponse');
        }
      } else {
        throw Exception('Erreur lors de l\'upload de l\'image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }
}
