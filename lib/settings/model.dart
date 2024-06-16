import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// The settings of the application.
@JsonSerializable()
class Settings {
  Settings();

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  factory Settings.standard() {
    return Settings();
  }
}
