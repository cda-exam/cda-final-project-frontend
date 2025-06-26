import 'dart:io';
import 'dart:typed_data';
import 'package:cda_final_project_frontend/services/api-service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class DogImageService {
  static const String baseUrl = '/dog-images';
  static const String imageEndpoint = '/dog-images'; // Endpoint correct pour récupérer les images

  /// Récupère l'URL complète de l'image du chien à partir de son ID
  static String getDogImageUrl(String? imageId) {
    if (imageId == null || imageId.isEmpty) {
      print('getDogImageUrl: imageId is null or empty');
      return ''; // Retourne une chaîne vide si pas d'ID d'image
    }
    
    // Construit l'URL complète pour l'image
    final url = '${ApiService.baseUrl}$imageEndpoint/$imageId';
    print('getDogImageUrl: constructed URL: $url');
    return url;
  }
  
  /// Récupère les données binaires de l'image du chien
  static Future<Uint8List?> getDogImageBytes(String? imageId) async {
    if (imageId == null || imageId.isEmpty) {
      print('getDogImageBytes: imageId is null or empty');
      return null;
    }
    
    try {
      final url = Uri.parse('${ApiService.baseUrl}$imageEndpoint/$imageId');
      print('Fetching dog image from: $url');
      
      // Récupérer le token depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Préparer les headers
      final headers = <String, String>{
        'Accept': '*/*',
      };
      
      // Ajouter le token d'authentification si disponible
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // Faire la requête HTTP
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error fetching dog image: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception while fetching dog image: $e');
      return null;
    }
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
  
  /// Crée un widget Image à partir de l'ID de l'image
  static Widget buildDogImage(String? imageId, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageId == null || imageId.isEmpty) {
      return placeholder ?? Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.pets, color: Colors.grey),
      );
    }
    
    return FutureBuilder<Uint8List?>(
      future: getDogImageBytes(imageId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return errorWidget ?? Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        }
        
        return Image.memory(
          snapshot.data!,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
