import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// A fertilizer.
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

  Fertilizer copyWith({
    String? id,
    String? name,
    String? description,
  }) {
    return Fertilizer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => _$FertilizerToJson(this);
}

/// A collection of fertilizers.
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
