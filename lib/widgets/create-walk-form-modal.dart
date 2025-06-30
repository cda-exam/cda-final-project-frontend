import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/colors.dart';
import '../models/walk.dart';
import '../services/geocoding-service.dart';

class CreateWalkFormModal extends StatefulWidget {
  final Function(Walk, double?, double?) onWalkCreated;
  final Position? currentPosition;

  const CreateWalkFormModal({
    super.key,
    required this.onWalkCreated,
    required this.currentPosition,
  });

  @override
  State<CreateWalkFormModal> createState() => _CreateWalkFormModalState();
}

class _CreateWalkFormModalState extends State<CreateWalkFormModal> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs du formulaire
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final durationController = TextEditingController();
  final participantsMaxController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  
  // Variables pour la recherche de lieux
  List<Place> searchResults = [];
  bool isSearching = false;
  Place? selectedPlace;
  
  // Valeurs par défaut
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser les valeurs par défaut
    selectedDate = DateTime.now().add(const Duration(days: 1));
    selectedTime = TimeOfDay.now();
    
    // Initialiser les contrôleurs
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    timeController.text = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    durationController.text = '60';
    participantsMaxController.text = '5';
    
    // S'inscrire à WidgetsBinding
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Nettoyer les contrôleurs et les listeners
    dateController.dispose();
    timeController.dispose();
    durationController.dispose();
    participantsMaxController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    
    // Se désinscrire de WidgetsBinding
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pas besoin d'implémenter pour notre cas
  }

  @override
  void didHaveMemoryPressure() {
    // Pas besoin d'implémenter pour notre cas
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Pas besoin d'implémenter pour notre cas
  }

  @override
  void didChangePlatformBrightness() {
    // Pas besoin d'implémenter pour notre cas
  }

  @override
  void didChangeAccessibilityFeatures() {
    // Pas besoin d'implémenter pour notre cas
  }
  
  // Fonction pour rechercher des lieux
  Future<void> searchPlaces(String query) async {
    if (query.length < 3) return;
    
    setState(() {
      isSearching = true;
    });
    
    try {
      final results = await GeocodingService.searchPlaces(query);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      print('Erreur lors de la recherche de lieux: $e');
    }
  }
  
  // Fonction pour sélectionner un lieu
  void selectPlace(Place place) {
    setState(() {
      selectedPlace = place;
      locationController.text = place.displayName;
      searchResults = [];  // Vide déjà les résultats
    });
  }
  
  // Fonction pour sélectionner une date
  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  // Fonction pour sélectionner une heure
  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  // Fonction pour soumettre le formulaire
  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // Combiner date et heure
      final DateTime dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      
      // Créer l'objet Walk
      final walk = Walk(
        date: dateTime,
        duration: int.parse(durationController.text),
        participantsMax: int.parse(participantsMaxController.text),
        description: descriptionController.text,
        location: locationController.text,
      );
      
      // Coordonnées du lieu sélectionné ou valeurs par défaut
      double? latitude;
      double? longitude;
      
      if (selectedPlace != null) {
        latitude = selectedPlace!.latitude;
        longitude = selectedPlace!.longitude;
      }
      
      // Fermer le modal
      Navigator.pop(context);
      
      // Appeler la fonction de création de promenade
      widget.onWalkCreated(walk, latitude, longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thème personnalisé pour les inputs
    final inputTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentBrown,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryGreen),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusColor: AppColors.primaryGreen,
      ),
    );
    
    // Utiliser un padding pour s'adapter au clavier
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Theme(
        data: inputTheme,
        child: FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
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
                
                // Formulaire
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Contenu défilant du formulaire
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Date
                                  TextFormField(
                                    controller: dateController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onTap: selectDate,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez sélectionner une date';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Heure
                                  TextFormField(
                                    controller: timeController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Heure',
                                      prefixIcon: const Icon(Icons.access_time, color: AppColors.primaryGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onTap: selectTime,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez sélectionner une heure';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Durée et participants max
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: durationController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Durée (min)',
                                            prefixIcon: const Icon(Icons.timer, color: AppColors.primaryGreen),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer une durée';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: participantsMaxController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Participants max',
                                            prefixIcon: const Icon(Icons.group, color: AppColors.primaryGreen),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer un nombre';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Description
                                  TextFormField(
                                    controller: descriptionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Description',
                                      prefixIcon: const Icon(Icons.description, color: AppColors.primaryGreen),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer une description';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Lieu avec recherche
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: locationController,
                                        decoration: InputDecoration(
                                          labelText: 'Lieu',
                                          hintText: 'Commencez à taper pour rechercher...',
                                          prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryGreen),
                                          suffixIcon: isSearching 
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ) 
                                            : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          // Si un lieu a été sélectionné et que le texte est modifié,
                                          // réinitialiser le lieu sélectionné
                                          if (selectedPlace != null && value != selectedPlace!.displayName) {
                                            setState(() {
                                              selectedPlace = null;
                                            });
                                          }
                                          
                                          // Utiliser un délai pour éviter trop de requêtes
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            if (value == locationController.text && value.length >= 3) {
                                              searchPlaces(value);
                                            }
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer un lieu';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      // Afficher les résultats de recherche
                                      if (searchResults.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: searchResults.length,
                                            itemBuilder: (context, index) {
                                              final place = searchResults[index];
                                              return ListTile(
                                                dense: true,
                                                title: Text(
                                                  place.displayName,
                                                  style: const TextStyle(fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  '${place.city ?? ''} ${place.postcode ?? ''}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                onTap: () => selectPlace(place),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Boutons toujours visibles en bas
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, -2),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: AppColors.primaryGreen),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(color: AppColors.primaryGreen),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Créer',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
