import 'package:json_annotation/json_annotation.dart';
import 'package:weedy/plants/model.dart';

part 'model.g.dart';

/// A class that represents a plant lifecycle transition.
@JsonSerializable()
class PlantLifecycleTransition {
  final LifeCycleState from;
  final LifeCycleState? to;
  final String plantId;
  final DateTime timestamp;

  PlantLifecycleTransition({
    required this.from,
    required this.to,
    required this.plantId,
    required this.timestamp,
  });

  factory PlantLifecycleTransition.fromJson(Map<String, dynamic> json) =>
      _$PlantLifecycleTransitionFromJson(json);

  Map<String, dynamic> toJson() => _$PlantLifecycleTransitionToJson(this);
}

/// A class that represents a list of plant lifecycle transitions.
@JsonSerializable()
class PlantLifecycleTransitions {
  List<PlantLifecycleTransition> transitions;

  PlantLifecycleTransitions({
    required this.transitions,
  });

  factory PlantLifecycleTransitions.fromJson(Map<String, dynamic> json) =>
      _$PlantLifecycleTransitionsFromJson(json);

  Map<String, dynamic> toJson() => _$PlantLifecycleTransitionsToJson(this);

  factory PlantLifecycleTransitions.standard() {
    return PlantLifecycleTransitions(
      transitions: [],
    );
  }
}
