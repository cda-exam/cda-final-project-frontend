import 'dart:io';
import 'package:cda_final_project_frontend/services/api-service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DogImageService {
  static const String baseUrl = '/dog-images';

  /// Récupère l'URL complète de l'image du chien à partir de son ID
  static String getDogImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      print('getDogImageUrl: imageId is null or empty');
      return ''; // Retourne une chaîne vide si pas d'ID d'image
    }
    
    // Construit l'URL complète pour l'image
    final url = '${ApiService.baseUrl}/dog-images/$imageId';
    print('getDogImageUrl: constructed URL: $url');
    return url;
  }
  
  /// Vérifie si le chien a une image valide
  static bool hasDogImage(String? imageId) {
    return imageId != null && imageId.isNotEmpty;
  }
  
  /// Upload une image de chien et retourne l'ID de l'image stockée
  static Future<String> uploadDogImage(File imageFile) async {
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
        final body = response.body.trim();
        // Retourner directement la chaîne reçue (l'id)
        if (body.isNotEmpty) {
          print('Image de chien uploadée avec succès, ID: $body');
          return body;
        } else {
          throw Exception('Réponse vide lors de l\'upload de l\'image du chien');
        }
      } else {
        throw Exception('Erreur lors de l\'upload de l\'image du chien: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image du chien: $e');
      throw Exception('Erreur lors de l\'upload de l\'image du chien: $e');
    }
  }
}
