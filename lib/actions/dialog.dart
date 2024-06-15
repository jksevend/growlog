import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';

/// Opens a dialog to confirm the deletion of a [plantAction].
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
            onPressed: () => _onClose(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async => _deletePlantAction(context, actionsProvider, plantAction),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed!;
}

/// Closes the dialog.
void _onClose(BuildContext context) {
  Navigator.of(context).pop(false);
}

/// Deletes a [plantAction].
Future<void> _deletePlantAction(
  BuildContext context,
  ActionsProvider actionsProvider,
  PlantAction plantAction,
) async {
  await actionsProvider.deletePlantAction(plantAction);
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pop(true);
}

/// Opens a dialog to confirm the deletion of an [environmentAction].
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
            onPressed: () => _onClose(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async =>
                _deleteEnvironmentAction(context, actionsProvider, environmentAction),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed!;
}

/// Deletes an [environmentAction].
Future<void> _deleteEnvironmentAction(
  BuildContext context,
  ActionsProvider actionsProvider,
  EnvironmentAction environmentAction,
) async {
  await actionsProvider.deleteEnvironmentAction(environmentAction);
  if (!context.mounted) {
    return;
  }
  Navigator.of(context).pop(true);
}
