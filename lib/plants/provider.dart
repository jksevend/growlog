import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/model.dart';

class PlantsProvider with ChangeNotifier {
  static const String _fileName = 'plants.json';
  static final Plants _standardPlants = Plants.standard();

  final BehaviorSubject<Map<String, Plant>> _plantsMap = BehaviorSubject();

  Stream<Map<String, Plant>> get plants => _plantsMap.stream;

  late Plants _plants;

  PlantsProvider() {
    _initialize();
  }

  void _initialize() async {
    final plantsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardPlants.toJson()),
    );
    _plants = Plants.fromJson(plantsJson);
    await setPlants(_plants);
  }

  Future<void> setPlants(Plants plants) async {
    _plants.plants = plants.plants;
    await writeJsonFile(name: _fileName, content: plants.toJson());
    final map = plants.plants.asMap().map((index, plant) => MapEntry(plant.id, plant));
    _plantsMap.sink.add(map);
  }

  Future<void> addPlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await setPlants(Plants(plants: plants.values.toList()));
  }

  Future<void> removePlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants.remove(plant.id);
    await setPlants(Plants(plants: plants.values.toList()));
  }

  Future<void> removePlantsInEnvironment(String environmentId) async{
    final plants = await _plantsMap.first;
    final plantsToRemove = plants.values.where((plant) => plant.environmentId == environmentId).toList();
    for (final plant in plantsToRemove) {
      plant.environmentId = '';
    }
    await setPlants(Plants(plants: plants.values.toList()));
  }

  Future<void> updatePlant(Plant plant) async {
    final plants = await _plantsMap.first;
    plants[plant.id] = plant;
    await setPlants(Plants(plants: plants.values.toList()));
  }
}