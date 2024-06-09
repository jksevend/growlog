import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
            return const Center(
              child: Text('No environment actions created yet.'),
            );
          }

          final specificEnvironmentActions =
              environmentActions.where((action) => action.environmentId == environment.id).toList();

          if (specificEnvironmentActions.isEmpty) {
            return const Center(
              child: Text('No actions for this environment.'),
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
                  return EnvironmentActionLogItem(
                    actionsProvider: actionsProvider,
                    environment: environment,
                    action: action,
                    isFirst: index == 0,
                    isLast: index == specificEnvironmentActions.length - 1,
                  );
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
            return const Center(
              child: Text('No plant actions created yet.'),
            );
          }

          final specificPlantActions =
              plantActions.where((action) => action.plantId == widget.plant.id).toList();

          if (specificPlantActions.isEmpty) {
            return const Center(
              child: Text('No actions for this plant.'),
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

  final GlobalKey<EnvironmentTemperatureFormState> _environmentTemperatureWidgetKey = GlobalKey();
  final GlobalKey<EnvironmentHumidityFormState> _environmentHumidityWidgetKey = GlobalKey();
  final GlobalKey<EnvironmentLightDistanceFormState> _environmentLightDistanceWidgetKey =
      GlobalKey();
  final GlobalKey<EnvironmentCO2FormState> _environmentCO2WidgetKey = GlobalKey();

  final GlobalKey<_PlantWateringFormState> _plantWateringWidgetKey = GlobalKey();

  final GlobalKey<_PlantFertilizingFormState> _plantFertilizingFormKey = GlobalKey();
  final GlobalKey<_PlantPruningFormState> _plantPruningFormKey = GlobalKey();
  final GlobalKey<_PlantHarvestingFormState> _plantHarvestingFormKey = GlobalKey();
  final GlobalKey<_PlantTrainingFormState> _plantTrainingFormKey = GlobalKey();
  final GlobalKey<_PlantMeasurementFormState> _plantMeasuringFormKey = GlobalKey();
  final GlobalKey<PictureFormState> _plantPictureFormState = GlobalKey();
  final GlobalKey<PictureFormState> _environmentPictureFormState = GlobalKey();

  final GlobalKey<PlantHeightMeasurementFormState> _plantHeightMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPHMeasurementFormState> _plantPHMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantECMeasurementFormState> _plantECMeasurementWidgetKey = GlobalKey();
  final GlobalKey<PlantPPMMeasurementFormState> _plantPPMMeasurementWidgetKey = GlobalKey();
  final GlobalKey<_EnvironmentMeasurementFormState> _environmentMeasurementWidgetKey = GlobalKey();

  Plant? _currentPlant;
  late PlantActionType _currentPlantActionType = PlantActionType.watering;
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
                        const Text('What do you want to do?'),
                        const SizedBox(height: 10),
                        ToggleButtons(
                          constraints: const BoxConstraints(minWidth: 100),
                          isSelected: _choices,
                          onPressed: (int index) {
                            setState(() {
                              // The button that is tapped is set to true, and the others to false.
                              for (int i = 0; i < _choices.length; i++) {
                                _choices[i] = i == index;
                              }
                            });
                          },
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.eco,
                                  size: 50,
                                  color: Colors.green[900],
                                ),
                                const Text('Plant')
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  size: 50,
                                  color: Colors.yellow[900],
                                ),
                                const Text('Environment')
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
                    const Text('Choose a plant:'),
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
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text('No plants created yet.'),
                              ),
                            );
                          }
                          _currentPlant = plants[plants.keys.first]!;
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
                        const Icon(Icons.calendar_month),
                        const Text('Select date: '),
                        TextButton(
                          onPressed: () => _selectDate(context, _plantActionDate),
                          child: Text(
                            '${_plantActionDate.toLocal()}'.split(' ')[0],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _plantActionDescriptionTextController,
                      maxLines: null,
                      minLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a description of the plant',
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
                          onChanged: (PlantActionType? value) {
                            setState(() {
                              _currentPlantActionType = value!;
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
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (_currentPlant == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                    final hasFertilizer = _plantFertilizingFormKey.currentState!.hasFertilizers;
                    if (!hasFertilizer) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
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
                                'Add fertilizers before saving the action',
                              ),
                            ],
                          ),
                          duration: Duration(seconds: 3),
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
                    final pruning = _plantPruningFormKey.currentState!.pruning;
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
                    final training = _plantTrainingFormKey.currentState!.training;
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

                  if (_currentPlantActionType == PlantActionType.measuring) {
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
                      action = PlantMeasuringAction(
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
                      action = PlantMeasuringAction(
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
                      action = PlantMeasuringAction(
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
                      throw Exception(
                          'Unknown plant measurement type: $currentPlantMeasurementType');
                    }
                  }

                  if (_currentPlantActionType == PlantActionType.picture) {
                    final action = PlantPictureAction(
                      id: const Uuid().v4().toString(),
                      description: _plantActionDescriptionTextController.text,
                      plantId: currentPlant.id,
                      type: _currentPlantActionType,
                      createdAt: _plantActionDate,
                      images: _plantPictureFormState.currentState!.images,
                    );
                    await widget.actionsProvider
                        .addPlantAction(action)
                        .whenComplete(() => Navigator.of(context).pop());
                    return;
                  }

                  if (_currentPlantActionType == PlantActionType.replanting) {
                    action = PlantAction(
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
                    action = PlantAction(
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
                    action = PlantAction(
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
                },
                label: const Text('Save'),
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
                  const Text('Choose an environment:'),
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
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('No environments created yet.'),
                          ),
                        );
                      }
                      _currentEnvironment = environments[environments.keys.first]!;
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
                      const Icon(Icons.calendar_month),
                      const Text('Select date: '),
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
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter a description of the plant',
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
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                if (_currentEnvironment == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
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
                    final isValid = _environmentTemperatureWidgetKey.currentState!.isValid;
                    if (!isValid) {
                      return;
                    }
                    final temperature = _environmentTemperatureWidgetKey.currentState!.temperature;
                    measurement = EnvironmentMeasurement(
                      type: currentEnvironmentMeasurementType,
                      measurement: temperature.toJson(),
                    );
                  } else if (currentEnvironmentMeasurementType ==
                      EnvironmentMeasurementType.humidity) {
                    final isValid = _environmentHumidityWidgetKey.currentState!.isValid;
                    if (!isValid) {
                      return;
                    }
                    final humidity = _environmentHumidityWidgetKey.currentState!.humidity;
                    measurement = EnvironmentMeasurement(
                        type: currentEnvironmentMeasurementType,
                        measurement: Map<String, dynamic>.from({'humidity': humidity}));
                  } else if (currentEnvironmentMeasurementType ==
                      EnvironmentMeasurementType.lightDistance) {
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
                    throw Exception(
                        'Unknown environment measurement type: $currentEnvironmentMeasurementType');
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
                  final action = EnvironmentPictureAction(
                    id: const Uuid().v4().toString(),
                    description: _environmentActionDescriptionTextController.text,
                    environmentId: currentEnvironment.id,
                    type: _currentEnvironmentActionType,
                    createdAt: _environmentActionDate,
                    images: _environmentPictureFormState.currentState!.images,
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
              },
              label: const Text('Save'),
              icon: const Icon(Icons.save),
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
          environmentTemperatureFormKey: _environmentTemperatureWidgetKey,
          environmentHumidityFormKey: _environmentHumidityWidgetKey,
          environmentLightDistanceFormKey: _environmentLightDistanceWidgetKey,
          environmentCO2FormKey: _environmentCO2WidgetKey,
        );
      case EnvironmentActionType.picture:
        return PictureForm(
          key: _environmentPictureFormState,
          allowMultiple: true,
        );
      case EnvironmentActionType.other:
        return Container();
    }
  }
}

class EnvironmentCO2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentCO2Form({super.key, required this.formKey});

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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          // Check if it is a double
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}

class EnvironmentLightDistanceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentLightDistanceForm({super.key, required this.formKey});

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
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.highlight_rounded),
                  labelText: 'Distance',
                  hintText: '50',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  // Check if it is a double
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
      ),
    );
  }
}

class EnvironmentHumidityForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentHumidityForm({super.key, required this.formKey});

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
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.water_damage),
            labelText: 'Humidity',
            hintText: '50',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            // Check if it is a double
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class EnvironmentTemperatureForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const EnvironmentTemperatureForm({super.key, required this.formKey});

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
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.thermostat),
                  labelText: 'Temperature',
                  hintText: '25',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  // Check if it is a double
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
      ),
    );
  }
}

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

  LiquidAmount get watering {
    return LiquidAmount(
      unit: _waterAmountUnit,
      amount: double.parse(_waterAmountController.text),
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
        width: double.infinity,
        height: 75,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextFormField(
                controller: _waterAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
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

  bool get isValid {
    return widget.formKey.currentState!.validate();
  }

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
                      const Text('No fertilizers created yet.'),
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
                        onChanged: (Fertilizer? value) {
                          setState(() {
                            _currentFertilizer = value!;
                          });
                        },
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
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.eco),
                        labelText: 'Amount',
                        hintText: '50',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        // Check if it is a double
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
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
      ),
    );
  }

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
      icon: const Icon(Icons.arrow_downward_sharp),
      items: PruningType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
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

  WeightAmount get harvest {
    return WeightAmount(
      unit: _weightUnit,
      amount: double.parse(_harvestAmountController.text),
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
            Flexible(
              child: TextFormField(
                controller: _harvestAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.eco),
                  labelText: 'Amount',
                  hintText: '50',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  // Check if it is a double
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
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
      icon: const Icon(Icons.arrow_downward_sharp),
      items: TrainingType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(type.name),
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
          onChanged: (PlantMeasurementType? value) {
            setState(() {
              _measurementType = value!;
            });
          },
        ),
        const Divider(),
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
                decoration: const InputDecoration(
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
        decoration: const InputDecoration(
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
        decoration: const InputDecoration(
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
        decoration: const InputDecoration(
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

class PictureForm extends StatefulWidget {
  final bool allowMultiple;
  const PictureForm({
    super.key,
    required this.allowMultiple,
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
    _images = [];
  }

  List<String> get images {
    return _images.isEmpty ? [] : _images.map((e) => e.path).toList();
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
                        ? const Text('No images selected')
                        : const Text('No image selected'),
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
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
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
                  title: const Text('Take one with camera'),
                  onTap: () async {
                    final file = await getImage(ImageSource.camera);
                    if (!context.mounted) return;
                    Navigator.of(context).pop(file);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Select from gallery'),
                  onTap: () async {
                    final file = await getImage(ImageSource.gallery);
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

  Future<File> getImage(final ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) throw Exception('No image picked');
    return File(pickedFile.path);
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
