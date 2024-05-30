import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/environments/model.dart';

class EnvironmentsProvider with ChangeNotifier {
  static const String _fileName = 'environments.json';
  static final Environments _standardEnvironments = Environments.standard();

  final BehaviorSubject<Environments> _environments = BehaviorSubject();

  Stream<Environments> get environments => _environments.stream;

  EnvironmentsProvider() {
    _initialize();
  }

  void _initialize() async {
    final environmentsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardEnvironments.toJson()),
    );
    final environments = Environments.fromJson(environmentsJson);
    await setEnvironments(environments);
  }

  Future<void> setEnvironments(Environments environments) async {
    await writeJsonFile(name: _fileName, content: environments.toJson());
    _environments.sink.add(environments);
  }

  Future<void> addEnvironment(Environment environment) async {
    final environments = await _environments.first;
    environments.environments.add(environment);
    await setEnvironments(environments);
  }
}