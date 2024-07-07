// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grow _$GrowFromJson(Map<String, dynamic> json) => Grow(
      id: json['id'] as String,
      name: json['name'] as String,
      plants: (json['plants'] as List<dynamic>)
          .map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList(),
      environments: (json['environments'] as List<dynamic>)
          .map((e) => Environment.fromJson(e as Map<String, dynamic>))
          .toList(),
      plantActions: Grow._plantActionsFromJson(json['plantActions'] as List),
      environmentActions: Grow._environmentActionsFromJson(json['environmentActions'] as List),
      plantLifecycleTransitions: (json['plantLifecycleTransitions'] as List<dynamic>)
          .map((e) => PlantLifecycleTransition.fromJson(e as Map<String, dynamic>))
          .toList(),
      plantRelocations: (json['plantRelocations'] as List<dynamic>)
          .map((e) => PlantRelocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      fertilizers: (json['fertilizers'] as List<dynamic>)
          .map((e) => Fertilizer.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GrowToJson(Grow instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'plants': instance.plants,
      'environments': instance.environments,
      'plantActions': instance.plantActions,
      'environmentActions': instance.environmentActions,
      'plantLifecycleTransitions': instance.plantLifecycleTransitions,
      'plantRelocations': instance.plantRelocations,
      'fertilizers': instance.fertilizers,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Grows _$GrowsFromJson(Map<String, dynamic> json) => Grows(
      grows: (json['grows'] as List<dynamic>)
          .map((e) => Grow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrowsToJson(Grows instance) => <String, dynamic>{
      'grows': instance.grows,
    };
