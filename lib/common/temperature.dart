import 'package:json_annotation/json_annotation.dart';

part 'temperature.g.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
}

extension TemperatureUnitExtension on TemperatureUnit {
  String get name {
    switch (this) {
      case TemperatureUnit.celsius:
        return 'Celsius';
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit';
    }
  }

  String get symbol {
    switch (this) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
    }
  }
}

@JsonSerializable()
class Temperature {
  final double value;
  final TemperatureUnit unit;

  Temperature({
    required this.value,
    required this.unit,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) => _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);
}
