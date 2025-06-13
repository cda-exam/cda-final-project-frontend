import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/colors.dart';

/// Modèle pour représenter un chien
class Dog {
  final String name;
  final String breed;
  final DateTime birthDate;
  final String gender; // 'male' ou 'female'
  final String? description;
  final File? photo;

  Dog({
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.gender,
    this.description,
    this.photo,
  });
}

/// Modal pour ajouter un nouveau chien
class AddDogModal extends StatefulWidget {
  final Function(Dog dog)? onDogAdded;

  const AddDogModal({
    super.key,
    this.onDogAdded,
  });

  /// Méthode statique pour afficher la modal facilement
  static Future<void> show(
      BuildContext context, {
        Function(Dog dog)? onDogAdded,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddDogModal(onDogAdded: onDogAdded),
    );
  }

  @override
  State<AddDogModal> createState() => _AddDogModalState();
}

class _AddDogModalState extends State<AddDogModal> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  DateTime _selectedBirthDate = DateTime.now();
  String _selectedGender = 'male';
  File? _selectedPhoto;
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // 25 ans max
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _handleAddDog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dog = Dog(
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        description: _descriptionController.text.trim(),
        photo: _selectedPhoto,
      );

      // Simulation d'un délai d'API
      await Future.delayed(const Duration(milliseconds: 500));

      if (widget.onDogAdded != null) {
        widget.onDogAdded!(dog);
      }

      if (mounted) {
        // Fermer la modal
        Navigator.pop(context);

        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${dog.name} a été ajouté avec succès !'),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      print('🐕 Chien ajouté: ${dog.name}, ${dog.breed}, ${dog.gender}');
      print('📅 Né le: ${_formatDate(dog.birthDate)} (${_calculateAge(dog.birthDate)} ans)');
    
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle de la modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Titre avec icône
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentBrown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppColors.accentBrown,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Ajouter un chien',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section photo
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 2,
                            ),
                            image: _selectedPhoto != null
                                ? DecorationImage(
                              image: FileImage(_selectedPhoto!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _selectedPhoto == null
                              ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: AppColors.primaryGreen,
                                size: 32,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ajouter\nune photo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Champ nom (requis)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du chien *',
                        hintText: 'Ex: Rex, Bella...',
                        prefixIcon: const Icon(Icons.badge, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.error, width: 2),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom du chien est requis';
                        }
                        if (value.trim().length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Champ race
                    TextFormField(
                      controller: _breedController,
                      decoration: InputDecoration(
                        labelText: 'Race',
                        hintText: 'Ex: Labrador, Golden Retriever...',
                        prefixIcon: const Icon(Icons.category, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Date de naissance
                    GestureDetector(
                      onTap: _selectBirthDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.mediumGray),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake, color: AppColors.primaryGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date de naissance',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedBirthDate != null
                                        ? '${_formatDate(_selectedBirthDate)} (${_calculateAge(_selectedBirthDate)} ans)'
                                        : 'Sélectionner une date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _selectedBirthDate != null
                                          ? AppColors.darkGray
                                          : AppColors.mediumGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.mediumGray),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sexe
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.mediumGray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.pets, color: AppColors.primaryGreen),
                              SizedBox(width: 12),
                              Text(
                                'Sexe',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedGender = 'male'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedGender == 'male'
                                          ? AppColors.primaryGreen.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedGender == 'male'
                                            ? AppColors.primaryGreen
                                            : AppColors.lightGray,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.male,
                                          color: _selectedGender == 'male'
                                              ? AppColors.primaryGreen
                                              : AppColors.mediumGray,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Mâle',
                                          style: TextStyle(
                                            color: _selectedGender == 'male'
                                                ? AppColors.primaryGreen
                                                : AppColors.mediumGray,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedGender = 'female'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _selectedGender == 'female'
                                          ? AppColors.primaryGreen.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedGender == 'female'
                                            ? AppColors.primaryGreen
                                            : AppColors.lightGray,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.female,
                                          color: _selectedGender == 'female'
                                              ? AppColors.primaryGreen
                                              : AppColors.mediumGray,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Femelle',
                                          style: TextStyle(
                                            color: _selectedGender == 'female'
                                                ? AppColors.primaryGreen
                                                : AppColors.mediumGray,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Décrivez votre chien (caractère, habitudes...)',
                        prefixIcon: const Icon(Icons.description, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.mediumGray),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAddDog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Ajouter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}