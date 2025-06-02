import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../services/api.dart';
// import '../services/auth_service.dart'; // Décommentez cette ligne

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers pour les informations utilisateur
  final _pseudoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _userProfileImage;

  // Controllers pour les informations du chien
  final List<Map<String, dynamic>> _dogs = [];
  int _currentDogIndex = 0;

  void _initializeFirstDog() {
    _dogs.add({
      'nameController': TextEditingController(),
      'breedController': TextEditingController(),
      'descriptionController': TextEditingController(),
      'birthDate': null,
      'profileImage': null,
    });
  }

  // Couleurs définies
  static const Color primaryGreen = Color(0xFF2F5233);
  static const Color accentBrown = Color(0xFF894514);
  static const Color mediumGray = Color(0xFF989898);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color darkGray = Color(0xFF373737);

  @override
  void initState() {
    super.initState();
    _initializeFirstDog();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();

    // Dispose des controllers des chiens
    for (var dog in _dogs) {
      dog['nameController']?.dispose();
      dog['breedController']?.dispose();
      dog['descriptionController']?.dispose();
    }

    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectUserImage() async {
    HapticFeedback.selectionClick();
    // Ici vous intégrerez image_picker
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _userProfileImage = File(image.path);
    //   });
    // }

    // Simulation pour la démo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité photo à implémenter'),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDogImage() async {
    HapticFeedback.selectionClick();
    // Même implémentation que _selectUserImage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité photo à implémenter'),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addNewDog() {
    HapticFeedback.lightImpact();
    setState(() {
      _dogs.add({
        'nameController': TextEditingController(),
        'breedController': TextEditingController(),
        'descriptionController': TextEditingController(),
        'birthDate': null,
        'profileImage': null,
      });
      _currentDogIndex = _dogs.length - 1;
    });
  }

  void _removeDog(int index) {
    if (_dogs.length > 1) {
      HapticFeedback.selectionClick();
      setState(() {
        // Dispose des controllers avant suppression
        _dogs[index]['nameController']?.dispose();
        _dogs[index]['breedController']?.dispose();
        _dogs[index]['descriptionController']?.dispose();

        _dogs.removeAt(index);

        // Ajuster l'index actuel si nécessaire
        if (_currentDogIndex >= _dogs.length) {
          _currentDogIndex = _dogs.length - 1;
        } else if (_currentDogIndex > index) {
          _currentDogIndex--;
        }
      });
    }
  }

  void _switchToDog(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentDogIndex = index;
    });
  }

  Future<void> _selectDogBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dogs[_currentDogIndex]['birthDate']) {
      HapticFeedback.selectionClick();
      setState(() {
        _dogs[_currentDogIndex]['birthDate'] = picked;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _validateUserInfo()) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1 && _validateDogInfo()) {
      _handleSignup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentStep = 0;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateUserInfo() {
    return _pseudoController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  bool _validateDogInfo() {
    for (var dog in _dogs) {
      if (dog['nameController'].text.isEmpty ||
          dog['breedController'].text.isEmpty ||
          dog['birthDate'] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      // Préparer les données des chiens
      List<Map<String, dynamic>> dogsData = _dogs.map((dog) {
        return {
          'name': dog['nameController'].text,
          'breed': dog['breedController'].text,
          'birthDate': dog['birthDate']!.toIso8601String(),
          'description': dog['descriptionController'].text.isNotEmpty
              ? dog['descriptionController'].text
              : null,
          'profileImage': dog['profileImage'], // Le fichier sera géré séparément
        };
      }).toList();

      // Appel à l'API d'inscription
      final response = await AuthService.signup(
        pseudo: _pseudoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        profileImage: _userProfileImage,
        dogs: dogsData,
      );

      setState(() {
        _isLoading = false;
      });

      // Inscription réussie
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  response['message'] ?? 'Compte créé avec succès !',
                ),
              ),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      // Retour à la page de connexion après un délai
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }

    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher l'erreur spécifique de l'API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );

      // Si erreur de validation, afficher les détails
      if (e.errors != null && e.errors!.isNotEmpty) {
        _showValidationErrors(e.errors!);
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Erreur générale
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Une erreur inattendue s\'est produite'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showValidationErrors(Map<String, dynamic> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Erreurs de validation',
          style: TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontFamily: 'Jost'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Jost',
                color: primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoStep() {
    return Column(
      children: [
        // Photo de profil utilisateur
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: lightGray,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryGreen, width: 3),
                ),
                child: _userProfileImage != null
                    ? ClipOval(
                  child: Image.file(
                    _userProfileImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 50,
                  color: mediumGray,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: primaryGreen,
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _selectUserImage,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Pseudo
        _buildTextField(
          controller: _pseudoController,
          label: 'Pseudo',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir un pseudo';
            }
            if (value.length < 3) {
              return 'Minimum 3 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Email
        _buildTextField(
          controller: _emailController,
          label: 'Adresse email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Format d\'email invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Mot de passe
        _buildTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          icon: Icons.lock_outlined,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: mediumGray,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir un mot de passe';
            }
            if (value.length < 6) {
              return 'Minimum 6 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Confirmation mot de passe
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          icon: Icons.lock_outlined,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: mediumGray,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Ville (facultatif)
        _buildTextField(
          controller: _cityController,
          label: 'Ville de résidence (facultatif)',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildDogInfoStep() {
    final currentDog = _dogs[_currentDogIndex];

    return Column(
      children: [
        // Sélecteur de chiens si plusieurs
        if (_dogs.length > 1) ...[
          Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dogs.length + 1, // +1 pour le bouton d'ajout
              itemBuilder: (context, index) {
                if (index == _dogs.length) {
                  // Bouton d'ajout
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: _addNewDog,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: lightGray,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentBrown.withOpacity(0.5),
                              width: 2,
                              style: BorderStyle.values[1], // Dashed style simulation
                            ),
                          ),
                          child: Icon(
                            Icons.add,
                            color: accentBrown,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _switchToDog(index),
                    child: Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: lightGray,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == _currentDogIndex ? accentBrown : mediumGray,
                              width: index == _currentDogIndex ? 3 : 2,
                            ),
                          ),
                          child: _dogs[index]['profileImage'] != null
                              ? ClipOval(
                            child: Image.file(
                              _dogs[index]['profileImage']!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Icon(
                            Icons.pets,
                            color: index == _currentDogIndex ? accentBrown : mediumGray,
                            size: 30,
                          ),
                        ),
                        if (_dogs.length > 1)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: GestureDetector(
                              onTap: () => _removeDog(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicateur du chien actuel
          Text(
            'Chien ${_currentDogIndex + 1}/${_dogs.length}',
            style: const TextStyle(
              color: mediumGray,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Photo du chien actuel
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: lightGray,
                  shape: BoxShape.circle,
                  border: Border.all(color: accentBrown, width: 3),
                ),
                child: currentDog['profileImage'] != null
                    ? ClipOval(
                  child: Image.file(
                    currentDog['profileImage']!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.pets,
                  size: 50,
                  color: mediumGray,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: accentBrown,
                  shape: const CircleBorder(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _selectDogImage,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Nom du chien
        _buildTextField(
          controller: currentDog['nameController'],
          label: 'Nom de votre chien',
          icon: Icons.pets,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom de votre chien';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Date de naissance
        InkWell(
          onTap: _selectDogBirthDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentDog['birthDate'] != null ? primaryGreen : Colors.transparent,
                width: currentDog['birthDate'] != null ? 2 : 0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: primaryGreen,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Text(
                    currentDog['birthDate'] != null
                        ? '${currentDog['birthDate']!.day}/${currentDog['birthDate']!.month}/${currentDog['birthDate']!.year}'
                        : 'Date de naissance',
                    style: TextStyle(
                      color: currentDog['birthDate'] != null ? darkGray : mediumGray,
                      fontSize: 17,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Race
        _buildTextField(
          controller: currentDog['breedController'],
          label: 'Race',
          icon: Icons.info_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir la race de votre chien';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Description (facultatif)
        _buildTextField(
          controller: currentDog['descriptionController'],
          label: 'Description (facultatif)',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),

        // Bouton d'ajout d'un autre chien (si on est sur le premier chien ou qu'il n'y en a qu'un)
        if (_dogs.length == 1 || _currentDogIndex == _dogs.length - 1) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _addNewDog,
              style: OutlinedButton.styleFrom(
                foregroundColor: accentBrown,
                side: BorderSide(color: accentBrown.withOpacity(0.5), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Ajouter un autre chien',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: const TextStyle(
        color: darkGray,
        fontSize: 17,
        fontFamily: 'Jost',
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: mediumGray,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryGreen,
            size: 22,
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: lightGray.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: lightGray,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGray),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          _currentStep == 0 ? 'Vos informations' : 'Votre compagnon',
          style: const TextStyle(
            color: darkGray,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicateur de progression
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentStep == 1 ? primaryGreen : mediumGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - 200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        SizedBox(height: keyboardVisible ? 10 : 20),

                        // Icône et titre de l'étape
                        if (!keyboardVisible) ...[
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _currentStep == 0 ? primaryGreen : accentBrown,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (_currentStep == 0 ? primaryGreen : accentBrown).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _currentStep == 0 ? Icons.person : Icons.pets,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Text(
                          _currentStep == 0 ? 'Créer votre compte' : _dogs.length > 1 ? 'Vos compagnons' : 'Votre compagnon',
                          style: TextStyle(
                            fontSize: keyboardVisible ? 20 : 28,
                            fontWeight: FontWeight.bold,
                            color: darkGray,
                            fontFamily: 'Jost',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (!keyboardVisible)
                          Text(
                            _currentStep == 0
                                ? 'Renseignez vos informations personnelles'
                                : _dogs.length > 1
                                ? 'Parlez-nous de vos compagnons à quatre pattes'
                                : 'Parlez-nous de votre compagnon à quatre pattes',
                            style: const TextStyle(
                              fontSize: 16,
                              color: mediumGray,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),

                        SizedBox(height: keyboardVisible ? 15 : 30),

                        // Formulaire dans un container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: _currentStep == 0 ? _buildUserInfoStep() : _buildDogInfoStep(),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Boutons de navigation
                        Row(
                          children: [
                            if (_currentStep > 0) ...[
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: _previousStep,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: mediumGray,
                                      side: BorderSide(color: mediumGray, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Précédent',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Jost',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              flex: _currentStep > 0 ? 1 : 1,
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _currentStep == 0 ? primaryGreen : accentBrown,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                    shadowColor: (_currentStep == 0 ? primaryGreen : accentBrown).withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : Text(
                                    _currentStep == 0 ? 'Suivant' : 'Créer mon compte',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Jost',
                                    ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}