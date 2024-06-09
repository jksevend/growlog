import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/view.dart';
import 'package:weedy/common/measurement.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/environments/sheet.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

class EnvironmentOverview extends StatefulWidget {
  final EnvironmentsProvider environmentsProvider;
  final PlantsProvider plantsProvider;
  final ActionsProvider actionsProvider;

  const EnvironmentOverview({
    super.key,
    required this.environmentsProvider,
    required this.plantsProvider,
    required this.actionsProvider,
  });

  @override
  State<EnvironmentOverview> createState() => _EnvironmentOverviewState();
}

class _EnvironmentOverviewState extends State<EnvironmentOverview> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list([
        widget.environmentsProvider.environments,
        widget.plantsProvider.plants,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final environments = snapshot.data![0] as Map<String, Environment>;
        final plants = snapshot.data![1] as Map<String, Plant>;
        if (environments.isEmpty) {
          return Center(
            child: Text('No environments created yet.'),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: environments.values.map(
              (environment) {
                final plantsInEnvironment =
                    plants.values.where((plant) => plant.environmentId == environment.id).toList();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Card(
                      child: Column(
                        children: [
                          Image.file(
                            height: constraints.maxWidth / 2,
                            width: constraints.maxWidth,
                            fit: BoxFit.fitWidth,
                            File(environment.bannerImagePath),
                          ),
                          ListTile(
                            leading: Text(
                              environment.type.icon,
                              style: const TextStyle(fontSize: 22.0),
                            ),
                            title: Text(environment.name),
                            subtitle: Text(environment.description),
                            onTap: () async {
                              debugPrint(
                                  'Navigate to the environment detail view for ${environment.name}');
                              await showEnvironmentDetailSheet(
                                  context,
                                  environment,
                                  plantsInEnvironment,
                                  widget.environmentsProvider,
                                  widget.plantsProvider,
                                  widget.actionsProvider);
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.timeline),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EnvironmentActionOverview(
                                      environment: environment,
                                      actionsProvider: widget.actionsProvider,
                                    )));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

class EnvironmentForm extends StatefulWidget {
  final Environment? environment;
  final GlobalKey<FormState> formKey;
  final String title;
  final EnvironmentsProvider environmentsProvider;

  const EnvironmentForm({
    super.key,
    required this.formKey,
    required this.title,
    required this.environmentsProvider,
    this.environment,
  });

  @override
  State<EnvironmentForm> createState() => _EnvironmentFormState();
}

class _EnvironmentFormState extends State<EnvironmentForm> {
  final GlobalKey<PictureFormState> _pictureFormKey = GlobalKey<PictureFormState>();

  final _wattFormKey = GlobalKey<FormState>();
  final _dimensionFormKey = GlobalKey<FormState>();

  final _nameFocus = FocusNode();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _wattController;
  late final TextEditingController _widthController;
  late final TextEditingController _lengthController;
  late final TextEditingController _heightController;

  // The first element is for indoor, the second for outdoor.
  late List<bool> _selectedEnvironmentType;
  late double _currentLightHours;
  late LightType _currentLightType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.environment?.name);
    _descriptionController = TextEditingController(text: widget.environment?.description);
    _wattController = TextEditingController(
        text: widget.environment != null && widget.environment!.lightDetails.lights.isNotEmpty
            ? widget.environment!.lightDetails.lights.first.watt.toString()
            : '0.0');
    _widthController = TextEditingController(
        text: widget.environment != null ? widget.environment!.dimension.width.toString() : '0.0');
    _lengthController = TextEditingController(
        text: widget.environment != null ? widget.environment!.dimension.length.toString() : '0.0');
    _heightController = TextEditingController(
        text: widget.environment != null ? widget.environment!.dimension.height.toString() : '0.0');
    _selectedEnvironmentType = widget.environment == null
        ? [true, false]
        : [
            widget.environment!.type == EnvironmentType.indoor,
            widget.environment!.type == EnvironmentType.outdoor
          ];
    _currentLightHours = widget.environment?.lightDetails.lightHours.toDouble() ?? 12;
    _currentLightType = widget.environment?.lightDetails.lights.first.type ?? LightType.led;
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
        title: Text(widget.title),
        centerTitle: true,
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
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter the name of the environment',
                          ),
                          focusNode: _nameFocus,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              FocusScope.of(context).requestFocus(_nameFocus);
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
                    children: EnvironmentType.values
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(e.icon),
                                SizedBox(width: 8.0),
                                Text(e.name),
                              ],
                            ),
                          ),
                        )
                        .toList()),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Banner image'),
                        PictureForm(
                          key: _pictureFormKey,
                          allowMultiple: false,
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
                              Form(
                                key: _wattFormKey,
                                child: TextFormField(
                                  controller: _wattController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Watt',
                                    hintText: 'Enter the watt of the light',
                                    suffixIcon: Icon(Icons.electrical_services),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a watt';
                                    }
                                    return null;
                                  },
                                ),
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
                          child: Form(
                            key: _dimensionFormKey,
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a width';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _lengthController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Length',
                                    hintText: 'Enter the length of the environment',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a length';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Height',
                                    hintText: 'Enter the height of the environment',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a height';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                // Submit button
                SizedBox(height: 16.0),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (widget.formKey.currentState!.validate()) {
                      Environment environment;
                      if (widget.environment == null) {
                        if (_selectedEnvironmentType[0]) {
                          if (_wattFormKey.currentState!.validate() &&
                              _dimensionFormKey.currentState!.validate()) {
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
                                    watt: double.parse(_wattController.text),
                                  ),
                                ],
                              ),
                              dimension: Dimension(
                                  width: MeasurementAmount(
                                    value: double.parse(_widthController.text),
                                    unit: MeasurementUnit.cm,
                                  ),
                                  length: MeasurementAmount(
                                    value: double.parse(_lengthController.text),
                                    unit: MeasurementUnit.cm,
                                  ),
                                  height: MeasurementAmount(
                                    value: double.parse(_heightController.text),
                                    unit: MeasurementUnit.cm,
                                  )),
                              bannerImagePath: _pictureFormKey.currentState!.images.isEmpty
                                  ? ''
                                  : _pictureFormKey.currentState!.images.first,
                            );
                          } else {
                            return;
                          }
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
                                width: MeasurementAmount(
                                  value: 0,
                                  unit: MeasurementUnit.cm,
                                ),
                                length: MeasurementAmount(
                                  value: 0,
                                  unit: MeasurementUnit.cm,
                                ),
                                height: MeasurementAmount(
                                  value: 0,
                                  unit: MeasurementUnit.cm,
                                )),
                            bannerImagePath: _pictureFormKey.currentState!.images.isEmpty
                                ? ''
                                : _pictureFormKey.currentState!.images.first,
                          );
                        }
                        await widget.environmentsProvider
                            .addEnvironment(environment)
                            .whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      } else {
                        environment = widget.environment!.copyWith(
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
                                watt: double.parse(_wattController.text),
                              ),
                            ],
                          ),
                          dimension: Dimension(
                              width: MeasurementAmount(
                                value: double.parse(_widthController.text),
                                unit: MeasurementUnit.cm,
                              ),
                              length: MeasurementAmount(
                                value: double.parse(_lengthController.text),
                                unit: MeasurementUnit.cm,
                              ),
                              height: MeasurementAmount(
                                value: double.parse(_heightController.text),
                                unit: MeasurementUnit.cm,
                              )),
                          bannerImagePath: _pictureFormKey.currentState!.images.isEmpty
                              ? ''
                              : _pictureFormKey.currentState!.images.first,
                        );
                        await widget.environmentsProvider
                            .updateEnvironment(environment)
                            .whenComplete(() {
                          Navigator.of(context).pop(environment);
                        });
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
}

class CreateEnvironmentView extends StatelessWidget {
  final EnvironmentsProvider environmentsProvider;

  CreateEnvironmentView({super.key, required this.environmentsProvider});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return EnvironmentForm(
      formKey: _formKey,
      title: 'Create environment',
      environment: null,
      environmentsProvider: environmentsProvider,
    );
  }
}

class EditEnvironmentView extends StatelessWidget {
  final Environment environment;
  final EnvironmentsProvider environmentsProvider;

  EditEnvironmentView({super.key, required this.environment, required this.environmentsProvider});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return EnvironmentForm(
      formKey: _formKey,
      title: 'Edit environment ${environment.name}',
      environment: environment,
      environmentsProvider: environmentsProvider,
    );
  }
}
