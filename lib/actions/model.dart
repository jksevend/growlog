import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'model.g.dart';

/// An action.
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

  bool isToday() {
    return createdAt.day == DateTime.now().day &&
        createdAt.month == DateTime.now().month &&
        createdAt.year == DateTime.now().year;
  }
}

/// The environment measurement types.
enum EnvironmentMeasurementType {
  temperature,
  humidity,
  co2,
  lightDistance,
}

/// An extension for [EnvironmentMeasurementType]
extension EnvironmentMeasurementTypeExtension on EnvironmentMeasurementType {
  /// The name of the environment measurement type.
  String get name {
    switch (this) {
      case EnvironmentMeasurementType.temperature:
        return tr('common.temperature');
      case EnvironmentMeasurementType.humidity:
        return tr('common.humidity');
      case EnvironmentMeasurementType.co2:
        return 'CO2';
      case EnvironmentMeasurementType.lightDistance:
        return tr('common.light_distance');
    }
  }

  /// The icon of the environment measurement type.
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

/// An environment action.
enum EnvironmentActionType {
  measurement,
  picture,
  other,
}

/// An extension for [EnvironmentActionType]
extension EnvironmentActionTypeExtension on EnvironmentActionType {
  /// The name of the environment action type.
  String get name {
    switch (this) {
      case EnvironmentActionType.measurement:
        return tr('common.measurement');
      case EnvironmentActionType.picture:
        return tr('common.picture');
      case EnvironmentActionType.other:
        return tr('common.other');
    }
  }

  /// The icon of the environment action type.
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

/// An environment action.
@JsonSerializable()
class EnvironmentAction extends Action {
  final String environmentId;
  final EnvironmentActionType type;

  /// Creates a new environment action.
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

/// An environment measurement action.
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

/// An environment picture action.
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

/// An arbitrary environment action.
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

/// A environment measurement.
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

/// The liquid units.
enum LiquidUnit {
  ml,
  l,
}

/// An extension for [LiquidUnit]
extension WateringUnitExtension on LiquidUnit {
  /// The name of the liquid unit.
  String get name {
    switch (this) {
      case LiquidUnit.ml:
        return 'ml';
      case LiquidUnit.l:
        return 'l';
    }
  }
}

/// A liquid amount.
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

/// The plant action types.
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

/// An extension for [PlantActionType]
extension PlantActionTypeExtension on PlantActionType {
  /// The name of the plant action type.
  String get name {
    switch (this) {
      case PlantActionType.watering:
        return tr('common.watering');
      case PlantActionType.fertilizing:
        return tr('common.fertilizing');
      case PlantActionType.pruning:
        return tr('common.pruning');
      case PlantActionType.harvesting:
        return tr('common.harvesting');
      case PlantActionType.replanting:
        return tr('common.replanting');
      case PlantActionType.training:
        return tr('common.training');
      case PlantActionType.measuring:
        return tr('common.measuring');
      case PlantActionType.picture:
        return tr('common.picture');
      case PlantActionType.death:
        return tr('common.death');
      case PlantActionType.other:
        return tr('common.other');
    }
  }

  /// The icon of the plant action type.
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

/// A plant action.
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

/// A plant watering action.
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

/// A plant watering action.
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

/// A plant fertilization.
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

/// A plant fertilizing action.
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

/// The pruning types.
enum PruningType {
  topping,
  fim,
  lollipopping,
}

/// An extension for [PruningType]
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

/// The weight units.
enum WeightUnit {
  g,
  kg,
}

/// An extension for [WeightUnit]
extension WeightUnitExtension on WeightUnit {
  /// The name of the weight unit.
  String get name {
    switch (this) {
      case WeightUnit.g:
        return 'g';
      case WeightUnit.kg:
        return 'kg';
    }
  }
}

/// A weight amount.
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

/// A plant harvesting action.
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

/// A plant replanting action.
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

/// The training types.
enum TrainingType {
  lst,
  scrog,
}

/// An extension for [TrainingType]
extension TrainingTypeExtension on TrainingType {
  /// The name of the training type.
  String get name {
    switch (this) {
      case TrainingType.lst:
        return 'LST';
      case TrainingType.scrog:
        return 'SCROG';
    }
  }
}

/// A plant training action.
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

/// The plant measurement types.
enum PlantMeasurementType {
  height,
  pH,
  ec,
  ppm,
}

/// An extension for [PlantMeasurementType]
extension PlantMeasurementTypeExtension on PlantMeasurementType {
  /// The name of the plant measurement type.
  String get name {
    switch (this) {
      case PlantMeasurementType.height:
        return tr('common.height');
      case PlantMeasurementType.pH:
        return 'pH';
      case PlantMeasurementType.ec:
        return 'EC';
      case PlantMeasurementType.ppm:
        return 'PPM';
    }
  }

  /// The icon of the plant measurement type.
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

/// A plant measuring action.
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

/// A plant death action.
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

/// A plant picture action.
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

/// An arbitrary plant action.
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

/// The actions.
@JsonSerializable()
class Actions {
  @JsonKey(fromJson: _plantActionsFromJson)
  List<PlantAction> plantActions;

  @JsonKey(fromJson: _environmentActionsFromJson)
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
        case 'measuring':
          return PlantMeasuringAction.fromJson(map);
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
