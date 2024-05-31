import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:weedy/actions/model.dart' as weedy;
import 'package:weedy/common/filestore.dart';

class ActionsProvider with ChangeNotifier {
  static const String _fileName = 'actions.json';
  static final weedy.Actions _standardActions = weedy.Actions.standard();

  final BehaviorSubject<List<weedy.PlantAction>> _plantActions = BehaviorSubject();
  final BehaviorSubject<List<weedy.EnvironmentAction>> _environmentActions = BehaviorSubject();

  Stream<List<weedy.PlantAction>> get plantActions => _plantActions.stream;
  Stream<List<weedy.EnvironmentAction>> get environmentActions => _environmentActions.stream;

  late weedy.Actions _actions;

  ActionsProvider() {
    _initialize();
  }

  void _initialize() async {
    final actionsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardActions.toJson()),
    );
    _actions = weedy.Actions.fromJson(actionsJson);
    await setPlantActions(_actions.plantActions);
    await setEnvironmentActions(_actions.environmentActions);
  }

  Future<void> setPlantActions(List<weedy.PlantAction> plantActions) async {
    _actions.plantActions = plantActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _plantActions.sink.add(plantActions);
  }

  Future<void> addPlantAction(weedy.PlantAction plantAction) async {
    final plantActions = await _plantActions.first;
    plantActions.add(plantAction);
    await setPlantActions(plantActions);
  }

  Future<void> setEnvironmentActions(List<weedy.EnvironmentAction> environmentActions) async {
    _actions.environmentActions = environmentActions;
    await writeJsonFile(name: _fileName, content: _actions.toJson());
    _environmentActions.sink.add(environmentActions);
  }

  Future<void> addEnvironmentAction(weedy.EnvironmentAction environmentAction) async {
    final environmentActions = await _environmentActions.first;
    environmentActions.add(environmentAction);
    await setEnvironmentActions(environmentActions);
  }

  Future<void> removeActionsForPlant(String plantId) async {
    final plantActions = await _plantActions.first;
    final actions = plantActions.where((action) => action.plantId != plantId).toList();
    await setPlantActions(actions);
  }

  Future<void> removeActionsForEnvironment(String environmentId) async {
    final environmentActions = await _environmentActions.first;
    final actions = environmentActions.where((action) => action.environmentId != environmentId).toList();
    await setEnvironmentActions(actions);
  }
}