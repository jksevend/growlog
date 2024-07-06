import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class PlantRelocation {
  String plantId;
  String environmentIdFrom;
  String environmentIdTo;
  DateTime timestamp;

  PlantRelocation({
    required this.plantId,
    required this.environmentIdFrom,
    required this.environmentIdTo,
    required this.timestamp,
  });

  factory PlantRelocation.fromJson(Map<String, dynamic> json) => _$PlantRelocationFromJson(json);

  Map<String, dynamic> toJson() => _$PlantRelocationToJson(this);
}

@JsonSerializable()
class PlantRelocations {
  List<PlantRelocation> relocations;

  PlantRelocations({
    required this.relocations,
  });

  factory PlantRelocations.fromJson(Map<String, dynamic> json) => _$PlantRelocationsFromJson(json);

  Map<String, dynamic> toJson() => _$PlantRelocationsToJson(this);

  factory PlantRelocations.standard() {
    return PlantRelocations(
      relocations: [],
    );
  }
}
