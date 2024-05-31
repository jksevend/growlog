// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Distance _$DistanceFromJson(Map<String, dynamic> json) => Distance(
      value: (json['value'] as num).toDouble(),
      unit: $enumDecode(_$DistanceUnitEnumMap, json['unit']),
    );

Map<String, dynamic> _$DistanceToJson(Distance instance) => <String, dynamic>{
      'value': instance.value,
      'unit': _$DistanceUnitEnumMap[instance.unit]!,
    };

const _$DistanceUnitEnumMap = {
  DistanceUnit.cm: 'cm',
  DistanceUnit.m: 'm',
};
