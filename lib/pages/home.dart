import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../constants/colors.dart';
import '../services/location-service.dart';
import '../services/auth-service.dart';
import '../services/user-image-service.dart';
import '../models/user.dart';
import '../widgets/map-widget.dart';
import '../widgets/loading-widget.dart';
import '../widgets/add-dog-modal-widget.dart' show AddDogModal, UIDog;
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
  
  // Informations utilisateur
  User? _currentUser;
  bool _isLoadingUser = true;

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
    _loadUserData();
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
    AddDogModal.show(context, onDogAdded: _onDogAdded);
  }

  void _onDogAdded(UIDog dog) {
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dog.name} a été ajouté à votre profil'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Ici, vous pourriez recharger la liste des chiens de l'utilisateur
    // si vous affichez cette liste quelque part dans l'interface
    // Exemple: _loadUserDogs();
    
    // Pour l'instant, on se contente d'un log
    print('Dog added: ${dog.name}, ${dog.breed}, ${_formatDate(dog.birthDate)}');
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  /// Charge les données de l'utilisateur connecté
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });
    
    try {
      final authData = await AuthService().getStoredAuthData();
      setState(() {
        _currentUser = authData.user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }
  
  /// Construit l'avatar de l'utilisateur
  Widget _buildUserAvatar() {
    // Si les données utilisateur sont en cours de chargement
    if (_isLoadingUser) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }
    
    // Si l'utilisateur a une image de profil
    if (_currentUser != null && UserImageService.hasProfileImage(_currentUser!.profilePicture)) {
      final imageUrl = UserImageService.getProfileImageUrl(_currentUser!.profilePicture);
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.lightGray,
        backgroundImage: NetworkImage(imageUrl),
      );
    }
    
    // Avatar par défaut
    return const CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryGreen,
      child: Icon(
        Icons.person,
        size: 26,
        color: Colors.white,
      ),
    );
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

          // Avatar utilisateur (en haut à gauche)
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildUserAvatar(),
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