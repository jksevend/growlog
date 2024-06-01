import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Fertilizer {
  final String id;
  final String name;
  final String description;

  const Fertilizer({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) => _$FertilizerFromJson(json);

  Map<String, dynamic> toJson() => _$FertilizerToJson(this);
}

@JsonSerializable()
class Fertilizers {
  List<Fertilizer> fertilizers;

  Fertilizers({
    required this.fertilizers,
  });

  factory Fertilizers.fromJson(Map<String, dynamic> json) => _$FertilizersFromJson(json);

  Map<String, dynamic> toJson() => _$FertilizersToJson(this);

  factory Fertilizers.standard() {
    return Fertilizers(
      fertilizers: [],
    );
  }
}
