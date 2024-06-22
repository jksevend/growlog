import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weedy/common/measurement.dart';

part 'model.g.dart';

/// The environments that are available in the application.
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

/// The type of environment.
enum EnvironmentType {
  indoor,
  outdoor,
}

/// An extension on the [EnvironmentType] enum.
extension EnvironmentTypeExtension on EnvironmentType {
  /// The name of the environment type.
  String get name {
    switch (this) {
      case EnvironmentType.indoor:
        return tr('common.indoor');
      case EnvironmentType.outdoor:
        return tr('common.outdoor');
    }
  }

  /// The icon of the environment type.
  String get icon {
    switch (this) {
      case EnvironmentType.indoor:
        return '🏠';
      case EnvironmentType.outdoor:
        return '🌻';
    }
  }
}

/// The dimension of an environment.
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

/// An environment in which plants can grow.
@JsonSerializable()
class Environment {
  final String id;
  final String name;
  final String description;
  final EnvironmentType type;
  final LightDetails lightDetails;
  final Dimension? dimension;
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

/// The type of light.
enum LightType {
  sunlight,
  cfl,
  led,
  hps,
  mh,
  lec,
}

/// An extension on the [LightType] enum.
extension LightTypeExtension on LightType {
  /// The name of the light type.
  String get name {
    switch (this) {
      case LightType.sunlight:
        return tr('common.sunlight');
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

/// A light source in an environment.
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
