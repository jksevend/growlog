import 'package:flutter/material.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/environments/sheet.dart';
import 'package:weedy/plants/dialog.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';
import 'package:weedy/plants/view.dart';

Future<void> showPlantDetailSheet(
  BuildContext context,
  Plant plant,
  List<Plant> plants,
  Environment? plantEnvironment,
  PlantsProvider plantsProvider,
  ActionsProvider actionsProvider,
  EnvironmentsProvider environmentsProvider,
  GlobalKey<State<BottomNavigationBar>> bottomNavigationBarKey,
) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            ListTile(
              leading: Icon(Icons.info),
              title: Text(plant.name),
              subtitle: Text(plant.description),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.eco, color: Colors.green),
              title: Text('Plant actions'),
              subtitle: Text('Performed today: 0'),
            ),
            Divider(),
            // Information about the plants' environment
            plantEnvironment == null
                ? Text('No environment')
                : ListTile(
                    leading: Icon(Icons.lightbulb, color: Colors.yellow),
                    title: Text('Environment'),
                    subtitle: Text(plantEnvironment.name),
                    trailing: IconButton(
                        icon: Icon(Icons.arrow_right_alt),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          var navigationBar =
                              bottomNavigationBarKey.currentWidget as BottomNavigationBar;
                          navigationBar.onTap!(2);
                          showEnvironmentDetailSheet(context, plantEnvironment, plants,
                              environmentsProvider, plantsProvider, actionsProvider);
                        }),
                  ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  TextButton(
                    onPressed: () async {
                      final updatedPlant = await Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => EditPlantView(
                                  plant: plant,
                                  plantsProvider: plantsProvider,
                                  environmentsProvider: environmentsProvider)));
                      setState(() {
                        if (updatedPlant != null) {
                          plant = updatedPlant;
                        }
                      });
                    },
                    child: Text('Edit plant '),
                  ),
                ],
              ),
            ),
            Spacer(),
            Text('Danger zone', style: TextStyle(color: Colors.red, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Divider(),
                  Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await confirmDeletionOfPlantDialog(
                              context, plant, plantsProvider, actionsProvider);
                          if (confirmed == true) {
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${plant.name} has been deleted'),
                              ),
                            );
                          }
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        );
      });
    },
  );
}
