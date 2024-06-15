import 'package:flutter/material.dart';
import 'package:weedy/actions/fertilizer/dialog.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';

/// Opens a bottom sheet to show the details of [fertilizers]
Future<void> showFertilizersDetailSheet(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  final Map<String, Fertilizer> fertilizers,
) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fertilizers', style: TextStyle(fontSize: 20)),
              const Divider(),
              ...fertilizers.entries.map(
                (fertilizer) {
                  return ListTile(
                    title: Text(fertilizer.value.name),
                    subtitle: Text(fertilizer.value.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async =>
                              await _editFertilizer(context, fertilizerProvider, fertilizer.value),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async => await _deleteFertilizer(
                              context, fertilizerProvider, fertilizer.value),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Edits a [fertilizer]
Future<void> _editFertilizer(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  Fertilizer fertilizer,
) async {
  await showFertilizerForm(
    context,
    fertilizerProvider,
    fertilizer,
  );
  if (!context.mounted) return;
  Navigator.pop(context);
}

/// Deletes a [fertilizer]
Future<void> _deleteFertilizer(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  Fertilizer fertilizer,
) async {
  await fertilizerProvider.deleteFertilizer(fertilizer.id);
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
