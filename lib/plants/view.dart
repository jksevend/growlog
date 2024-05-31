import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/view.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';
import 'package:weedy/plants/sheet.dart';

class PlantOverview extends StatelessWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final GlobalKey<State<BottomNavigationBar>> bottomNavigationKey;

  const PlantOverview({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.bottomNavigationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
          stream: CombineLatestStream.list([
            plantsProvider.plants,
            environmentsProvider.environments,
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final plants = snapshot.data![0] as Map<String, Plant>;
            final environments = snapshot.data![1] as Map<String, Environment>;
            if (plants.isEmpty) {
              return Center(
                child: Text('No plants found'),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: plants.values.map(
                (plant) {
                  final environment = environments[plant.environmentId];
                  final plantsInEnvironment =
                      plants.values.where((p) => p.environmentId == environment?.id).toList();
                  return Card(
                    child: ListTile(
                      leading: _plantLifeCycleIcon(plant.lifeCycleState),
                      title: Text(plant.name),
                      subtitle: Text(plant.description),
                      onTap: () async {
                        debugPrint('Navigate to the plant detail view for ${plant.name}');
                        await showPlantDetailSheet(
                            context,
                            plant,
                            plantsInEnvironment,
                            environment,
                            plantsProvider,
                            actionsProvider,
                            environmentsProvider,
                            bottomNavigationKey);
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.view_timeline),
                        onPressed: () {
                          debugPrint('Navigate to the plant timeline view for ${plant.name}');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PlantActionOverview(
                                    plant: plant,
                                    actionsProvider: actionsProvider,
                                  )));
                        },
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          }),
    );
  }

  Icon _plantLifeCycleIcon(LifeCycleState lifeCycleState) {
    switch (lifeCycleState) {
      case LifeCycleState.germination:
        return const Icon(Icons.spa, color: Colors.brown);
      case LifeCycleState.seedling:
        return Icon(Icons.grass, color: Colors.green[900]);
      case LifeCycleState.vegetative:
        return Icon(Icons.nature, color: Colors.green[700]);
      case LifeCycleState.flowering:
        return Icon(Icons.local_florist, color: Colors.green[200]);
      case LifeCycleState.drying:
        return Icon(Icons.hourglass_empty, color: Colors.orange[600]);
      case LifeCycleState.curing:
        return Icon(Icons.check_circle_outline, color: Colors.red[600]);
    }
  }
}

class PlantForm extends StatefulWidget {
  final Plant? plant;
  final GlobalKey<FormState> formKey;
  final String title;
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;

  const PlantForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.plant,
    required this.plantsProvider,
    required this.environmentsProvider,
  });

  @override
  State<PlantForm> createState() => _PlantFormState();
}

class _PlantFormState extends State<PlantForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late List<bool> _selectedLifeCycleState;
  Environment? _currentEnvironment;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.plant?.name);
    _descriptionController = TextEditingController(text: widget.plant?.description);
    _selectedLifeCycleState = _selectedLifeCycleStateFromPlant(widget.plant);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Plant details'),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter the name of the plant',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _descriptionController,
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
                        Text('Select an environment'),
                        StreamBuilder<Map<String, Environment>>(
                            stream: widget.environmentsProvider.environments,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }

                              final environments = snapshot.data!;
                              if (environments.isEmpty) {
                                return Center(
                                  child: Text('No environments found'),
                                );
                              }
                              _currentEnvironment = environments[environments.keys.first]!;
                              return DropdownButton<Environment>(
                                icon: Icon(Icons.arrow_downward_sharp),
                                isExpanded: true,
                                items: environments.values
                                    .map(
                                      (environment) => DropdownMenuItem<Environment>(
                                        child: Text(environment.name),
                                        value: environment,
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
                            }),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Current lifecycle state'),
                          SizedBox(height: 8.0),
                          ToggleButtons(
                            isSelected: _selectedLifeCycleState,
                            onPressed: (index) {
                              setState(() {
                                for (var i = 0; i <= index; i++) {
                                  _selectedLifeCycleState[i] = true;
                                }
                                for (var i = index + 1; i < _selectedLifeCycleState.length; i++) {
                                  _selectedLifeCycleState[i] = false;
                                }
                              });
                            },
                            children: [
                              Icon(Icons.spa, color: Colors.brown),
                              Icon(Icons.grass, color: Colors.green[900]),
                              Icon(Icons.nature, color: Colors.green[700]),
                              Icon(Icons.local_florist, color: Colors.green[200]),
                              Icon(Icons.hourglass_empty, color: Colors.orange[600]),
                              Icon(Icons.check_circle_outline, color: Colors.red[600]),
                            ],
                          ),
                          Divider(),
                          Text(_lifeCycleState.name),
                        ],
                      ),
                    ),
                  ),
                ),

                // Submit button
                SizedBox(height: 16.0),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (widget.formKey.currentState!.validate()) {
                      if (_currentEnvironment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an environment'),
                          ),
                        );
                        return;
                      } else {
                        Plant plant;
                        if (widget.plant != null) {
                          plant = Plant(
                            id: widget.plant!.id,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            environmentId: _currentEnvironment!.id,
                            lifeCycleState: _lifeCycleState,
                          );
                          await widget.plantsProvider
                              .updatePlant(plant)
                              .whenComplete(() => Navigator.of(context).pop(plant));
                        } else {
                          plant = Plant(
                            id: const Uuid().v4().toString(),
                            name: _nameController.text,
                            description: _descriptionController.text,
                            environmentId: _currentEnvironment!.id,
                            lifeCycleState: _lifeCycleState,
                          );
                          await widget.plantsProvider
                              .addPlant(plant)
                              .whenComplete(() => Navigator.of(context).pop());
                        }
                      }
                    }
                  },
                  label: Text('Save'),
                  icon: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LifeCycleState get _lifeCycleState {
    final lastIndex = _selectedLifeCycleState.lastIndexOf(true);
    switch (lastIndex) {
      case 0:
        return LifeCycleState.germination;
      case 1:
        return LifeCycleState.seedling;
      case 2:
        return LifeCycleState.vegetative;
      case 3:
        return LifeCycleState.flowering;
      case 4:
        return LifeCycleState.drying;
      case 5:
        return LifeCycleState.curing;
      default:
        return LifeCycleState.germination;
    }
  }

  List<bool> _selectedLifeCycleStateFromPlant(Plant? plant) {
    if (plant == null) {
      return <bool>[true, false, false, false, false, false];
    }
    switch (plant.lifeCycleState) {
      case LifeCycleState.germination:
        return <bool>[true, false, false, false, false, false];
      case LifeCycleState.seedling:
        return <bool>[true, true, false, false, false, false];
      case LifeCycleState.vegetative:
        return <bool>[true, true, true, false, false, false];
      case LifeCycleState.flowering:
        return <bool>[true, true, true, true, false, false];
      case LifeCycleState.drying:
        return <bool>[true, true, true, true, true, false];
      case LifeCycleState.curing:
        return <bool>[true, true, true, true, true, true];
    }
  }
}

class CreatePlantView extends StatelessWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;

  CreatePlantView({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
  });

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return PlantForm(
      formKey: _formKey,
      title: 'Create plant',
      plant: null,
      plantsProvider: plantsProvider,
      environmentsProvider: environmentsProvider,
    );
  }
}

class EditPlantView extends StatelessWidget {
  final Plant plant;
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;

  EditPlantView({
    super.key,
    required this.plant,
    required this.plantsProvider,
    required this.environmentsProvider,
  });

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return PlantForm(
      formKey: _formKey,
      title: 'Edit ${plant.name}',
      plant: plant,
      plantsProvider: plantsProvider,
      environmentsProvider: environmentsProvider,
    );
  }
}
