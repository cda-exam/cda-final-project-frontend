// lib/widgets/add_dog_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddDogWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onDogsChanged;
  final List<Map<String, dynamic>>? initialDogs;

  const AddDogWidget({
    super.key,
    required this.onDogsChanged,
    this.initialDogs,
  });

  @override
  State<AddDogWidget> createState() => _AddDogWidgetState();
}

class _AddDogWidgetState extends State<AddDogWidget> {
  List<Map<String, dynamic>> _dogs = [];
  int _currentDogIndex = 0;

  // Couleurs définies
  static const Color primaryGreen = Color(0xFF2F5233);
  static const Color accentBrown = Color(0xFF894514);
  static const Color mediumGray = Color(0xFF989898);
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color darkGray = Color(0xFF373737);

  @override
  void initState() {
    super.initState();
    if (widget.initialDogs != null && widget.initialDogs!.isNotEmpty) {
      _dogs = List.from(widget.initialDogs!);
    } else {
      _initializeFirstDog();
    }
  }

  void _initializeFirstDog() {
    _dogs.add({
      'nameController': TextEditingController(),
      'breedController': TextEditingController(),
      'descriptionController': TextEditingController(),
      'birthDate': null,
      'profileImage': null,
    });
    _notifyParent();
  }

  @override
  void dispose() {
    // Dispose des controllers des chiens
    for (var dog in _dogs) {
      dog['nameController']?.dispose();
      dog['breedController']?.dispose();
      dog['descriptionController']?.dispose();
    }
    super.dispose();
  }

  void _notifyParent() {
    widget.onDogsChanged(_dogs);
  }

  Future<void> _selectDogImage() async {
    HapticFeedback.selectionClick();
    // Ici vous intégrerez image_picker
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _dogs[_currentDogIndex]['profileImage'] = File(image.path);
    //   });
    //   _notifyParent();
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
    _notifyParent();
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
      _notifyParent();
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
      _notifyParent();
    }
  }

  bool validateAllDogs() {
    for (var dog in _dogs) {
      if (dog['nameController'].text.isEmpty ||
          dog['breedController'].text.isEmpty ||
          dog['birthDate'] == null) {
        return false;
      }
    }
    return true;
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
      onChanged: (_) => _notifyParent(),
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
    final currentDog = _dogs[_currentDogIndex];

    return Column(
      children: [
        // Titre
        Text(
          _dogs.length > 1 ? 'Vos compagnons' : 'Votre compagnon',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: darkGray,
            fontFamily: 'Jost',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          _dogs.length > 1
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
        const SizedBox(height: 30),

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
          child: Column(
            children: [
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

              // Bouton d'ajout d'un autre chien
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
          ),
        ),
      ],
    );
  }
}