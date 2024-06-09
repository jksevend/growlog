import 'package:flutter/material.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/dialog.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/environments/view.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

Future <void> showEnvironmentDetailSheet(
  BuildContext context,
  Environment environment,
  List<Plant> plants,
  EnvironmentsProvider environmentsProvider,
  PlantsProvider plantsProvider,
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
              title: Text(environment.name),
              subtitle: Text(environment.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      final confirmed = await confirmDeletionOfEnvironmentDialog(context,
                          environment, environmentsProvider, plantsProvider, actionsProvider);
                      if (confirmed == true) {
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${environment.name} has been deleted'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () async {
                      final updatedEnvironment = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditEnvironmentView(
                              environment: environment,
                              environmentsProvider: environmentsProvider)));
                      setState(() {
                        if (updatedEnvironment != null) {
                          environment = updatedEnvironment;
                        }
                      });
                    },
                    icon: Icon(Icons.edit, color: Colors.amber),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.eco, color: Colors.green),
              title: Text('Plants in this environment'),
              subtitle: Text(plants.length.toString()),
            ),
          ],
        );
      });
    },
  );
}