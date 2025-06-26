import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Exception personnalisée pour les erreurs de localisation
class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

/// Service de gestion de la géolocalisation
class LocationService {
  /// Position par défaut (Paris) si géolocalisation échoue
  static const LatLng defaultLocation = LatLng(48.8566, 2.3522);

  /// Convertit un objet Position de Geolocator en LatLng pour Flutter Map
  static LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }
  
  /// Vérifie et demande les permissions de localisation
  static Future<LocationPermission> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Vérifie si les services de localisation sont activés
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Récupère la position actuelle avec gestion des permissions
  static Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      // Vérifier si la localisation est activée
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Les services de localisation sont désactivés.');
      }

      // Vérifier les permissions
      var permission = await checkPermissions();
      if (permission == LocationPermission.denied) {
        throw LocationException('Les permissions de localisation ont été refusées.');
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
          'Les permissions de localisation sont définitivement refusées. '
          'Veuillez les activer dans les paramètres de votre appareil.'
        );
      }
      
      // Récupérer la position avec un timeout
      try {
        if (timeLimit != null) {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: timeLimit,
          );
        } else {
          // Sans timeout, utiliser une valeur par défaut plus longue
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: accuracy,
            timeLimit: const Duration(seconds: 30),
          );
        }
      } catch (e) {
        // En cas de timeout, essayer de récupérer la dernière position connue
        if (e is TimeoutException) {
          debugPrint('Timeout lors de la récupération de la position actuelle, utilisation de la dernière position connue');
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return lastPosition;
          } else {
            throw LocationException('Impossible d\'obtenir la position actuelle ou la dernière position connue.');
          }
        }
        rethrow;
      }
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException('Erreur lors de la localisation: $e');
    }
  }
  
  /// Calcule la distance entre deux positions en mètres
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude, 
      start.longitude, 
      end.latitude, 
      end.longitude
    );
  }
}