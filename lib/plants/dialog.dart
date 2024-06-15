import 'package:flutter/material.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

Future<bool> confirmDeletionOfPlantDialog(
  BuildContext context,
  Plant plant,
  PlantsProvider plantsProvider,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await plantsProvider.removePlant(plant);
              await actionsProvider.removeActionsForPlant(plant.id);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed!;
}
