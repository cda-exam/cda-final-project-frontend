import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../constants/colors.dart';
import '../services/location-service.dart';
import '../widgets/map-widget.dart';
import '../widgets/loading-widget.dart';
import '../widgets/add-dog-modal-widget.dart';
import '../widgets/add-dog-btn-widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  late AnimationController _fabController;
  late AnimationController _locationButtonController;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _locationButtonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _locationButtonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      final position = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        if (_mapController != null) {
          _mapController!.move(
            LocationService.positionToLatLng(position),
            16.0,
          );
        }
      }

      // Démarrer les animations après avoir obtenu la position
      _fabController.forward();
      _locationButtonController.forward();

    } on LocationException catch (e) {
      _showLocationError(e.message);
    } catch (e) {
      _showLocationError('Erreur inattendue: $e');
    }
  }

  void _showLocationError(String message) {
    setState(() {
      _isLoadingLocation = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }

    // Démarrer les animations même en cas d'erreur
    _fabController.forward();
    _locationButtonController.forward();
  }

  void _onMapReady(MapController controller) {
    _mapController = controller;

    // Si on a déjà la position, centrer la carte
    if (_currentPosition != null) {
      controller.move(
        LocationService.positionToLatLng(_currentPosition!),
        16.0,
      );
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_mapController != null && _currentPosition != null) {
      // Animation du bouton
      _locationButtonController.reset();
      _locationButtonController.forward();

      final targetLatLng = LocationService.positionToLatLng(_currentPosition!);

      _mapController!.move(targetLatLng, 16.0);
    } else {
      // Relancer la géolocalisation
      _getCurrentLocation();
    }
  }

  void _handleAddDog() {
    AddDogModal.show(
      context,
      onDogAdded: _onDogAdded,
    );
  }

  void _onDogAdded(Dog dog) {
    // TODO: Rafraîchir la liste des chiens ou mettre à jour l'état
    // setState(() {
    //   // Mettre à jour la liste des chiens
    // });
    print('dog added : ' + dog.name);
  }

  void _handleNewWalk() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localisation requise pour commencer une promenade'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Action pour créer une nouvelle promenade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.pets, color: Colors.white),
            SizedBox(width: 8),
            Text('Nouvelle promenade - À venir !'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleMapTap(LatLng tappedPoint) {
    // Action lors d'un tap sur la carte
    print('Position tappée: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte en plein écran
          OSMMapWidget(
            onMapReady: _onMapReady,
            initialPosition: _currentPosition,
            showCurrentLocationMarker: true,
            initialZoom: 15.0,
            onTap: _handleMapTap,
          ),

          // Overlay de chargement
          LoadingOverlay(
            isVisible: _isLoadingLocation,
            message: 'Localisation en cours...',
            onRetry: _getCurrentLocation,
          ),

          // Titre de l'app (en haut à gauche)
          SafeArea(
            child: Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Promenades',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Boutons flottants à droite
          AddDogBtn(
            isLoadingLocation: _isLoadingLocation,
            animationController: _locationButtonController,
            onLocationPressed: _centerOnCurrentLocation,
            onAddDogPressed: _handleAddDog,
          ),
        ],
      ),

      // FAB pour nouvelle promenade
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabController.value,
            child: FloatingActionButton.extended(
              heroTag: "new_walk_button",
              onPressed: _handleNewWalk,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_road),
              label: const Text(
                'Nouvelle promenade',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}