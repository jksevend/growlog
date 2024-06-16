import 'package:flutter/material.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/common/measurement.dart';
import 'package:weedy/environments/dialog.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/environments/view.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

/// Shows a bottom sheet with the details of the [environment].
Future<void> showEnvironmentDetailSheet(
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
      return StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(environment.name),
                  subtitle: Text(environment.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async => await _onDeleteEnvironment(
                          context,
                          environment,
                          environmentsProvider,
                          plantsProvider,
                          actionsProvider,
                        ),
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () async {
                          final updatedEnvironment = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => EditEnvironmentView(
                                      environment: environment,
                                      environmentsProvider: environmentsProvider)));
                          setState(() {
                            if (updatedEnvironment != null) {
                              environment = updatedEnvironment;
                            }
                          });
                        },
                        icon: const Icon(Icons.edit, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green),
                  title: const Text('Plants in this environment'),
                  subtitle: Text(plants.length.toString()),
                ),
                const Divider(),
                ListTile(
                  isThreeLine: true,
                  leading: const Icon(Icons.light_mode, color: Colors.yellow),
                  title: const Text('Light'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${environment.lightDetails.lightHours}h per day'),
                      Text(
                          '${environment.lightDetails.lights[0].watt}W ${environment.lightDetails.lights[0].type.name}'),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  isThreeLine: true,
                  leading: const Icon(Icons.rectangle_outlined, color: Colors.amber),
                  title: const Text('Dimensions'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${environment.dimension.width.value}${environment.dimension.width.unit.symbol} x '
                          '${environment.dimension.length.value}${environment.dimension.length.unit.symbol} x '
                          '${environment.dimension.height.value}${environment.dimension.height.unit.symbol}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _onDeleteEnvironment(
  BuildContext context,
  Environment environment,
  EnvironmentsProvider environmentsProvider,
  PlantsProvider plantsProvider,
  ActionsProvider actionsProvider,
) async {
  final confirmed = await confirmDeletionOfEnvironmentDialog(
      context, environment, environmentsProvider, plantsProvider, actionsProvider);
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
}
