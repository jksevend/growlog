import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';

/// Show a dialog to add or edit a fertilizer.
Future<void> showFertilizerForm(
  BuildContext context,
  FertilizerProvider fertilizerProvider,
  Fertilizer? fertilizer,
) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(
    text: fertilizer == null ? '' : fertilizer.name,
  );
  final TextEditingController descriptionController = TextEditingController(
    text: fertilizer == null ? '' : fertilizer.description,
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          fertilizer == null ? 'Add Fertilizer' : 'Edit Fertilizer',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) => _validateName(value),
              ),
              TextField(
                controller: descriptionController,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => _onCancel(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async => await _onSave(
              context,
              formKey,
              nameController,
              descriptionController,
              fertilizer,
              fertilizerProvider,
            ),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

/// Show a dialog to confirm the deletion of a fertilizer.
void _onCancel(BuildContext context) {
  Navigator.of(context).pop();
}

/// Save the fertilizer to the database.
Future<void> _onSave(
  BuildContext context,
  GlobalKey<FormState> formKey,
  TextEditingController nameController,
  TextEditingController descriptionController,
  Fertilizer? fertilizer,
  FertilizerProvider fertilizerProvider,
) async {
  if (formKey.currentState!.validate()) {
    if (fertilizer != null) {
      final updatedFertilizer = fertilizer.copyWith(
        id: fertilizer.id,
        name: nameController.text,
        description: descriptionController.text,
      );
      await fertilizerProvider.updateFertilizer(updatedFertilizer);
      if (!context.mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final newFertilizer = Fertilizer(
      id: const Uuid().v4().toString(),
      name: nameController.text,
      description: descriptionController.text,
    );
    await fertilizerProvider.addFertilizer(newFertilizer);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

/// Validate the name of the fertilizer.
String? _validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a name';
  }
  return null;
}
