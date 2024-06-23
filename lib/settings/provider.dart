import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/settings/model.dart';

/// A provider class that manages the application's settings.
///
/// The settings are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [settings] and changed via [_setSettings]
/// which will also update the JSON file on the device's file system.
class SettingsProvider extends ChangeNotifier {
  /// The name of the JSON file that holds the settings.
  static const String _fileName = 'settings.txt';

  /// The standard settings that are used if the JSON file does not exist.
  static final Settings _standardSettings = Settings.standard();

  /// A stream controller that holds the current settings.
  final BehaviorSubject<Settings> _settings = BehaviorSubject();

  /// A getter that returns the current settings as a stream.
  Stream<Settings> get settings => _settings.stream;

  /// Initializes the settings provider by reading the JSON file from the device's file system.
  SettingsProvider() {
    _initialize();
  }

  /// Reads the JSON file from the device's file system and initializes the settings provider.
  void _initialize() async {
    final params = await getEncryptionParams();
    final settingsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardSettings.toJson()),
      params: params,
    );
    final settings = Settings.fromJson(settingsJson);
    await _setSettings(settings, params);
  }

  /// Sets the current settings to [settings] and updates the JSON file on the device's file system.
  Future<void> _setSettings(Settings settings, EncryptionParams params) async {
    await writeJsonFile(
      name: _fileName,
      content: settings.toJson(),
      params: params,
    );
    _settings.sink.add(settings);
  }
}
