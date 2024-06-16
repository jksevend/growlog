import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/model.dart' as weedy;
import 'package:weedy/common/filestore.dart';

/// A provider for actions.
///
/// This provider manages the actions and provides them as a stream.
/// It also allows adding, removing, and updating actions.
class ActionsProvider with ChangeNotifier {
  /// The file name of the actions.
  static const String _fileName = 'actions.json';

  /// The standard actions.
  static final weedy.Actions _standardActions = weedy.Actions.standard();

  /// The plant actions as a stream.
  final BehaviorSubject<List<weedy.PlantAction>> _plantActions = BehaviorSubject();

  /// The environment actions as a stream.
  final BehaviorSubject<List<weedy.EnvironmentAction>> _environmentActions = BehaviorSubject();

  /// The plant actions as a stream.
  Stream<List<weedy.PlantAction>> get plantActions => _plantActions.stream;

  /// The environment actions as a stream.
  Stream<List<weedy.EnvironmentAction>> get environmentActions => _environmentActions.stream;

  /// The actions.
  late weedy.Actions _actions;

  /// Creates a new actions provider.
  ActionsProvider() {
    _initialize();
  }

  /// Initializes the provider.
  void _initialize() async {
    final actionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardActions.toJson()),
    );

    _actions = weedy.Actions.fromJson(actionsJson);
    await _setPlantActions(_actions.plantActions);
    await _setEnvironmentActions(_actions.environmentActions);
  }

  /// Sets the [plantActions].
  Future<void> _setPlantActions(List<weedy.PlantAction> plantActions) async {
    _actions.plantActions = plantActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _plantActions.sink.add(plantActions);
  }

  /// Sets the [environmentActions].
  Future<void> _setEnvironmentActions(List<weedy.EnvironmentAction> environmentActions) async {
    _actions.environmentActions = environmentActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _environmentActions.sink.add(environmentActions);
  }

  /// Adds a [plantAction].
  Future<void> addPlantAction(weedy.PlantAction plantAction) async {
    final plantActions = await _plantActions.first;
    plantActions.add(plantAction);
    await _setPlantActions(plantActions);
  }

  /// Adds an [environmentAction].
  Future<void> addEnvironmentAction(weedy.EnvironmentAction environmentAction) async {
    final environmentActions = await _environmentActions.first;
    environmentActions.add(environmentAction);
    await _setEnvironmentActions(environmentActions);
  }

  /// Deletes a plant action by its [plantId].
  Future<void> removeActionsForPlant(String plantId) async {
    final plantActions = await _plantActions.first;
    final actions = plantActions.where((action) => action.plantId != plantId).toList();
    await _setPlantActions(actions);
  }

  /// Deletes an environment action by its [environmentId].
  Future<void> removeActionsForEnvironment(String environmentId) async {
    final environmentActions = await _environmentActions.first;
    final actions =
        environmentActions.where((action) => action.environmentId != environmentId).toList();
    await _setEnvironmentActions(actions);
  }

  /// Deletes a plant action by its [id].
  Future<void> deletePlantAction(weedy.PlantAction plantAction) async {
    final plantActions = await _plantActions.first;
    plantActions.remove(plantAction);
    await _setPlantActions(plantActions);
  }

  /// Deletes an environment action by its [id].
  Future<void> deleteEnvironmentAction(weedy.EnvironmentAction environmentAction) async {
    final environmentActions = await _environmentActions.first;
    environmentActions.remove(environmentAction);
    await _setEnvironmentActions(environmentActions);
  }
}
