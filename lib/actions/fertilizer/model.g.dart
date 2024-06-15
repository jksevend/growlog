// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fertilizer _$FertilizerFromJson(Map<String, dynamic> json) => Fertilizer(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$FertilizerToJson(Fertilizer instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

Fertilizers _$FertilizersFromJson(Map<String, dynamic> json) => Fertilizers(
      fertilizers: (json['fertilizers'] as List<dynamic>)
          .map((e) => Fertilizer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FertilizersToJson(Fertilizers instance) => <String, dynamic>{
      'fertilizers': instance.fertilizers,
    };
