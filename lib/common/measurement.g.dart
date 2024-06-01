// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeasurementAmount _$MeasurementAmountFromJson(Map<String, dynamic> json) =>
    MeasurementAmount(
      value: (json['value'] as num).toDouble(),
      unit: $enumDecode(_$MeasurementUnitEnumMap, json['unit']),
    );

Map<String, dynamic> _$MeasurementAmountToJson(MeasurementAmount instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': _$MeasurementUnitEnumMap[instance.unit]!,
    };

const _$MeasurementUnitEnumMap = {
  MeasurementUnit.cm: 'cm',
  MeasurementUnit.m: 'm',
};
