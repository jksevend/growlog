import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:growlog/common/filestore.dart';
import 'package:growlog/grow/model.dart';
import 'package:rxdart/rxdart.dart';

class GrowProvider extends ChangeNotifier {
  /// The file name of the actions.
  static const String _fileName = 'grows.txt';

  /// The standard actions.
  static final Grows _standardGrows = Grows.standard();

  /// The plant actions as a stream.
  final BehaviorSubject<List<Grow>> _grows = BehaviorSubject();

  /// The environment actions as a stream.

  /// The plant actions as a stream.
  Stream<List<Grow>> get grows => _grows.stream;

  /// The environment actions as a stream.

  /// The actions.
  late Grows _growObjects;

  /// Creates a new actions provider.
  GrowProvider() {
    _initialize();
  }

  /// Initializes the provider.
  void _initialize() async {
    final params = await getEncryptionParams();
    final actionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardGrows.toJson()),
      params: params,
    );

    _growObjects = Grows.fromJson(actionsJson);
    await _setGrows(_growObjects.grows, params);
  }

  /// Sets the [grows].
  Future<void> _setGrows(
    List<Grow> grows,
    EncryptionParams params,
  ) async {
    _growObjects.grows = grows;
    await writeJsonFile(
      name: _fileName,
      content: _growObjects.toJson(),
      params: params,
    );
    _grows.add(_growObjects.grows);
  }

  Future<void> addGrow(Grow grow) async {
    final grows = List<Grow>.from(_growObjects.grows)..add(grow);
    await _setGrows(grows, await getEncryptionParams());
  }
}
