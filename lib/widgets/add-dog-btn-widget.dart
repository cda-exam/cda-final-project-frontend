import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Widget des boutons flottants pour la HomePage
class AddDogBtn extends StatelessWidget {
  final bool isLoadingLocation;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onAddDogPressed;
  final AnimationController animationController;

  const AddDogBtn({
    super.key,
    required this.isLoadingLocation,
    required this.animationController,
    this.onLocationPressed,
    this.onAddDogPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: [
          // Bouton d'ajout de chien
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: animationController.value,
                child: FloatingActionButton(
                  heroTag: "add_dog_button",
                  mini: true,
                  backgroundColor: AppColors.accentBrown,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: onAddDogPressed,
                  tooltip: 'Ajouter un chien',
                  child: const Icon(Icons.pets),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Bouton de repositionnement
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: animationController.value,
                child: FloatingActionButton(
                  heroTag: "location_button",
                  mini: true,
                  backgroundColor: isLoadingLocation
                      ? AppColors.mediumGray
                      : Colors.white,
                  foregroundColor: isLoadingLocation
                      ? Colors.white
                      : AppColors.primaryGreen,
                  elevation: 4,
                  onPressed: isLoadingLocation ? null : onLocationPressed,
                  tooltip: 'Centrer sur ma position',
                  child: isLoadingLocation
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.my_location),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}