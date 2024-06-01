import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/common/filestore.dart';

class FertilizerProvider extends ChangeNotifier {
  static const String _fileName = 'fertilizers.json';
  static final Fertilizers _standardFertilizers = Fertilizers.standard();

  final BehaviorSubject<Map<String, Fertilizer>> _fertilizersMap = BehaviorSubject();

  Stream<Map<String, Fertilizer>> get fertilizers => _fertilizersMap.stream;

  late Fertilizers _fertilizers;

  FertilizerProvider() {
    _initialize();
  }

  void _initialize() async {
    final fertilizersJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardFertilizers.toJson()),
    );
    _fertilizers = Fertilizers.fromJson(fertilizersJson);
    await setFertilizers(_fertilizers);
  }

  Future<void> setFertilizers(Fertilizers fertilizers) async {
    _fertilizers.fertilizers = fertilizers.fertilizers;
    await writeJsonFile(name: _fileName, content: fertilizers.toJson());
    final map = fertilizers.fertilizers
        .asMap()
        .map((index, fertilizer) => MapEntry(fertilizer.id, fertilizer));
    _fertilizersMap.sink.add(map);
  }

  Future<void> addFertilizer(Fertilizer fertilizer) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers[fertilizer.id] = fertilizer;
    await setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }

  Future<void> removeFertilizer(String fertilizerId) async {
    final fertilizers = await _fertilizersMap.first;
    fertilizers.remove(fertilizerId);
    await setFertilizers(Fertilizers(fertilizers: fertilizers.values.toList()));
  }
}
