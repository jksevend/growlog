import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/fertilizer/dialog.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/widget.dart';
import 'package:weedy/common/measurement.dart';
import 'package:weedy/common/temperature.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

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
              child: Text('No environment actions created yet.'),
            );
          }

          final specificEnvironmentActions =
              environmentActions.where((action) => action.environmentId == environment.id).toList();

          if (specificEnvironmentActions.isEmpty) {
            return Center(
              child: Text('No actions for this environment.'),
            );
          }

          return ListView.builder(
            itemCount: specificEnvironmentActions.length,
            itemBuilder: (context, index) {
              final action = specificEnvironmentActions.elementAt(index);
              return ListTile(
                title: Text(action.description),
                subtitle: Text(action.formattedDate),
              );
            },
          );
        },
      ),
    );
  }
}

class PlantActionOverview extends StatefulWidget {
  final Plant plant;
  final ActionsProvider actionsProvider;

  const PlantActionOverview({
    super.key,
    required this.plant,
    required this.actionsProvider,
  });

  @override
  State<PlantActionOverview> createState() => _PlantActionOverviewState();
}

class _PlantActionOverviewState extends State<PlantActionOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PlantAction>>(
        stream: widget.actionsProvider.plantActions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final plantActions = snapshot.data!;
          if (plantActions.isEmpty) {
            return Center(
              child: Text('No plant actions created yet.'),
            );
          }

          final specificPlantActions =
              plantActions.where((action) => action.plantId == widget.plant.id).toList();

          if (specificPlantActions.isEmpty) {
            return Center(
              child: Text('No actions for this plant.'),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: VerticalDivider(
                  thickness: 2.0,
                  color: Colors.grey,
                ),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: specificPlantActions.length,
                itemBuilder: (context, index) {
                  final action = specificPlantActions.elementAt(index);
                  return PlantActionLogItem(
                    action: action,
                    isFirst: index == 0,
                    isLast: index == specificPlantActions.length - 1,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
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
  final List<bool> _choices = [true, false];

  final GlobalKey<EnvironmentTemperatureFormState> _environmentTemperatureFormKey = GlobalKey();
  final GlobalKey<EnvironmentHumidityFormState> _environmentHumidityFormKey = GlobalKey();
  final GlobalKey<EnvironmentLightDistanceFormState> _environmentLightDistanceFormKey = GlobalKey();
  final GlobalKey<EnvironmentCO2FormState> _environmentCO2FormKey = GlobalKey();

  final GlobalKey<_PlantWateringFormState> _plantWateringWidgetKey = GlobalKey();

  final GlobalKey<_PlantFertilizingFormState> _plantFertilizingFormKey = GlobalKey();
  final GlobalKey<_PlantPruningFormState> _plantPruningFormKey = GlobalKey();
  final GlobalKey<_PlantHarvestingFormState> _plantHarvestingFormKey = GlobalKey();
  final GlobalKey<_PlantTrainingFormState> _plantTrainingFormKey = GlobalKey();
  final GlobalKey<_PlantMeasurementFormState> _plantMeasuringFormKey = GlobalKey();

  final GlobalKey<PlantHeightMeasurementFormState> _plantHeightMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPHMeasurementFormState> _plantPHMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantECMeasurementFormState> _plantECMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPPMMeasurementFormState> _plantPPMMeasurementWidgetKey = GlobalKey();
  final GlobalKey<_EnvironmentMeasurementFormState> _environmentMeasurementWidgetKey = GlobalKey();

  final GlobalKey<_RecurringDetailsFormState> _recurringDetailsFormKey = GlobalKey();
  final GlobalKey<FormState> _plantRecurringDetailsFormKey = GlobalKey();
  final GlobalKey<FormState> _environmentRecurringDetailsFormKey = GlobalKey();

  Plant? _currentPlant;
  late PlantActionType _currentActionType = PlantActionType.watering;
  late EnvironmentActionType _currentEnvironmentActionType = EnvironmentActionType.measurement;
  late TextEditingController _plantActionDescriptionTextController = TextEditingController();
  late TextEditingController _environmentActionDescriptionTextController = TextEditingController();
  final DateTime _plantActionDate = DateTime.now();
  final DateTime _environmentActionDate = DateTime.now();
  Environment? _currentEnvironment;

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
        title: const Text('Choose Action'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('What do you want to do?'),
                      SizedBox(height: 10),
                      ToggleButtons(
                        constraints: BoxConstraints(minWidth: 100),
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.eco,
                                size: 50,
                                color: Colors.green[900],
                              ),
                              Text('Plant')
                            ],
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                size: 50,
                                color: Colors.yellow[900],
                              ),
                              Text('Environment')
                            ],
                          )
                        ],
                        isSelected: _choices,
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _choices.length; i++) {
                              _choices[i] = i == index;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            _actionForm(context),
          ],
        ),
      ),
    );
  }

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
                    Text('Choose a plant:'),
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
                                child: Text('No plants created yet.'),
                              ),
                            );
                          }
                          _currentPlant = plants[plants.keys.first]!;
                          return DropdownButton<Plant>(
                            icon: Icon(Icons.arrow_downward_sharp),
                            isExpanded: true,
                            items: plants.values
                                .map(
                                  (plant) => DropdownMenuItem<Plant>(
                                    child: Text(plant.name),
                                    value: plant,
                                  ),
                                )
                                .toList(),
                            onChanged: (Plant? value) {
                              setState(() {
                                _currentPlant = value!;
                              });
                            },
                            value: _currentPlant,
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(Icons.calendar_month),
                        Text('Select date: '),
                        TextButton(
                          onPressed: () => _selectDate(context, _plantActionDate),
                          child: Text(
                            '${_plantActionDate.toLocal()}'.split(' ')[0],
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    TextFormField(
                      controller: _plantActionDescriptionTextController,
                      maxLines: null,
                      minLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a description of the plant',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        DropdownButton<PlantActionType>(
                          icon: Icon(Icons.arrow_downward_sharp),
                          value: _currentActionType,
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
                          onChanged: (PlantActionType? value) {
                            setState(() {
                              _currentActionType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    _plantActionForm(),
                  ],
                ),
              ),
            ),
            Card(
              child: RecurringDetailsForm(
                key: _recurringDetailsFormKey,
                formKey: _plantRecurringDetailsFormKey,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (_currentPlant == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              'Create a plant before creating an action for it',
                            ),
                          ],
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  final currentPlant = _currentPlant!;
                  final PlantAction action;

                  final isValid = _recurringDetailsFormKey.currentState!.isValid;
                  if (!isValid) {
                    return;
                  }
                  final recurring = _recurringDetailsFormKey.currentState!.recurringDetails;

                  debugPrint('Recurring: ${recurring?.toJson()}');

                  if (_currentActionType == PlantActionType.watering) {
                    final isValid = _plantWateringWidgetKey.currentState!.isValid;
                    if (!isValid) {
                      return;
                    }
                    final watering = _plantWateringWidgetKey.currentState!.watering;
                    action = PlantWateringAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      recurring: recurring,
                      amount: watering,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }
                  if (_currentActionType == PlantActionType.fertilizing) {
                    final fertilization = _plantFertilizingFormKey.currentState!.fertilization;
                    action = PlantFertilizingAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      fertilization: fertilization,
                      recurring: recurring,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }
                  if (_currentActionType == PlantActionType.pruning) {
                    final pruning = _plantPruningFormKey.currentState!.pruning;
                    action = PlantPruningAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      pruningType: pruning,
                      recurring: recurring,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentActionType == PlantActionType.harvesting) {
                    final harvesting = _plantHarvestingFormKey.currentState!.harvest;
                    action = PlantHarvestingAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      recurring: recurring,
                      amount: harvesting,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentActionType == PlantActionType.training) {
                    final training = _plantTrainingFormKey.currentState!.training;
                    action = PlantTrainingAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      recurring: recurring,
                      trainingType: training,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentActionType == PlantActionType.measuring) {
                    final currentPlantMeasurementType =
                        _plantMeasuringFormKey.currentState!.measurementType;
                    if (currentPlantMeasurementType == PlantMeasurementType.height) {
                      final isValid = _plantHeightMeasurementWidgetKey.currentState!.isValid;
                      if (!isValid) {
                        return;
                      }
                      final height = _plantHeightMeasurementWidgetKey.currentState!.height;
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: currentPlant.id,
                        type: _currentActionType,
                        createdAt: _plantActionDate,
                        recurring: recurring,
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
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: currentPlant.id,
                        type: _currentActionType,
                        createdAt: _plantActionDate,
                        recurring: recurring,
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
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: currentPlant.id,
                        type: _currentActionType,
                        createdAt: _plantActionDate,
                        recurring: recurring,
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
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: currentPlant.id,
                        type: _currentActionType,
                        createdAt: _plantActionDate,
                        recurring: recurring,
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
                      throw Exception(
                          'Unknown plant measurement type: $currentPlantMeasurementType');
                    }
                  }

                  if (_currentActionType == PlantActionType.replanting) {
                    action = PlantAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      recurring: recurring,
                      createdAt: _plantActionDate,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentActionType == PlantActionType.death) {
                    action = PlantAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      recurring: recurring,
                      createdAt: _plantActionDate,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentActionType == PlantActionType.other) {
                    action = PlantAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentActionType,
                      recurring: recurring,
                      createdAt: _plantActionDate,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  throw Exception('Unknown action type: $_currentActionType');
                },
                label: Text('Save'),
                icon: Icon(Icons.save),
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
                  Text('Choose an environment:'),
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
                            child: Text('No environments created yet.'),
                          ),
                        );
                      }
                      _currentEnvironment = environments[environments.keys.first]!;
                      return DropdownButton<Environment>(
                        icon: Icon(Icons.arrow_downward_sharp),
                        isExpanded: true,
                        items: environments.values
                            .map(
                              (e) => DropdownMenuItem<Environment>(
                                child: Text(e.name),
                                value: e,
                              ),
                            )
                            .toList(),
                        onChanged: (Environment? value) {
                          setState(() {
                            _currentEnvironment = value!;
                          });
                        },
                        value: _currentEnvironment,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.calendar_month),
                      Text('Select date: '),
                      TextButton(
                        onPressed: () => _selectDate(context, _environmentActionDate),
                        child: Text(
                          '${_environmentActionDate.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  TextFormField(
                    controller: _environmentActionDescriptionTextController,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter a description of the plant',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButton<EnvironmentActionType>(
                    icon: Icon(Icons.arrow_downward_sharp),
                    value: _currentEnvironmentActionType,
                    isExpanded: true,
                    items: EnvironmentActionType.values
                        .map(
                          (action) => DropdownMenuItem<EnvironmentActionType>(
                            child: Row(
                              children: [
                               Text( action.icon,),
                                const SizedBox(width: 10),
                                Text(action.name),
                              ],
                            ),
                            value: action,
                          ),
                        )
                        .toList(),
                    onChanged: (EnvironmentActionType? value) {
                      setState(() {
                        _currentEnvironmentActionType = value!;
                      });
                    },
                  ),
                  _environmentActionForm(),
                ],
              ),
            ),
          ),
          Divider(),
          Card(
            child: RecurringDetailsForm(
              key: _recurringDetailsFormKey,
              formKey: _environmentRecurringDetailsFormKey,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                if (_currentEnvironment == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            'Create an environment before creating an action!',
                          ),
                        ],
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                final currentEnvironment = _currentEnvironment!;
                if (_currentEnvironmentActionType == EnvironmentActionType.measurement) {
                  EnvironmentMeasurement measurement;
                  final currentEnvironmentMeasurementType =
                      _environmentMeasurementWidgetKey.currentState!.measurementType;
                  if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.temperature) {
                    final temperature = _environmentTemperatureFormKey.currentState!.temperature;
                    measurement = EnvironmentMeasurement(
                      type: currentEnvironmentMeasurementType,
                      measurement: temperature.toJson(),
                    );
                  } else if (currentEnvironmentMeasurementType ==
                      EnvironmentMeasurementType.humidity) {
                    final humidity = _environmentHumidityFormKey.currentState!.humidity;
                    measurement = EnvironmentMeasurement(
                        type: currentEnvironmentMeasurementType,
                        measurement: Map<String, dynamic>.from({'humidity': humidity}));
                  } else if (currentEnvironmentMeasurementType ==
                      EnvironmentMeasurementType.lightDistance) {
                    final distance = _environmentLightDistanceFormKey.currentState!.distance;
                    measurement = EnvironmentMeasurement(
                      type: currentEnvironmentMeasurementType,
                      measurement: distance.toJson(),
                    );
                  } else if (currentEnvironmentMeasurementType == EnvironmentMeasurementType.co2) {
                    final co2 = _environmentCO2FormKey.currentState!.co2;
                    measurement = EnvironmentMeasurement(
                        type: currentEnvironmentMeasurementType,
                        measurement: Map<String, dynamic>.from({'co2': co2}));
                  } else {
                    throw Exception(
                        'Unknown environment measurement type: $currentEnvironmentMeasurementType');
                  }

                  final isValid = _recurringDetailsFormKey.currentState!.isValid;
                  if (!isValid) {
                    return;
                  }

                  final recurring = _recurringDetailsFormKey.currentState!.recurringDetails;

                  final action = EnvironmentMeasurementAction(
                    id: const Uuid().v4().toString(),
                    description: _environmentActionDescriptionTextController.text,
                    environmentId: currentEnvironment.id,
                    type: _currentEnvironmentActionType,
                    measurement: measurement,
                    recurring: recurring,
                    createdAt: _environmentActionDate,
                  );
                  await widget.actionsProvider
                      .addEnvironmentAction(action)
                      .whenComplete(() => Navigator.of(context).pop());
                  return;
                }

                final isValid = _recurringDetailsFormKey.currentState!.isValid;
                if (!isValid) {
                  return;
                }

                final recurring = _recurringDetailsFormKey.currentState!.recurringDetails;
                final action = EnvironmentOtherAction(
                  id: const Uuid().v4().toString(),
                  description: _environmentActionDescriptionTextController.text,
                  environmentId: currentEnvironment.id,
                  type: _currentEnvironmentActionType,
                  recurring: recurring,
                  createdAt: _environmentActionDate,
                );
                await widget.actionsProvider
                    .addEnvironmentAction(action)
                    .whenComplete(() => Navigator.of(context).pop());
              },
              label: Text('Save'),
              icon: Icon(Icons.save),
            ),
          ),
        ],
      );
    }
  }

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

  Widget _plantActionForm() {
    switch (_currentActionType) {
      case PlantActionType.watering:
        return PlantWateringForm(
          key: _plantWateringWidgetKey,
        );
      case PlantActionType.fertilizing:
        return PlantFertilizingForm(
          key: _plantFertilizingFormKey,
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
        );
      case PlantActionType.measuring:
        return PlantMeasurementForm(
          key: _plantMeasuringFormKey,
          plantMeasurementWidgetKey: _plantHeightMeasurementWidgetKey,
          plantPHMeasurementFormKey: _plantPHMeasurementWidgetKey,
          plantECMeasurementFormKey: _plantECMeasurementWidgetKey,
          plantPPMMeasurementFormKey: _plantPPMMeasurementWidgetKey,
        );
      case PlantActionType.death:
      case PlantActionType.other:
        return Container();
    }
  }

  Widget _environmentActionForm() {
    switch (_currentEnvironmentActionType) {
      case EnvironmentActionType.measurement:
        return EnvironmentMeasurementForm(
          key: _environmentMeasurementWidgetKey,
          environmentTemperatureFormKey: _environmentTemperatureFormKey,
          environmentHumidityFormKey: _environmentHumidityFormKey,
          environmentLightDistanceFormKey: _environmentLightDistanceFormKey,
          environmentCO2FormKey: _environmentCO2FormKey,
        );
      case EnvironmentActionType.other:
        return Container();
    }
  }
}

class RecurringDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const RecurringDetailsForm({super.key, required this.formKey});

  @override
  State<RecurringDetailsForm> createState() => _RecurringDetailsFormState();
}

class _RecurringDetailsFormState extends State<RecurringDetailsForm> {
  late bool _useRecurring;
  late TextEditingController _intervalController;
  late IntervalUnit _interval;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(text: '1');
    _interval = IntervalUnit.day;
    _useRecurring = false;
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Recurring? get recurringDetails {
    return _useRecurring
        ? Recurring(
            interval: int.parse(_intervalController.text),
            unit: _interval,
          )
        : null;
  }

  bool get isValid {
    if (!_useRecurring) {
      return true;
    }
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _useRecurring,
                onChanged: (bool? value) {
                  setState(() {
                    _useRecurring = value!;
                  });
                },
              ),
              Text('Use recurring')
            ],
          ),
          Visibility(
            visible: _useRecurring,
            child: Column(
              children: [
                Divider(),
                SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _intervalController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Interval',
                              hintText: '1',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an interval';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 50),
                        VerticalDivider(),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Unit:'),
                            DropdownButton<IntervalUnit>(
                              value: _interval,
                              icon: Icon(Icons.arrow_downward_sharp),
                              items: IntervalUnit.values
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      child: Text(unit.name),
                                      value: unit,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (IntervalUnit? value) {
                                setState(() {
                                  _interval = value!;
                                });
                              },
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
  }
}

class EnvironmentCO2Form extends StatefulWidget {
  const EnvironmentCO2Form({super.key});

  @override
  State<EnvironmentCO2Form> createState() => EnvironmentCO2FormState();
}

class EnvironmentCO2FormState extends State<EnvironmentCO2Form> {
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

  double get co2 {
    return double.parse(_co2Controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _co2Controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.co2),
        labelText: 'CO2',
        hintText: '50',
      ),
    );
  }
}

class EnvironmentLightDistanceForm extends StatefulWidget {
  const EnvironmentLightDistanceForm({super.key});

  @override
  State<EnvironmentLightDistanceForm> createState() => EnvironmentLightDistanceFormState();
}

class EnvironmentLightDistanceFormState extends State<EnvironmentLightDistanceForm> {
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

  MeasurementAmount get distance {
    return MeasurementAmount(
      value: double.parse(_distanceController.text),
      unit: _distanceUnit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.highlight_rounded),
                labelText: 'Distance',
                hintText: '50',
              ),
            ),
          ),
          SizedBox(width: 50),
          VerticalDivider(),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unit:'),
              DropdownButton<MeasurementUnit>(
                value: _distanceUnit,
                icon: Icon(Icons.arrow_downward_sharp),
                items: MeasurementUnit.values
                    .map(
                      (unit) => DropdownMenuItem(
                        child: Text(unit.name),
                        value: unit,
                      ),
                    )
                    .toList(),
                onChanged: (MeasurementUnit? value) {
                  setState(() {
                    _distanceUnit = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnvironmentHumidityForm extends StatefulWidget {
  const EnvironmentHumidityForm({super.key});

  @override
  State<EnvironmentHumidityForm> createState() => EnvironmentHumidityFormState();
}

class EnvironmentHumidityFormState extends State<EnvironmentHumidityForm> {
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

  double get humidity {
    return double.parse(_humidityController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _humidityController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.water_damage),
          labelText: 'Humidity',
          hintText: '50',
        ),
      ),
    );
  }
}

class EnvironmentTemperatureForm extends StatefulWidget {
  const EnvironmentTemperatureForm({super.key});

  @override
  State<EnvironmentTemperatureForm> createState() => EnvironmentTemperatureFormState();
}

class EnvironmentTemperatureFormState extends State<EnvironmentTemperatureForm> {
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

  Temperature get temperature {
    return Temperature(
      value: double.parse(_temperatureController.text),
      unit: _temperatureUnit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                suffixIcon: Icon(Icons.thermostat),
                labelText: 'Temperature',
                hintText: '25',
              ),
            ),
          ),
          SizedBox(width: 50),
          VerticalDivider(),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unit:'),
              DropdownButton<TemperatureUnit>(
                value: _temperatureUnit,
                icon: Icon(Icons.arrow_downward_sharp),
                items: TemperatureUnit.values
                    .map(
                      (unit) => DropdownMenuItem(
                        child: Text(unit.name),
                        value: unit,
                      ),
                    )
                    .toList(),
                onChanged: (TemperatureUnit? value) {
                  setState(() {
                    _temperatureUnit = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlantWateringForm extends StatefulWidget {
  const PlantWateringForm({super.key});

  @override
  State<PlantWateringForm> createState() => _PlantWateringFormState();
}

class _PlantWateringFormState extends State<PlantWateringForm> {
  final GlobalKey<FormState> _plantWateringFormKey = GlobalKey<FormState>();

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

  LiquidAmount get watering {
    return LiquidAmount(
      unit: _waterAmountUnit,
      amount: double.parse(_waterAmountController.text),
    );
  }

  bool get isValid {
    return _plantWateringFormKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _plantWateringFormKey,
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
                  suffixIcon: Icon(Icons.water_drop_outlined),
                  labelText: 'Amount',
                  hintText: '50',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 50),
            VerticalDivider(),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Unit:'),
                DropdownButton<LiquidUnit>(
                  value: _waterAmountUnit,
                  icon: Icon(Icons.arrow_downward_sharp),
                  items: LiquidUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          child: Text(unit.name),
                          value: unit,
                        ),
                      )
                      .toList(),
                  onChanged: (LiquidUnit? value) {
                    setState(() {
                      _waterAmountUnit = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlantFertilizingForm extends StatefulWidget {
  final FertilizerProvider fertilizerProvider;

  const PlantFertilizingForm({
    super.key,
    required this.fertilizerProvider,
  });

  @override
  State<PlantFertilizingForm> createState() => _PlantFertilizingFormState();
}

class _PlantFertilizingFormState extends State<PlantFertilizingForm> {
  late TextEditingController _fertilizerAmountController;
  late LiquidUnit _liquidUnit;
  late Fertilizer _currentFertilizer;

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

  PlantFertilization get fertilization {
    return PlantFertilization(
      fertilizerId: _currentFertilizer.id,
      amount: LiquidAmount(
        unit: _liquidUnit,
        amount: double.parse(_fertilizerAmountController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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

              final fertilizers = snapshot.data!.values;
              if (fertilizers.isEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('No fertilizers created yet.'),
                    _addFertilizerButton(),
                  ],
                );
              }

              _currentFertilizer = fertilizers.first;
              return SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<Fertilizer>(
                      icon: Icon(Icons.arrow_downward_sharp),
                      items: fertilizers
                          .map(
                            (fertilizer) => DropdownMenuItem<Fertilizer>(
                              child: Text(fertilizer.name),
                              value: fertilizer,
                            ),
                          )
                          .toList(),
                      onChanged: (Fertilizer? value) {
                        setState(() {
                          _currentFertilizer = value!;
                        });
                      },
                      value: _currentFertilizer,
                    ),
                    VerticalDivider(),
                    _addFertilizerButton(),
                  ],
                ),
              );
            },
          ),
          Divider(),
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
                      suffixIcon: Icon(Icons.eco),
                      labelText: 'Amount',
                      hintText: '50',
                    ),
                  ),
                ),
                SizedBox(width: 50),
                VerticalDivider(),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Unit:'),
                    DropdownButton<LiquidUnit>(
                      value: _liquidUnit,
                      icon: Icon(Icons.arrow_downward_sharp),
                      items: LiquidUnit.values
                          .map(
                            (unit) => DropdownMenuItem(
                              child: Text(unit.name),
                              value: unit,
                            ),
                          )
                          .toList(),
                      onChanged: (LiquidUnit? value) {
                        setState(() {
                          _liquidUnit = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFertilizerButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        await showCreateFertilizerDialog(context, widget.fertilizerProvider);
      },
      icon: Icon(Icons.add),
      label: Text('Add'),
    );
  }
}

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

  PruningType get pruning {
    return _pruningType;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<PruningType>(
      isExpanded: true,
      value: _pruningType,
      icon: Icon(Icons.arrow_downward_sharp),
      items: PruningType.values
          .map(
            (type) => DropdownMenuItem(
              child: Text(type.name),
              value: type,
            ),
          )
          .toList(),
      onChanged: (PruningType? value) {
        setState(() {
          _pruningType = value!;
        });
      },
    );
  }
}

class PlantHarvestingForm extends StatefulWidget {
  const PlantHarvestingForm({super.key});

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

  WeightAmount get harvest {
    return WeightAmount(
      unit: _weightUnit,
      amount: double.parse(_harvestAmountController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: double.infinity,
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              controller: _harvestAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.eco),
                labelText: 'Amount',
                hintText: '50',
              ),
            ),
          ),
          SizedBox(width: 50),
          VerticalDivider(),
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unit:'),
              DropdownButton<WeightUnit>(
                value: _weightUnit,
                icon: Icon(Icons.arrow_downward_sharp),
                items: WeightUnit.values
                    .map(
                      (unit) => DropdownMenuItem(
                        child: Text(unit.name),
                        value: unit,
                      ),
                    )
                    .toList(),
                onChanged: (WeightUnit? value) {
                  setState(() {
                    _weightUnit = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

  TrainingType get training {
    return _trainingType;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TrainingType>(
      isExpanded: true,
      value: _trainingType,
      icon: Icon(Icons.arrow_downward_sharp),
      items: TrainingType.values
          .map(
            (type) => DropdownMenuItem(
              child: Text(type.name),
              value: type,
            ),
          )
          .toList(),
      onChanged: (TrainingType? value) {
        setState(() {
          _trainingType = value!;
        });
      },
    );
  }
}

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
          icon: Icon(Icons.arrow_downward_sharp),
          items: PlantMeasurementType.values
              .map(
                (type) => DropdownMenuItem(
                  child: Row(
                    children: [
                      Text(type.icon,),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                  value: type,
                ),
              )
              .toList(),
          onChanged: (PlantMeasurementType? value) {
            setState(() {
              _measurementType = value!;
            });
          },
        ),
        Divider(),
        _measurementForm(),
      ],
    );
  }

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

  MeasurementAmount get height {
    return MeasurementAmount(
      value: double.parse(_heightController.text),
      unit: _heightUnit,
    );
  }

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
                  labelText: 'Height',
                  hintText: '50',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 50),
            VerticalDivider(),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Unit:'),
                DropdownButton<MeasurementUnit>(
                  value: MeasurementUnit.cm,
                  icon: Icon(Icons.arrow_downward_sharp),
                  items: MeasurementUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          child: Text(unit.name),
                          value: unit,
                        ),
                      )
                      .toList(),
                  onChanged: (MeasurementUnit? value) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

  double get ph {
    return double.parse(_phController.text);
  }

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
        decoration: InputDecoration(
          labelText: 'pH',
          hintText: '7.0',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}

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

  double get ec {
    return double.parse(_ecController.text);
  }

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
        decoration: InputDecoration(
          labelText: 'EC',
          hintText: '1.5',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}

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

  double get ppm {
    return double.parse(_ppmController.text);
  }

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
        decoration: InputDecoration(
          labelText: 'PPM',
          hintText: '500',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}

class EnvironmentMeasurementForm extends StatefulWidget {
  final GlobalKey<EnvironmentCO2FormState> environmentCO2FormKey;
  final GlobalKey<EnvironmentHumidityFormState> environmentHumidityFormKey;
  final GlobalKey<EnvironmentLightDistanceFormState> environmentLightDistanceFormKey;
  final GlobalKey<EnvironmentTemperatureFormState> environmentTemperatureFormKey;

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

  EnvironmentMeasurementType get measurementType {
    return _measurementType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<EnvironmentMeasurementType>(
          icon: Icon(Icons.arrow_downward_sharp),
          value: _measurementType,
          isExpanded: true,
          items: EnvironmentMeasurementType.values
              .map(
                (type) => DropdownMenuItem<EnvironmentMeasurementType>(
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 10),
                      Text(type.name),
                    ],
                  ),
                  value: type,
                ),
              )
              .toList(),
          onChanged: (EnvironmentMeasurementType? value) {
            setState(() {
              _measurementType = value!;
            });
          },
        ),
        _environmentActionMeasurementForm(),
      ],
    );
  }

  Widget _environmentActionMeasurementForm() {
    switch (_measurementType) {
      case EnvironmentMeasurementType.temperature:
        return EnvironmentTemperatureForm(
          key: widget.environmentTemperatureFormKey,
        );
      case EnvironmentMeasurementType.humidity:
        return EnvironmentHumidityForm(
          key: widget.environmentHumidityFormKey,
        );
      case EnvironmentMeasurementType.co2:
        return EnvironmentCO2Form(
          key: widget.environmentCO2FormKey,
        );
      case EnvironmentMeasurementType.lightDistance:
        return EnvironmentLightDistanceForm(
          key: widget.environmentLightDistanceFormKey,
        );
    }
  }
}
