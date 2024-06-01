import 'package:json_annotation/json_annotation.dart';

part 'measurement.g.dart';

enum MeasurementUnit {
  cm,
  m,
}

@JsonSerializable()
class MeasurementAmount {
  final double value;
  final MeasurementUnit unit;

  MeasurementAmount({required this.value, required this.unit});

  factory MeasurementAmount.fromJson(Map<String, dynamic> json) => _$MeasurementAmountFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementAmountToJson(this);

}