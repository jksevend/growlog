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
      measurement: json['measurement'] == null
          ? null
          : EnvironmentMeasurement.fromJson(
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

PlantAction _$PlantActionFromJson(Map<String, dynamic> json) => PlantAction(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      plantId: json['plantId'] as String,
      type: $enumDecode(_$PlantActionTypeEnumMap, json['type']),
      measurement: json['measurement'] == null
          ? null
          : PlantMeasurement.fromJson(
              json['measurement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlantActionToJson(PlantAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'plantId': instance.plantId,
      'type': _$PlantActionTypeEnumMap[instance.type]!,
      'measurement': instance.measurement,
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
    );

Map<String, dynamic> _$PlantMeasurementToJson(PlantMeasurement instance) =>
    <String, dynamic>{
      'type': _$PlantMeasurementTypeEnumMap[instance.type]!,
    };

const _$PlantMeasurementTypeEnumMap = {
  PlantMeasurementType.height: 'height',
  PlantMeasurementType.pH: 'pH',
  PlantMeasurementType.ec: 'ec',
  PlantMeasurementType.ppm: 'ppm',
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
