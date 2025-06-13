import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

/// Service de gestion des cartes avec OpenStreetMap
class MapService {
  static const String cartoDBUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  // Subdomains pour CartoDB
  static const List<String> cartoDBSubdomains = ['a', 'b', 'c', 'd'];

  /// Configuration des tuiles CartoDB (plus esthétique)
  static TileLayer get cartoDBTileLayer => TileLayer(
    urlTemplate: cartoDBUrl,
    subdomains: cartoDBSubdomains,
    userAgentPackageName: 'com.example.promenades_canines',
    retinaMode: true,
    tileProvider: CancellableNetworkTileProvider(),
    maxZoom: 19,
    minZoom: 1,
  );

  /// Configuration par défaut recommandée
  static TileLayer get defaultTileLayer => cartoDBTileLayer;

  /// Créer un marqueur personnalisé
  static Marker createMarker({
    required LatLng position,
    required String markerId,
    String? title,
    String? subtitle,
    Widget? customIcon,
  }) {
    return Marker(
      point: position,
      child: customIcon ?? _defaultMarkerIcon(),
      width: 40,
      height: 40,
    );
  }

  /// Créer un marqueur pour la position actuelle
  static Marker createCurrentLocationMarker(LatLng position) {
    return Marker(
      point: position,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2F5233).withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
      width: 40,
      height: 40,
    );
  }

  /// Créer un marqueur pour une promenade
  static Marker createWalkMarker({
    required LatLng position,
    required String walkId,
    bool isStartPoint = false,
  }) {
    return Marker(
      point: position,
      child: Container(
        decoration: BoxDecoration(
          color: isStartPoint ? const Color(0xFF2F5233) : const Color(0xFF894514),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isStartPoint ? Icons.play_arrow : Icons.pets,
          color: Colors.white,
          size: 16,
        ),
      ),
      width: 30,
      height: 30,
    );
  }

  /// Options de carte par défaut
  static MapOptions getDefaultMapOptions({
    required LatLng center,
    double zoom = 15.0,
    Function(LatLng)? onTap,
  }) {
    return MapOptions(
      initialCenter: center,
      initialZoom: zoom,
      minZoom: 5.0,
      maxZoom: 18.0,
      onTap: onTap != null ? (tapPosition, point) => onTap(point) : null,
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all,
      ),
    );
  }

  /// Widget d'icône de marqueur par défaut
  static Widget _defaultMarkerIcon() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF894514),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Calculer les limites pour centrer plusieurs marqueurs
  static LatLngBounds calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('La liste de points ne peut pas être vide');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }
}