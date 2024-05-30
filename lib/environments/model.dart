import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Environments {
  final List<Environment> environments;

  Environments({
    required this.environments,
  });

  factory Environments.fromJson(Map<String, dynamic> json) => _$EnvironmentsFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentsToJson(this);

  factory Environments.standard() {
    return Environments(
      environments: [],
    );
  }
}

enum EnvironmentType {
  indoor,
  outdoor,
}

@JsonSerializable()
class Dimension {
  final double width;
  final double length;
  final double height;

  Dimension({
    required this.width,
    required this.length,
    required this.height,
  });

  factory Dimension.fromJson(Map<String, dynamic> json) => _$DimensionFromJson(json);
  Map<String, dynamic> toJson() => _$DimensionToJson(this);

}

@JsonSerializable()
class Environment {
  final String id;
  final String name;
  final String description;
  final EnvironmentType type;
  final LightDetails lightDetails;
  final Dimension dimension;

  Environment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lightDetails,
    required this.dimension,
  });

  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);
}

enum LightType {
  sunlight,
  cfl,
  led,
  hps,
  mh,
  lec,
}

@JsonSerializable()
class Light {
  final String id;
  final LightType type;
  final int watt;

  Light({
    required this.id,
    required this.type,
    required this.watt,
  });

  factory Light.fromJson(Map<String, dynamic> json) => _$LightFromJson(json);
  Map<String, dynamic> toJson() => _$LightToJson(this);
}

@JsonSerializable()
class LightDetails {
  final int lightHours;
  final List<Light> lights;

  LightDetails({
    required this.lightHours,
    required this.lights,
  });

  factory LightDetails.fromJson(Map<String, dynamic> json) => _$LightDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LightDetailsToJson(this);
}