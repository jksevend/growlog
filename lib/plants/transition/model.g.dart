// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantLifecycleTransition _$PlantLifecycleTransitionFromJson(Map<String, dynamic> json) =>
    PlantLifecycleTransition(
      from: $enumDecode(_$LifeCycleStateEnumMap, json['from']),
      to: $enumDecodeNullable(_$LifeCycleStateEnumMap, json['to']),
      plantId: json['plantId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$PlantLifecycleTransitionToJson(PlantLifecycleTransition instance) =>
    <String, dynamic>{
      'from': _$LifeCycleStateEnumMap[instance.from]!,
      'to': _$LifeCycleStateEnumMap[instance.to],
      'plantId': instance.plantId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$LifeCycleStateEnumMap = {
  LifeCycleState.germination: 'germination',
  LifeCycleState.seedling: 'seedling',
  LifeCycleState.vegetative: 'vegetative',
  LifeCycleState.flowering: 'flowering',
  LifeCycleState.drying: 'drying',
  LifeCycleState.curing: 'curing',
};

PlantLifecycleTransitions _$PlantLifecycleTransitionsFromJson(Map<String, dynamic> json) =>
    PlantLifecycleTransitions(
      transitions: (json['transitions'] as List<dynamic>)
          .map((e) => PlantLifecycleTransition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlantLifecycleTransitionsToJson(PlantLifecycleTransitions instance) =>
    <String, dynamic>{
      'transitions': instance.transitions,
    };
