import 'package:json_annotation/json_annotation.dart';

part 'distance.g.dart';

enum DistanceUnit {
  cm,
  m,
}

@JsonSerializable()
class Distance {
  final double value;
  final DistanceUnit unit;

  Distance({required this.value, required this.unit});

  factory Distance.fromJson(Map<String, dynamic> json) => _$DistanceFromJson(json);

  Map<String, dynamic> toJson() => _$DistanceToJson(this);

}