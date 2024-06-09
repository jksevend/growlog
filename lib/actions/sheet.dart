import 'package:flutter/material.dart';
import 'package:weedy/actions/dialog.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/plants/model.dart';

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
              leading: Icon(Icons.info),
              title: Text(plantAction.type.name),
              subtitle: Text(plantAction.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      final confirmed = await confirmDeletionOfPlantActionDialog(
                          context, plantAction, actionsProvider);
                      if (confirmed == true) {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${plantAction.type.name} has been deleted'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.red),
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

Future<void> showEnvironmentActionDetailSheet(
  BuildContext context,
  EnvironmentAction environmentAction,
  Environment environment,
  ActionsProvider actionsProvider,
) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        children: [
          ListTile(
              leading: Icon(Icons.info),
              title: Text(environmentAction.type.name),
              subtitle: Text(environmentAction.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      final confirmed = await confirmDeletionOfEnvironmentActionDialog(
                          context, environmentAction, actionsProvider);
                      if (confirmed == true) {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${environmentAction.type.name} has been deleted'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                ],
              )),
        ],
      );
    },
  );
}
