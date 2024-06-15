import 'package:json_annotation/json_annotation.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'model.g.dart';

/// A class that represents an action.
@JsonSerializable()
class Action {
  final String id;
  final String description;
  final DateTime createdAt;

  Action({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  String get formattedDate => timeago.format(createdAt, locale: 'en');

  factory Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);

  Map<String, dynamic> toJson() => _$ActionToJson(this);

  /// Returns whether the action was created today.
  bool isToday() {
    return createdAt.day == DateTime.now().day &&
        createdAt.month == DateTime.now().month &&
        createdAt.year == DateTime.now().year;
  }
}

/// Represents a measurement type in the environment.
enum EnvironmentMeasurementType {
  temperature,
  humidity,
  co2,
  lightDistance,
}

/// Extension methods for the [EnvironmentMeasurementType] enum.
extension EnvironmentMeasurementTypeExtension on EnvironmentMeasurementType {
  /// Returns the name of the measurement type.
  String get name {
    switch (this) {
      case EnvironmentMeasurementType.temperature:
        return 'Temperature';
      case EnvironmentMeasurementType.humidity:
        return 'Humidity';
      case EnvironmentMeasurementType.co2:
        return 'CO2';
      case EnvironmentMeasurementType.lightDistance:
        return 'Light distance';
    }
  }

  /// Returns the icon of the measurement type.
  String get icon {
    switch (this) {
      case EnvironmentMeasurementType.temperature:
        return '🌡️';
      case EnvironmentMeasurementType.humidity:
        return '☔';
      case EnvironmentMeasurementType.co2:
        return '🏭';
      case EnvironmentMeasurementType.lightDistance:
        return '📏';
    }
  }
}

/// Represents an action in the environment.
enum EnvironmentActionType {
  measurement,
  picture,
  other,
}

/// Extension methods for the [EnvironmentActionType] enum.
extension EnvironmentActionTypeExtension on EnvironmentActionType {
  /// Returns the name of the action type.
  String get name {
    switch (this) {
      case EnvironmentActionType.measurement:
        return 'Measurement';
      case EnvironmentActionType.picture:
        return 'Picture';
      case EnvironmentActionType.other:
        return 'Other';
    }
  }

  /// Returns the icon of the action type.
  String get icon {
    switch (this) {
      case EnvironmentActionType.measurement:
        return '📐';
      case EnvironmentActionType.picture:
        return '📸';
      case EnvironmentActionType.other:
        return '❓';
    }
  }
}

/// Represents an action in the environment.
@JsonSerializable()
class EnvironmentAction extends Action {
  final String environmentId;
  final EnvironmentActionType type;

  EnvironmentAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.environmentId,
    required this.type,
  });

  factory EnvironmentAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentActionToJson(this);
}

/// Represents a measurement in the environment.
@JsonSerializable()
class EnvironmentMeasurementAction extends EnvironmentAction {
  final EnvironmentMeasurement measurement;

  EnvironmentMeasurementAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.environmentId,
    required super.type,
    required this.measurement,
  });

  factory EnvironmentMeasurementAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentMeasurementActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentMeasurementActionToJson(this);
}

/// Represents an action in the environment that is a picture.
@JsonSerializable()
class EnvironmentPictureAction extends EnvironmentAction {
  final List<String> images;

  EnvironmentPictureAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.environmentId,
    required super.type,
    required this.images,
  });

  factory EnvironmentPictureAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentPictureActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentPictureActionToJson(this);
}

//// Represents an arbitrary action in the environment.
@JsonSerializable()
class EnvironmentOtherAction extends EnvironmentAction {
  EnvironmentOtherAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.environmentId,
    required super.type,
  });

  factory EnvironmentOtherAction.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentOtherActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnvironmentOtherActionToJson(this);
}

/// Arbitrary measurement representation in the environment
@JsonSerializable()
class EnvironmentMeasurement {
  final EnvironmentMeasurementType type;

  final Map<String, dynamic> measurement;

  EnvironmentMeasurement({
    required this.type,
    required this.measurement,
  });

  factory EnvironmentMeasurement.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentMeasurementToJson(this);
}

/// Represents a liquid unit.
enum LiquidUnit {
  ml,
  l,
}

/// Extension methods for the [LiquidUnit] enum.
extension WateringUnitExtension on LiquidUnit {
  /// Returns the name of the liquid unit.
  String get name {
    switch (this) {
      case LiquidUnit.ml:
        return 'ml';
      case LiquidUnit.l:
        return 'l';
    }
  }
}

/// Represents a liquid amount.
@JsonSerializable()
class LiquidAmount {
  final LiquidUnit unit;
  final double amount;

  LiquidAmount({
    required this.unit,
    required this.amount,
  });

  factory LiquidAmount.fromJson(Map<String, dynamic> json) => _$LiquidAmountFromJson(json);

  Map<String, dynamic> toJson() => _$LiquidAmountToJson(this);
}

/// Represents a plant action type.
enum PlantActionType {
  watering,
  fertilizing,
  pruning,
  harvesting,
  replanting,
  training,
  measuring,
  picture,
  death,
  other,
}

/// Extension methods for the [PlantActionType] enum.
extension PlantActionTypeExtension on PlantActionType {
  /// Returns the name of the plant action type.
  String get name {
    switch (this) {
      case PlantActionType.watering:
        return 'Watering';
      case PlantActionType.fertilizing:
        return 'Fertilizing';
      case PlantActionType.pruning:
        return 'Pruning';
      case PlantActionType.harvesting:
        return 'Harvesting';
      case PlantActionType.replanting:
        return 'Replanting';
      case PlantActionType.training:
        return 'Training';
      case PlantActionType.measuring:
        return 'Measuring';
      case PlantActionType.picture:
        return 'Picture';
      case PlantActionType.death:
        return 'Death';
      case PlantActionType.other:
        return 'Other';
    }
  }

  /// Returns the icon of the plant action type.
  String get icon {
    switch (this) {
      case PlantActionType.watering:
        return '💧';
      case PlantActionType.fertilizing:
        return '🧪';
      case PlantActionType.pruning:
        return '✂️';
      case PlantActionType.harvesting:
        return '🧺';
      case PlantActionType.replanting:
        return '🔄';
      case PlantActionType.training:
        return '🏋️‍♂️';
      case PlantActionType.measuring:
        return '📐';
      case PlantActionType.picture:
        return '📸';
      case PlantActionType.death:
        return '🪦';
      case PlantActionType.other:
        return '❓';
    }
  }
}

/// Represents a plant action.
@JsonSerializable()
class PlantAction extends Action {
  final String plantId;
  final PlantActionType type;

  PlantAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required this.plantId,
    required this.type,
  });

  factory PlantAction.fromJson(Map<String, dynamic> json) => _$PlantActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantActionToJson(this);
}

/// Represents an arbitrary plant measurement.
@JsonSerializable()
class PlantMeasurement {
  final PlantMeasurementType type;
  final Map<String, dynamic> measurement;

  PlantMeasurement({
    required this.type,
    required this.measurement,
  });

  factory PlantMeasurement.fromJson(Map<String, dynamic> json) => _$PlantMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$PlantMeasurementToJson(this);
}

/// Represents a watering action.
@JsonSerializable()
class PlantWateringAction extends PlantAction {
  final LiquidAmount amount;

  PlantWateringAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.amount,
  });

  factory PlantWateringAction.fromJson(Map<String, dynamic> json) =>
      _$PlantWateringActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantWateringActionToJson(this);
}

/// Represents a plant fertilization.
@JsonSerializable()
class PlantFertilization {
  final String fertilizerId;
  final LiquidAmount amount;

  PlantFertilization({
    required this.fertilizerId,
    required this.amount,
  });

  factory PlantFertilization.fromJson(Map<String, dynamic> json) =>
      _$PlantFertilizationFromJson(json);

  Map<String, dynamic> toJson() => _$PlantFertilizationToJson(this);
}

/// Represents a fertilizing action.
@JsonSerializable()
class PlantFertilizingAction extends PlantAction {
  final PlantFertilization fertilization;

  PlantFertilizingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.fertilization,
  });

  factory PlantFertilizingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantFertilizingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantFertilizingActionToJson(this);
}

/// Represents a pruning type.
enum PruningType {
  topping,
  fim,
  lollipopping,
}

/// Extension methods for the [PruningType] enum.
extension PruningTypeExtension on PruningType {
  /// Returns the name of the pruning type.
  String get name {
    switch (this) {
      case PruningType.topping:
        return 'Topping';
      case PruningType.fim:
        return 'FIM';
      case PruningType.lollipopping:
        return 'Lollipopping';
    }
  }
}

/// Represents a pruning action.
@JsonSerializable()
class PlantPruningAction extends PlantAction {
  final PruningType pruningType;

  PlantPruningAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.pruningType,
  });

  factory PlantPruningAction.fromJson(Map<String, dynamic> json) =>
      _$PlantPruningActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantPruningActionToJson(this);
}

/// Represents a weight unit.
enum WeightUnit {
  g,
  kg,
}

/// Extension methods for the [WeightUnit] enum.
extension WeightUnitExtension on WeightUnit {
  /// Returns the name of the weight unit.
  String get name {
    switch (this) {
      case WeightUnit.g:
        return 'g';
      case WeightUnit.kg:
        return 'kg';
    }
  }
}

/// Represents a weight amount.
@JsonSerializable()
class WeightAmount {
  final WeightUnit unit;
  final double amount;

  WeightAmount({
    required this.unit,
    required this.amount,
  });

  factory WeightAmount.fromJson(Map<String, dynamic> json) => _$WeightAmountFromJson(json);

  Map<String, dynamic> toJson() => _$WeightAmountToJson(this);
}

/// Represents a harvesting action.
@JsonSerializable()
class PlantHarvestingAction extends PlantAction {
  final WeightAmount amount;

  PlantHarvestingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.amount,
  });

  factory PlantHarvestingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantHarvestingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantHarvestingActionToJson(this);
}

/// Represents a replanting action.
@JsonSerializable()
class PlantReplantingAction extends PlantAction {
  PlantReplantingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantReplantingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantReplantingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantReplantingActionToJson(this);
}

/// Represents a plant training type.
enum TrainingType {
  lst,
  scrog,
}

/// Extension methods for the [TrainingType] enum.
extension TrainingTypeExtension on TrainingType {
  /// Returns the name of the training type.
  String get name {
    switch (this) {
      case TrainingType.lst:
        return 'LST';
      case TrainingType.scrog:
        return 'SCROG';
    }
  }
}

/// Represents a training action.
@JsonSerializable()
class PlantTrainingAction extends PlantAction {
  final TrainingType trainingType;

  PlantTrainingAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.trainingType,
  });

  factory PlantTrainingAction.fromJson(Map<String, dynamic> json) =>
      _$PlantTrainingActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantTrainingActionToJson(this);
}

/// Represents a plant measuring type.
enum PlantMeasurementType {
  height,
  pH,
  ec,
  ppm,
}

/// Extension methods for the [PlantMeasurementType] enum.
extension PlantMeasurementTypeExtension on PlantMeasurementType {
  /// Returns the name of the plant measurement type.
  String get name {
    switch (this) {
      case PlantMeasurementType.height:
        return 'Height';
      case PlantMeasurementType.pH:
        return 'pH';
      case PlantMeasurementType.ec:
        return 'EC';
      case PlantMeasurementType.ppm:
        return 'PPM';
    }
  }

  /// Returns the icon of the plant measurement type.
  String get icon {
    switch (this) {
      case PlantMeasurementType.height:
        return '📏';
      case PlantMeasurementType.pH:
        return '📈';
      case PlantMeasurementType.ec:
        return '🔬';
      case PlantMeasurementType.ppm:
        return '🔢';
    }
  }
}

/// Represents a measuring action.
@JsonSerializable()
class PlantMeasuringAction extends PlantAction {
  final PlantMeasurement measurement;

  PlantMeasuringAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.measurement,
  });

  factory PlantMeasuringAction.fromJson(Map<String, dynamic> json) =>
      _$PlantMeasuringActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantMeasuringActionToJson(this);
}

/// Represents a plants death.
@JsonSerializable()
class PlantDeathAction extends PlantAction {
  PlantDeathAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantDeathAction.fromJson(Map<String, dynamic> json) => _$PlantDeathActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantDeathActionToJson(this);
}

/// Represents a plant picture action.
@JsonSerializable()
class PlantPictureAction extends PlantAction {
  final List<String> images;

  PlantPictureAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
    required this.images,
  });

  factory PlantPictureAction.fromJson(Map<String, dynamic> json) =>
      _$PlantPictureActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantPictureActionToJson(this);
}

/// Represents an arbitrary plant action.
@JsonSerializable()
class PlantOtherAction extends PlantAction {
  PlantOtherAction({
    required super.id,
    required super.description,
    required super.createdAt,
    required super.plantId,
    required super.type,
  });

  factory PlantOtherAction.fromJson(Map<String, dynamic> json) => _$PlantOtherActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlantOtherActionToJson(this);
}

/// Represents a collection of plant and environment actions.
@JsonSerializable()
class Actions {
  List<PlantAction> plantActions;
  List<EnvironmentAction> environmentActions;

  Actions({
    required this.plantActions,
    required this.environmentActions,
  });

  factory Actions.fromJson(Map<String, dynamic> json) => _$ActionsFromJson(json);

  Map<String, dynamic> toJson() => _$ActionsToJson(this);

  factory Actions.standard() {
    return Actions(
      plantActions: [],
      environmentActions: [],
    );
  }
}
