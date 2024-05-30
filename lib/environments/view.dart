import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';

class EnvironmentOverview extends StatefulWidget {
  final EnvironmentsProvider environmentsProvider;

  const EnvironmentOverview({super.key, required this.environmentsProvider});

  @override
  State<EnvironmentOverview> createState() => _EnvironmentOverviewState();
}

class _EnvironmentOverviewState extends State<EnvironmentOverview> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Environments>(
      stream: widget.environmentsProvider.environments,
      builder: (context, snapshot) {
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
        return ListView(
          shrinkWrap: true,
          children: environments.environments
              .map(
                (environment) => Card(
                  child: ListTile(
                    title: Text(environment.name),
                    subtitle: Text(environment.description),
                    onTap: () {
                      debugPrint('Navigate to the environment detail view for ${environment.name}');
                    },
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class CreateEnvironmentView extends StatefulWidget {
  final EnvironmentsProvider environmentsProvider;

  const CreateEnvironmentView({super.key, required this.environmentsProvider});

  @override
  State<CreateEnvironmentView> createState() => _CreateEnvironmentViewState();
}

class _CreateEnvironmentViewState extends State<CreateEnvironmentView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _wattController;
  late final TextEditingController _widthController;
  late final TextEditingController _lengthController;
  late final TextEditingController _heightController;

  // The first element is for indoor, the second for outdoor.
  final List<bool> _selectedEnvironmentType = <bool>[true, false];
  double _currentLightHours = 12;
  LightType _currentLightType = LightType.led;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _wattController = TextEditingController();
    _widthController = TextEditingController();
    _lengthController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _wattController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an environment'),
        centerTitle: true,
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
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter the name of the environment',
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
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter a description of the environment',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Choose an environment type: ' +
                    (_selectedEnvironmentType[0] ? 'Indoor' : 'Outdoor')),
                SizedBox(height: 16.0),
                ToggleButtons(
                  isSelected: _selectedEnvironmentType,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _selectedEnvironmentType.length; i++) {
                        _selectedEnvironmentType[i] = i == index;
                      }
                    });
                  },
                  children: const [Icon(Icons.house), Icon(Icons.light_mode_rounded)],
                ),
                SizedBox(height: 16.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Choose the amount of light hours: ${_currentLightHours.round()}'),
                        Row(
                          children: [
                            Icon(Icons.nightlight_round_outlined),
                            Expanded(
                              child: Slider(
                                max: 24,
                                divisions: 24,
                                label: _currentLightHours.round().toString(),
                                value: _currentLightHours,
                                onChanged: (double value) {
                                  setState(() {
                                    _currentLightHours = value;
                                  });
                                },
                              ),
                            ),
                            Icon(Icons.wb_sunny),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedEnvironmentType[0])
                  Column(
                    children: [
                      SizedBox(height: 16.0),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Choose the light details:'),
                              SizedBox(height: 16.0),
                              DropdownButton<LightType>(
                                icon: Icon(Icons.arrow_downward_sharp),
                                isExpanded: true,
                                items: LightType.values
                                    .map(
                                      (e) => DropdownMenuItem<LightType>(
                                        child: Text(e.name),
                                        value: e,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (LightType? value) {
                                  setState(() {
                                    _currentLightType = value!;
                                  });
                                },
                                value: _currentLightType,
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                controller: _wattController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Watt',
                                    hintText: 'Enter the watt of the light',
                                    suffixIcon: Icon(Icons.electrical_services)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Dimension
                      SizedBox(height: 16.0),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Enter the dimension:'),
                              SizedBox(height: 16.0),
                              TextFormField(
                                controller: _widthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Width',
                                  hintText: 'Enter the width of the environment',
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                controller: _lengthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Length',
                                  hintText: 'Enter the length of the environment',
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                  hintText: 'Enter the height of the environment',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                // Submit button
                SizedBox(height: 16.0),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      debugPrint('Create the environment');
                      // Environment parameters differ based on selected environment type.
                      // TODO: Consider using a factory method to create the environment.
                      Environment environment;
                      if (_selectedEnvironmentType[0]) {
                        environment = Environment(
                          id: const Uuid().v4().toString(),
                          name: _nameController.text,
                          description: _descriptionController.text,
                          type: _selectedEnvironmentType[0]
                              ? EnvironmentType.indoor
                              : EnvironmentType.outdoor,
                          lightDetails: LightDetails(
                            lightHours: _currentLightHours.toInt(),
                            lights: [
                              Light(
                                id: const Uuid().v4().toString(),
                                type: _currentLightType,
                                watt: int.parse(_wattController.text),
                              ),
                            ],
                          ),
                          dimension: Dimension(
                            width: double.parse(_widthController.text),
                            length: double.parse(_lengthController.text),
                            height: double.parse(_heightController.text),
                          ),
                        );
                      } else {
                        environment = Environment(
                          id: const Uuid().v4().toString(),
                          name: _nameController.text,
                          description: _descriptionController.text,
                          type: _selectedEnvironmentType[0]
                              ? EnvironmentType.indoor
                              : EnvironmentType.outdoor,
                          lightDetails: LightDetails(
                            lightHours: _currentLightHours.toInt(),
                            lights: [],
                          ),
                          dimension: Dimension(
                            width: 0,
                            length: 0,
                            height: 0,
                          ),
                        );
                      }
                      await widget.environmentsProvider
                          .addEnvironment(environment)
                          .whenComplete(() {
                        Navigator.of(context).pop();
                      });
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
}
