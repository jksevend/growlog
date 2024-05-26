import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/model.dart';

class PlantProvider with ChangeNotifier {
  static const String _fileName = 'plants.json';
  static final Plants _standardPlants = Plants.standard();

  final BehaviorSubject<Plants> _plants = BehaviorSubject();

  Stream<Plants> get plants => _plants.stream;

  Future<void> setPlants(Plants plants) async {
    await writeJsonFile(name: _fileName, content: plants.toJson());
    _plants.sink.add(plants);
  }

  PlantProvider() {
    _initialize();
  }

  void _initialize() async {
    final plantsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardPlants.toJson()),
    );
    final plants = Plants.fromJson(plantsJson);
    await setPlants(plants);
  }
}