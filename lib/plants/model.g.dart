// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      lifeCycleState:
          $enumDecode(_$LifeCycleStateEnumMap, json['lifeCycleState']),
      environmentId: json['environmentId'] as String,
    );

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'lifeCycleState': _$LifeCycleStateEnumMap[instance.lifeCycleState]!,
      'environmentId': instance.environmentId,
    };

const _$LifeCycleStateEnumMap = {
  LifeCycleState.germination: 'germination',
  LifeCycleState.seedling: 'seedling',
  LifeCycleState.vegetative: 'vegetative',
  LifeCycleState.flowering: 'flowering',
  LifeCycleState.drying: 'drying',
  LifeCycleState.curing: 'curing',
};
