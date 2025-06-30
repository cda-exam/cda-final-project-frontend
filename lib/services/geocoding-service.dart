import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  
  /// Recherche des lieux à partir d'une requête
  static Future<List<Place>> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      // Encoder la requête pour l'URL
      final encodedQuery = Uri.encodeComponent(query);
      
      // Construire l'URL avec les paramètres
      final url = '$_baseUrl/search?q=$encodedQuery&format=json&limit=5&addressdetails=1';
      
      // Effectuer la requête HTTP
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'CDA_Final_Project_App/1.0', // Important pour respecter les conditions d'utilisation de Nominatim
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        // Décoder la réponse JSON
        final List<dynamic> data = jsonDecode(response.body);
        
        // Convertir les données en objets Place
        return data.map((item) => Place.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors de la recherche de lieux: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche de lieux: $e');
    }
  }
}

/// Modèle représentant un lieu géographique
class Place {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? type;
  final String? city;
  final String? postcode;
  
  Place({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.type,
    this.city,
    this.postcode,
  });
  
  /// Crée une instance de Place à partir d'un objet JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    // Extraire les détails d'adresse si disponibles
    String? city;
    String? postcode;
    
    if (json.containsKey('address')) {
      final address = json['address'];
      city = address['city'] ?? address['town'] ?? address['village'] ?? address['hamlet'];
      postcode = address['postcode'];
    }
    
    return Place(
      displayName: json['display_name'] ?? 'Lieu inconnu',
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      type: json['type'],
      city: city,
      postcode: postcode,
    );
  }
  
  /// Convertit le lieu en LatLng pour la carte
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}
