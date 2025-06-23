import 'dart:convert';
import 'dart:io';
import '../models/dog.dart';
import 'api-service.dart';

class DogService {
  /// Ajoute un ou plusieurs chiens à un utilisateur
  /// Correspond à l'API: POST /dogs/{userId}
  static Future<void> addDogsToUser(String userId, List<Dog> dogs) async {
    try {
      final List<Map<String, dynamic>> dogDTOs = dogs.map((dog) => dog.toJson()).toList();
      
      await ApiService.post(
        '/dogs/$userId',
        {'dogs': dogDTOs},  // Envelopper la liste dans un objet Map avec la clé 'dogs'
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute un seul chien à un utilisateur
  static Future<void> addDogToUser(String userId, Dog dog) async {
    return addDogsToUser(userId, [dog]);
  }

  /// Récupère tous les chiens d'un utilisateur
  static Future<List<Dog>> getUserDogs(String userId) async {
    try {
      final response = await ApiService.get('/dogs/user/$userId');
      
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
  static Future<String> uploadDogImage(File imageFile) async {
    try {
      final response = await ApiService.postMultipart(
        '/upload/dog-image',
        {},
        {'image': imageFile},
      );
      
      return response['imageUrl'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
