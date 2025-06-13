import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/map-service.dart';

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
  State<OSMMapWidget> createState() => _OSMMapWidgetState();
}

class _OSMMapWidgetState extends State<OSMMapWidget> {
  late final MapController _mapController;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMarkers();

    // Notifier le parent que la carte est prête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onMapReady != null) {
        widget.onMapReady!(_mapController);
      }
    });
  }

  void _initializeMarkers() {
    _markers = List<Marker>.from(widget.additionalMarkers ?? []);

    // Ajouter le marqueur de position actuelle si demandé
    if (widget.showCurrentLocationMarker && widget.initialPosition != null) {
      final currentLocationMarker = MapService.createCurrentLocationMarker(
        LatLng(
          widget.initialPosition!.latitude,
          widget.initialPosition!.longitude,
        ),
      );
      _markers.add(currentLocationMarker);
    }
  }

  LatLng get _initialCenter {
    if (widget.initialPosition != null) {
      return LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    }
    return const LatLng(48.8566, 2.3522); // Paris par défaut
  }

  /// Centrer la carte sur une position
  void centerOnPosition(LatLng position, {double? zoom}) {
    _mapController.move(position, zoom ?? _mapController.camera.zoom);
  }

  /// Ajouter un marqueur à la carte
  void addMarker(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }

  /// Supprimer tous les marqueurs
  void clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  /// Mettre à jour les marqueurs
  void updateMarkers(List<Marker> newMarkers) {
    setState(() {
      _markers = newMarkers;
    });
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
              '© OpenStreetMap contributors',
              onTap: () {}, // Vous pouvez ajouter un lien vers OSM
            ),
          ],
        ),
      ],
    );
  }
}