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
        return Icon(Icons.thermostat, size: 25);
      case EnvironmentMeasurementType.humidity:
        return Icon(Icons.water_damage, size: 25);
      case EnvironmentMeasurementType.co2:
        return Icon(Icons.co2, size: 25);
      case EnvironmentMeasurementType.lightDistance:
        return Icon(Icons.highlight_rounded, size: 25);
      case EnvironmentMeasurementType.other:
        return Icon(Icons.miscellaneous_services, size: 25);
    }
  }
}

@JsonSerializable()
class EnvironmentAction extends Action {
  final String environmentId;
  EnvironmentMeasurement measurement;

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

enum LiquidUnit {
  ml,
  l,
}

extension WateringUnitExtension on LiquidUnit {
  String get name {
    switch (this) {
      case LiquidUnit.ml:
        return 'ml';
      case LiquidUnit.l:
        return 'l';
    }
  }
}

@JsonSerializable()
class LiquidAmount {
  final LiquidUnit unit;
  final double amount;

  LiquidAmount({
    required this.unit,
    required this.amount,
  });

  factory LiquidAmount.fromJson(Map<String, dynamic> json) => _$LiquidAmountFromJson(json);

  Map<String, dynamic> toJson() => _$LiquidAmountToJson(this);
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
        return Icon(Icons.water_drop, size: 25);
      case PlantActionType.fertilizing:
        return Icon(Icons.emoji_nature, size: 25);
      case PlantActionType.pruning:
        return Icon(Icons.content_cut, size: 25);
      case PlantActionType.harvesting:
        return Icon(Icons.agriculture, size: 25);
      case PlantActionType.replanting:
        return Icon(Icons.eco, size: 25);
      case PlantActionType.training:
        return Icon(Icons.insights, size: 25);
      case PlantActionType.measuring:
        return Icon(Icons.analytics, size: 25);
      case PlantActionType.death:
        return Icon(Icons.warning_amber_outlined, size: 25);
      case PlantActionType.other:
        return Icon(Icons.miscellaneous_services, size: 25);
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
class PlantMeasurement {
  final PlantMeasurementType type;
  final Map<String, dynamic> measurement;

  PlantMeasurement({
    required this.type,
    required this.measurement,
  });

  factory PlantMeasurement.fromJson(Map<String, dynamic> json) => _$PlantMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$PlantMeasurementToJson(this);
}

@JsonSerializable()
class PlantWateringAction extends PlantAction {
  final LiquidAmount amount;

  PlantWateringAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.amount,
  });

  factory PlantWateringAction.fromJson(Map<String, dynamic> json) =>
      _$PlantWateringActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantWateringActionToJson(this);
}

@JsonSerializable()
class PlantFertilization {
  final String fertilizerId;
  final LiquidAmount amount;

  PlantFertilization({
    required this.fertilizerId,
    required this.amount,
  });

  factory PlantFertilization.fromJson(Map<String, dynamic> json) =>
      _$PlantFertilizationFromJson(json);

  Map<String, dynamic> toJson() => _$PlantFertilizationToJson(this);
}

@JsonSerializable()
class PlantFertilizingAction extends PlantAction {
  final PlantFertilization fertilization;

  PlantFertilizingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.fertilization,
  });

  factory PlantFertilizingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantFertilizingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantFertilizingActionToJson(this);
}

enum PruningType {
  topping,
  fim,
  lollipopping,
}

@JsonSerializable()
class PlantPruningAction extends PlantAction {
  final PruningType pruningType;

  PlantPruningAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.pruningType,
  });

  factory PlantPruningAction.fromJson(Map<String, dynamic> json) =>
      _$PlantPruningActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantPruningActionToJson(this);
}

enum WeightUnit {
  g,
  kg,
}

extension WeightUnitExtension on WeightUnit {
  String get name {
    switch (this) {
      case WeightUnit.g:
        return 'g';
      case WeightUnit.kg:
        return 'kg';
    }
  }
}

@JsonSerializable()
class WeightAmount {
  final WeightUnit unit;
  final double amount;

  WeightAmount({
    required this.unit,
    required this.amount,
  });

  factory WeightAmount.fromJson(Map<String, dynamic> json) => _$WeightAmountFromJson(json);

  Map<String, dynamic> toJson() => _$WeightAmountToJson(this);
}

@JsonSerializable()
class PlantHarvestingAction extends PlantAction {
  final WeightAmount amount;

  PlantHarvestingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.amount,
  });

  factory PlantHarvestingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantHarvestingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantHarvestingActionToJson(this);
}

@JsonSerializable()
class PlantReplantingAction extends PlantAction {
  PlantReplantingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantReplantingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantReplantingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantReplantingActionToJson(this);
}

enum TrainingType {
  lst,
  scrog,
}

@JsonSerializable()
class PlantTrainingAction extends PlantAction {
  final TrainingType trainingType;

  PlantTrainingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.trainingType,
  });

  factory PlantTrainingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantTrainingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantTrainingActionToJson(this);
}

enum PlantMeasurementType {
  height,
  pH,
  ec,
  ppm,
}

extension PlantMeasurementTypeExtension on PlantMeasurementType {
  String get name {
    switch (this) {
      case PlantMeasurementType.height:
        return 'Height';
      case PlantMeasurementType.pH:
        return 'pH';
      case PlantMeasurementType.ec:
        return 'EC';
      case PlantMeasurementType.ppm:
        return 'PPM';
    }
  }

  Icon get icon {
    switch (this) {
      case PlantMeasurementType.height:
        return Icon(Icons.height, size: 25);
      case PlantMeasurementType.pH:
        return Icon(Icons.ac_unit, size: 25);
      case PlantMeasurementType.ec:
        return Icon(Icons.water_damage, size: 25);
      case PlantMeasurementType.ppm:
        return Icon(Icons.water_damage, size: 25);
    }
  }
}

@JsonSerializable()
class PlantMeasuringAction extends PlantAction {
  final PlantMeasurement measurement;

  PlantMeasuringAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.measurement,
  });

  factory PlantMeasuringAction.fromJson(Map<String, dynamic> json) =>
      _$PlantMeasuringActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantMeasuringActionToJson(this);
}

@JsonSerializable()
class PlantDeathAction extends PlantAction {
  PlantDeathAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantDeathAction.fromJson(Map<String, dynamic> json) => _$PlantDeathActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantDeathActionToJson(this);
}

@JsonSerializable()
class PlantOtherAction extends PlantAction {
  PlantOtherAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantOtherAction.fromJson(Map<String, dynamic> json) => _$PlantOtherActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantOtherActionToJson(this);
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
