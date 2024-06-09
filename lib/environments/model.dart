import 'package:json_annotation/json_annotation.dart';
import 'package:weedy/common/measurement.dart';

part 'model.g.dart';

@JsonSerializable()
class Environments {
  List<Environment> environments;

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

extension EnvironmentTypeExtension on EnvironmentType {
  String get name {
    switch (this) {
      case EnvironmentType.indoor:
        return 'Indoor';
      case EnvironmentType.outdoor:
        return 'Outdoor';
    }
  }

  String get icon {
    switch (this) {
      case EnvironmentType.indoor:
        return '🏠';
      case EnvironmentType.outdoor:
        return '🌻';
    }
  }
}

@JsonSerializable()
class Dimension {
  final MeasurementAmount width;
  final MeasurementAmount length;
  final MeasurementAmount height;

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
  final String bannerImagePath;

  Environment({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.lightDetails,
    required this.dimension,
    required this.bannerImagePath,
  });

  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);

  Environment copyWith({
    required String name,
    required String description,
    required EnvironmentType type,
    required LightDetails lightDetails,
    required Dimension dimension,
    required String bannerImagePath,
  }) {
    return Environment(
      id: id,
      name: name,
      description: description,
      type: type,
      lightDetails: lightDetails,
      bannerImagePath: bannerImagePath,
      dimension: dimension,
    );
  }
}

enum LightType {
  sunlight,
  cfl,
  led,
  hps,
  mh,
  lec,
}

extension LightTypeExtension on LightType {
  String get name {
    switch (this) {
      case LightType.sunlight:
        return 'Sunlight';
      case LightType.cfl:
        return 'CFL';
      case LightType.led:
        return 'LED';
      case LightType.hps:
        return 'HPS';
      case LightType.mh:
        return 'MH';
      case LightType.lec:
        return 'LEC';
    }
  }
}

@JsonSerializable()
class Light {
  final String id;
  final LightType type;
  final double watt;

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
