import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:growlog/actions/fertilizer/model.dart';
import 'package:growlog/actions/fertilizer/provider.dart';
import 'package:growlog/actions/model.dart';
import 'package:growlog/actions/provider.dart';
import 'package:growlog/environments/model.dart';
import 'package:growlog/environments/provider.dart';
import 'package:growlog/grow/model.dart';
import 'package:growlog/grow/provider.dart';
import 'package:growlog/plants/model.dart';
import 'package:growlog/plants/provider.dart';
import 'package:growlog/plants/relocation/model.dart';
import 'package:growlog/plants/transition/model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class GrowOverview extends StatelessWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final GrowProvider growProvider;

  const GrowOverview({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.growProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<Grow>>(
        stream: growProvider.grows,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final grows = snapshot.data!;

          if (grows.isEmpty) {
            return const Center(child: Text('No grows found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final grow = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(grow.name),
                  subtitle: Text(grow.formattedDate()),
                  trailing: IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(grow.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan the QR code below on another device to import this grow.',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              FutureBuilder<String>(
                                future: _generateQRCodeData(grow),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  }
                                  return SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: QrImageView(
                                      data: snapshot.data!,
                                      version: QrVersions.auto,
                                      backgroundColor: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _generateQRCodeData(final Grow grow) async {
    // Serialize the data
    String serializedData = jsonEncode(grow.toJson());
    Map<String, dynamic> combinedData = {
      "data": serializedData,
    };
    String combinedDataJson = jsonEncode(combinedData);

    // Compress the combined data
    List<int>? compressedData = GZipEncoder().encode(utf8.encode(combinedDataJson));

    // Encode compressed data to base64
    return base64Encode(compressedData!);
  }
}

class CreateGrowView extends StatelessWidget {
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final GrowProvider growProvider;

  const CreateGrowView({
    super.key,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.growProvider,
  });

  @override
  Widget build(BuildContext context) {
    return GrowForm(
      grow: null,
      formKey: GlobalKey<FormState>(),
      title: 'Create Grow',
      plantsProvider: plantsProvider,
      environmentsProvider: environmentsProvider,
      actionsProvider: actionsProvider,
      fertilizerProvider: fertilizerProvider,
      growProvider: growProvider,
    );
  }
}

class GrowForm extends StatefulWidget {
  final Grow? grow;
  final GlobalKey<FormState> formKey;
  final String title;
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final GrowProvider growProvider;

  const GrowForm({
    super.key,
    required this.grow,
    required this.formKey,
    required this.title,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.growProvider,
  });

  @override
  State<GrowForm> createState() => _GrowFormState();
}

class _GrowFormState extends State<GrowForm> {
  // 1 - plants, 2 - environments, 3 - export settings
  int _currentSelectionTypeIndex = 0;
  static const int steps = 3;

  Plant? _currentPlant;
  bool _includePlantBanner = false;
  final List<Plant> _selectedPlants = [];
  late final TextEditingController _plantSearchStringController;
  final FocusNode _plantSearchFocusNode = FocusNode();
  final GlobalKey _plantSearchKey = GlobalKey();

  Environment? _currentEnvironment;
  bool _includeEnvironmentBanner = false;
  final List<Environment> _selectedEnvironments = [];
  late final TextEditingController _environmentSearchStringController;
  final FocusNode _environmentSearchFocusNode = FocusNode();
  final GlobalKey _environmentSearchKey = GlobalKey();

  bool _includeLifecycleTransitions = true;
  bool _includeRelocations = true;
  bool _includePlantPictureActions = false;
  bool _includeEnvironmentPictureActions = false;
  bool _includeFertilizers = true;

  @override
  void initState() {
    super.initState();
    _plantSearchStringController = TextEditingController();
    _environmentSearchStringController = TextEditingController();
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
        child: StreamBuilder<List<dynamic>>(
            stream: CombineLatestStream.list([
              widget.plantsProvider.transitions,
              widget.plantsProvider.relocations,
              widget.actionsProvider.plantActions,
              widget.actionsProvider.environmentActions,
              widget.fertilizerProvider.fertilizers,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final transitions = snapshot.data![0] as List<PlantLifecycleTransition>;
              final relocations = snapshot.data![1] as List<PlantRelocation>;
              final plantActions = snapshot.data![2] as List<PlantAction>;
              final environmentActions = snapshot.data![3] as List<EnvironmentAction>;
              final fertilizers = snapshot.data![4] as Map<String, Fertilizer>;

              return SingleChildScrollView(
                child: Form(
                  key: widget.formKey,
                  child: Stepper(
                    currentStep: _currentSelectionTypeIndex,
                    onStepCancel: () {
                      if (_currentSelectionTypeIndex > 0) {
                        setState(() {
                          _currentSelectionTypeIndex -= 1;
                        });
                      }
                    },
                    onStepContinue: () async {
                      if (_currentSelectionTypeIndex == steps - 1) {
                        final relevantPlants = _selectedPlants;
                        final relevantEnvironments = _selectedEnvironments;
                        final List<PlantLifecycleTransition> relevantTransitions =
                            _includeLifecycleTransitions ? transitions : [];
                        final List<PlantRelocation> relevantRelocations =
                            _includeRelocations ? relocations : [];

                        var relevantPlantActions = plantActions.where((PlantAction action) {
                          return _includePlantPictureActions ? true : action is! PlantPictureAction;
                        }).toList();
                        relevantPlantActions = relevantPlantActions.where((PlantAction action) {
                          return _includeFertilizers ? true : action is! PlantFertilizingAction;
                        }).toList();

                        final relevantEnvironmentActions =
                            environmentActions.where((EnvironmentAction action) {
                          return _includeEnvironmentPictureActions
                              ? true
                              : action is! EnvironmentPictureAction;
                        }).toList();

                        final relevantFertilizers = fertilizers.values.toList();

                        final grow = Grow(
                          id: const Uuid().v4().toString(),
                          name: 'Main grow',
                          plants: relevantPlants,
                          environments: relevantEnvironments,
                          plantActions: relevantPlantActions,
                          environmentActions: relevantEnvironmentActions,
                          plantLifecycleTransitions: relevantTransitions,
                          plantRelocations: relevantRelocations,
                          fertilizers: relevantFertilizers,
                          createdAt: DateTime.now(),
                        );
                        await widget.growProvider
                            .addGrow(grow)
                            .whenComplete(() => Navigator.of(context).pop());
                      } else {
                        if (_currentSelectionTypeIndex < steps - 1) {
                          setState(() {
                            _currentSelectionTypeIndex += 1;
                          });
                        }
                      }
                    },
                    onStepTapped: (int index) {
                      setState(() {
                        _currentSelectionTypeIndex = index;
                      });
                    },
                    steps: <Step>[
                      Step(
                        title: Row(
                          children: [
                            Icon(Icons.eco, color: Colors.green[900]),
                            SizedBox(width: 8),
                            Text('Plants'),
                          ],
                        ),
                        content: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StreamBuilder<Map<String, Plant>>(
                                        stream: widget.plantsProvider.plants,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator());
                                          }

                                          if (snapshot.hasError) {
                                            return Center(child: Text('Error: ${snapshot.error}'));
                                          }
                                          return RawAutocomplete<Plant>(
                                            key: _plantSearchKey,
                                            focusNode: _plantSearchFocusNode,
                                            textEditingController: _plantSearchStringController,
                                            optionsBuilder: (TextEditingValue textEditingValue) {
                                              return snapshot.data!.values.where((Plant option) {
                                                return option.name
                                                    .toLowerCase()
                                                    .contains(textEditingValue.text.toLowerCase());
                                              });
                                            },
                                            onSelected: (Plant plant) {
                                              setState(() {
                                                _currentPlant = plant;
                                                if (!_selectedPlants.contains(plant)) {
                                                  _selectedPlants.add(plant);
                                                }
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext context,
                                                TextEditingController textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller: textEditingController,
                                                focusNode: focusNode,
                                                decoration: const InputDecoration(
                                                  labelText: 'Plant',
                                                ),
                                              );
                                            },
                                            displayStringForOption: (Plant option) => option.name,
                                            optionsViewBuilder: (BuildContext context,
                                                void Function(Plant) onSelected,
                                                Iterable<Plant> options) {
                                              return Material(
                                                elevation: 4.0,
                                                child: ListView(
                                                  children: options
                                                      .map(
                                                        (Plant option) => GestureDetector(
                                                          onTap: () {
                                                            onSelected(option);
                                                          },
                                                          child: ListTile(
                                                            title: Text(option.name),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                  ),
                                  if (_currentPlant != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _currentPlant = null;
                                          _plantSearchStringController.clear();
                                        });
                                      },
                                    ),
                                ],
                              ),
                              ..._selectedPlants.map((Plant plant) {
                                return ListTile(
                                  title: Text(plant.name),
                                  leading: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _selectedPlants.remove(plant);
                                      });
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: const Text('Include plant banner'),
                                value: _includePlantBanner,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includePlantBanner = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.yellow[900]),
                            SizedBox(width: 8),
                            Text('Environments'),
                          ],
                        ),
                        content: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StreamBuilder<Map<String, Environment>>(
                                        stream: widget.environmentsProvider.environments,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator());
                                          }

                                          if (snapshot.hasError) {
                                            return Center(child: Text('Error: ${snapshot.error}'));
                                          }
                                          return RawAutocomplete<Environment>(
                                            key: _environmentSearchKey,
                                            focusNode: _environmentSearchFocusNode,
                                            textEditingController:
                                                _environmentSearchStringController,
                                            optionsBuilder: (TextEditingValue textEditingValue) {
                                              return snapshot.data!.values
                                                  .where((Environment option) {
                                                return option.name
                                                    .toLowerCase()
                                                    .contains(textEditingValue.text.toLowerCase());
                                              });
                                            },
                                            onSelected: (Environment environment) {
                                              setState(() {
                                                _currentEnvironment = environment;
                                                if (!_selectedEnvironments.contains(environment)) {
                                                  _selectedEnvironments.add(environment);
                                                }
                                              });
                                            },
                                            fieldViewBuilder: (BuildContext context,
                                                TextEditingController textEditingController,
                                                FocusNode focusNode,
                                                VoidCallback onFieldSubmitted) {
                                              return TextFormField(
                                                controller: textEditingController,
                                                focusNode: focusNode,
                                                decoration: const InputDecoration(
                                                  labelText: 'Environment',
                                                ),
                                              );
                                            },
                                            displayStringForOption: (Environment option) =>
                                                option.name,
                                            optionsViewBuilder: (BuildContext context,
                                                void Function(Environment) onSelected,
                                                Iterable<Environment> options) {
                                              return Material(
                                                elevation: 4.0,
                                                child: ListView(
                                                  children: options
                                                      .map(
                                                        (Environment option) => GestureDetector(
                                                          onTap: () {
                                                            onSelected(option);
                                                          },
                                                          child: ListTile(
                                                            title: Text(option.name),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                  ),
                                  if (_currentEnvironment != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _currentEnvironment = null;
                                          _environmentSearchStringController.clear();
                                        });
                                      },
                                    ),
                                ],
                              ),
                              ..._selectedEnvironments.map((Environment environment) {
                                return ListTile(
                                  title: Text(environment.name),
                                  leading: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _selectedEnvironments.remove(environment);
                                      });
                                    },
                                  ),
                                );
                              }),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: const Text('Include environment banner'),
                                value: _includeEnvironmentBanner,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includeEnvironmentBanner = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Step(
                        title: Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            SizedBox(width: 8),
                            Text('Options'),
                          ],
                        ),
                        content: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'General',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              CheckboxListTile(
                                title: const Text('Include lifecycle transitions'),
                                value: _includeLifecycleTransitions,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includeLifecycleTransitions = value!;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Include relocations'),
                                value: _includeRelocations,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includeRelocations = value!;
                                  });
                                },
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Actions',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              CheckboxListTile(
                                title: const Text('Include plant picture actions'),
                                value: _includePlantPictureActions,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includePlantPictureActions = value!;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Include environment picture actions'),
                                value: _includeEnvironmentPictureActions,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includeEnvironmentPictureActions = value!;
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: const Text('Include fertilizers'),
                                value: _includeFertilizers,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _includeFertilizers = value!;
                                  });
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _includeLifecycleTransitions = true;
                                      _includeRelocations = true;
                                      _includePlantPictureActions = false;
                                      _includeEnvironmentPictureActions = false;
                                      _includeFertilizers = true;
                                    });
                                  },
                                  label: Text('Reset options'),
                                  icon: Icon(Icons.refresh),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
