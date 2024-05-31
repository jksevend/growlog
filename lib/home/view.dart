import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/home/widget.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

class HomeView extends StatefulWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;

  const HomeView({
    super.key,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.environmentsProvider,
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
          var plants = snapshot.data![0] as Map<String, Plant>;
          var environments = snapshot.data![1] as Map<String, Environment>;
          var plantActions = snapshot.data![2] as List<PlantAction>;
          var environmentActions = snapshot.data![3] as List<EnvironmentAction>;

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
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Actions today', style: TextStyle(fontSize: 18),),
                        ),
                      ),
                      Divider(),
                      Card(
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text('Plant actions'),
                                subtitle: Text('Performed today: $todayPlantActionsPerformed'),
                                leading: Icon(
                                  Icons.eco,
                                  color: Colors.green,
                                ),
                                children: [
                                  if (todayPlantActions.isEmpty)
                                    Center(
                                      child: Text('No plant actions performed today.'),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: todayPlantActions
                                            .map((action) => PlantActionLogHomeWidget(
                                                plant: plants[action.plantId]!, action: action))
                                            .toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Divider(),
                      ),
                      Card(
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text('Environment actions'),
                                subtitle:
                                    Text('Performed today: $todayEnvironmentActionsPerformed'),
                                leading: Icon(
                                  Icons.lightbulb,
                                  color: Colors.yellow[900],
                                ),
                                children: [
                                  if (todayEnvironmentActions.isEmpty)
                                    Center(
                                      child: Text('No environment actions performed today.'),
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
        });
  }
}
