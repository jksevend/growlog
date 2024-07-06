import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/relocation/model.dart';

/// A provider class that manages the plants.
///
/// The plants are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [plants] and changed via [_setPlants]
/// which will also update the JSON file on the device's file system.
class PlantsProvider with ChangeNotifier {
  /// The name of the JSON file that holds the plants.
  static const String _plantsFileName = 'plants.txt';

  /// The standard plants that are used if the JSON file does not exist.
  static final Plants _standardPlants = Plants.standard();

  /// A stream controller that holds the current plants.
  final BehaviorSubject<Map<String, Plant>> _plantsMap = BehaviorSubject();

  /// A getter that returns the current plants as a stream.
  Stream<Map<String, Plant>> get plants => _plantsMap.stream;

  /// The plants that are currently stored in the provider.
  late Plants _plants;

  /// The file name of the relocations.
  static const String _fileName = 'plant_relocations.txt';

  /// The standard relocations.
  static final PlantRelocations _standardRelocations = PlantRelocations.standard();

  /// The relocations as a stream.
  final BehaviorSubject<List<PlantRelocation>> _relocations = BehaviorSubject();

  /// The relocations as a stream.
  ValueStream<List<PlantRelocation>> get relocations => _relocations.stream;

  /// The relocations.
  late PlantRelocations _plantRelocations;

  /// Initializes the plants provider by reading the JSON file from the device's file system.
  PlantsProvider() {
    _initializePlants();
    _initializePlantRelocations();
  }

  /// Reads the JSON file from the device's file system and initializes the plants provider.
  void _initializePlants() async {
    final params = await getEncryptionParams();
    final plantsJson = await readJsonFile(
      name: _plantsFileName,
      preset: json.encode(_standardPlants.toJson()),
      params: params,
    );
    _plants = Plants.fromJson(plantsJson);
    await _setPlants(_plants, params);
  }

  /// Initializes the provider.
  Future<void> _initializePlantRelocations() async {
    final params = await getEncryptionParams();
    final transitionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardRelocations.toJson()),
      params: params,
    );
    _plantRelocations = PlantRelocations.fromJson(transitionsJson);
    await _setRelocations(_plantRelocations, params);
  }

  /// Sets the [relocations].
  Future<void> _setRelocations(
    PlantRelocations relocations,
    EncryptionParams params,
  ) async {
    _plantRelocations.relocations = relocations.relocations;
    await writeJsonFile(
      name: _fileName,
      content: relocations.toJson(),
      params: params,
    );
    _relocations.sink.add(relocations.relocations);
  }

  /// Adds a new [relocation].
  Future<void> addRelocation(PlantRelocation relocation) async {
    final relocations = _plantRelocations.relocations;
    relocations.add(relocation);
    await _setRelocations(_plantRelocations, await getEncryptionParams());
  }

  /// Removes all relocations for the plant with the given [plantId].
  Future<void> removeRelocationsForPlant(String plantId) async {
    final relocations = _plantRelocations.relocations;
    relocations.removeWhere((relocation) => relocation.plantId == plantId);
    await _setRelocations(_plantRelocations, await getEncryptionParams());
  }

  /// Sets the current plants to [plants] and updates the JSON file on the device's file system.
  Future<void> _setPlants(Plants plants, EncryptionParams params) async {
    _plants.plants = plants.plants;
    await writeJsonFile(
      name: _plantsFileName,
      content: plants.toJson(),
      params: params,
    );
    final map = plants.plants.asMap().map((index, plant) => MapEntry(plant.id, plant));
    _plantsMap.sink.add(map);
  }

  /// Adds a new [plant] to the provider.
  Future<void> addPlant(Plant plant) async {
    final params = await getEncryptionParams();
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await _setPlants(Plants(plants: plants.values.toList()), params);
  }

  /// Removes the [plant] from the provider.
  Future<void> removePlant(Plant plant) async {
    final params = await getEncryptionParams();
    final plants = await _plantsMap.first;
    plants.remove(plant.id);
    await _setPlants(Plants(plants: plants.values.toList()), params);
  }

  /// Removes all plants in the environment with the given [environmentId].
  Future<void> removePlantsInEnvironment(String environmentId) async {
    final params = await getEncryptionParams();
    final plants = await _plantsMap.first;
    final plantsToRemove =
        plants.values.where((plant) => plant.environmentId == environmentId).toList();
    for (final plant in plantsToRemove) {
      plant.environmentId = '';
    }
    await _setPlants(Plants(plants: plants.values.toList()), params);
  }

  /// Updates the [plant] in the provider.
  Future<Plant> updatePlant(Plant plant) async {
    final params = await getEncryptionParams();
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await _setPlants(Plants(plants: plants.values.toList()), params);
    return plant;
  }
}
