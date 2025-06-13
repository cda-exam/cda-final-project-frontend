import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Service de gestion de la géolocalisation
class LocationService {
  // Position par défaut (Paris) si géolocalisation échoue
  static const LatLng defaultLocation = LatLng(48.8566, 2.3522);

  /// Vérifie et demande les permissions de localisation
  static Future<LocationPermission> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Obtient la position actuelle de l'utilisateur
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      final permission = await checkPermissions();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationException('Permission de localisation refusée');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit ?? const Duration(seconds: 10),
      );
    } catch (e) {
      throw LocationException('Erreur lors de la localisation: $e');
    }
  }

  /// Vérifie si les services de localisation sont activés
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Convertit une Position en LatLng (pour flutter_map)
  static LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
}

/// Exception personnalisée pour les erreurs de localisation
class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}