// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Environments _$EnvironmentsFromJson(Map<String, dynamic> json) => Environments(
      environments: (json['environments'] as List<dynamic>)
          .map((e) => Environment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EnvironmentsToJson(Environments instance) => <String, dynamic>{
      'environments': instance.environments,
    };

Dimension _$DimensionFromJson(Map<String, dynamic> json) => Dimension(
      width: MeasurementAmount.fromJson(json['width'] as Map<String, dynamic>),
      length: MeasurementAmount.fromJson(json['length'] as Map<String, dynamic>),
      height: MeasurementAmount.fromJson(json['height'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DimensionToJson(Dimension instance) => <String, dynamic>{
      'width': instance.width,
      'length': instance.length,
      'height': instance.height,
    };

Environment _$EnvironmentFromJson(Map<String, dynamic> json) => Environment(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$EnvironmentTypeEnumMap, json['type']),
      lightDetails: LightDetails.fromJson(json['lightDetails'] as Map<String, dynamic>),
      dimension: Dimension.fromJson(json['dimension'] as Map<String, dynamic>),
      bannerImagePath: json['bannerImagePath'] as String,
    );

Map<String, dynamic> _$EnvironmentToJson(Environment instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$EnvironmentTypeEnumMap[instance.type]!,
      'lightDetails': instance.lightDetails,
      'dimension': instance.dimension,
      'bannerImagePath': instance.bannerImagePath,
    };

const _$EnvironmentTypeEnumMap = {
  EnvironmentType.indoor: 'indoor',
  EnvironmentType.outdoor: 'outdoor',
};

Light _$LightFromJson(Map<String, dynamic> json) => Light(
      id: json['id'] as String,
      type: $enumDecode(_$LightTypeEnumMap, json['type']),
      watt: (json['watt'] as num).toDouble(),
    );

Map<String, dynamic> _$LightToJson(Light instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$LightTypeEnumMap[instance.type]!,
      'watt': instance.watt,
    };

const _$LightTypeEnumMap = {
  LightType.sunlight: 'sunlight',
  LightType.cfl: 'cfl',
  LightType.led: 'led',
  LightType.hps: 'hps',
  LightType.mh: 'mh',
  LightType.lec: 'lec',
};

LightDetails _$LightDetailsFromJson(Map<String, dynamic> json) => LightDetails(
      lightHours: (json['lightHours'] as num).toInt(),
      lights: (json['lights'] as List<dynamic>)
          .map((e) => Light.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LightDetailsToJson(LightDetails instance) => <String, dynamic>{
      'lightHours': instance.lightHours,
      'lights': instance.lights,
    };
