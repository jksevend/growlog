import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/environments/model.dart';

class EnvironmentsProvider with ChangeNotifier {
  static const String _fileName = 'environments.json';
  static final Environments _standardEnvironments = Environments.standard();

  final BehaviorSubject<Map<String, Environment>> _environmentsMap = BehaviorSubject();

  Stream<Map<String, Environment>> get environments => _environmentsMap.stream;

  late Environments _environments;

  EnvironmentsProvider() {
    _initialize();
  }

  void _initialize() async {
    final environmentsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardEnvironments.toJson()),
    );
    _environments = Environments.fromJson(environmentsJson);
    await setEnvironments(_environments);
  }

  Future<void> setEnvironments(Environments environments) async {
    _environments.environments = environments.environments;
    await writeJsonFile(name: _fileName, content: environments.toJson());
    final map = environments.environments.asMap().map((index, environment) => MapEntry(environment.id, environment));
    _environmentsMap.sink.add(map);
  }

  Future<void> addEnvironment(Environment environment) async {
    final environments = await _environmentsMap.first;
    environments[environment.id] = environment;
    await setEnvironments(Environments(environments: environments.values.toList()));
  }

  Future<void> removeEnvironment(Environment environment) async {
    final environments = await _environmentsMap.first;
    environments.remove(environment.id);
    await setEnvironments(Environments(environments: environments.values.toList()));
  }

  Future<void> updateEnvironment(Environment environment) async {
    final environments = await _environmentsMap.first;
    environments[environment.id] = environment;
    await setEnvironments(Environments(environments: environments.values.toList()));
  }
}