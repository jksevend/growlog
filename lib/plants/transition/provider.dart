import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/plants/transition/model.dart';

/// A provider class that manages the plant lifecycle transitions.
/// The transitions are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [transitions] and changed via [_setTransitions]
/// which will also update the JSON file on the device's file system.
class PlantLifecycleTransitionProvider extends ChangeNotifier {
  /// The file name of the lifecycle transitions.
  static const String _fileName = 'plant_transitions.txt';

  /// The standard transitions.
  static final PlantLifecycleTransitions _standardTransitions =
      PlantLifecycleTransitions.standard();

  /// The transitions as a stream.
  final BehaviorSubject<List<PlantLifecycleTransition>> _transitions = BehaviorSubject();

  /// The transitions as a stream.
  Stream<List<PlantLifecycleTransition>> get transitions => _transitions.stream;

  /// The transitions.
  late PlantLifecycleTransitions _lifecycleTransitions;

  /// Creates a new transitions provider.
  PlantLifecycleTransitionProvider() {
    _initialize();
  }

  /// Initializes the provider.
  Future<void> _initialize() async {
    final params = await getEncryptionParams();
    final transitionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardTransitions.toJson()),
      params: params,
    );
    _lifecycleTransitions = PlantLifecycleTransitions.fromJson(transitionsJson);
    await _setTransitions(_lifecycleTransitions, params);
  }

  /// Sets the [transitions].
  Future<void> _setTransitions(
    PlantLifecycleTransitions transitions,
    EncryptionParams params,
  ) async {
    _lifecycleTransitions.transitions = transitions.transitions;
    await writeJsonFile(
      name: _fileName,
      content: transitions.toJson(),
      params: params,
    );
    _transitions.sink.add(transitions.transitions);
  }

  /// Adds a new [transition].
  Future<void> addTransition(PlantLifecycleTransition transition) async {
    final transitions = _lifecycleTransitions.transitions;
    transitions.add(transition);
    await _setTransitions(_lifecycleTransitions, await getEncryptionParams());
  }

  /// Removes all transitions for the plant with the given [plantId].
  Future<void> removeTransitionsForPlant(String plantId) async {
    final transitions = _lifecycleTransitions.transitions;
    transitions.removeWhere((transition) => transition.plantId == plantId);
    await _setTransitions(_lifecycleTransitions, await getEncryptionParams());
  }
}
