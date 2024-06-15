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
              leading: const Icon(Icons.info),
              title: Row(
                children: [
                  Text(plant.name),
                  const SizedBox(width: 8.0),
                  Text(plant.lifeCycleState.icon),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.medium.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(plant.description),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
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
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final updatedPlant = await Navigator.of(context).push(MaterialPageRoute(
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
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Information about the plants' environment
            plantEnvironment == null
                ? const Text('No environment')
                : ListTile(
                    leading: const Icon(Icons.lightbulb, color: Colors.yellow),
                    title: const Text('Environment'),
                    subtitle: Text(plantEnvironment.name),
                    trailing: IconButton(
                        icon: const Icon(Icons.arrow_right_alt),
                        onPressed: () async {
                          var navigationBar =
                              bottomNavigationBarKey.currentWidget as BottomNavigationBar;
                          await Future.delayed(const Duration(milliseconds: 500));
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          navigationBar.onTap!(2);
                          await showEnvironmentDetailSheet(context, plantEnvironment, plants,
                              environmentsProvider, plantsProvider, actionsProvider);
                        }),
                  ),
            const Divider(),
          ],
        );
      });
    },
  );
}
