import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:growlog/actions/model.dart' as growlog;
import 'package:growlog/common/filestore.dart';
import 'package:rxdart/rxdart.dart';

/// A provider for actions.
///
/// This provider manages the actions and provides them as a stream.
/// It also allows adding, removing, and updating actions.
class ActionsProvider with ChangeNotifier {
  /// The file name of the actions.
  static const String _fileName = 'actions.txt';

  /// The standard actions.
  static final growlog.Actions _standardActions = growlog.Actions.standard();

  /// The plant actions as a stream.
  final BehaviorSubject<List<growlog.PlantAction>> _plantActions = BehaviorSubject();

  /// The environment actions as a stream.
  final BehaviorSubject<List<growlog.EnvironmentAction>> _environmentActions = BehaviorSubject();

  /// The plant actions as a stream.
  Stream<List<growlog.PlantAction>> get plantActions => _plantActions.stream;

  /// The environment actions as a stream.
  Stream<List<growlog.EnvironmentAction>> get environmentActions => _environmentActions.stream;

  /// The actions.
  late growlog.Actions _actions;

  /// Creates a new actions provider.
  ActionsProvider() {
    _initialize();
  }

  /// Initializes the provider.
  void _initialize() async {
    final params = await getEncryptionParams();
    final actionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardActions.toJson()),
      params: params,
    );

    _actions = growlog.Actions.fromJson(actionsJson);
    await _setPlantActions(_actions.plantActions, params);
    await _setEnvironmentActions(_actions.environmentActions, params);
  }

  /// Sets the [plantActions].
  Future<void> _setPlantActions(
    List<growlog.PlantAction> plantActions,
    EncryptionParams params,
  ) async {
    _actions.plantActions = plantActions;
    await writeJsonFile(
      name: _fileName,
      content: _actions.toJson(),
      params: params,
    );
    _plantActions.sink.add(plantActions);
  }

  /// Sets the [environmentActions].
  Future<void> _setEnvironmentActions(
    List<growlog.EnvironmentAction> environmentActions,
    EncryptionParams params,
  ) async {
    _actions.environmentActions = environmentActions;
    await writeJsonFile(
      name: _fileName,
      content: _actions.toJson(),
      params: params,
    );
    _environmentActions.sink.add(environmentActions);
  }

  /// Adds a [plantAction].
  Future<void> addPlantAction(growlog.PlantAction plantAction) async {
    final params = await getEncryptionParams();
    final plantActions = await _plantActions.first;
    plantActions.add(plantAction);
    await _setPlantActions(plantActions, params);
  }

  /// Adds an [environmentAction].
  Future<void> addEnvironmentAction(growlog.EnvironmentAction environmentAction) async {
    final params = await getEncryptionParams();
    final environmentActions = await _environmentActions.first;
    environmentActions.add(environmentAction);
    await _setEnvironmentActions(environmentActions, params);
  }

  Future<void> updateEnvironmentAction(growlog.EnvironmentAction environmentAction) async {
    final params = await getEncryptionParams();
    final environmentActions = await _environmentActions.first;
    final index = environmentActions.indexWhere((action) => action.id == environmentAction.id);
    if (index != -1) {
      environmentActions[index] = environmentAction;
      await _setEnvironmentActions(environmentActions, params);
    }
  }

  /// Deletes a plant action by its [plantId].
  Future<void> removeActionsForPlant(String plantId) async {
    final params = await getEncryptionParams();
    final plantActions = await _plantActions.first;
    final actions = plantActions.where((action) => action.plantId != plantId).toList();
    await _setPlantActions(actions, params);
  }

  /// Deletes an environment action by its [environmentId].
  Future<void> removeActionsForEnvironment(String environmentId) async {
    final params = await getEncryptionParams();
    final environmentActions = await _environmentActions.first;
    final actions =
        environmentActions.where((action) => action.environmentId != environmentId).toList();
    await _setEnvironmentActions(actions, params);
  }

  /// Deletes a plant action by its [id].
  Future<void> deletePlantAction(growlog.PlantAction plantAction) async {
    final params = await getEncryptionParams();
    final plantActions = await _plantActions.first;
    plantActions.remove(plantAction);
    await _setPlantActions(plantActions, params);
  }

  /// Deletes an environment action by its [id].
  Future<void> deleteEnvironmentAction(growlog.EnvironmentAction environmentAction) async {
    final params = await getEncryptionParams();
    final environmentActions = await _environmentActions.first;
    environmentActions.remove(environmentAction);
    await _setEnvironmentActions(environmentActions, params);
  }
}
