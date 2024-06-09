import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum Medium {
  soil,
  coco,
  hydroponics,
}

extension MediumExtension on Medium {
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

enum LifeCycleState {
  germination,
  seedling,
  vegetative,
  flowering,
  drying,
  curing,
}

extension LifeCycleStateExtension on LifeCycleState {
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

@JsonSerializable()
class Plant {
  final String id;
  final String name;
  final String description;
  final LifeCycleState lifeCycleState;
  final Medium medium;
  final String bannerImagePath;

  String environmentId;

  Plant({
    required this.id,
    required this.name,
    required this.description,
    required this.lifeCycleState,
    required this.medium,
    required this.environmentId,
    required this.bannerImagePath,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

  Map<String, dynamic> toJson() => _$PlantToJson(this);


}
