import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/relocation/model.dart';

/// A provider class that manages the plant relocations.
/// The relocations are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [relocations] and changed via [_setRelocations]
/// which will also update the JSON file on the device's file system.
class PlantRelocationProvider extends ChangeNotifier {
  /// The file name of the relocations.
  static const String _fileName = 'plant_relocations.txt';

  /// The standard relocations.
  static final PlantRelocations _standardRelocations = PlantRelocations.standard();

  /// The relocations as a stream.
  final BehaviorSubject<Map<String, PlantRelocation>> _relocations = BehaviorSubject();

  /// The relocations as a stream.
  ValueStream<Map<String, PlantRelocation>> get relocations => _relocations.stream;

  /// The relocations.
  late PlantRelocations _plantRelocations;

  /// Creates a new relocations provider.
  PlantRelocationProvider() {
    _initialize();
  }

  /// Initializes the provider.
  Future<void> _initialize() async {
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
    final map = relocations.relocations
        .asMap()
        .map((index, relocation) => MapEntry(relocation.plantId, relocation));
    _relocations.sink.add(map);
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
}
