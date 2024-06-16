import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// The medium in which a plant is grown.
enum Medium {
  soil,
  coco,
  hydroponics,
}

/// The plants that are available in the application.
extension MediumExtension on Medium {
  /// The name of the medium.
  String get name {
    switch (this) {
      case Medium.soil:
        return 'Soil';
      case Medium.coco:
        return 'Coco';
      case Medium.hydroponics:
        return 'Hydroponics';
    }
  }
}

/// The plants that are available in the application.
@JsonSerializable()
class Plants {
  List<Plant> plants;

  Plants({
    required this.plants,
  });

  factory Plants.fromJson(Map<String, dynamic> json) => _$PlantsFromJson(json);

  Map<String, dynamic> toJson() => _$PlantsToJson(this);

  factory Plants.standard() {
    return Plants(
      plants: [],
    );
  }
}

/// The life cycle state of a plant.
enum LifeCycleState {
  germination,
  seedling,
  vegetative,
  flowering,
  drying,
  curing,
}

/// An extension on the [LifeCycleState] enum.
extension LifeCycleStateExtension on LifeCycleState {
  /// The name of the life cycle state.
  String get name {
    switch (this) {
      case LifeCycleState.germination:
        return 'Germination';
      case LifeCycleState.seedling:
        return 'Seedling';
      case LifeCycleState.vegetative:
        return 'Vegetative';
      case LifeCycleState.flowering:
        return 'Flowering';
      case LifeCycleState.drying:
        return 'Drying';
      case LifeCycleState.curing:
        return 'Curing';
    }
  }

  /// The icon of the life cycle state.
  String get icon {
    switch (this) {
      case LifeCycleState.germination:
        return '🌱';
      case LifeCycleState.seedling:
        return '🌿';
      case LifeCycleState.vegetative:
        return '🪴';
      case LifeCycleState.flowering:
        return '🌸';
      case LifeCycleState.drying:
        return '🍂';
      case LifeCycleState.curing:
        return '🍁';
    }
  }
}

/// A plant that can be grown in the application.
@JsonSerializable()
class Plant {
  final String id;
  final String name;
  final String description;
  final LifeCycleState lifeCycleState;
  final Medium medium;
  final String bannerImagePath;
  final DateTime createdAt;

  String environmentId;

  Plant({
    required this.id,
    required this.name,
    required this.description,
    required this.lifeCycleState,
    required this.medium,
    required this.environmentId,
    required this.bannerImagePath,
    required this.createdAt,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);
}
