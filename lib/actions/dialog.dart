import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';

/// Cancel the dialog.
void _close<T>(BuildContext context, final T value) {
  Navigator.of(context).pop(value);
}

/// Open a dialog to confirm the deletion of a [plantAction].
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
            onPressed: () => _close(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async => await _deletePlantAction(context, plantAction, actionsProvider),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed!;
}

/// Delete the [plantAction].
Future<void> _deletePlantAction(
  BuildContext context,
  PlantAction plantAction,
  ActionsProvider actionsProvider,
) async {
  await actionsProvider.deletePlantAction(plantAction);
  if (!context.mounted) {
    return;
  }
  _close(context, true);
}

/// Open a dialog to confirm the deletion of an [environmentAction].
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
            onPressed: () => _close(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async =>
                await _deleteEnvironmentAction(context, environmentAction, actionsProvider),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return confirmed!;
}

/// Delete the [environmentAction].
Future<void> _deleteEnvironmentAction(
  BuildContext context,
  EnvironmentAction environmentAction,
  ActionsProvider actionsProvider,
) async {
  await actionsProvider.deleteEnvironmentAction(environmentAction);
  if (!context.mounted) {
    return;
  }
  _close(context, true);
}
