import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/widget.dart';
import 'package:weedy/common/distance.dart';
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

              final specificEnvironmentActions = environmentActions
                  .where((action) => action.environmentId == environment.id)
                  .toList();

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
            }));
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

  const ChooseActionView({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
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
                    _plantActionExtraForm(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final action = PlantAction(
                    id: const Uuid().v4().toString(),
                    description: _plantActionDescriptionTextController.text,
                    plantId: _currentPlant.id,
                    type: _currentActionType,
                    measurement: null,
                    createdAt: _plantActionDate,
                  );
                  await widget.actionsProvider
                      .addPlantAction(action)
                      .whenComplete(() => Navigator.of(context).pop());
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
                EnvironmentMeasurement? measurement;

                if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.temperature) {
                  final temperature = _environmentTemperatureFormKey.currentState!.temperature;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: temperature.toJson(),
                  );
                }
                if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.humidity) {
                  final humidity = _environmentHumidityFormKey.currentState!.humidity;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: Map<String, dynamic>.from({'humidity': humidity})
                  );
                }
                if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.lightDistance) {
                  final distance = _environmentLightDistanceFormKey.currentState!.distance;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: distance.toJson(),
                  );
                }
                if (_currentEnvironmentMeasurementType == EnvironmentMeasurementType.co2) {
                  final co2 = _environmentCO2FormKey.currentState!.co2;
                  measurement = EnvironmentMeasurement(
                    type: _currentEnvironmentMeasurementType,
                    measurement: Map<String, dynamic>.from({'co2': co2})
                  );
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

  Widget _plantActionExtraForm() {
    switch (_currentActionType) {
      case PlantActionType.watering:
      case PlantActionType.fertilizing:
      case PlantActionType.pruning:
      case PlantActionType.replanting:
      case PlantActionType.training:
      case PlantActionType.harvesting:
      case PlantActionType.measuring:
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
  late DistanceUnit _distanceUnit;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController();
    _distanceUnit = DistanceUnit.cm;
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  Distance get distance {
    return Distance(
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
            DropdownButton<DistanceUnit>(
              value: _distanceUnit,
              icon: Icon(Icons.arrow_downward_sharp),
              items: DistanceUnit.values
                  .map(
                    (unit) => DropdownMenuItem(
                      child: Text(unit.name),
                      value: unit,
                    ),
                  )
                  .toList(),
              onChanged: (DistanceUnit? value) {
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
