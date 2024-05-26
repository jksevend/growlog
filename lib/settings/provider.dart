import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/common/filestore.dart';
import 'package:weedy/settings/model.dart';

/// A provider class that manages the application's settings.
///
/// The settings are stored in a JSON file on the device's file system
/// and can be accessed via a stream called [settings] and changed via [setSettings]
/// which will also update the JSON file on the device's file system.
class SettingsProvider extends ChangeNotifier {
  static const String _fileName = 'settings.json';
  static final Settings _standardSettings = Settings.standard();

  final BehaviorSubject<Settings> _settings = BehaviorSubject();

  Stream<Settings> get settings => _settings.stream;

  Future<void> setSettings(Settings settings) async {
    await writeJsonFile(name: _fileName, content: settings.toJson());
    _settings.sink.add(settings);
  }

  SettingsProvider() {
    _initialize();
  }

  void _initialize() async {
    final settingsJson = await readJsonFile(
      name: _fileName,
      preset: json.encode(_standardSettings.toJson()),
    );
    final settings = Settings.fromJson(settingsJson);
    await setSettings(settings);
  }
}
