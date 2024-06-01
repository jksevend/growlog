import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/plants/model.dart';

class PlantActionLogHomeWidget extends StatelessWidget {
  final Plant plant;
  final PlantAction action;

  const PlantActionLogHomeWidget({
    super.key,
    required this.plant,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: action.type.icon,
        title: Text(plant.name),
        subtitle: Text(action.formattedDate),
      ),
    );
  }
}

class EnvironmentActionLogHomeWidget extends StatelessWidget {
  final Environment environment;
  final EnvironmentAction action;

  const EnvironmentActionLogHomeWidget({
    super.key,
    required this.environment,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
          leading: action.measurement.type.icon,
          title: Text(environment.name),
          subtitle: Text(action.formattedDate),
      ),
    );
  }
}
