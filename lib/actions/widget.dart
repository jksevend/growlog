import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';

class PlantActionLogItem extends StatelessWidget {
  final PlantAction action;
  final bool isFirst;
  final bool isLast;

  const PlantActionLogItem({
    super.key,
    required this.action,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action.id,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
            Text(
              action.type.name,
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class EnvironmentActionLogItem extends StatelessWidget {
  final EnvironmentAction action;
  final bool isFirst;
  final bool isLast;

  const EnvironmentActionLogItem({
    super.key,
    required this.action,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
