import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Settings {
  final NotificationSettings notification;

  Settings({
    required this.notification,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  factory Settings.standard() {
    return Settings(
      notification: NotificationSettings(enabled: true),
    );
  }
}

@JsonSerializable()
class NotificationSettings {
  bool enabled;

  NotificationSettings({
    required this.enabled,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);
}