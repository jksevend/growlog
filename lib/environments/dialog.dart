import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:growlog/actions/provider.dart';
import 'package:growlog/environments/model.dart';
import 'package:growlog/environments/provider.dart';
import 'package:growlog/plants/provider.dart';

/// Shows a dialog that asks the user to confirm the deletion of an [environment].
Future<bool> confirmDeletionOfEnvironmentDialog(
  BuildContext context,
  Environment environment,
  EnvironmentsProvider environmentsProvider,
  PlantsProvider plantsProvider,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(tr('environments.dialog.delete_title')),
        content: Text(tr('environments.dialog.delete_message')),
        actions: [
          TextButton(
            onPressed: () => _onClose(context, false),
            child: Text(tr('common.cancel')),
          ),
          TextButton(
            onPressed: () async => _onEnvironmentDeleted(
              context,
              environmentsProvider,
              plantsProvider,
              actionsProvider,
              environment,
            ),
            child: Text(tr('common.delete')),
          ),
        ],
      );
    },
  );
  return confirmed!;
}

/// Close the dialog and return a value.
void _onClose<T>(BuildContext context, T value) {
  Navigator.of(context).pop(value);
}

/// Deletes the [environment] and all plants and actions associated with it.
void _onEnvironmentDeleted(
  BuildContext context,
  EnvironmentsProvider environmentsProvider,
  PlantsProvider plantsProvider,
  ActionsProvider actionsProvider,
  Environment environment,
) async {
  await environmentsProvider.removeEnvironment(environment);
  await plantsProvider.removePlantsInEnvironment(environment.id);
  await actionsProvider.removeActionsForEnvironment(environment.id);

  if (!context.mounted) {
    return;
  }
  _onClose(context, true);
}
