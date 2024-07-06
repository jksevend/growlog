import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:growlog/actions/fertilizer/model.dart';
import 'package:growlog/common/filestore.dart';
import 'package:rxdart/rxdart.dart';

/// A provider for fertilizers.
///
/// This provider manages the fertilizers and provides them as a stream.
/// It also allows adding, removing, and updating fertilizers.
class FertilizerProvider extends ChangeNotifier {
  /// The file name of the fertilizers.
  static const String _fileName = 'fertilizers.txt';

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
    final params = await getEncryptionParams();
    final fertilizersJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardFertilizers.toJson()),
      params: params,
    );
    _fertilizers = Fertilizers.fromJson(fertilizersJson);
    await _setFertilizers(_fertilizers, params);
  }

  /// Sets the [fertilizers].
  Future<void> _setFertilizers(Fertilizers fertilizers, EncryptionParams params) async {
    _fertilizers.fertilizers = fertilizers.fertilizers;
    await writeJsonFile(
      name: _fileName,
      content: fertilizers.toJson(),
      params: params,
    );
    final map = fertilizers.fertilizers
        .asMap()
        .map((index, fertilizer) => MapEntry(fertilizer.id, fertilizer));
    _fertilizersMap.sink.add(map);
  }

  /// Adds a [fertilizer].
  Future<void> addFertilizer(Fertilizer fertilizer) async {
    final params = await getEncryptionParams();
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()), params);
  }

  /// Deletes a fertilizer by its [id].
  Future<void> deleteFertilizer(String id) async {
    final params = await getEncryptionParams();
    final fertilizers = await _fertilizersMap.first;
    fertilizers.remove(id);
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()), params);
  }

  /// Updates a [fertilizer].
  Future<void> updateFertilizer(Fertilizer fertilizer) async {
    final params = await getEncryptionParams();
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await _setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()), params);
  }
}
