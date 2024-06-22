import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:weedy/actions/dialog.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/widget.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/plants/model.dart';

/// Show a bottom sheet with the details of the [plantAction].
Future<void> showPlantActionDetailSheet(
  BuildContext context,
  PlantAction plantAction,
  Plant plant,
  ActionsProvider actionsProvider,
) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(plantAction.type.name),
              subtitle: Text(plantAction.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async => await _deletePlantAction(
                      context,
                      plantAction,
                      actionsProvider,
                    ),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        );
      });
    },
  );
}

/// Delete the [plantAction].
Future<void> _deletePlantAction(
  BuildContext context,
  PlantAction plantAction,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await confirmDeletionOfPlantActionDialog(context, plantAction, actionsProvider);
  if (confirmed == true) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('common.deleted_args', namedArgs: {'name': plantAction.type.name})),
      ),
    );
  }
}

/// Show a bottom sheet with the details of the [environmentAction].
Future<void> showEnvironmentActionDetailSheet(
  BuildContext context,
  EnvironmentAction environmentAction,
  Environment environment,
  ActionsProvider actionsProvider,
) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) {
      if (environmentAction is EnvironmentMeasurementAction) {
        return EnvironmentMeasurementActionSheetWidget(
          action: environmentAction,
          environment: environment,
          actionsProvider: actionsProvider,
        );
      }

      if (environmentAction is EnvironmentOtherAction) {
        return EnvironmentOtherActionSheetWidget(
          action: environmentAction,
          environment: environment,
          actionsProvider: actionsProvider,
        );
      }

      if (environmentAction is EnvironmentPictureAction) {
        return EnvironmentPictureActionSheetWidget(
          action: environmentAction,
          environment: environment,
          actionsProvider: actionsProvider,
        );
      }

      throw UnimplementedError('Unknown environment action type: ${environmentAction.toJson()}');
    },
  );
}
