import 'package:flutter/material.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/provider.dart';

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
        title: Text('Delete environment'),
        content: Text('Are you sure you want to delete ${environment.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await environmentsProvider.removeEnvironment(environment);
              await plantsProvider.removePlantsInEnvironment(environment.id);
              await actionsProvider.removeActionsForEnvironment(environment.id);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed!;
}