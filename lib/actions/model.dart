import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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

  factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);

  Map<String, dynamic> toJson() => _$ActionToJson(this);
}

@JsonSerializable()
class EnvironmentAction extends Action {
  final String environmentId;

  EnvironmentAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.environmentId,
  });

  factory EnvironmentAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentActionToJson(this);
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
        return Icon(Icons.emoji_nature,  size: 35, color: Colors.amber[500]);
      case PlantActionType.pruning:
        return Icon(Icons.content_cut, size: 35, color: Colors.teal);
      case PlantActionType.harvesting:
        return Icon(Icons.agriculture, size: 35, color: Colors.deepOrange);
      case PlantActionType.replanting:
        return Icon(Icons.eco, size: 35, color: Colors.green[900]);
      case PlantActionType.training:
        return Icon(Icons.insights, size: 35, color: Colors.deepPurple  [900]);
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

  PlantAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.plantId,
    required this.type,
  });

  factory PlantAction.fromJson(Map<String, dynamic> json) => _$PlantActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantActionToJson(this);
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
