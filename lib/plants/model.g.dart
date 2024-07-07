// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plants _$PlantsFromJson(Map<String, dynamic> json) => Plants(
      plants: (json['plants'] as List<dynamic>)
          .map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlantsToJson(Plants instance) => <String, dynamic>{
      'plants': instance.plants,
    };

Plant _$PlantFromJson(Map<String, dynamic> json) => Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      strainDetails: json['strainDetails'] == null
          ? null
          : StrainDetails.fromJson(json['strainDetails'] as Map<String, dynamic>),
      description: json['description'] as String,
      lifeCycleState: $enumDecode(_$LifeCycleStateEnumMap, json['lifeCycleState']),
      medium: $enumDecode(_$MediumEnumMap, json['medium']),
      environmentId: json['environmentId'] as String,
      bannerImagePath: json['bannerImagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PlantToJson(Plant instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'strainDetails': instance.strainDetails,
      'description': instance.description,
      'lifeCycleState': _$LifeCycleStateEnumMap[instance.lifeCycleState]!,
      'medium': _$MediumEnumMap[instance.medium]!,
      'bannerImagePath': instance.bannerImagePath,
      'createdAt': instance.createdAt.toIso8601String(),
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

const _$MediumEnumMap = {
  Medium.soil: 'soil',
  Medium.coco: 'coco',
  Medium.hydroponics: 'hydroponics',
};

StrainDetails _$StrainDetailsFromJson(Map<String, dynamic> json) => StrainDetails(
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$StrainDetailsToJson(StrainDetails instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
    };
