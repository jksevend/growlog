import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/home/widget.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

/// Home view that displays the actions performed today.
class HomeView extends StatefulWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;

  const HomeView({
    super.key,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.fertilizerProvider,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: CombineLatestStream.list(
          [
            widget.plantsProvider.plants,
            widget.environmentsProvider.environments,
            widget.actionsProvider.plantActions,
            widget.actionsProvider.environmentActions,
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extract data
          var plants = snapshot.data![0] as Map<String, Plant>;
          var environments = snapshot.data![1] as Map<String, Environment>;
          var plantActions = snapshot.data![2] as List<PlantAction>;
          var environmentActions = snapshot.data![3] as List<EnvironmentAction>;

          // Filter actions performed today
          var todayPlantActions =
              plantActions.where((action) => action.createdAt.day == DateTime.now().day).toList();
          var todayEnvironmentActions = environmentActions
              .where((action) => action.createdAt.day == DateTime.now().day)
              .toList();
          var todayPlantActionsPerformed = todayPlantActions.length;
          var todayEnvironmentActionsPerformed = todayEnvironmentActions.length;

          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  child: WeekAndMonthView(
                    actionsProvider: widget.actionsProvider,
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text('⚡️', style: TextStyle(fontSize: 22)),
                              SizedBox(width: 8),
                              Text(
                                'Actions today',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Card(
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: const Text('Plant actions'),
                                subtitle: Text('Performed today: $todayPlantActionsPerformed'),
                                leading: const Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                ),
                                children: [
                                  if (todayPlantActions.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text('No plant actions performed today.'),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: todayPlantActions
                                            .map(
                                              (action) => PlantActionLogHomeWidget(
                                                plant: plants[action.plantId]!,
                                                action: action,
                                                actionsProvider: widget.actionsProvider,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Divider(),
                      ),
                      Card(
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: const Text('Environment actions'),
                                subtitle:
                                    Text('Performed today: $todayEnvironmentActionsPerformed'),
                                leading: Icon(
                                  Icons.lightbulb,
                                  color: Colors.yellow[900],
                                ),
                                children: [
                                  if (todayEnvironmentActions.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text('No environment actions performed today.'),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: todayEnvironmentActions
                                            .map(
                                              (action) => EnvironmentActionLogHomeWidget(
                                                environment: environments[action.environmentId]!,
                                                action: action,
                                                actionsProvider: widget.actionsProvider,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      },
    );
  }
}
