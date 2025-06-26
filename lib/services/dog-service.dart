import 'dart:io';
import '../models/dog.dart';
import 'api-service.dart';

class DogService {
  /// Ajoute un ou plusieurs chiens à un utilisateur
  /// Correspond à l'API: POST /dogs/{userId}
  static Future<void> addDogsToUser(String userId, List<Dog> dogs) async {
    try {
      // Vérifier si userId est vide ou null
      if (userId == null || userId.isEmpty) {
        throw Exception('userId ne peut pas être vide ou null');
      }
      
      final List<Map<String, dynamic>> dogDTOs = dogs.map((dog) => dog.toJson()).toList();
      
      // Assurons-nous que l'URL inclut bien l'ID utilisateur
      final String endpoint = '/dogs/$userId';
      
      // Debug pour vérifier l'URL
      print('Calling API endpoint: $endpoint with userId: $userId');
      print('URL complète attendue: ${ApiService.baseUrl}$endpoint');
      
      await ApiService.post(
        endpoint,
        {'dogs': dogDTOs},  // Envelopper la liste dans un objet Map avec la clé 'dogs'
      );
    } catch (e) {
      print('Error in addDogsToUser: $e');
      rethrow;
    }
  }

  /// Ajoute un seul chien à un utilisateur
  static Future<void> addDogToUser(String userId, Dog dog) async {
    try {
      // Vérifier si userId est vide ou null
      if (userId == null || userId.isEmpty) {
        throw Exception('userId ne peut pas être vide ou null');
      }
      
      // Convertir le chien en JSON
      final dogJson = dog.toJson();
      
      // Assurons-nous que l'URL inclut bien l'ID utilisateur
      final String endpoint = '/dogs/$userId';
      
      // Debug pour vérifier l'URL
      print('Calling API endpoint: $endpoint with userId: $userId');
      print('URL complète attendue: ${ApiService.baseUrl}$endpoint');
      print('Données envoyées: $dogJson');
      
      // Envoyer directement l'objet JSON du chien, sans l'envelopper dans un tableau ou un objet
      await ApiService.post(endpoint, dogJson);
    } catch (e) {
      print('Error in addDogToUser: $e');
      rethrow;
    }
  }

  /// Récupère tous les chiens d'un utilisateur
  /// Correspond à l'API: GET /dogs/{userId}
  static Future<List<Dog>> getUserDogs(String userId) async {
    try {
      final response = await ApiService.get('/dogs/$userId');
      
      if (response['dogs'] != null) {
        return (response['dogs'] as List)
            .map((dogJson) => Dog.fromJson(dogJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Télécharge une image de chien
  /// Retourne l'ID MongoDB de l'image
  static Future<String> uploadDogImage(File imageFile) async {
    try {
      print('Uploading dog image...');
      final response = await ApiService.postMultipart(
        '/dog-images/upload',
        {},
        {'image': imageFile},
      );
      
      // Afficher la réponse complète pour déboguer
      print('Image upload response: $response');
      
      // Essayer de récupérer l'ID de l'image avec différentes clés possibles
      String? imageId;
      if (response.containsKey('id')) {
        imageId = response['id'] as String;
      } else if (response.containsKey('_id')) {
        imageId = response['_id'] as String;
      } else if (response.containsKey('imageId')) {
        imageId = response['imageId'] as String;
      } else if (response.containsKey('image')) {
        // Si l'image est un objet avec un ID
        if (response['image'] is Map && (response['image'] as Map).containsKey('id')) {
          imageId = (response['image'] as Map)['id'] as String;
        }
      }
      
      if (imageId == null || imageId.isEmpty) {
        throw Exception('Impossible de récupérer l\'ID de l\'image dans la réponse: $response');
      }
      
      print('Image uploaded successfully, ID: $imageId');
      return imageId;
    } catch (e) {
      print('Error uploading dog image: $e');
      rethrow;
    }
  }
  
  /// Supprime un chien
  /// Correspond à l'API: DELETE /dogs/{dogId}
  static Future<void> deleteDog(String dogId) async {
    try {
      await ApiService.delete('/dogs/$dogId');
    } catch (e) {
      rethrow;
    }
  }
  
  /// Met à jour les informations d'un chien
  /// Correspond à l'API: PUT /dogs/{dogId}
  static Future<void> updateDog(String dogId, Dog dog) async {
    try {
      await ApiService.put(
        '/dogs/$dogId',
        dog.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
