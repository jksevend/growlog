import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:growlog/common/filestore.dart';
import 'package:growlog/environments/model.dart';
import 'package:rxdart/rxdart.dart';

/// A provider class that manages the environments.
///
/// The environments are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [environments] and changed via [_setEnvironments]
/// which will also update the JSON file on the device's file system.
class EnvironmentsProvider with ChangeNotifier {
  /// The name of the JSON file that holds the environments.
  static const String _fileName = 'environments.txt';

  /// The standard environments that are used if the JSON file does not exist.
  static final Environments _standardEnvironments = Environments.standard();

  /// A stream controller that holds the current environments.
  final BehaviorSubject<Map<String, Environment>> _environmentsMap = BehaviorSubject();

  /// A getter that returns the current environments as a stream.
  Stream<Map<String, Environment>> get environments => _environmentsMap.stream;

  /// The environments that are currently stored in the provider.
  late Environments _environments;

  /// Initializes the environments provider by reading the
  /// JSON file from the device's file system.
  EnvironmentsProvider() {
    _initialize();
  }

  /// Reads the JSON file from the device's file system and
  /// initializes the environments provider.
  void _initialize() async {
    final params = await getEncryptionParams();
    final environmentsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardEnvironments.toJson()),
      params: params,
    );
    _environments = Environments.fromJson(environmentsJson);
    await _setEnvironments(_environments, params);
  }

  /// Sets the current environments to [environments] and updates
  /// the JSON file on the device's file system.
  Future<void> _setEnvironments(Environments environments, EncryptionParams params) async {
    _environments.environments = environments.environments;
    await writeJsonFile(
      name: _fileName,
      content: environments.toJson(),
      params: params,
    );
    final map = environments.environments
        .asMap()
        .map((index, environment) => MapEntry(environment.id, environment));
    _environmentsMap.sink.add(map);
  }

  /// Adds a new [environment] to the provider.
  Future<void> addEnvironment(Environment environment) async {
    final params = await getEncryptionParams();
    final environments = await _environmentsMap.first;
    environments[environment.id] = environment;
    await _setEnvironments(Environments(environments: environments.values.toList()), params);
  }

  /// Removes the [environment] from the provider.
  Future<void> removeEnvironment(Environment environment) async {
    final params = await getEncryptionParams();
    final environments = await _environmentsMap.first;
    environments.remove(environment.id);
    await _setEnvironments(Environments(environments: environments.values.toList()), params);
  }

  /// Updates the [environment] in the provider.
  Future<void> updateEnvironment(Environment environment) async {
    final params = await getEncryptionParams();
    final environments = await _environmentsMap.first;
    environments[environment.id] = environment;
    await _setEnvironments(Environments(environments: environments.values.toList()), params);
  }
}
