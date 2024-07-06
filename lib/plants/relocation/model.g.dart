// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlantRelocation _$PlantRelocationFromJson(Map<String, dynamic> json) => PlantRelocation(
      plantId: json['plantId'] as String,
      environmentIdFrom: json['environmentIdFrom'] as String,
      environmentIdTo: json['environmentIdTo'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$PlantRelocationToJson(PlantRelocation instance) => <String, dynamic>{
      'plantId': instance.plantId,
      'environmentIdFrom': instance.environmentIdFrom,
      'environmentIdTo': instance.environmentIdTo,
      'timestamp': instance.timestamp.toIso8601String(),
    };

PlantRelocations _$PlantRelocationsFromJson(Map<String, dynamic> json) => PlantRelocations(
      relocations: (json['relocations'] as List<dynamic>)
          .map((e) => PlantRelocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlantRelocationsToJson(PlantRelocations instance) => <String, dynamic>{
      'relocations': instance.relocations,
    };
