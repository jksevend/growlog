import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';

Future<bool> confirmDeletionOfPlantActionDialog(
  BuildContext context,
  PlantAction plantAction,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete ${plantAction.type.name}?'),
        content: const Text('Are you sure you want to delete this action?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await actionsProvider.deletePlantAction(plantAction);
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

Future<bool> confirmDeletionOfEnvironmentActionDialog(
  BuildContext context,
  EnvironmentAction environmentAction,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete ${environmentAction.type.name}?'),
        content: const Text('Are you sure you want to delete this action?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await actionsProvider.deleteEnvironmentAction(environmentAction);
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
