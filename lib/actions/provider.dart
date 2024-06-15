import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/model.dart' as weedy;
import 'package:weedy/common/filestore.dart';

/// A provider class that manages the application's actions.
///
/// The actions are stored in a JSON file on the device's file system
/// and can be accessed via streams called [plantActions] and [environmentActions]
/// and changed via [_setPlantActions] and [_setEnvironmentActions] which will also update
/// the JSON file on the device's file system.
class ActionsProvider with ChangeNotifier {
  /// The name of the JSON file that holds the actions.
  static const String _fileName = 'actions.json';

  /// The standard actions that are used if the JSON file does not exist.
  static final weedy.Actions _standardActions = weedy.Actions.standard();

  /// A stream controller that holds the current plant actions.
  final BehaviorSubject<List<weedy.PlantAction>> _plantActions = BehaviorSubject();

  /// A stream controller that holds the current environment actions.
  final BehaviorSubject<List<weedy.EnvironmentAction>> _environmentActions = BehaviorSubject();

  /// A getter that returns the current plant actions as a stream.
  Stream<List<weedy.PlantAction>> get plantActions => _plantActions.stream;

  /// A getter that returns the current environment actions as a stream.
  Stream<List<weedy.EnvironmentAction>> get environmentActions => _environmentActions.stream;

  /// The current actions.
  late weedy.Actions _actions;

  /// Initializes the actions provider by reading the JSON file
  ActionsProvider() {
    _initialize();
  }

  /// Reads the JSON file from the device's file system and
  /// initializes the action providers.
  Future<void> _initialize() async {
    final actionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardActions.toJson()),
    );
    _actions = weedy.Actions.fromJson(actionsJson);
    await _setPlantActions(_actions.plantActions);
    await _setEnvironmentActions(_actions.environmentActions);
  }

  /// Sets the current plant actions to [plantActions] and updates
  Future<void> _setPlantActions(List<weedy.PlantAction> plantActions) async {
    _actions.plantActions = plantActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _plantActions.sink.add(plantActions);
  }

  /// Sets the current environment actions to [environmentActions] and updates
  Future<void> _setEnvironmentActions(List<weedy.EnvironmentAction> environmentActions) async {
    _actions.environmentActions = environmentActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _environmentActions.sink.add(environmentActions);
  }

  /// Adds a new [plantAction] to the current plant actions.
  Future<void> addPlantAction(weedy.PlantAction plantAction) async {
    final plantActions = await _plantActions.first;
    plantActions.add(plantAction);
    await _setPlantActions(plantActions);
  }

  /// Adds a new [environmentAction] to the current environment actions.
  Future<void> addEnvironmentAction(weedy.EnvironmentAction environmentAction) async {
    final environmentActions = await _environmentActions.first;
    environmentActions.add(environmentAction);
    await _setEnvironmentActions(environmentActions);
  }

  /// Deletes a [plantAction] from the current plant actions.
  Future<void> removeActionsForPlant(String plantId) async {
    final plantActions = await _plantActions.first;
    final actions = plantActions.where((action) => action.plantId != plantId).toList();
    await _setPlantActions(actions);
  }

  /// Deletes a [environmentAction] from the current environment actions.
  Future<void> removeActionsForEnvironment(String environmentId) async {
    final environmentActions = await _environmentActions.first;
    final actions =
        environmentActions.where((action) => action.environmentId != environmentId).toList();
    await _setEnvironmentActions(actions);
  }

  /// Deletes a [plantAction] from the current plant actions.
  Future<void> deletePlantAction(weedy.PlantAction plantAction) async {
    final plantActions = await _plantActions.first;
    plantActions.remove(plantAction);
    await _setPlantActions(plantActions);
  }

  /// Deletes a [environmentAction] from the current environment actions.
  Future<void> deleteEnvironmentAction(weedy.EnvironmentAction environmentAction) async {
    final environmentActions = await _environmentActions.first;
    environmentActions.remove(environmentAction);
    await _setEnvironmentActions(environmentActions);
  }
}
