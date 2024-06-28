import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/streams.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/fertilizer/dialog.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
import 'package:weedy/actions/fertilizer/sheet.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/widget.dart';
import 'package:weedy/common/measurement.dart';
import 'package:weedy/common/temperature.dart';
import 'package:weedy/common/validators.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';
import 'package:weedy/plants/transition/model.dart';
import 'package:weedy/plants/transition/provider.dart';

/// An over view of all environment actions.
class EnvironmentActionOverview extends StatelessWidget {
  final Environment environment;
  final ActionsProvider actionsProvider;

  const EnvironmentActionOverview({
    super.key,
    required this.environment,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(environment.name),
        centerTitle: true,
      ),
      body: StreamBuilder<List<EnvironmentAction>>(
        stream: actionsProvider.environmentActions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final environmentActions = snapshot.data!;
          if (environmentActions.isEmpty) {
            return Center(
              child: Text(tr('actions.environments.none')),
            );
          }

          final specificEnvironmentActions =
              environmentActions.where((action) => action.environmentId == environment.id).toList();

          if (specificEnvironmentActions.isEmpty) {
            return Center(
              child: Text(tr('actions.environments.none_for_this')),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                child: VerticalDivider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: specificEnvironmentActions.length,
                itemBuilder: (context, index) {
                  final action = specificEnvironmentActions.elementAt(index);
                  final actionLogItem = EnvironmentActionLogItem(
                    actionsProvider: actionsProvider,
                    environment: environment,
                    action: action,
                    isFirst: index == 0,
                    isLast: index == specificEnvironmentActions.length - 1,
                  );

                  return actionLogItem;
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// An over view of all plant actions.
class PlantActionOverview extends StatefulWidget {
  final Plant plant;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final PlantLifecycleTransitionProvider plantLifecycleTransitionProvider;

  const PlantActionOverview({
    super.key,
    required this.plant,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.plantLifecycleTransitionProvider,
  });

  @override
  State<PlantActionOverview> createState() => _PlantActionOverviewState();
}

class _PlantActionOverviewState extends State<PlantActionOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: widget.plant.id,
              child: Text(widget.plant.lifeCycleState.icon),
            ),
            const SizedBox(width: 10),
            Text(widget.plant.name),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream.list([
          widget.actionsProvider.plantActions,
          widget.plantLifecycleTransitionProvider.transitions,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Prepare data
          final plantActions = snapshot.data![0] as List<PlantAction>;
          final specificPlantActions =
              plantActions.where((action) => action.plantId == widget.plant.id).toList();
          final specificPlantLifecycleTransitions =
              (snapshot.data![1] as List<PlantLifecycleTransition>)
                  .where((transition) => transition.plantId == widget.plant.id);
          final combinedActions = [...specificPlantActions, ...specificPlantLifecycleTransitions];

          // Latest actions appear first
          combinedActions.sort((a, b) {
            var aDate = a is PlantAction ? a.createdAt : (a as PlantLifecycleTransition).timestamp;
            var bDate = b is PlantAction ? b.createdAt : (b as PlantLifecycleTransition).timestamp;
            return bDate.compareTo(aDate);
          });

          // Group actions by date
          final groupedByDate =
              combinedActions.fold<Map<DateTime, List<dynamic>>>({}, (map, action) {
            final date = action is PlantAction
                ? action.createdAt
                : (action as PlantLifecycleTransition).timestamp;
            final dateKey = DateTime(date.year, date.month, date.day);
            map[dateKey] = map[dateKey] ?? [];
            map[dateKey]!.add(action);
            return map;
          });

          // Per latest action the actions are sorted by date descending
          groupedByDate.forEach((date, actions) {
            actions.sort((a, b) {
              var aTime =
                  a is PlantAction ? a.createdAt : (a as PlantLifecycleTransition).timestamp;
              var bTime =
                  b is PlantAction ? b.createdAt : (b as PlantLifecycleTransition).timestamp;
              return bTime.compareTo(aTime);
            });
          });
          return Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                child: VerticalDivider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
              ),
              ListView(
                children: groupedByDate.entries.map((entry) {
                  var date = entry.key;
                  var actions = entry.value;
                  final formattedDate = DateFormat.yMMMd().format(date);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: actions.length,
                        itemBuilder: (context, index) {
                          final action = actions[index];
                          if (action is PlantAction) {
                            return PlantActionLogItem(
                              actionsProvider: widget.actionsProvider,
                              fertilizerProvider: widget.fertilizerProvider,
                              plant: widget.plant,
                              action: action,
                              isFirst: index == 0,
                              isLast: index == actions.length - 1,
                            );
                          } else {
                            final transition = action as PlantLifecycleTransition;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: transition.from.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(transition.from.icon,
                                          style: const TextStyle(fontSize: 20)),
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          _lifecycleMessage(widget.plant.name, transition.from),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(tr('common.lifecycle')),
                                                content: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text('${tr('common.next_lifecycle')}: '),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          transition.to!.icon,
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          transition.to!.name,
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text(tr('common.ok')),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _lifecycleMessage(String name, LifeCycleState lifeCycleState) {
    switch (lifeCycleState) {
      case LifeCycleState.germination:
        return tr('common.germination_message', namedArgs: {'name': name});
      case LifeCycleState.seedling:
        return tr('common.seedling_message', namedArgs: {'name': name});
      case LifeCycleState.vegetative:
        return tr('common.vegetative_message', namedArgs: {'name': name});
      case LifeCycleState.flowering:
        return tr('common.flowering_message', namedArgs: {'name': name});
      case LifeCycleState.drying:
        return tr('common.lifecycle.drying', namedArgs: {'name': name});
      case LifeCycleState.curing:
        return tr('common.lifecycle.curing', namedArgs: {'name': name});
    }
  }
}

/// A view to chose between creating a [PlantAction] or an [EnvironmentAction].
class ChooseActionView extends StatefulWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;

  const ChooseActionView({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.fertilizerProvider,
  });

  @override
  State<ChooseActionView> createState() => _ChooseActionViewState();
}

class _ChooseActionViewState extends State<ChooseActionView> {
  /// The choices to choose between a plant or an environment action.
  /// Index 0 is for plant actions, and index 1 is for environment actions.
  final List<bool> _choices = [true, false];

  /// Environment actions widget keys

  final GlobalKey<_EnvironmentMeasurementFormState> _environmentMeasurementFormKey = GlobalKey();
  final GlobalKey<EnvironmentTemperatureMeasurementFormState> _environmentTemperatureWidgetKey =
      GlobalKey();
  final GlobalKey<EnvironmentHumidityMeasurementFormState> _environmentHumidityWidgetKey =
      GlobalKey();
  final GlobalKey<EnvironmentLightDistanceMeasurementFormState> _environmentLightDistanceWidgetKey =
      GlobalKey();
  final GlobalKey<EnvironmentCO2MeasurementFormState> _environmentCO2WidgetKey = GlobalKey();
  final GlobalKey<PictureFormState> _environmentPictureFormState = GlobalKey();

  /// Plant actions widget keys

  final GlobalKey<_PlantMeasurementFormState> _plantMeasuringFormKey = GlobalKey();
  final GlobalKey<_PlantWateringFormState> _plantWateringWidgetKey = GlobalKey();
  final GlobalKey<_PlantFertilizingFormState> _plantFertilizingFormKey = GlobalKey();
  final GlobalKey<_PlantPruningFormState> _plantPruningFormKey = GlobalKey();
  final GlobalKey<_PlantHarvestingFormState> _plantHarvestingFormKey = GlobalKey();
  final GlobalKey<_PlantTrainingFormState> _plantTrainingFormKey = GlobalKey();
  final GlobalKey<PictureFormState> _plantPictureFormState = GlobalKey();

  final GlobalKey<PlantHeightMeasurementFormState> _plantHeightMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPHMeasurementFormState> _plantPHMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantECMeasurementFormState> _plantECMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPPMMeasurementFormState> _plantPPMMeasurementWidgetKey = GlobalKey();

  /// Plant form information

  Plant? _currentPlant;
  late PlantActionType _currentPlantActionType = PlantActionType.watering;
  late TextEditingController _plantActionDescriptionTextController = TextEditingController();
  final DateTime _plantActionDate = DateTime.now();

  /// Environment form information

  Environment? _currentEnvironment;
  late EnvironmentActionType _currentEnvironmentActionType = EnvironmentActionType.measurement;
  late TextEditingController _environmentActionDescriptionTextController = TextEditingController();
  final DateTime _environmentActionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _plantActionDescriptionTextController = TextEditingController();
    _environmentActionDescriptionTextController = TextEditingController();
  }

  @override
  void dispose() {
    _plantActionDescriptionTextController.dispose();
    _environmentActionDescriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(tr('actions.choose')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(tr('actions.choose_hint')),
                        const SizedBox(height: 10),
                        ToggleButtons(
                          constraints: const BoxConstraints(minWidth: 100),
                          isSelected: _choices,
                          onPressed: (int index) => _onToggleButtonsPressed(index),
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.eco,
                                  size: 50,
                                  color: Colors.green[900],
                                ),
                                Text(tr('common.plant')),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  size: 50,
                                  color: Colors.yellow[900],
                                ),
                                Text(tr('common.environment')),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              _actionForm(context),
            ],
          ),
        ),
      ),
    );
  }

  /// The callback for the toggle buttons.
  void _onToggleButtonsPressed(int index) {
    setState(() {
      // The button that is tapped is set to true, and the others to false.
      for (int i = 0; i < _choices.length; i++) {
        _choices[i] = i == index;
      }
    });
  }

  /// The form for the plant actions.
  Widget _actionForm(final BuildContext context) {
    if (_choices[0]) {
      // Plant actions
      return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(tr('actions.plants.choose')),
                    StreamBuilder<Map<String, Plant>>(
                        stream: widget.plantsProvider.plants,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }

                          final plants = snapshot.data!;
                          if (plants.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(tr('plants.none')),
                              ),
                            );
                          }
                          return DropdownButton<Plant>(
                            icon: const Icon(Icons.arrow_downward_sharp),
                            isExpanded: true,
                            items: plants.values
                                .map(
                                  (plant) => DropdownMenuItem<Plant>(
                                    value: plant,
                                    child: Text(plant.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (Plant? value) => _updateCurrentPlant(value),
                            hint: Text(tr('plants.mandatory')),
                            value: _currentPlant,
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.calendar_month),
                        Text('${tr('common.select_date')}: '),
                        TextButton(
                          onPressed: () => _selectDate(context, _plantActionDate),
                          child: Text(
                            '${_plantActionDate.toLocal()}'.split(' ')[0],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: _plantActionDescriptionTextController,
                      maxLines: null,
                      minLines: 5,
                      decoration: InputDecoration(
                        labelText: tr('common.description'),
                        hintText: tr('actions.plants.description_hint'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        DropdownButton<PlantActionType>(
                          icon: const Icon(Icons.arrow_downward_sharp),
                          value: _currentPlantActionType,
                          isExpanded: true,
                          items: PlantActionType.values
                              .map(
                                (action) => DropdownMenuItem<PlantActionType>(
                                  value: action,
                                  child: Row(
                                    children: [
                                      Text(action.icon),
                                      const SizedBox(width: 10),
                                      Text(action.name),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (PlantActionType? value) =>
                              _updateCurrentPlantActionType(value),
                        ),
                      ],
                    ),
                    _plantActionForm(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async => await _onPlantActionCreated(),
                label: Text(tr('common.save')),
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      );
    } else {
      // Environment actions
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(tr('actions.environments.choose')),
                  StreamBuilder<Map<String, Environment>>(
                    stream: widget.environmentsProvider.environments,
                    builder: (builder, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final environments = snapshot.data!;
                      if (environments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(tr('environments.none')),
                          ),
                        );
                      }
                      return DropdownButton<Environment>(
                        icon: const Icon(Icons.arrow_downward_sharp),
                        isExpanded: true,
                        items: environments.values
                            .map(
                              (e) => DropdownMenuItem<Environment>(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (Environment? value) => _updateCurrentEnvironment(value),
                        hint: Text(tr('environments.mandatory')),
                        value: _currentEnvironment,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(Icons.calendar_month),
                      Text('${tr('common.select_date')}: '),
                      TextButton(
                        onPressed: () => _selectDate(context, _environmentActionDate),
                        child: Text(
                          '${_environmentActionDate.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  TextFormField(
                    controller: _environmentActionDescriptionTextController,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      labelText: tr('common.description'),
                      hintText: tr('actions.environments.description_hint'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButton<EnvironmentActionType>(
                    icon: const Icon(Icons.arrow_downward_sharp),
                    value: _currentEnvironmentActionType,
                    isExpanded: true,
                    items: EnvironmentActionType.values
                        .map(
                          (action) => DropdownMenuItem<EnvironmentActionType>(
                            value: action,
                            child: Row(
                              children: [
                                Text(
                                  action.icon,
                                ),
                                const SizedBox(width: 10),
                                Text(action.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (EnvironmentActionType? value) =>
                        _updateCurrentEnvironmentActionType(value),
                  ),
                  _environmentActionForm(),
                ],
              ),
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async => await _onEnvironmentActionCreated(),
              label: Text(tr('common.save')),
              icon: const Icon(Icons.save),
            ),
          ),
        ],
      );
    }
  }

  /// Update the current plant.
  void _updateCurrentPlant(Plant? plant) {
    setState(() {
      _currentPlant = plant!;
    });
  }

  /// Update the current plant action type.
  void _updateCurrentPlantActionType(PlantActionType? actionType) {
    setState(() {
      _currentPlantActionType = actionType!;
    });
  }

  void _showImageSelectionMandatorySnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
            Text(
              tr('common.images_mandatory'),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Open up a date picker to select a date.
  Future<void> _selectDate(BuildContext context, DateTime date) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  /// The specific plant action form.
  Widget _plantActionForm() {
    switch (_currentPlantActionType) {
      case PlantActionType.watering:
        return PlantWateringForm(
          key: _plantWateringWidgetKey,
          formKey: GlobalKey<FormState>(),
        );
      case PlantActionType.fertilizing:
        return PlantFertilizingForm(
          key: _plantFertilizingFormKey,
          formKey: GlobalKey<FormState>(),
          fertilizerProvider: widget.fertilizerProvider,
        );
      case PlantActionType.pruning:
        return PlantPruningForm(
          key: _plantPruningFormKey,
        );
      case PlantActionType.replanting:
        return Container();
      case PlantActionType.training:
        return PlantTrainingForm(
          key: _plantTrainingFormKey,
        );
      case PlantActionType.harvesting:
        return PlantHarvestingForm(
          key: _plantHarvestingFormKey,
          formKey: GlobalKey<FormState>(),
        );
      case PlantActionType.measuring:
        return PlantMeasurementForm(
          key: _plantMeasuringFormKey,
          plantMeasurementWidgetKey: _plantHeightMeasurementWidgetKey,
          plantPHMeasurementFormKey: _plantPHMeasurementWidgetKey,
          plantECMeasurementFormKey: _plantECMeasurementWidgetKey,
          plantPPMMeasurementFormKey: _plantPPMMeasurementWidgetKey,
        );
      case PlantActionType.picture:
        return PictureForm(
          key: _plantPictureFormState,
          allowMultiple: true,
          images: const [],
        );
      case PlantActionType.death:
      case PlantActionType.other:
        return Container();
    }
  }

  /// The callback for creating a new [PlantAction].
  Future<void> _onPlantActionCreated() async {
    // If no plant is selected, show a snackbar and return.
    if (_currentPlant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
              Text(
                tr('plants.none'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final currentPlant = _currentPlant!;
    final PlantAction action;

    // CHeck the current plant action type, check the form validity and create the action.
    if (_currentPlantActionType == PlantActionType.watering) {
      final isValid = _plantWateringWidgetKey.currentState!.isValid;
      if (!isValid) {
        return;
      }
      final watering = _plantWateringWidgetKey.currentState!.watering;
      action = PlantWateringAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        amount: watering,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }
    if (_currentPlantActionType == PlantActionType.fertilizing) {
      // In case of fertilizing, check if the form has fertilizers.
      final hasFertilizer = _plantFertilizingFormKey.currentState!.hasFertilizers;
      if (!hasFertilizer) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
                Text(
                  tr('fertilizers.none'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      final isValid = _plantFertilizingFormKey.currentState!.isValid;
      if (!isValid) {
        return;
      }
      final fertilization = _plantFertilizingFormKey.currentState!.fertilization;
      action = PlantFertilizingAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        fertilization: fertilization,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }
    if (_currentPlantActionType == PlantActionType.pruning) {
      final pruning = _plantPruningFormKey.currentState!.pruningType;
      action = PlantPruningAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        pruningType: pruning,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentPlantActionType == PlantActionType.harvesting) {
      final isValid = _plantHarvestingFormKey.currentState!.isValid;
      if (!isValid) {
        return;
      }
      final harvesting = _plantHarvestingFormKey.currentState!.harvest;
      action = PlantHarvestingAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        amount: harvesting,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentPlantActionType == PlantActionType.training) {
      final training = _plantTrainingFormKey.currentState!.trainingType;
      action = PlantTrainingAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        trainingType: training,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    // In case of measuring, check the measurement type and create the action.
    if (_currentPlantActionType == PlantActionType.measuring) {
      final currentPlantMeasurementType = _plantMeasuringFormKey.currentState!.measurementType;
      if (currentPlantMeasurementType == PlantMeasurementType.height) {
        final isValid = _plantHeightMeasurementWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final height = _plantHeightMeasurementWidgetKey.currentState!.height;
        action = PlantMeasurementAction(
          id: const Uuid().v4().toString(),
          description: _plantActionDescriptionTextController.text,
          plantId: currentPlant.id,
          type: _currentPlantActionType,
          createdAt: _plantActionDate,
          measurement: PlantMeasurement(
            type: currentPlantMeasurementType,
            measurement: height.toJson(),
          ),
        );
        await widget.actionsProvider
            .addPlantAction(action)
            .whenComplete(() => Navigator.of(context).pop());
        return;
      } else if (currentPlantMeasurementType == PlantMeasurementType.pH) {
        final isValid = _plantPHMeasurementWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final ph = _plantPHMeasurementWidgetKey.currentState!.ph;
        action = PlantMeasurementAction(
          id: const Uuid().v4().toString(),
          description: _plantActionDescriptionTextController.text,
          plantId: currentPlant.id,
          type: _currentPlantActionType,
          createdAt: _plantActionDate,
          measurement: PlantMeasurement(
            type: currentPlantMeasurementType,
            measurement: Map<String, dynamic>.from({'ph': ph}),
          ),
        );
        await widget.actionsProvider
            .addPlantAction(action)
            .whenComplete(() => Navigator.of(context).pop());
        return;
      } else if (currentPlantMeasurementType == PlantMeasurementType.ec) {
        final isValid = _plantECMeasurementWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final ec = _plantECMeasurementWidgetKey.currentState!.ec;
        action = PlantMeasurementAction(
          id: const Uuid().v4().toString(),
          description: _plantActionDescriptionTextController.text,
          plantId: currentPlant.id,
          type: _currentPlantActionType,
          createdAt: _plantActionDate,
          measurement: PlantMeasurement(
            type: currentPlantMeasurementType,
            measurement: Map<String, dynamic>.from({'ec': ec}),
          ),
        );
        await widget.actionsProvider
            .addPlantAction(action)
            .whenComplete(() => Navigator.of(context).pop());
        return;
      } else if (currentPlantMeasurementType == PlantMeasurementType.ppm) {
        final isValid = _plantPPMMeasurementWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final ppm = _plantPPMMeasurementWidgetKey.currentState!.ppm;
        action = PlantMeasurementAction(
          id: const Uuid().v4().toString(),
          description: _plantActionDescriptionTextController.text,
          plantId: currentPlant.id,
          type: _currentPlantActionType,
          createdAt: _plantActionDate,
          measurement: PlantMeasurement(
            type: currentPlantMeasurementType,
            measurement: Map<String, dynamic>.from({'ppm': ppm}),
          ),
        );
        await widget.actionsProvider
            .addPlantAction(action)
            .whenComplete(() => Navigator.of(context).pop());
        return;
      } else {
        throw Exception('Unknown plant measurement type: $currentPlantMeasurementType');
      }
    }

    if (_currentPlantActionType == PlantActionType.picture) {
      final images = _plantPictureFormState.currentState!.images;
      if (images.isEmpty) {
        _showImageSelectionMandatorySnackbar();
        return;
      }
      final action = PlantPictureAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
        images: images,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentPlantActionType == PlantActionType.replanting) {
      action = PlantReplantingAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentPlantActionType == PlantActionType.death) {
      action = PlantDeathAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentPlantActionType == PlantActionType.other) {
      action = PlantOtherAction(
        id: const Uuid().v4().toString(),
        description: _plantActionDescriptionTextController.text,
        plantId: currentPlant.id,
        type: _currentPlantActionType,
        createdAt: _plantActionDate,
      );
      await widget.actionsProvider
          .addPlantAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    throw Exception('Unknown action type: $_currentPlantActionType');
  }

  /// Update the current environment.
  void _updateCurrentEnvironment(Environment? environment) {
    setState(() {
      _currentEnvironment = environment!;
    });
  }

  /// Update the current environment action type.
  void _updateCurrentEnvironmentActionType(EnvironmentActionType? actionType) {
    setState(() {
      _currentEnvironmentActionType = actionType!;
    });
  }

  /// The specific environment action form.
  Widget _environmentActionForm() {
    switch (_currentEnvironmentActionType) {
      case EnvironmentActionType.measurement:
        return EnvironmentMeasurementForm(
          key: _environmentMeasurementFormKey,
          environmentTemperatureFormKey: _environmentTemperatureWidgetKey,
          environmentHumidityFormKey: _environmentHumidityWidgetKey,
          environmentLightDistanceFormKey: _environmentLightDistanceWidgetKey,
          environmentCO2FormKey: _environmentCO2WidgetKey,
        );
      case EnvironmentActionType.picture:
        return PictureForm(
          key: _environmentPictureFormState,
          allowMultiple: true,
          images: const [],
        );
      case EnvironmentActionType.other:
        return Container();
    }
  }

  /// The callback for creating a new [EnvironmentAction].
  Future<void> _onEnvironmentActionCreated() async {
    if (_currentEnvironment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
              Text(
                tr('environments.none'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    final currentEnvironment = _currentEnvironment!;
    if (_currentEnvironmentActionType == EnvironmentActionType.measurement) {
      EnvironmentMeasurement measurement;
      final currentEnvironmentMeasurementType =
          _environmentMeasurementFormKey.currentState!.measurementType;
      if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.temperature) {
        final isValid = _environmentTemperatureWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final temperature = _environmentTemperatureWidgetKey.currentState!.temperature;
        measurement = EnvironmentMeasurement(
          type: currentEnvironmentMeasurementType,
          measurement: temperature.toJson(),
        );
      } else if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.humidity) {
        final isValid = _environmentHumidityWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final humidity = _environmentHumidityWidgetKey.currentState!.humidity;
        measurement = EnvironmentMeasurement(
            type: currentEnvironmentMeasurementType,
            measurement: Map<String, dynamic>.from({'humidity': humidity}));
      } else if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.lightDistance) {
        final isValid = _environmentLightDistanceWidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final distance = _environmentLightDistanceWidgetKey.currentState!.distance;
        measurement = EnvironmentMeasurement(
          type: currentEnvironmentMeasurementType,
          measurement: distance.toJson(),
        );
      } else if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.co2) {
        final isValid = _environmentCO2WidgetKey.currentState!.isValid;
        if (!isValid) {
          return;
        }
        final co2 = _environmentCO2WidgetKey.currentState!.co2;
        measurement = EnvironmentMeasurement(
            type: currentEnvironmentMeasurementType,
            measurement: Map<String, dynamic>.from({'co2': co2}));
      } else {
        throw Exception('Unknown environment measurement type: $currentEnvironmentMeasurementType');
      }
      final action = EnvironmentMeasurementAction(
        id: const Uuid().v4().toString(),
        description: _environmentActionDescriptionTextController.text,
        environmentId: currentEnvironment.id,
        type: _currentEnvironmentActionType,
        measurement: measurement,
        createdAt: _environmentActionDate,
      );
      await widget.actionsProvider
          .addEnvironmentAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }

    if (_currentEnvironmentActionType == EnvironmentActionType.picture) {
      final images = _environmentPictureFormState.currentState!.images;
      if (images.isEmpty) {
        _showImageSelectionMandatorySnackbar();
        return;
      }
      final action = EnvironmentPictureAction(
        id: const Uuid().v4().toString(),
        description: _environmentActionDescriptionTextController.text,
        environmentId: currentEnvironment.id,
        type: _currentEnvironmentActionType,
        createdAt: _environmentActionDate,
        images: images,
      );
      await widget.actionsProvider
          .addEnvironmentAction(action)
          .whenComplete(() => Navigator.of(context).pop());
      return;
    }
    final action = EnvironmentOtherAction(
      id: const Uuid().v4().toString(),
      description: _environmentActionDescriptionTextController.text,
      environmentId: currentEnvironment.id,
      type: _currentEnvironmentActionType,
      createdAt: _environmentActionDate,
    );
    await widget.actionsProvider
        .addEnvironmentAction(action)
        .whenComplete(() => Navigator.of(context).pop());
  }
}

/// A form to display the CO2 measurement in the environment.
class EnvironmentCO2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentCO2Form({super.key, required this.formKey});

  @override
  State<EnvironmentCO2Form> createState() => EnvironmentCO2MeasurementFormState();
}

class EnvironmentCO2MeasurementFormState extends State<EnvironmentCO2Form> {
  late TextEditingController _co2Controller;

  @override
  void initState() {
    super.initState();
    _co2Controller = TextEditingController();
  }

  @override
  void dispose() {
    _co2Controller.dispose();
    super.dispose();
  }

  /// The CO2 value.
  double get co2 {
    return double.parse(_co2Controller.text);
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        controller: _co2Controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.co2),
          labelText: 'CO2',
          hintText: '50',
        ),
        validator: (value) => validateInput(value, isDouble: true),
      ),
    );
  }
}

/// A form to display the distance of the light in the environment.
class EnvironmentLightDistanceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentLightDistanceForm({super.key, required this.formKey});

  @override
  State<EnvironmentLightDistanceForm> createState() =>
      EnvironmentLightDistanceMeasurementFormState();
}

class EnvironmentLightDistanceMeasurementFormState extends State<EnvironmentLightDistanceForm> {
  late TextEditingController _distanceController;
  late MeasurementUnit _distanceUnit;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController();
    _distanceUnit = MeasurementUnit.cm;
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  /// The distance value.
  MeasurementAmount get distance {
    return MeasurementAmount(
      value: double.parse(_distanceController.text),
      unit: _distanceUnit,
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 75,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.highlight_rounded),
                  labelText: tr('common.distance'),
                  hintText: '50',
                ),
                validator: (value) => validateInput(value, isDouble: true),
              ),
            ),
            const SizedBox(width: 50),
            const VerticalDivider(),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unit:'),
                DropdownButton<MeasurementUnit>(
                  value: _distanceUnit,
                  icon: const Icon(Icons.arrow_downward_sharp),
                  items: MeasurementUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.symbol),
                        ),
                      )
                      .toList(),
                  onChanged: (MeasurementUnit? value) => _updateMeasurementUnit(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Update the distance unit.
  void _updateMeasurementUnit(MeasurementUnit? value) {
    setState(() {
      _distanceUnit = value!;
    });
  }
}

/// A form to display the humidity measurement in the environment.
class EnvironmentHumidityForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentHumidityForm({super.key, required this.formKey});

  @override
  State<EnvironmentHumidityForm> createState() => EnvironmentHumidityMeasurementFormState();
}

class EnvironmentHumidityMeasurementFormState extends State<EnvironmentHumidityForm> {
  late TextEditingController _humidityController;

  @override
  void initState() {
    super.initState();
    _humidityController = TextEditingController();
  }

  @override
  void dispose() {
    _humidityController.dispose();
    super.dispose();
  }

  /// The humidity value.
  double get humidity {
    return double.parse(_humidityController.text);
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: _humidityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.water_damage),
            labelText: tr('common.humidity'),
            hintText: '50',
          ),
          validator: (value) => validateInput(value, isDouble: true),
        ),
      ),
    );
  }
}

/// A form to display the temperature measurement in the environment.
class EnvironmentTemperatureForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentTemperatureForm({super.key, required this.formKey});

  @override
  State<EnvironmentTemperatureForm> createState() => EnvironmentTemperatureMeasurementFormState();
}

class EnvironmentTemperatureMeasurementFormState extends State<EnvironmentTemperatureForm> {
  late TextEditingController _temperatureController;
  late TemperatureUnit _temperatureUnit;

  @override
  void initState() {
    super.initState();
    _temperatureController = TextEditingController();
    _temperatureUnit = TemperatureUnit.celsius;
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  /// The temperature value.
  Temperature get temperature {
    return Temperature(
      value: double.parse(_temperatureController.text),
      unit: _temperatureUnit,
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        width: double.infinity,
        height: 75,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFormField(
                controller: _temperatureController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.thermostat),
                  labelText: tr('common.temperature'),
                  hintText: '25',
                ),
                validator: (value) => validateInput(value, isDouble: true),
              ),
            ),
            const SizedBox(width: 50),
            const VerticalDivider(),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unit:'),
                DropdownButton<TemperatureUnit>(
                  value: _temperatureUnit,
                  icon: const Icon(Icons.arrow_downward_sharp),
                  items: TemperatureUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (TemperatureUnit? value) => _updateTemperatureUnit(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Update the temperature unit.
  void _updateTemperatureUnit(TemperatureUnit? value) {
    setState(() {
      _temperatureUnit = value!;
    });
  }
}

/// A form to display the amount of water used for watering the plant.
class PlantWateringForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantWateringForm({super.key, required this.formKey});

  @override
  State<PlantWateringForm> createState() => _PlantWateringFormState();
}

class _PlantWateringFormState extends State<PlantWateringForm> {
  late TextEditingController _waterAmountController;
  late LiquidUnit _waterAmountUnit;

  @override
  void initState() {
    super.initState();
    _waterAmountController = TextEditingController();
    _waterAmountUnit = LiquidUnit.ml;
  }

  @override
  void dispose() {
    _waterAmountController.dispose();
    super.dispose();
  }

  /// The watering amount.
  LiquidAmount get watering {
    return LiquidAmount(
      unit: _waterAmountUnit,
      amount: double.parse(_waterAmountController.text),
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        width: double.infinity,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextFormField(
                  controller: _waterAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.water_drop_outlined),
                    labelText: tr('common.amount'),
                    hintText: '50',
                  ),
                  validator: (value) => validateInput(value, isDouble: true)),
            ),
            const SizedBox(width: 50),
            const VerticalDivider(),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unit:'),
                DropdownButton<LiquidUnit>(
                  value: _waterAmountUnit,
                  icon: const Icon(Icons.arrow_downward_sharp),
                  items: LiquidUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (LiquidUnit? value) => _updateWaterAmountUnit(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateWaterAmountUnit(LiquidUnit? value) {
    setState(() {
      _waterAmountUnit = value!;
    });
  }
}

/// A form to display the amount of fertilizer used for fertilizing the plant.
class PlantFertilizingForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FertilizerProvider fertilizerProvider;

  const PlantFertilizingForm({
    super.key,
    required this.formKey,
    required this.fertilizerProvider,
  });

  @override
  State<PlantFertilizingForm> createState() => _PlantFertilizingFormState();
}

class _PlantFertilizingFormState extends State<PlantFertilizingForm> {
  late TextEditingController _fertilizerAmountController;
  late LiquidUnit _liquidUnit;
  Fertilizer? _currentFertilizer;

  @override
  void initState() {
    super.initState();
    _fertilizerAmountController = TextEditingController();
    _liquidUnit = LiquidUnit.ml;
  }

  @override
  void dispose() {
    _fertilizerAmountController.dispose();
    super.dispose();
  }

  /// The fertilization amount.
  PlantFertilization get fertilization {
    if (_currentFertilizer == null) {
      throw Exception('No fertilizer selected');
    }
    return PlantFertilization(
      fertilizerId: _currentFertilizer!.id,
      amount: LiquidAmount(
        unit: _liquidUnit,
        amount: double.parse(_fertilizerAmountController.text),
      ),
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  /// Check if the form has fertilizers.
  bool get hasFertilizers {
    return _currentFertilizer != null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            StreamBuilder<Map<String, Fertilizer>>(
              stream: widget.fertilizerProvider.fertilizers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final fertilizers = snapshot.data!;
                if (fertilizers.isEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(tr('fertilizers.none')),
                      _addFertilizerButton(),
                    ],
                  );
                }

                _currentFertilizer = fertilizers.entries.first.value;
                return SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<Fertilizer>(
                        icon: const Icon(Icons.arrow_downward_sharp),
                        items: fertilizers.entries
                            .map(
                              (fertilizer) => DropdownMenuItem<Fertilizer>(
                                value: fertilizer.value,
                                child: Text(fertilizer.value.name),
                              ),
                            )
                            .toList(),
                        onChanged: (Fertilizer? value) => _updateCurrentFertilizer(value),
                        value: _currentFertilizer,
                      ),
                      const VerticalDivider(),
                      Row(
                        children: [
                          _addFertilizerButton(),
                          const SizedBox(width: 10),
                          IconButton(
                              onPressed: () async {
                                await showFertilizerDetailSheet(
                                    context, widget.fertilizerProvider, fertilizers);
                              },
                              icon: const Icon(Icons.list)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            SizedBox(
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: TextFormField(
                        controller: _fertilizerAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.eco),
                          labelText: tr('common.amount'),
                          hintText: '50',
                        ),
                        validator: (value) => validateInput(value, isDouble: true)),
                  ),
                  const SizedBox(width: 50),
                  const VerticalDivider(),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Unit:'),
                      DropdownButton<LiquidUnit>(
                        value: _liquidUnit,
                        icon: const Icon(Icons.arrow_downward_sharp),
                        items: LiquidUnit.values
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                        onChanged: (LiquidUnit? value) => _updateLiquidUnit(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update the liquid unit.
  void _updateLiquidUnit(LiquidUnit? value) {
    setState(() {
      _liquidUnit = value!;
    });
  }

  /// Update the current fertilizer.
  void _updateCurrentFertilizer(Fertilizer? value) {
    setState(() {
      _currentFertilizer = value;
    });
  }

  /// The button to add a new fertilizer.
  Widget _addFertilizerButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        await showFertilizerForm(context, widget.fertilizerProvider, null);
      },
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    );
  }
}

/// A form to display the type of pruning done on the plant.
class PlantPruningForm extends StatefulWidget {
  const PlantPruningForm({super.key});

  @override
  State<PlantPruningForm> createState() => _PlantPruningFormState();
}

class _PlantPruningFormState extends State<PlantPruningForm> {
  late PruningType _pruningType;

  @override
  void initState() {
    super.initState();
    _pruningType = PruningType.topping;
  }

  /// The pruning type.
  PruningType get pruningType {
    return _pruningType;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PruningType>(
      isExpanded: true,
      value: _pruningType,
      icon: const Icon(Icons.arrow_downward_sharp),
      items: PruningType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
            ),
          )
          .toList(),
      onChanged: (PruningType? value) => _updatePruningType(value),
    );
  }

  /// Update the pruning type.
  void _updatePruningType(PruningType? value) {
    setState(() {
      _pruningType = value!;
    });
  }
}

/// A form to display the amount of the plant harvested.
class PlantHarvestingForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantHarvestingForm({super.key, required this.formKey});

  @override
  State<PlantHarvestingForm> createState() => _PlantHarvestingFormState();
}

class _PlantHarvestingFormState extends State<PlantHarvestingForm> {
  late TextEditingController _harvestAmountController;
  late WeightUnit _weightUnit;

  @override
  void initState() {
    super.initState();
    _harvestAmountController = TextEditingController();
    _weightUnit = WeightUnit.g;
  }

  @override
  void dispose() {
    _harvestAmountController.dispose();
    super.dispose();
  }

  /// The harvest amount.
  WeightAmount get harvest {
    return WeightAmount(
      unit: _weightUnit,
      amount: double.parse(_harvestAmountController.text),
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 75,
        width: double.infinity,
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                  controller: _harvestAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.eco),
                    labelText: tr('common.amount'),
                    hintText: '50',
                  ),
                  validator: (value) => validateInput(value, isDouble: true)),
            ),
            const SizedBox(width: 50),
            const VerticalDivider(),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unit:'),
                DropdownButton<WeightUnit>(
                  value: _weightUnit,
                  icon: const Icon(Icons.arrow_downward_sharp),
                  items: WeightUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (WeightUnit? value) => _updateWeightUnit(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Update the weight unit.
  void _updateWeightUnit(WeightUnit? value) {
    setState(() {
      _weightUnit = value!;
    });
  }
}

/// A form to display the type of training done on the plant.
class PlantTrainingForm extends StatefulWidget {
  const PlantTrainingForm({super.key});

  @override
  State<PlantTrainingForm> createState() => _PlantTrainingFormState();
}

class _PlantTrainingFormState extends State<PlantTrainingForm> {
  late TrainingType _trainingType;

  @override
  void initState() {
    super.initState();
    _trainingType = TrainingType.lst;
  }

  /// The training type.
  TrainingType get trainingType {
    return _trainingType;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TrainingType>(
      isExpanded: true,
      value: _trainingType,
      icon: const Icon(Icons.arrow_downward_sharp),
      items: TrainingType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
            ),
          )
          .toList(),
      onChanged: (TrainingType? value) => _updateTrainingType(value),
    );
  }

  void _updateTrainingType(TrainingType? value) {
    setState(() {
      _trainingType = value!;
    });
  }
}

/// A form to display different types of plant measurements.
class PlantMeasurementForm extends StatefulWidget {
  final GlobalKey<PlantHeightMeasurementFormState> plantMeasurementWidgetKey;
  final GlobalKey<PlantECMeasurementFormState> plantECMeasurementFormKey;
  final GlobalKey<PlantPHMeasurementFormState> plantPHMeasurementFormKey;
  final GlobalKey<PlantPPMMeasurementFormState> plantPPMMeasurementFormKey;

  const PlantMeasurementForm({
    super.key,
    required this.plantMeasurementWidgetKey,
    required this.plantECMeasurementFormKey,
    required this.plantPHMeasurementFormKey,
    required this.plantPPMMeasurementFormKey,
  });

  @override
  State<PlantMeasurementForm> createState() => _PlantMeasurementFormState();
}

class _PlantMeasurementFormState extends State<PlantMeasurementForm> {
  late PlantMeasurementType _measurementType;

  @override
  void initState() {
    super.initState();
    _measurementType = PlantMeasurementType.height;
  }

  /// The current measurement type.
  PlantMeasurementType get measurementType {
    return _measurementType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<PlantMeasurementType>(
          isExpanded: true,
          value: _measurementType,
          icon: const Icon(Icons.arrow_downward_sharp),
          items: PlantMeasurementType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(
                        type.icon,
                      ),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (PlantMeasurementType? value) => _updateMeasurementType(value),
        ),
        const Divider(),
        _measurementForm(),
      ],
    );
  }

  void _updateMeasurementType(PlantMeasurementType? value) {
    setState(() {
      _measurementType = value!;
    });
  }

  /// The specific plant measurement form.
  Widget _measurementForm() {
    switch (_measurementType) {
      case PlantMeasurementType.height:
        return PlantHeightMeasurementForm(
          key: widget.plantMeasurementWidgetKey,
          formKey: GlobalKey<FormState>(),
        );
      case PlantMeasurementType.pH:
        return PlantPHMeasurementForm(
          key: widget.plantPHMeasurementFormKey,
          formKey: GlobalKey<FormState>(),
        );
      case PlantMeasurementType.ec:
        return PlantECMeasurementForm(
          key: widget.plantECMeasurementFormKey,
          formKey: GlobalKey<FormState>(),
        );
      case PlantMeasurementType.ppm:
        return PlantPPMMeasurementForm(
          key: widget.plantPPMMeasurementFormKey,
          formKey: GlobalKey<FormState>(),
        );
    }
  }
}

/// A form to display the height measurement of the plant.
class PlantHeightMeasurementForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantHeightMeasurementForm({super.key, required this.formKey});

  @override
  State<PlantHeightMeasurementForm> createState() => PlantHeightMeasurementFormState();
}

class PlantHeightMeasurementFormState extends State<PlantHeightMeasurementForm> {
  late TextEditingController _heightController;
  late MeasurementUnit _heightUnit;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _heightUnit = MeasurementUnit.cm;
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  /// The height value.
  MeasurementAmount get height {
    return MeasurementAmount(
      value: double.parse(_heightController.text),
      unit: _heightUnit,
    );
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 75,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr('common.height'),
                    hintText: '50',
                  ),
                  validator: (value) => validateInput(value, isDouble: true)),
            ),
            const SizedBox(width: 50),
            const VerticalDivider(),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Unit:'),
                DropdownButton<MeasurementUnit>(
                  value: MeasurementUnit.cm,
                  icon: const Icon(Icons.arrow_downward_sharp),
                  items: MeasurementUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit.name),
                        ),
                      )
                      .toList(),
                  onChanged: (MeasurementUnit? value) => _updateHeightUnit(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Update the height unit.
  void _updateHeightUnit(MeasurementUnit? value) {
    setState(() {
      _heightUnit = value!;
    });
  }
}

/// A form to display the pH measurement of the plant.
class PlantPHMeasurementForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantPHMeasurementForm({super.key, required this.formKey});

  @override
  State<PlantPHMeasurementForm> createState() => PlantPHMeasurementFormState();
}

class PlantPHMeasurementFormState extends State<PlantPHMeasurementForm> {
  late TextEditingController _phController;

  @override
  void initState() {
    super.initState();
    _phController = TextEditingController();
  }

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  /// The pH value.
  double get ph {
    return double.parse(_phController.text);
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        controller: _phController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'pH',
          hintText: '7.0',
        ),
        validator: (value) => validateInput(value, isDouble: true),
      ),
    );
  }
}

/// A form to display the EC measurement of the plant.
class PlantECMeasurementForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantECMeasurementForm({super.key, required this.formKey});

  @override
  State<PlantECMeasurementForm> createState() => PlantECMeasurementFormState();
}

class PlantECMeasurementFormState extends State<PlantECMeasurementForm> {
  late TextEditingController _ecController;

  @override
  void initState() {
    super.initState();
    _ecController = TextEditingController();
  }

  @override
  void dispose() {
    _ecController.dispose();
    super.dispose();
  }

  /// The EC value.
  double get ec {
    return double.parse(_ecController.text);
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        controller: _ecController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'EC',
          hintText: '1.5',
        ),
        validator: (value) => validateInput(value, isDouble: true),
      ),
    );
  }
}

/// A form to display the PPM measurement of the plant.
class PlantPPMMeasurementForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const PlantPPMMeasurementForm({super.key, required this.formKey});

  @override
  State<PlantPPMMeasurementForm> createState() => PlantPPMMeasurementFormState();
}

class PlantPPMMeasurementFormState extends State<PlantPPMMeasurementForm> {
  late TextEditingController _ppmController;

  @override
  void initState() {
    super.initState();
    _ppmController = TextEditingController();
  }

  @override
  void dispose() {
    _ppmController.dispose();
    super.dispose();
  }

  /// The PPM value.
  double get ppm {
    return double.parse(_ppmController.text);
  }

  /// Check if the form is valid.
  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        controller: _ppmController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'PPM',
          hintText: '500',
        ),
        validator: (value) => validateInput(value, isDouble: true),
      ),
    );
  }
}

/// A form to take pictures.
class PictureForm extends StatefulWidget {
  final bool allowMultiple;
  final List<File> images;

  const PictureForm({
    super.key,
    required this.allowMultiple,
    required this.images,
  });

  @override
  State<PictureForm> createState() => PictureFormState();
}

class PictureFormState extends State<PictureForm> {
  final ImagePicker _picker = ImagePicker();
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images = [...widget.images];
  }

  /// The images taken.
  List<String> get images {
    return _images.isEmpty ? [] : _images.map((image) => image.path).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _images.isEmpty
            ? SizedBox(
                child: Row(
                  children: [
                    widget.allowMultiple
                        ? Text(tr('common.no_images'))
                        : Text(tr('common.no_image')),
                    _addImageButton(),
                  ],
                ),
              )
            : SizedBox(
                height: 125,
                child: Row(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (context, index) => const VerticalDivider(),
                      itemBuilder: (context, index) {
                        final image = _images[index];
                        return Column(
                          children: [
                            IconButton(
                              onPressed: () => _removeImage(index),
                              icon: const Icon(Icons.clear, color: Colors.red),
                            ),
                            Image.file(
                              image,
                              width: 75,
                              height: 75,
                            ),
                          ],
                        );
                      },
                    ),
                    if (widget.allowMultiple) const VerticalDivider(),
                    _addImageButton(),
                  ],
                ),
              ),
      ],
    );
  }

  /// Remove an image.
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  /// The button to add an image.
  Widget _addImageButton() {
    return IconButton(
      onPressed: () async {
        final File? image = await showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(tr('common.take_image_camera')),
                  onTap: () async {
                    final file = await _getImage(ImageSource.camera);
                    if (!context.mounted) return;
                    Navigator.of(context).pop(file);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text(tr('common.select_image_gallery')),
                  onTap: () async {
                    final file = await _getImage(ImageSource.gallery);
                    if (!context.mounted) return;
                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            );
          },
        );

        if (image == null) return;

        setState(() {
          _images.add(image);
        });
      },
      icon: const Icon(Icons.add_a_photo),
    );
  }

  /// Get an image from the camera or gallery.
  Future<File> _getImage(final ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) throw Exception('No image picked');
    if (source == ImageSource.camera) {
      // images taken from the camera are stored in the app directory for now
      // TODO: Store images in platform specific gallery directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final fullPath = '${appDir.path}/images/$fileName';

      // Create the images directory if it does not exist
      final imagesDirectory = Directory('${appDir.path}/images');
      if (!imagesDirectory.existsSync()) {
        imagesDirectory.createSync();
      }

      // Save the image to the app directory
      await pickedFile.saveTo(fullPath);

      // Delete the image from the temporary directory
      final cachedFile = File(pickedFile.path);
      await cachedFile.delete();

      final file = File(fullPath);
      return file;
    }
    return File(pickedFile.path);
  }
}

/// A form to display the type of the environment measurement.
class EnvironmentMeasurementForm extends StatefulWidget {
  final GlobalKey<EnvironmentCO2MeasurementFormState> environmentCO2FormKey;
  final GlobalKey<EnvironmentHumidityMeasurementFormState> environmentHumidityFormKey;
  final GlobalKey<EnvironmentLightDistanceMeasurementFormState> environmentLightDistanceFormKey;
  final GlobalKey<EnvironmentTemperatureMeasurementFormState> environmentTemperatureFormKey;

  const EnvironmentMeasurementForm({
    super.key,
    required this.environmentCO2FormKey,
    required this.environmentHumidityFormKey,
    required this.environmentLightDistanceFormKey,
    required this.environmentTemperatureFormKey,
  });

  @override
  State<EnvironmentMeasurementForm> createState() => _EnvironmentMeasurementFormState();
}

class _EnvironmentMeasurementFormState extends State<EnvironmentMeasurementForm> {
  late EnvironmentMeasurementType _measurementType;

  @override
  void initState() {
    super.initState();
    _measurementType = EnvironmentMeasurementType.temperature;
  }

  /// The current measurement type.
  EnvironmentMeasurementType get measurementType {
    return _measurementType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<EnvironmentMeasurementType>(
          icon: const Icon(Icons.arrow_downward_sharp),
          value: _measurementType,
          isExpanded: true,
          items: EnvironmentMeasurementType.values
              .map(
                (type) => DropdownMenuItem<EnvironmentMeasurementType>(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (EnvironmentMeasurementType? value) => _updateMeasurementType(value),
        ),
        _environmentActionMeasurementForm(),
      ],
    );
  }

  /// Update the measurement type.
  void _updateMeasurementType(EnvironmentMeasurementType? value) {
    setState(() {
      _measurementType = value!;
    });
  }

  /// The specific environment measurement form.
  Widget _environmentActionMeasurementForm() {
    switch (_measurementType) {
      case EnvironmentMeasurementType.temperature:
        return EnvironmentTemperatureForm(
          key: widget.environmentTemperatureFormKey,
          formKey: GlobalKey<FormState>(),
        );
      case EnvironmentMeasurementType.humidity:
        return EnvironmentHumidityForm(
          key: widget.environmentHumidityFormKey,
          formKey: GlobalKey<FormState>(),
        );
      case EnvironmentMeasurementType.co2:
        return EnvironmentCO2Form(
          key: widget.environmentCO2FormKey,
          formKey: GlobalKey<FormState>(),
        );
      case EnvironmentMeasurementType.lightDistance:
        return EnvironmentLightDistanceForm(
          key: widget.environmentLightDistanceFormKey,
          formKey: GlobalKey<FormState>(),
        );
    }
  }
}
