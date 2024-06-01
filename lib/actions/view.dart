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

  final GlobalKey<_EnvironmentTemperatureFormState> _environmentTemperatureFormKey = GlobalKey();
  final GlobalKey<_EnvironmentHumidityFormState> _environmentHumidityFormKey = GlobalKey();
  final GlobalKey<_EnvironmentLightDistanceFormState> _environmentLightDistanceFormKey =
      GlobalKey();
  final GlobalKey<_EnvironmentCO2FormState> _environmentCO2FormKey = GlobalKey();

  final GlobalKey<_PlantWateringFormState> _plantWateringFormKey = GlobalKey();
  final GlobalKey<_PlantFertilizingFormState> _plantFertilizingFormKey = GlobalKey();
  final GlobalKey<_PlantPruningFormState> _plantPruningFormKey = GlobalKey();
  final GlobalKey<_PlantHarvestingFormState> _plantHarvestingFormKey = GlobalKey();
  final GlobalKey<_PlantTrainingFormState> _plantTrainingFormKey = GlobalKey();
  final GlobalKey<_PlantMeasuringFormState> _plantMeasuringFormKey = GlobalKey();

  final GlobalKey<PlantHeightMeasurementFormState> _plantHeightMeasurementFormKey = GlobalKey();
  final GlobalKey<PlantPHMeasurementFormState> _plantPHMeasurementFormKey = GlobalKey();
  final GlobalKey<PlantECMeasurementFormState> _plantECMeasurementFormKey = GlobalKey();
  final GlobalKey<PlantPPMMeasurementFormState> _plantPPMMeasurementFormKey = GlobalKey();

  late Plant _currentPlant;
  late PlantActionType _currentActionType = PlantActionType.watering;
  late EnvironmentMeasurementType _currentEnvironmentMeasurementType =
      EnvironmentMeasurementType.temperature;
  late TextEditingController _plantActionDescriptionTextController = TextEditingController();
  late TextEditingController _environmentActionDescriptionTextController = TextEditingController();
  final DateTime _plantActionDate = DateTime.now();
  final DateTime _environmentActionDate = DateTime.now();
  late Environment _currentEnvironment;

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
      body: Center(
        child: Padding(
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
                            return Center(
                              child: Text('No plants created yet.'),
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
                    DropdownButton<PlantActionType>(
                      icon: Icon(Icons.arrow_downward_sharp),
                      value: _currentActionType,
                      isExpanded: true,
                      items: PlantActionType.values
                          .map(
                            (action) => DropdownMenuItem<PlantActionType>(
                              child: Row(
                                children: [
                                  action.icon,
                                  const SizedBox(width: 10),
                                  Text(action.name),
                                ],
                              ),
                              value: action,
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
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _plantActionForm(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final PlantAction action;
                  if (_currentActionType == PlantActionType.watering) {
                    final watering = _plantWateringFormKey.currentState!.watering;
                    action = PlantWateringAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: _currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      fertilization: fertilization,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
                      pruningType: pruning,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
                      createdAt: _plantActionDate,
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
                      final height = _plantHeightMeasurementFormKey.currentState!.height;
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: _currentPlant.id,
                        type: _currentActionType,
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
                      final ph = _plantPHMeasurementFormKey.currentState!.ph;
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: _currentPlant.id,
                        type: _currentActionType,
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
                      final ec = _plantECMeasurementFormKey.currentState!.ec;
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: _currentPlant.id,
                        type: _currentActionType,
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
                      final ppm = _plantPPMMeasurementFormKey.currentState!.ppm;
                      action = PlantMeasuringAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: _currentPlant.id,
                        type: _currentActionType,
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
                      throw Exception(
                          'Unknown plant measurement type: $currentPlantMeasurementType');
                    }
                  }

                  if (_currentActionType == PlantActionType.replanting) {
                    action = PlantAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: _currentPlant.id,
                      type: _currentActionType,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
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
                      plantId: _currentPlant.id,
                      type: _currentActionType,
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
                        return Center(
                          child: Text('No environments created yet.'),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                      value: _currentEnvironmentMeasurementType,
                      icon: Icon(Icons.arrow_downward_sharp),
                      items: EnvironmentMeasurementType.values
                          .map(
                            (type) => DropdownMenuItem(
                              child: Row(
                                children: [
                                  type.icon,
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
                          _currentEnvironmentMeasurementType = value!;
                        });
                      },
                    ),
                  ),
                  Divider(),
                  _environmentActionMeasurementForm()
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                EnvironmentMeasurement measurement;

                if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.temperature) {
                  final temperature = _environmentTemperatureFormKey.currentState!.temperature;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: temperature.toJson(),
                  );
                } else if (_currentEnvironmentMeasurementType ==
                    EnvironmentMeasurementType.humidity) {
                  final humidity = _environmentHumidityFormKey.currentState!.humidity;
                  measurement = EnvironmentMeasurement(
                      type: _currentEnvironmentMeasurementType,
                      measurement: Map<String, dynamic>.from({'humidity': humidity}));
                } else if (_currentEnvironmentMeasurementType ==
                    EnvironmentMeasurementType.lightDistance) {
                  final distance = _environmentLightDistanceFormKey.currentState!.distance;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: distance.toJson(),
                  );
                } else if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.co2) {
                  final co2 = _environmentCO2FormKey.currentState!.co2;
                  measurement = EnvironmentMeasurement(
                      type: _currentEnvironmentMeasurementType,
                      measurement: Map<String, dynamic>.from({'co2': co2}));
                } else if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.other) {
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: Map<String, dynamic>.from({}),
                  );
                } else {
                  throw Exception(
                      'Unknown environment measurement type: $_currentEnvironmentMeasurementType');
                }
                final action = EnvironmentAction(
                  id: const Uuid().v4().toString(),
                  description: _environmentActionDescriptionTextController.text,
                  environmentId: _currentEnvironment.id,
                  createdAt: _environmentActionDate,
                  measurement: measurement,
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
          key: _plantWateringFormKey,
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
        return PlantMeasuringForm(
          key: _plantMeasuringFormKey,
          plantMeasuringFormKey: _plantHeightMeasurementFormKey,
          plantPHMeasurementFormKey: _plantPHMeasurementFormKey,
          plantECMeasurementFormKey: _plantECMeasurementFormKey,
          plantPPMMeasurementFormKey: _plantPPMMeasurementFormKey,
        );
      case PlantActionType.death:
      case PlantActionType.other:
        return Container();
    }
  }

  Widget _environmentActionMeasurementForm() {
    switch (_currentEnvironmentMeasurementType) {
      case EnvironmentMeasurementType.temperature:
        return EnvironmentTemperatureForm(
          key: _environmentTemperatureFormKey,
        );
      case EnvironmentMeasurementType.humidity:
        return EnvironmentHumidityForm(
          key: _environmentHumidityFormKey,
        );
      case EnvironmentMeasurementType.co2:
        return EnvironmentCO2Form(
          key: _environmentCO2FormKey,
        );
      case EnvironmentMeasurementType.lightDistance:
        return EnvironmentLightDistanceForm(
          key: _environmentLightDistanceFormKey,
        );
      case EnvironmentMeasurementType.other:
        return Container();
    }
  }
}

class EnvironmentCO2Form extends StatefulWidget {
  const EnvironmentCO2Form({super.key});

  @override
  State<EnvironmentCO2Form> createState() => _EnvironmentCO2FormState();
}

class _EnvironmentCO2FormState extends State<EnvironmentCO2Form> {
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
  State<EnvironmentLightDistanceForm> createState() => _EnvironmentLightDistanceFormState();
}

class _EnvironmentLightDistanceFormState extends State<EnvironmentLightDistanceForm> {
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
    return Row(
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
        SizedBox(width: 10),
        VerticalDivider(),
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
    );
  }
}

class EnvironmentHumidityForm extends StatefulWidget {
  const EnvironmentHumidityForm({super.key});

  @override
  State<EnvironmentHumidityForm> createState() => _EnvironmentHumidityFormState();
}

class _EnvironmentHumidityFormState extends State<EnvironmentHumidityForm> {
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
  State<EnvironmentTemperatureForm> createState() => _EnvironmentTemperatureFormState();
}

class _EnvironmentTemperatureFormState extends State<EnvironmentTemperatureForm> {
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
      height: 100,
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
          SizedBox(width: 10), // Add some space between the text field and the dropdown button
          VerticalDivider(),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
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
            ),
          ),
          SizedBox(width: 10),
          VerticalDivider(),
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
          Row(
            children: [
              Expanded(
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
              SizedBox(width: 10),
              VerticalDivider(),
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
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
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
          SizedBox(width: 10),
          VerticalDivider(),
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

class PlantMeasuringForm extends StatefulWidget {
  final GlobalKey<PlantHeightMeasurementFormState> plantMeasuringFormKey;
  final GlobalKey<PlantECMeasurementFormState> plantECMeasurementFormKey;
  final GlobalKey<PlantPHMeasurementFormState> plantPHMeasurementFormKey;
  final GlobalKey<PlantPPMMeasurementFormState> plantPPMMeasurementFormKey;

  const PlantMeasuringForm({
    super.key,
    required this.plantMeasuringFormKey,
    required this.plantECMeasurementFormKey,
    required this.plantPHMeasurementFormKey,
    required this.plantPPMMeasurementFormKey,
  });

  @override
  State<PlantMeasuringForm> createState() => _PlantMeasuringFormState();
}

class _PlantMeasuringFormState extends State<PlantMeasuringForm> {
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
          value: _measurementType,
          icon: Icon(Icons.arrow_downward_sharp),
          items: PlantMeasurementType.values
              .map(
                (type) => DropdownMenuItem(
                  child: Row(
                    children: [
                      type.icon,
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
          key: widget.plantMeasuringFormKey,
        );
      case PlantMeasurementType.pH:
        return PlantPHMeasurementForm(
          key: widget.plantPHMeasurementFormKey,
        );
      case PlantMeasurementType.ec:
        return PlantECMeasurementForm(
          key: widget.plantECMeasurementFormKey,
        );
      case PlantMeasurementType.ppm:
        return PlantPPMMeasurementForm(
          key: widget.plantPPMMeasurementFormKey,
        );
    }
  }
}

class PlantHeightMeasurementForm extends StatefulWidget {
  const PlantHeightMeasurementForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            ),
          ),
          SizedBox(width: 10),
          VerticalDivider(),
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
    );
  }
}

class PlantPHMeasurementForm extends StatefulWidget {
  const PlantPHMeasurementForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _phController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'pH',
        hintText: '7.0',
      ),
    );
  }
}

class PlantECMeasurementForm extends StatefulWidget {
  const PlantECMeasurementForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ecController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'EC',
        hintText: '1.5',
      ),
    );
  }
}

class PlantPPMMeasurementForm extends StatefulWidget {
  const PlantPPMMeasurementForm({super.key});

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ppmController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'PPM',
        hintText: '500',
      ),
    );
  }
}
