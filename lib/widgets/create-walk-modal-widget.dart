import 'package:flutter/material.dart';
import '../models/walk.dart';
import '../constants/colors.dart';
import 'create-walk-form-widget.dart';

class CreateWalkModal extends StatelessWidget {
  final Function(Walk, double?, double?)? onWalkCreated;

  const CreateWalkModal({
    Key? key,
    this.onWalkCreated,
  }) : super(key: key);

  /// Affiche le modal de création de promenade en plein écran
  static Future<void> show(BuildContext context, {Function(Walk, double?, double?)? onWalkCreated}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important pour permettre le plein écran
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.95, // Prend 95% de la hauteur de l'écran
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: CreateWalkModal(
              onWalkCreated: onWalkCreated,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de titre avec bouton de fermeture
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Créer une promenade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        
        // Contenu du formulaire
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CreateWalkFormWidget(
                onWalkCreated: (walk, latitude, longitude) {
                  Navigator.of(context).pop(); // Fermer le modal
                  if (onWalkCreated != null) {
                    onWalkCreated!(walk, latitude, longitude);
                  }
                },
                onCancel: () {
                  Navigator.of(context).pop(); // Fermer le modal
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
