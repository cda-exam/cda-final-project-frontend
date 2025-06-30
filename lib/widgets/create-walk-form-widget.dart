import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../models/walk.dart';
import '../services/geocoding-service.dart';
import 'package:latlong2/latlong.dart';

class CreateWalkFormWidget extends StatefulWidget {
  final Function(Walk, double?, double?)? onWalkCreated;
  final VoidCallback? onCancel;

  const CreateWalkFormWidget({
    Key? key,
    this.onWalkCreated,
    this.onCancel,
  }) : super(key: key);

  @override
  State<CreateWalkFormWidget> createState() => _CreateWalkFormWidgetState();
}

class _CreateWalkFormWidgetState extends State<CreateWalkFormWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs du formulaire
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _participantsMaxController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Valeurs par défaut
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // Variables pour la recherche de lieux
  List<Place> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  Place? _selectedPlace;
  
  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs avec des valeurs par défaut
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _timeController.text = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    _durationController.text = '60'; // 60 minutes par défaut
    _participantsMaxController.text = '5'; // 5 participants max par défaut
    
    // Ajouter un listener pour la recherche de lieux
    _locationController.addListener(_onLocationInputChanged);
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _participantsMaxController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  // Méthode appelée lorsque le texte du champ de lieu change
  void _onLocationInputChanged() {
    // Annuler le timer précédent s'il existe
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Créer un nouveau timer pour éviter trop de requêtes
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _locationController.text;
      if (query.length >= 3) {
        _searchPlaces(query);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }
  
  // Recherche de lieux via l'API
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });
    
    try {
      final results = await GeocodingService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      print('Erreur lors de la recherche de lieux: $e');
    }
  }
  
  // Sélectionner un lieu dans les résultats
  void _selectPlace(Place place) {
    setState(() {
      _selectedPlace = place;
      _locationController.text = place.displayName;
      _searchResults = []; // Effacer les résultats après sélection
    });
  }
  
  // Sélectionner une date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }
  
  // Sélectionner une heure
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  // Soumettre le formulaire
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Combiner date et heure
      final DateTime dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Coordonnées du lieu sélectionné ou valeurs par défaut
      double? latitude;
      double? longitude;
      
      if (_selectedPlace != null) {
        latitude = _selectedPlace!.latitude;
        longitude = _selectedPlace!.longitude;
      }
      
      // Créer l'objet Walk
      final walk = Walk(
        date: dateTime,
        duration: int.parse(_durationController.text),
        participantsMax: int.parse(_participantsMaxController.text),
        description: _descriptionController.text,
        location: _locationController.text,
      );
      
      // Appeler le callback avec les coordonnées
      if (widget.onWalkCreated != null) {
        widget.onWalkCreated!(walk, latitude, longitude);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            const Text(
              'Créer une nouvelle promenade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            
            // Date et heure
            Row(
              children: [
                // Champ date
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Champ heure
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    decoration: InputDecoration(
                      labelText: 'Heure',
                      prefixIcon: const Icon(Icons.access_time, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une heure';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Durée et participants max
            Row(
              children: [
                // Champ durée
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Durée (minutes)',
                      prefixIcon: const Icon(Icons.timer, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une durée';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Durée invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Champ participants max
                Expanded(
                  child: TextFormField(
                    controller: _participantsMaxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Participants max',
                      prefixIcon: const Icon(Icons.pets, color: AppColors.primaryGreen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nombre';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lieu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Lieu',
                    hintText: 'Commencez à taper pour rechercher...',
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryGreen),
                    suffixIcon: _isSearching 
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un lieu';
                    }
                    return null;
                  },
                ),
                
                // Afficher les résultats de recherche
                if (_searchResults.isNotEmpty)
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
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
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
                          onTap: () => _selectPlace(place),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
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
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton annuler
                TextButton(
                  onPressed: widget.onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 24),
                // Bouton créer
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Go !',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
