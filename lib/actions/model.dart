import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'model.g.dart';

@JsonSerializable()
class Action {
  final String id;
  final String description;
  final DateTime createdAt;

  Action({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  String get formattedDate => timeago.format(createdAt, locale: 'en');

  factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);

  Map<String, dynamic> toJson() => _$ActionToJson(this);
}

enum EnvironmentMeasurementType {
  temperature,
  humidity,
  co2,
  lightDistance,
  other,
}

extension EnvironmentMeasurementTypeExtension on EnvironmentMeasurementType {
  String get name {
    switch (this) {
      case EnvironmentMeasurementType.temperature:
        return 'Temperature';
      case EnvironmentMeasurementType.humidity:
        return 'Humidity';
      case EnvironmentMeasurementType.co2:
        return 'CO2';
      case EnvironmentMeasurementType.lightDistance:
        return 'Light distance';
      case EnvironmentMeasurementType.other:
        return 'Other';
    }
  }

  Icon get icon {
    switch (this) {
      case EnvironmentMeasurementType.temperature:
        return Icon(Icons.thermostat, size: 35, color: Colors.red);
      case EnvironmentMeasurementType.humidity:
        return Icon(Icons.water_damage, size: 35, color: Colors.blue);
      case EnvironmentMeasurementType.co2:
        return Icon(Icons.co2, size: 35, color: Colors.green);
      case EnvironmentMeasurementType.lightDistance:
        return Icon(Icons.highlight_rounded, size: 35, color: Colors.yellow);
      case EnvironmentMeasurementType.other:
        return Icon(Icons.miscellaneous_services, size: 35, color: Colors.grey[700]);
    }
  }
}

@JsonSerializable()
class EnvironmentAction extends Action {
  final String environmentId;
  EnvironmentMeasurement? measurement;

  EnvironmentAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.environmentId,
    required this.measurement,
  });

  factory EnvironmentAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentActionToJson(this);
}

enum PlantMeasurementType { height, pH, ec, ppm }

@JsonSerializable()
class EnvironmentMeasurement {
  final EnvironmentMeasurementType type;

  final Map<String, dynamic> measurement;

  EnvironmentMeasurement({
    required this.type,
    required this.measurement,
  });

  factory EnvironmentMeasurement.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentMeasurementToJson(this);
}

enum PlantActionType {
  watering,
  fertilizing,
  pruning,
  harvesting,
  replanting,
  training,
  measuring,
  death,
  other,
}

extension PlantActionTypeExtension on PlantActionType {
  String get name {
    switch (this) {
      case PlantActionType.watering:
        return 'Watering';
      case PlantActionType.fertilizing:
        return 'Fertilizing';
      case PlantActionType.pruning:
        return 'Pruning';
      case PlantActionType.harvesting:
        return 'Harvesting';
      case PlantActionType.replanting:
        return 'Replanting';
      case PlantActionType.training:
        return 'Training';
      case PlantActionType.measuring:
        return 'Measuring';
      case PlantActionType.death:
        return 'Death';
      case PlantActionType.other:
        return 'Other';
    }
  }

  Icon get icon {
    switch (this) {
      case PlantActionType.watering:
        return Icon(Icons.water_drop, size: 35, color: Colors.blue[900]);
      case PlantActionType.fertilizing:
        return Icon(Icons.emoji_nature, size: 35, color: Colors.amber[500]);
      case PlantActionType.pruning:
        return Icon(Icons.content_cut, size: 35, color: Colors.teal);
      case PlantActionType.harvesting:
        return Icon(Icons.agriculture, size: 35, color: Colors.deepOrange);
      case PlantActionType.replanting:
        return Icon(Icons.eco, size: 35, color: Colors.green[900]);
      case PlantActionType.training:
        return Icon(Icons.insights, size: 35, color: Colors.deepPurple[900]);
      case PlantActionType.measuring:
        return Icon(Icons.analytics, size: 35, color: Colors.purple[900]);
      case PlantActionType.death:
        return Icon(Icons.warning_amber_outlined, size: 35, color: Colors.grey);
      case PlantActionType.other:
        return Icon(Icons.miscellaneous_services, size: 35, color: Colors.grey[700]);
    }
  }
}

@JsonSerializable()
class PlantAction extends Action {
  final String plantId;
  final PlantActionType type;
  final PlantMeasurement? measurement;

  PlantAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.plantId,
    required this.type,
    required this.measurement,
  });

  factory PlantAction.fromJson(Map<String, dynamic> json) => _$PlantActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantActionToJson(this);
}

@JsonSerializable()
class PlantMeasurement {
  final PlantMeasurementType type;

  PlantMeasurement({
    required this.type,
  });

  factory PlantMeasurement.fromJson(Map<String, dynamic> json) => _$PlantMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$PlantMeasurementToJson(this);
}

@JsonSerializable()
class Actions {
  List<PlantAction> plantActions;
  List<EnvironmentAction> environmentActions;

  Actions({
    required this.plantActions,
    required this.environmentActions,
  });

  factory Actions.fromJson(Map<String, dynamic> json) => _$ActionsFromJson(json);

  Map<String, dynamic> toJson() => _$ActionsToJson(this);

  factory Actions.standard() {
    return Actions(
      plantActions: [],
      environmentActions: [],
    );
  }
}
