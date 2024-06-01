// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Action _$ActionFromJson(Map<String, dynamic> json) => Action(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ActionToJson(Action instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };

EnvironmentAction _$EnvironmentActionFromJson(Map<String, dynamic> json) =>
    EnvironmentAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      environmentId: json['environmentId'] as String,
      measurement: EnvironmentMeasurement.fromJson(
          json['measurement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EnvironmentActionToJson(EnvironmentAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'environmentId': instance.environmentId,
      'measurement': instance.measurement,
    };

EnvironmentMeasurement _$EnvironmentMeasurementFromJson(
        Map<String, dynamic> json) =>
    EnvironmentMeasurement(
      type: $enumDecode(_$EnvironmentMeasurementTypeEnumMap, json['type']),
      measurement: json['measurement'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EnvironmentMeasurementToJson(
        EnvironmentMeasurement instance) =>
    <String, dynamic>{
      'type': _$EnvironmentMeasurementTypeEnumMap[instance.type]!,
      'measurement': instance.measurement,
    };

const _$EnvironmentMeasurementTypeEnumMap = {
  EnvironmentMeasurementType.temperature: 'temperature',
  EnvironmentMeasurementType.humidity: 'humidity',
  EnvironmentMeasurementType.co2: 'co2',
  EnvironmentMeasurementType.lightDistance: 'lightDistance',
  EnvironmentMeasurementType.other: 'other',
};

LiquidAmount _$LiquidAmountFromJson(Map<String, dynamic> json) => LiquidAmount(
      unit: $enumDecode(_$LiquidUnitEnumMap, json['unit']),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$LiquidAmountToJson(LiquidAmount instance) =>
    <String, dynamic>{
      'unit': _$LiquidUnitEnumMap[instance.unit]!,
      'amount': instance.amount,
    };

const _$LiquidUnitEnumMap = {
  LiquidUnit.ml: 'ml',
  LiquidUnit.l: 'l',
};

PlantAction _$PlantActionFromJson(Map<String, dynamic> json) => PlantAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PlantActionToJson(PlantAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
    };

const _$PlantActionTypeEnumMap = {
  PlantActionType.watering: 'watering',
  PlantActionType.fertilizing: 'fertilizing',
  PlantActionType.pruning: 'pruning',
  PlantActionType.harvesting: 'harvesting',
  PlantActionType.replanting: 'replanting',
  PlantActionType.training: 'training',
  PlantActionType.measuring: 'measuring',
  PlantActionType.death: 'death',
  PlantActionType.other: 'other',
};

PlantMeasurement _$PlantMeasurementFromJson(Map<String, dynamic> json) =>
    PlantMeasurement(
      type: $enumDecode(_$PlantMeasurementTypeEnumMap, json['type']),
      measurement: json['measurement'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PlantMeasurementToJson(PlantMeasurement instance) =>
    <String, dynamic>{
      'type': _$PlantMeasurementTypeEnumMap[instance.type]!,
      'measurement': instance.measurement,
    };

const _$PlantMeasurementTypeEnumMap = {
  PlantMeasurementType.height: 'height',
  PlantMeasurementType.pH: 'pH',
  PlantMeasurementType.ec: 'ec',
  PlantMeasurementType.ppm: 'ppm',
};

PlantWateringAction _$PlantWateringActionFromJson(Map<String, dynamic> json) =>
    PlantWateringAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      amount: LiquidAmount.fromJson(json['amount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantWateringActionToJson(
        PlantWateringAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
    };

PlantFertilization _$PlantFertilizationFromJson(Map<String, dynamic> json) =>
    PlantFertilization(
      fertilizerId: json['fertilizerId'] as String,
      amount: LiquidAmount.fromJson(json['amount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantFertilizationToJson(PlantFertilization instance) =>
    <String, dynamic>{
      'fertilizerId': instance.fertilizerId,
      'amount': instance.amount,
    };

PlantFertilizingAction _$PlantFertilizingActionFromJson(
        Map<String, dynamic> json) =>
    PlantFertilizingAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      fertilization: PlantFertilization.fromJson(
          json['fertilization'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantFertilizingActionToJson(
        PlantFertilizingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'fertilization': instance.fertilization,
    };

PlantPruningAction _$PlantPruningActionFromJson(Map<String, dynamic> json) =>
    PlantPruningAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      pruningType: $enumDecode(_$PruningTypeEnumMap, json['pruningType']),
    );

Map<String, dynamic> _$PlantPruningActionToJson(PlantPruningAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'pruningType': _$PruningTypeEnumMap[instance.pruningType]!,
    };

const _$PruningTypeEnumMap = {
  PruningType.topping: 'topping',
  PruningType.fim: 'fim',
  PruningType.lollipopping: 'lollipopping',
};

WeightAmount _$WeightAmountFromJson(Map<String, dynamic> json) => WeightAmount(
      unit: $enumDecode(_$WeightUnitEnumMap, json['unit']),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$WeightAmountToJson(WeightAmount instance) =>
    <String, dynamic>{
      'unit': _$WeightUnitEnumMap[instance.unit]!,
      'amount': instance.amount,
    };

const _$WeightUnitEnumMap = {
  WeightUnit.g: 'g',
  WeightUnit.kg: 'kg',
};

PlantHarvestingAction _$PlantHarvestingActionFromJson(
        Map<String, dynamic> json) =>
    PlantHarvestingAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      amount: WeightAmount.fromJson(json['amount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantHarvestingActionToJson(
        PlantHarvestingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
    };

PlantReplantingAction _$PlantReplantingActionFromJson(
        Map<String, dynamic> json) =>
    PlantReplantingAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PlantReplantingActionToJson(
        PlantReplantingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
    };

PlantTrainingAction _$PlantTrainingActionFromJson(Map<String, dynamic> json) =>
    PlantTrainingAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      trainingType: $enumDecode(_$TrainingTypeEnumMap, json['trainingType']),
    );

Map<String, dynamic> _$PlantTrainingActionToJson(
        PlantTrainingAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'trainingType': _$TrainingTypeEnumMap[instance.trainingType]!,
    };

const _$TrainingTypeEnumMap = {
  TrainingType.lst: 'lst',
  TrainingType.scrog: 'scrog',
};

PlantMeasuringAction _$PlantMeasuringActionFromJson(
        Map<String, dynamic> json) =>
    PlantMeasuringAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      measurement: PlantMeasurement.fromJson(
          json['measurement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantMeasuringActionToJson(
        PlantMeasuringAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'measurement': instance.measurement,
    };

PlantDeathAction _$PlantDeathActionFromJson(Map<String, dynamic> json) =>
    PlantDeathAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PlantDeathActionToJson(PlantDeathAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
    };

PlantOtherAction _$PlantOtherActionFromJson(Map<String, dynamic> json) =>
    PlantOtherAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PlantOtherActionToJson(PlantOtherAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
    };

Actions _$ActionsFromJson(Map<String, dynamic> json) => Actions(
      plantActions: (json['plantActions'] as List<dynamic>)
          .map((e) => PlantAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      environmentActions: (json['environmentActions'] as List<dynamic>)
          .map((e) => EnvironmentAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActionsToJson(Actions instance) => <String, dynamic>{
      'plantActions': instance.plantActions,
      'environmentActions': instance.environmentActions,
    };
