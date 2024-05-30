import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

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

  late Plant _currentPlant;
  late PlantActionType _currentActionType = PlantActionType.watering;
  late TextEditingController _plantActionDescriptionTextController = TextEditingController();
  late TextEditingController _environmentActionDescriptionTextController = TextEditingController();
  DateTime _plantActionDate = DateTime.now();
  DateTime _environmentActionDate = DateTime.now();
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
              _actionForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionForm() {
    if (_choices[0]) {
      // Plant actions
      return SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Choose a plant:'),
                StreamBuilder<Plants>(
                    stream: widget.plantsProvider.plants,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final plants = snapshot.data!;
                      if (plants.plants.isEmpty) {
                        return Center(
                          child: Text('No plants created yet.'),
                        );
                      }
                      _currentPlant = plants.plants.first;
                      return DropdownButton<Plant>(
                        icon: Icon(Icons.arrow_downward_sharp),
                        isExpanded: true,
                        items: plants.plants
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
                      onPressed: () => _selectDate(context),
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
                Divider(),
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
                _actionExtraForm(),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final action = PlantAction(
                        id: const Uuid().v4().toString(),
                        description: _plantActionDescriptionTextController.text,
                        plantId: _currentPlant.id,
                        type: _currentActionType,
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
          ),
        ),
      );
    } else {
      // Environment actions
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Choose an environment:'),
              StreamBuilder<Environments>(
                stream: widget.environmentsProvider.environments,
                builder: (builder, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final environments = snapshot.data!;
                  if (environments.environments.isEmpty) {
                    return Center(
                      child: Text('No environments created yet.'),
                    );
                  }
                  _currentEnvironment = environments.environments.first;
                  return DropdownButton<Environment>(
                    icon: Icon(Icons.arrow_downward_sharp),
                    isExpanded: true,
                    items: environments.environments
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
                    onPressed: () => _selectDate(context),
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
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final action = EnvironmentAction(
                      id: const Uuid().v4().toString(),
                      description: _environmentActionDescriptionTextController.text,
                      environmentId: _currentEnvironment.id,
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
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _plantActionDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _plantActionDate) {
      setState(() {
        _plantActionDate = picked;
      });
    }
  }

  Widget _actionExtraForm() {
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
}
