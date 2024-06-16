import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/common/filestore.dart';

/// A provider for fertilizers.
///
/// This provider manages the fertilizers and provides them as a stream.
/// It also allows adding, removing, and updating fertilizers.
class FertilizerProvider extends ChangeNotifier {
  /// The file name of the fertilizers.
  static const String _fileName = 'fertilizers.json';

  /// The standard fertilizers.
  static final Fertilizers _standardFertilizers = Fertilizers.standard();

  /// The fertilizers as a stream.
  final BehaviorSubject<Map<String, Fertilizer>> _fertilizersMap = BehaviorSubject();

  /// The fertilizers as a stream.
  Stream<Map<String, Fertilizer>> get fertilizers => _fertilizersMap.stream;

  /// The fertilizers.
  late Fertilizers _fertilizers;

  /// Creates a new fertilizer provider.
  FertilizerProvider() {
    _initialize();
  }

  /// Initializes the provider.
  Future<void> _initialize() async {
    final fertilizersJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardFertilizers.toJson()),
    );
    _fertilizers = Fertilizers.fromJson(fertilizersJson);
    await setFertilizers(_fertilizers);
  }

  /// Sets the [fertilizers].
  Future<void> setFertilizers(Fertilizers fertilizers) async {
    _fertilizers.fertilizers = fertilizers.fertilizers;
    await writeJsonFile(name: _fileName, content: fertilizers.toJson());
    final map = fertilizers.fertilizers
        .asMap()
        .map((index, fertilizer) => MapEntry(fertilizer.id, fertilizer));
    _fertilizersMap.sink.add(map);
  }

  /// Adds a [fertilizer].
  Future<void> addFertilizer(Fertilizer fertilizer) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }

  /// Deletes a fertilizer by its [id].
  Future<void> deleteFertilizer(String id) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers.remove(id);
    await setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }

  /// Updates a [fertilizer].
  Future<void> updateFertilizer(Fertilizer fertilizer) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }
}
