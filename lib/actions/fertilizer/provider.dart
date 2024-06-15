import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/common/filestore.dart';

/// A provider class that manages the application's fertilizers.
///
/// The fertilizers are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [fertilizers] and changed via [_setFertilizers]
/// which will also update the JSON file on the device's file system.
class FertilizerProvider extends ChangeNotifier {
  /// The name of the JSON file that holds the fertilizers.
  static const String _fileName = 'fertilizers.json';

  /// The standard fertilizers that are used if the JSON file does not exist.
  static final Fertilizers _standardFertilizers = Fertilizers.standard();

  /// A stream controller that holds the current fertilizers.
  final BehaviorSubject<Map<String, Fertilizer>> _fertilizersMap = BehaviorSubject();

  /// A getter that returns the current fertilizers as a stream.
  Stream<Map<String, Fertilizer>> get fertilizers => _fertilizersMap.stream;

  /// The current fertilizers.
  late Fertilizers _fertilizers;

  /// Initializes the fertilizer provider by reading the JSON file
  /// from the device's file system.
  FertilizerProvider() {
    _initialize();
  }

  /// Reads the JSON file from the device's file system and
  /// initializes the fertilizer provider.
  Future<void> _initialize() async {
    final fertilizersJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardFertilizers.toJson()),
    );
    _fertilizers = Fertilizers.fromJson(fertilizersJson);
    await _setFertilizers(_fertilizers);
  }

  /// Sets the current fertilizers to [fertilizers] and updates
  /// the JSON file on the device's file system.
  Future<void> _setFertilizers(Fertilizers fertilizers) async {
    _fertilizers.fertilizers = fertilizers.fertilizers;
    await writeJsonFile(name: _fileName, content: fertilizers.toJson());
    final map = fertilizers.fertilizers
        .asMap()
        .map((index, fertilizer) => MapEntry(fertilizer.id, fertilizer));
    _fertilizersMap.sink.add(map);
  }

  /// Adds a new [fertilizer] to the current fertilizers.
  Future<void> addFertilizer(Fertilizer fertilizer) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }

  /// Deletes a [fertilizer] from the current fertilizers.
  Future<void> deleteFertilizer(String id) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers.remove(id);
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }

  /// Updates a [fertilizer] in the current fertilizers.
  Future<void> updateFertilizer(Fertilizer fertilizer) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }
}
