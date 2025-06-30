import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../constants/colors.dart';
import '../models/user.dart';
import '../models/dog.dart';
import '../services/auth-service.dart';
import '../services/dog-service.dart';
import '../services/location-service.dart';
import '../services/user-image-service.dart';
import '../services/walk-service.dart';
import '../widgets/loading-widget.dart';
import '../widgets/map-widget.dart';
import '../widgets/add-dog-btn-widget.dart';
import '../widgets/add-dog-modal-widget.dart' show AddDogModal, UIDog;
import '../widgets/create-walk-form-widget.dart';
import '../pages/my_dogs_page.dart';

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
  final GlobalKey<OSMMapWidgetState> _mapKey = GlobalKey<OSMMapWidgetState>();
  Timer? _locationUpdateTimer;
  
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
    
    // Mettre à jour la position toutes les 10 secondes
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _locationButtonController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
  
  void _startLocationUpdates() {
    // Annuler le timer existant s'il y en a un
    _locationUpdateTimer?.cancel();
    
    // Créer un nouveau timer pour mettre à jour la position périodiquement
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateCurrentLocation();
    });
  }
  
  Future<void> _updateCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );

      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
        });

        // Mettre à jour le marqueur sur la carte
        if (_mapKey.currentState != null) {
          _mapKey.currentState!.updateCurrentPosition(position);
        }
      }
    } catch (e) {
      // Ignorer les erreurs lors des mises à jour en arrière-plan
      print('Erreur lors de la mise à jour de la position: $e');
    }
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

        // Mettre à jour le marqueur sur la carte
        if (_mapKey.currentState != null) {
          _mapKey.currentState!.updateCurrentPosition(position);
        }

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
      
      // Forcer la mise à jour du marqueur de position
      if (_mapKey.currentState != null) {
        _mapKey.currentState!.updateCurrentPosition(_currentPosition!);
      }
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

    // Afficher le modal avec le formulaire de création de promenade
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: CreateWalkFormWidget(
            onWalkCreated: (walk, latitude, longitude) async {
              // Fermer le modal
              Navigator.pop(context);
              
              // Afficher un indicateur de chargement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(width: 16),
                      Text('Création de la promenade en cours...'),
                    ],
                  ),
                  backgroundColor: AppColors.primaryGreen,
                  duration: Duration(seconds: 2),
                ),
              );
              
              try {
                // Utiliser les coordonnées du lieu sélectionné si disponibles,
                // sinon utiliser la position actuelle de l'utilisateur
                final double walkLatitude = latitude ?? _currentPosition!.latitude;
                final double walkLongitude = longitude ?? _currentPosition!.longitude;
                
                // Appeler l'API pour créer la promenade
                final createdWalk = await WalkService.createWalk(
                  walk,
                  walkLatitude,
                  walkLongitude,
                );
                
                // Afficher un message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Promenade créée avec succès !'),
                      ],
                    ),
                    backgroundColor: AppColors.primaryGreen,
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Actualiser la carte si nécessaire
                // TODO: Ajouter un marqueur pour la nouvelle promenade
                
              } catch (e) {
                // Afficher un message d'erreur
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Erreur: ${e.toString()}'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _handleMapTap(LatLng tappedPoint) {
    // Action lors d'un tap sur la carte
    print('Position tappée: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
  }

  void _showUserMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryGreen),
              SizedBox(width: 12),
              Text('Mon profil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'dogs',
          child: Row(
            children: [
              Icon(Icons.pets, color: AppColors.accentBrown),
              SizedBox(width: 12),
              Text('Mes chiens'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: AppColors.darkGray),
              SizedBox(width: 12),
              Text('Paramètres'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error),
              SizedBox(width: 12),
              Text('Déconnexion'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'profile') {
        // Navigation vers la page de profil (à implémenter)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page de profil - Fonctionnalité à venir'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (value == 'dogs') {
        // Navigation vers la page des chiens
        _navigateToMyDogsPage();
      } else if (value == 'settings') {
        // Navigation vers la page de paramètres (à implémenter)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paramètres - Fonctionnalité à venir'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (value == 'logout') {
        // Déconnexion (à implémenter)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Déconnexion - Fonctionnalité à venir'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  /// Navigue vers la page des chiens de l'utilisateur
  void _navigateToMyDogsPage() {
    if (_currentUser == null || _currentUser!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer vos informations utilisateur'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyDogsPage(userId: _currentUser!.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte en plein écran
          OSMMapWidget(
            key: _mapKey,
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
              child: GestureDetector(
                onTap: () {
                  _showUserMenu(context);
                },
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