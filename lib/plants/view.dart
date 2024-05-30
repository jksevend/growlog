import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

class PlantOverview extends StatelessWidget {
  final PlantsProvider plantsProvider;

  const PlantOverview({super.key, required this.plantsProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<Plants>(
          stream: plantsProvider.plants,
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
                child: Text('No plants found'),
              );
            }
            return ListView(
              shrinkWrap: true,
              children: plants.plants
                  .map(
                    (plant) => Card(
                  child: ListTile(
                    title: Text(plant.name),
                    subtitle: Text(plant.description),
                    onTap: () {
                      debugPrint('Navigate to the plant detail view for ${plant.name}');
                    },
                  ),
                ),
              )
                  .toList(),
            );
          }),
    );
  }
}

class CreatePlantView extends StatefulWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;

  const CreatePlantView({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
  });

  @override
  State<CreatePlantView> createState() => _CreatePlantViewState();
}

class _CreatePlantViewState extends State<CreatePlantView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final List<bool> _selectedLifeCycleState = <bool>[true, false, false, false, false, false];

  late Environment _currentEnvironment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
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
        title: const Text('Create a Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                        StreamBuilder<Environments>(
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
                              if (environments.environments.isEmpty) {
                                return Center(
                                  child: Text('No environments found'),
                                );
                              }
                              _currentEnvironment = environments.environments.first;
                              return DropdownButton<Environment>(
                                icon: Icon(Icons.arrow_downward_sharp),
                                isExpanded: true,
                                items: environments.environments
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
                              Icon(Icons.spa),
                              Icon(Icons.grass),
                              Icon(Icons.nature),
                              Icon(Icons.local_florist),
                              Icon(Icons.hourglass_empty),
                              Icon(Icons.check_circle_outline),
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
                    if (_formKey.currentState!.validate()) {
                      final plant = Plant(
                        id: const Uuid().v4().toString(),
                        name: _nameController.text,
                        description: _descriptionController.text,
                        environmentId: _currentEnvironment.id,
                        lifeCycleState: _lifeCycleState,
                      );
                      await widget.plantsProvider
                          .addPlant(plant)
                          .whenComplete(() => Navigator.of(context).pop());
                    }
                  },
                  label: Text('Create'),
                  icon: Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the current lifecycle state based on the selected icons
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
}
