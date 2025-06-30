import 'package:flutter/material.dart';
import '../models/walk.dart';
import 'create-walk-form-widget.dart';

class CreateWalkModal extends StatelessWidget {
  final Function(Walk)? onWalkCreated;

  const CreateWalkModal({
    Key? key,
    this.onWalkCreated,
  }) : super(key: key);

  /// Affiche le modal de création de promenade
  static Future<void> show(BuildContext context, {Function(Walk)? onWalkCreated}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: CreateWalkModal(
            onWalkCreated: onWalkCreated,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: CreateWalkFormWidget(
          onWalkCreated: (walk) {
            Navigator.of(context).pop(); // Fermer le modal
            if (onWalkCreated != null) {
              onWalkCreated!(walk);
            }
          },
          onCancel: () {
            Navigator.of(context).pop(); // Fermer le modal
          },
        ),
      ),
    );
  }
}
