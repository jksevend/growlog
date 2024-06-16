import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/model.dart';

/// A provider class that manages the plants.
///
/// The plants are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [plants] and changed via [_setPlants]
/// which will also update the JSON file on the device's file system.
class PlantsProvider with ChangeNotifier {
  /// The name of the JSON file that holds the plants.
  static const String _fileName = 'plants.json';

  /// The standard plants that are used if the JSON file does not exist.
  static final Plants _standardPlants = Plants.standard();

  /// A stream controller that holds the current plants.
  final BehaviorSubject<Map<String, Plant>> _plantsMap = BehaviorSubject();

  /// A getter that returns the current plants as a stream.
  Stream<Map<String, Plant>> get plants => _plantsMap.stream;

  /// The plants that are currently stored in the provider.
  late Plants _plants;

  /// Initializes the plants provider by reading the JSON file from the device's file system.
  PlantsProvider() {
    _initialize();
  }

  /// Reads the JSON file from the device's file system and initializes the plants provider.
  void _initialize() async {
    final plantsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardPlants.toJson()),
    );
    _plants = Plants.fromJson(plantsJson);
    await _setPlants(_plants);
  }

  /// Sets the current plants to [plants] and updates the JSON file on the device's file system.
  Future<void> _setPlants(Plants plants) async {
    _plants.plants = plants.plants;
    await writeJsonFile(name: _fileName, content: plants.toJson());
    final map = plants.plants.asMap().map((index, plant) => MapEntry(plant.id, plant));
    _plantsMap.sink.add(map);
  }

  /// Adds a new [plant] to the provider.
  Future<void> addPlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await _setPlants(Plants(plants: plants.values.toList()));
  }

  /// Removes the [plant] from the provider.
  Future<void> removePlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants.remove(plant.id);
    await _setPlants(Plants(plants: plants.values.toList()));
  }

  /// Removes all plants in the environment with the given [environmentId].
  Future<void> removePlantsInEnvironment(String environmentId) async {
    final plants = await _plantsMap.first;
    final plantsToRemove =
        plants.values.where((plant) => plant.environmentId == environmentId).toList();
    for (final plant in plantsToRemove) {
      plant.environmentId = '';
    }
    await _setPlants(Plants(plants: plants.values.toList()));
  }

  /// Updates the [plant] in the provider.
  Future<void> updatePlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await _setPlants(Plants(plants: plants.values.toList()));
  }
}
