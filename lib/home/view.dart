import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:growlog/actions/fertilizer/provider.dart';
import 'package:growlog/actions/model.dart' as growlog;
import 'package:growlog/actions/provider.dart';
import 'package:growlog/environments/model.dart';
import 'package:growlog/environments/provider.dart';
import 'package:growlog/home/widget.dart';
import 'package:growlog/plants/model.dart';
import 'package:growlog/plants/provider.dart';
import 'package:rxdart/streams.dart';

/// Home view that displays the actions performed today.
class HomeView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list(
        [
          plantsProvider.plants,
          environmentsProvider.environments,
          actionsProvider.plantActions,
          actionsProvider.environmentActions,
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
        var plantActions = snapshot.data![2] as List<growlog.PlantAction>;
        var environmentActions = snapshot.data![3] as List<growlog.EnvironmentAction>;

        // Filter actions performed today
        var todayPlantActions =
            plantActions.where((action) => action.createdAt.day == DateTime.now().day).toList();
        var todayEnvironmentActions = environmentActions
            .where((action) => action.createdAt.day == DateTime.now().day)
            .toList();
        var todayPlantActionsPerformed = todayPlantActions.length;
        var todayEnvironmentActionsPerformed = todayEnvironmentActions.length;

        List<growlog.Action> allActions = [...plantActions, ...environmentActions];
        allActions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final Map<DateTime, List<growlog.Action>> fourLatestActionsByDate = allActions
            .fold<Map<DateTime, List<growlog.Action>>>({},
                (Map<DateTime, List<growlog.Action>> map, growlog.Action action) {
          final dateKey =
              DateTime(action.createdAt.year, action.createdAt.month, action.createdAt.day);
          if (!map.containsKey(dateKey)) {
            map[dateKey] = [];
          }
          map[dateKey]!.add(action);
          return map;
        });
        final Map<DateTime, List<Widget>> actionIndicatorsGrouped = fourLatestActionsByDate.map(
          (date, actions) {
            return MapEntry(
              date,
              actions.map(
                (action) {
                  if (action is growlog.PlantAction) {
                    return Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    );
                  } else {
                    return Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.yellow[900],
                        shape: BoxShape.circle,
                      ),
                    );
                  }
                },
              ).toList(),
            );
          },
        );

        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              Card(
                child: WeekAndMonthView(
                  actionIndicators: actionIndicatorsGrouped,
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text('⚡️', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              tr('home.actions_today'),
                              style: const TextStyle(fontSize: 18),
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
                              title: Text(tr('home.plant_actions')),
                              subtitle: Text(
                                tr('common.actions_performed_today_args',
                                    namedArgs: {'count': todayPlantActionsPerformed.toString()}),
                              ),
                              leading: const Icon(
                                Icons.eco,
                                color: Colors.green,
                              ),
                              children: [
                                if (todayPlantActions.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(tr('home.plant_actions_none_today')),
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
                                              actionsProvider: actionsProvider,
                                              fertilizerProvider: fertilizerProvider,
                                              plantsProvider: plantsProvider,
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
                              title: Text(tr('home.environment_actions')),
                              subtitle: Text(
                                tr(
                                  'common.actions_performed_today_args',
                                  namedArgs: {'count': todayEnvironmentActionsPerformed.toString()},
                                ),
                              ),
                              leading: Icon(
                                Icons.lightbulb,
                                color: Colors.yellow[900],
                              ),
                              children: [
                                if (todayEnvironmentActions.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(tr('home.environment_actions_none_today')),
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
                                              actionsProvider: actionsProvider,
                                              environmentsProvider: environmentsProvider,
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
