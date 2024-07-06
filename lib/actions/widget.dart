import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:growlog/actions/dialog.dart';
import 'package:growlog/actions/fertilizer/model.dart';
import 'package:growlog/actions/fertilizer/provider.dart';
import 'package:growlog/actions/model.dart';
import 'package:growlog/actions/provider.dart';
import 'package:growlog/actions/sheet.dart';
import 'package:growlog/common/measurement.dart';
import 'package:growlog/common/temperature.dart';
import 'package:growlog/environments/model.dart';
import 'package:growlog/environments/provider.dart';
import 'package:growlog/plants/model.dart';
import 'package:growlog/plants/provider.dart';

/// A list item to display a [PlantAction].
class PlantActionLogItem extends StatelessWidget {
  final FertilizerProvider fertilizerProvider;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final Plant plant;
  final PlantAction action;
  final bool isFirst;
  final bool isLast;

  const PlantActionLogItem({
    super.key,
    required this.fertilizerProvider,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.plant,
    required this.action,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListTile(
          leading: Text(action.type.icon, style: const TextStyle(fontSize: 18)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action.type.name),
              Text(
                action.formattedDate,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.description,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              _actionInformationWidget(),
            ],
          ),
          onTap: () async {
            await showPlantActionDetailSheet(
                context, action, plant, actionsProvider, fertilizerProvider, plantsProvider);
          },
        ),
      ),
    );
  }

  Widget _actionInformationWidget() {
    if (action is PlantWateringAction) {
      final wateringAction = action as PlantWateringAction;
      return Text(
        '${tr('common.water_amount')}\n${wateringAction.amount.amount} ${wateringAction.amount.unit.name}',
      );
    }

    if (action is PlantFertilizingAction) {
      final fertilizingAction = action as PlantFertilizingAction;
      return StreamBuilder<Map<String, Fertilizer>>(
        stream: fertilizerProvider.fertilizers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final fertilizer = snapshot.data![fertilizingAction.fertilization.fertilizerId]!;
          return Text(
            '${fertilizer.name} - ${fertilizingAction.fertilization.amount.amount} ${fertilizingAction.fertilization.amount.unit.name}',
          );
        },
      );
    }

    if (action is PlantPruningAction) {
      final pruningAction = action as PlantPruningAction;
      return Text('${tr('common.pruning')}\n${pruningAction.pruningType.name}');
    }

    if (action is PlantTrainingAction) {
      final trainingAction = action as PlantTrainingAction;
      return Text('${tr('common.training')}\n${trainingAction.trainingType.name}');
    }

    if (action is PlantReplantingAction) {
      return Container();
    }

    if (action is PlantHarvestingAction) {
      final harvestingAction = action as PlantHarvestingAction;
      return Text(
          '${tr('common.harvesting')}\n${harvestingAction.amount.amount} ${harvestingAction.amount.unit.name}');
    }

    if (action is PlantDeathAction) {
      return Text(tr('common.death'));
    }

    if (action is PlantOtherAction) {
      return Container();
    }

    if (action is PlantPictureAction) {
      final pictureAction = action as PlantPictureAction;
      return Row(
        children: pictureAction.images
            .map(
              (image) => CircleAvatar(
                backgroundImage: FileImage(File(image)),
              ),
            )
            .toList(),
      );
    }

    if (action is PlantMeasurementAction) {
      final measurementAction = action as PlantMeasurementAction;
      if (measurementAction.measurement.type == PlantMeasurementType.height) {
        final amount = MeasurementAmount.fromJson(measurementAction.measurement.measurement);
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('${tr('common.height')}\n${amount.value} ${amount.measurementUnit.symbol}'),
          ],
        );
      }

      if (measurementAction.measurement.type == PlantMeasurementType.pH) {
        final ph = measurementAction.measurement.measurement['ph'] as double;
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('pH\n$ph'),
          ],
        );
      }

      if (measurementAction.measurement.type == PlantMeasurementType.ec) {
        final ec = measurementAction.measurement.measurement['ec'] as double;
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('EC\n$ec'),
          ],
        );
      }

      if (measurementAction.measurement.type == PlantMeasurementType.ppm) {
        final ppm = measurementAction.measurement.measurement['ppm'] as double;
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('PPM\n$ppm'),
          ],
        );
      }
    }

    return Container();
  }
}

/// A list item to display an [EnvironmentAction].
class EnvironmentActionLogItem extends StatelessWidget {
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final Environment environment;
  final EnvironmentAction action;
  final bool isFirst;
  final bool isLast;

  const EnvironmentActionLogItem({
    super.key,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.environment,
    required this.action,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListTile(
          isThreeLine: true,
          leading: Text(action.type.icon, style: const TextStyle(fontSize: 18)),
          title: Text(action.type.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.description,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              _actionInformationWidget(),
            ],
          ),
          onTap: () async {
            await showEnvironmentActionDetailSheet(
              context,
              action,
              environment,
              actionsProvider,
              environmentsProvider,
            );
          },
        ),
      ),
    );
  }

  Widget _actionInformationWidget() {
    if (action is EnvironmentMeasurementAction) {
      final measurementAction = action as EnvironmentMeasurementAction;
      if (measurementAction.measurement.type == EnvironmentMeasurementType.temperature) {
        final temperature = Temperature.fromJson(measurementAction.measurement.measurement);
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text(
                '${tr('common.temperature')}\n${temperature.value} ${temperature.temperatureUnit.symbol}'),
          ],
        );
      }

      if (measurementAction.measurement.type == EnvironmentMeasurementType.humidity) {
        final humidity = measurementAction.measurement.measurement['humidity'] as double;
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('${tr('common.humidity')}\n$humidity %'),
          ],
        );
      }

      if (measurementAction.measurement.type == EnvironmentMeasurementType.co2) {
        final co2 = measurementAction.measurement.measurement['co2'] as double;
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('CO2\n$co2 ppm'),
          ],
        );
      }

      if (measurementAction.measurement.type == EnvironmentMeasurementType.lightDistance) {
        final amount = MeasurementAmount.fromJson(measurementAction.measurement.measurement);
        return Row(
          children: [
            Text(measurementAction.measurement.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Text('${tr('common.light_distance')}\n${amount.value}${amount.measurementUnit.symbol}'),
          ],
        );
      }
    }

    if (action is EnvironmentOtherAction) {
      return Container();
    }

    if (action is EnvironmentPictureAction) {
      final pictureAction = action as EnvironmentPictureAction;
      return Row(
        children: pictureAction.images
            .map(
              (image) => CircleAvatar(
                backgroundImage: FileImage(File(image)),
              ),
            )
            .toList(),
      );
    }

    return Container();
  }
}

/// Show a bottom sheet with the details of an [EnvironmentMeasurementAction].
class EnvironmentMeasurementActionSheetWidget extends StatelessWidget {
  final Environment environment;
  final EnvironmentMeasurementAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentMeasurementActionSheetWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      environment: environment,
      action: action,
      actionsProvider: actionsProvider,
      child: _measurementWidget(),
    );
  }

  /// Return a widget based on the [EnvironmentMeasurementType] of the action.
  Widget _measurementWidget() {
    if (action.measurement.type == EnvironmentMeasurementType.temperature) {
      final temperature = Temperature.fromJson(action.measurement.measurement);
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: Text(tr('common.temperature')),
        subtitle: Text('${temperature.value} ${temperature.temperatureUnit.symbol}'),
      );
    }

    if (action.measurement.type == EnvironmentMeasurementType.humidity) {
      final humidity = action.measurement.measurement['humidity'] as double;
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: Text(tr('common.humidity')),
        subtitle: Text('$humidity %'),
      );
    }

    if (action.measurement.type == EnvironmentMeasurementType.co2) {
      final co2 = action.measurement.measurement['co2'] as double;
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: const Text('CO2'),
        subtitle: Text('$co2 ppm'),
      );
    }

    if (action.measurement.type == EnvironmentMeasurementType.lightDistance) {
      final amount = MeasurementAmount.fromJson(action.measurement.measurement);
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: Text(tr('common.light_distance')),
        subtitle: Text('${amount.value}${amount.measurementUnit.symbol}'),
      );
    }

    return Container();
  }
}

/// Show a bottom sheet with the details of an [EnvironmentOtherAction].
class EnvironmentOtherActionSheetWidget extends StatelessWidget {
  final Environment environment;
  final EnvironmentOtherAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentOtherActionSheetWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      environment: environment,
      action: action,
      actionsProvider: actionsProvider,
      child: Container(),
    );
  }
}

/// Show a bottom sheet with the details of an [EnvironmentPictureAction].
class EnvironmentPictureActionSheetWidget extends StatelessWidget {
  final Environment environment;
  final EnvironmentPictureAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentPictureActionSheetWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      environment: environment,
      action: action,
      actionsProvider: actionsProvider,
      child: SizedBox(
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemCount: action.images.length,
          itemBuilder: (context, index) {
            final picture = action.images[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: InteractiveViewer(
                        panEnabled: false,
                        // Set it to false
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 1,
                        maxScale: 2,
                        child: Image.file(
                          alignment: Alignment.center,
                          File(picture),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Image.file(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                File(picture),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Base widget for an [EnvironmentAction] bottom sheet.
class _BaseEnvironmentActionSheetWidget extends StatelessWidget {
  final Environment environment;
  final EnvironmentAction action;
  final ActionsProvider actionsProvider;
  final Widget child;

  const _BaseEnvironmentActionSheetWidget({
    required this.child,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Text(action.type.icon, style: const TextStyle(fontSize: 18)),
          title: Text(action.type.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                environment.name,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              Text(action.formattedDate),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async => await _deleteEnvironmentAction(
                  context,
                  action,
                  actionsProvider,
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
        const Divider(),
        Text(action.description == '' ? tr('common.no_description') : action.description),
        const Divider(),
        child,
      ],
    );
  }
}

/// Delete the [environmentAction].
Future<void> _deleteEnvironmentAction(
  BuildContext context,
  EnvironmentAction environmentAction,
  ActionsProvider actionsProvider,
) async {
  final confirmed =
      await confirmDeletionOfEnvironmentActionDialog(context, environmentAction, actionsProvider);
  if (confirmed == true) {
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('common.deleted_args', namedArgs: {'name': environmentAction.type.name})),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantAction].
class _BasePlantActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantAction action;
  final ActionsProvider actionsProvider;
  final Widget child;

  const _BasePlantActionSheetWidget({
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Text(action.type.icon, style: const TextStyle(fontSize: 18)),
          title: Text(action.type.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.name,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              Text(action.formattedDate),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async => await _deletePlantAction(
                  context,
                  action,
                  actionsProvider,
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
        const Divider(),
        Text(action.description == '' ? tr('common.no_description') : action.description),
        const Divider(),
        child,
      ],
    );
  }
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

/// Show a bottom sheet with the details of a [PlantWateringAction].
class PlantWateringActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantWateringAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantWateringActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: ListTile(
        title: Text(tr('common.water_amount')),
        subtitle: Text('${action.amount.amount} ${action.amount.unit.name}'),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantFertilizingAction].
class PlantFertilizingActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantFertilizingAction action;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final PlantsProvider plantsProvider;

  const PlantFertilizingActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.plantsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: StreamBuilder<Map<String, Fertilizer>>(
        stream: fertilizerProvider.fertilizers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fertilizer = snapshot.data![action.fertilization.fertilizerId]!;
          return ListTile(
            isThreeLine: true,
            title: Text(tr('common.fertilizer')),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fertilizer.name),
                const SizedBox(height: 5),
                Text(
                    '${action.fertilization.amount.amount} ${action.fertilization.amount.unit.name}'),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(fertilizer.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('common.description')),
                          Text(fertilizer.description),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(tr('common.close')),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.info_outline),
            ),
          );
        },
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantPruningAction].
class PlantPruningActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantPruningAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantPruningActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: ListTile(
        title: Text(tr('common.pruning')),
        subtitle: Text(action.pruningType.name),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantTrainingAction].
class PlantTrainingActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantTrainingAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantTrainingActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: ListTile(
        title: Text(tr('common.training')),
        subtitle: Text(action.trainingType.name),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantReplantingAction].
class PlantReplantingActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantReplantingAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantReplantingActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: Container(),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantHarvestingAction].
class PlantHarvestingActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantHarvestingAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantHarvestingActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: ListTile(
        title: Text(tr('common.harvesting')),
        subtitle: Text('${action.amount.amount} ${action.amount.unit.name}'),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantDeathAction].
class PlantDeathActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantDeathAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantDeathActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: ListTile(
        title: Text(tr('common.death')),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantPictureAction].
class PlantPictureActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantPictureAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantPictureActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: SizedBox(
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemCount: action.images.length,
          itemBuilder: (context, index) {
            final picture = action.images[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: InteractiveViewer(
                        panEnabled: false,
                        // Set it to false
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 1,
                        maxScale: 2,
                        child: Image.file(
                          alignment: Alignment.center,
                          File(picture),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Image.file(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                File(picture),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantOtherAction].
class PlantOtherActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantOtherAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantOtherActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: Container(),
    );
  }
}

/// Show a bottom sheet with the details of a [PlantMeasurementAction].
class PlantMeasurementActionSheetWidget extends StatelessWidget {
  final Plant plant;
  final PlantMeasurementAction action;
  final ActionsProvider actionsProvider;
  final PlantsProvider plantsProvider;
  final FertilizerProvider fertilizerProvider;

  const PlantMeasurementActionSheetWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.plantsProvider,
    required this.fertilizerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePlantActionSheetWidget(
      plant: plant,
      action: action,
      actionsProvider: actionsProvider,
      child: _measurementWidget(),
    );
  }

  /// Return a widget based on the [PlantMeasurementType] of the action.
  Widget _measurementWidget() {
    if (action.measurement.type == PlantMeasurementType.height) {
      final amount = MeasurementAmount.fromJson(action.measurement.measurement);
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: Text(tr('common.height')),
        subtitle: Text('${amount.value} ${amount.measurementUnit.symbol}'),
      );
    }

    if (action.measurement.type == PlantMeasurementType.pH) {
      final ph = action.measurement.measurement['ph'] as double;
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: const Text('pH'),
        subtitle: Text('$ph'),
      );
    }

    if (action.measurement.type == PlantMeasurementType.ec) {
      final ec = action.measurement.measurement['ec'] as double;
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: const Text('EC'),
        subtitle: Text('$ec'),
      );
    }

    if (action.measurement.type == PlantMeasurementType.ppm) {
      final ppm = action.measurement.measurement['ppm'] as double;
      return ListTile(
        leading: Text(action.measurement.type.icon, style: const TextStyle(fontSize: 20)),
        title: const Text('PPM'),
        subtitle: Text('$ppm'),
      );
    }

    return Container();
  }
}
