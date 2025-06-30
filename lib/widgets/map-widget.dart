import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/map-service.dart';
import '../widgets/pulsating-location-marker.dart';

/// Interface publique pour accéder aux méthodes du widget de carte
abstract class OSMMapWidgetInterface {
  void updateCurrentPosition(Position position);
  void centerOnPosition(LatLng position, {double? zoom});
  void addMarker(Marker marker);
  void clearMarkers();
  void updateMarkers(List<Marker> newMarkers);
}

/// Widget de carte OpenStreetMap réutilisable
class OSMMapWidget extends StatefulWidget {
  final Position? initialPosition;
  final double initialZoom;
  final bool showCurrentLocationMarker;
  final List<Marker>? additionalMarkers;
  final Function(LatLng)? onTap;
  final Function(MapController)? onMapReady;

  const OSMMapWidget({
    super.key,
    this.initialPosition,
    this.initialZoom = 15.0,
    this.showCurrentLocationMarker = true,
    this.additionalMarkers,
    this.onTap,
    this.onMapReady,
  });

  @override
  State<OSMMapWidget> createState() => OSMMapWidgetState();
}

class OSMMapWidgetState extends State<OSMMapWidget> implements OSMMapWidgetInterface {
  late final MapController _mapController;
  List<Marker> _markers = [];
  Position? _currentPosition;
  Marker? _currentLocationMarker;
  final Key _locationMarkerKey = const Key('location_marker');

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = widget.initialPosition;
    _initializeMarkers();

    // Notifier le parent que la carte est prête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onMapReady != null) {
        widget.onMapReady!(_mapController);
      }
    });
  }

  @override
  void didUpdateWidget(OSMMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si la position a changé, mettre à jour le marqueur
    if (widget.initialPosition != null && 
        (oldWidget.initialPosition == null || 
         widget.initialPosition!.latitude != oldWidget.initialPosition!.latitude || 
         widget.initialPosition!.longitude != oldWidget.initialPosition!.longitude)) {
      _currentPosition = widget.initialPosition;
      _updateCurrentLocationMarker();
    }
  }

  void _initializeMarkers() {
    _markers = List<Marker>.from(widget.additionalMarkers ?? []);
    _updateCurrentLocationMarker();
  }

  void _updateCurrentLocationMarker() {
    if (!widget.showCurrentLocationMarker || _currentPosition == null) {
      return;
    }

    // Créer le marqueur de position actuelle
    final latLng = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    // Créer le nouveau marqueur avec la même clé
    final newLocationMarker = Marker(
      key: _locationMarkerKey,
      point: latLng,
      width: 50,
      height: 50,
      child: const PulsatingLocationMarker(size: 50.0),
    );

    setState(() {
      // Supprimer l'ancien marqueur s'il existe
      if (_currentLocationMarker != null) {
        _markers.remove(_currentLocationMarker);
      }
      
      // Ajouter le nouveau marqueur
      _markers.add(newLocationMarker);
      _currentLocationMarker = newLocationMarker;
    });

    // Debug
    print('Position mise à jour: ${latLng.latitude}, ${latLng.longitude}');
  }

  LatLng get _initialCenter {
    if (_currentPosition != null) {
      return LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    return const LatLng(48.8566, 2.3522); // Paris par défaut
  }

  /// Centrer la carte sur une position
  @override
  void centerOnPosition(LatLng position, {double? zoom}) {
    _mapController.move(position, zoom ?? _mapController.camera.zoom);
  }

  /// Ajouter un marqueur à la carte
  @override
  void addMarker(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }

  /// Supprimer tous les marqueurs
  @override
  void clearMarkers() {
    setState(() {
      _markers.clear();
      _currentLocationMarker = null;
    });
  }

  /// Mettre à jour les marqueurs
  @override
  void updateMarkers(List<Marker> newMarkers) {
    setState(() {
      _markers = newMarkers;
      if (_currentLocationMarker != null) {
        _markers.add(_currentLocationMarker!);
      }
    });
  }

  /// Mettre à jour la position actuelle
  @override
  void updateCurrentPosition(Position position) {
    _currentPosition = position;
    _updateCurrentLocationMarker();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapService.getDefaultMapOptions(
        center: _initialCenter,
        zoom: widget.initialZoom,
        onTap: widget.onTap,
      ),
      children: [
        // Couche de tuiles (carte de base)
        MapService.defaultTileLayer,

        // Couche des marqueurs
        MarkerLayer(
          markers: _markers,
        ),

        // Attribution (obligatoire pour OpenStreetMap)
        RichAttributionWidget(
          popupInitialDisplayDuration: const Duration(seconds: 2),
          animationConfig: const ScaleRAWA(),
          showFlutterMapAttribution: false,
          attributions: [
            TextSourceAttribution(
              ' OpenStreetMap contributors',
              onTap: () {}, // Vous pouvez ajouter un lien vers OSM
            ),
          ],
        ),
      ],
    );
  }
}