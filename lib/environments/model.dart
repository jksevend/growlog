import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Environment {
  final String id;
  final String name;
  final String description;

  Environment({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Environment.fromJson(Map<String, dynamic> json) => _$EnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);
}