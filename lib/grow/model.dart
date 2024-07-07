import 'package:growlog/actions/fertilizer/model.dart';
import 'package:growlog/actions/model.dart';
import 'package:growlog/environments/model.dart';
import 'package:growlog/plants/model.dart';
import 'package:growlog/plants/relocation/model.dart';
import 'package:growlog/plants/transition/model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'model.g.dart';

@JsonSerializable()
class Grow {
  final String id;
  String name;
  List<Plant> plants;
  List<Environment> environments;

  @JsonKey(fromJson: _plantActionsFromJson)
  List<PlantAction> plantActions;

  @JsonKey(fromJson: _environmentActionsFromJson)
  List<EnvironmentAction> environmentActions;
  List<PlantLifecycleTransition> plantLifecycleTransitions;
  List<PlantRelocation> plantRelocations;

  List<Fertilizer> fertilizers;

  final DateTime createdAt;

  Grow({
    required this.id,
    required this.name,
    required this.plants,
    required this.environments,
    required this.plantActions,
    required this.environmentActions,
    required this.plantLifecycleTransitions,
    required this.plantRelocations,
    required this.fertilizers,
    required this.createdAt,
  });

  factory Grow.fromJson(Map<String, dynamic> json) => _$GrowFromJson(json);

  Map<String, dynamic> toJson() => _$GrowToJson(this);

  String formattedDate() {
    return timeago.format(createdAt, locale: 'en');
  }

  /// Create the implementations of the [PlantAction] classes from the JSON.
  static List<PlantAction> _plantActionsFromJson(List<dynamic> json) {
    return json.map((e) {
      var map = e as Map<String, dynamic>;
      switch (map['type'] as String) {
        case 'watering':
          return PlantWateringAction.fromJson(map);
        case 'fertilizing':
          return PlantFertilizingAction.fromJson(map);
        case 'pruning':
          return PlantPruningAction.fromJson(map);
        case 'harvesting':
          return PlantHarvestingAction.fromJson(map);
        case 'replanting':
          return PlantReplantingAction.fromJson(map);
        case 'training':
          return PlantTrainingAction.fromJson(map);
        case 'measurement':
          return PlantMeasurementAction.fromJson(map);
        case 'picture':
          return PlantPictureAction.fromJson(map);
        case 'death':
          return PlantDeathAction.fromJson(map);
        case 'other':
          return PlantOtherAction.fromJson(map);
        default:
          throw Exception('Unknown type for PlantAction: ${map['type']}');
      }
    }).toList();
  }

  /// Create the implementations of the [EnvironmentAction] classes from the JSON.
  static List<EnvironmentAction> _environmentActionsFromJson(List<dynamic> json) {
    return json.map((e) {
      var map = e as Map<String, dynamic>;
      switch (map['type'] as String) {
        case 'measurement':
          return EnvironmentMeasurementAction.fromJson(map);
        case 'picture':
          return EnvironmentPictureAction.fromJson(map);
        case 'other':
          return EnvironmentOtherAction.fromJson(map);
        default:
          throw Exception('Unknown type for EnvironmentAction: ${map['type']}');
      }
    }).toList();
  }
}

@JsonSerializable()
class Grows {
  List<Grow> grows;

  Grows({
    required this.grows,
  });

  factory Grows.fromJson(Map<String, dynamic> json) => _$GrowsFromJson(json);

  Map<String, dynamic> toJson() => _$GrowsToJson(this);

  factory Grows.standard() {
    return Grows(grows: []);
  }
}
