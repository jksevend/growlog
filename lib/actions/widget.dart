import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weedy/actions/dialog.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/common/measurement.dart';
import 'package:weedy/common/temperature.dart';
import 'package:weedy/environments/model.dart';

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

class EnvironmentMeasurementActionSheetWidget extends StatefulWidget {
  final Environment environment;
  final EnvironmentMeasurementAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentMeasurementActionSheetWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  State<EnvironmentMeasurementActionSheetWidget> createState() =>
      _EnvironmentMeasurementActionSheetWidgetState();
}

class _EnvironmentMeasurementActionSheetWidgetState
    extends State<EnvironmentMeasurementActionSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      child: _measurementWidget(),
      environment: widget.environment,
      action: widget.action,
      actionsProvider: widget.actionsProvider,
    );
  }

  Widget _measurementWidget() {
    if (widget.action.measurement.type == EnvironmentMeasurementType.temperature) {
      final temperature = Temperature.fromJson(widget.action.measurement.measurement);
      return ListTile(
        leading: Text(widget.action.measurement.type.icon, style: TextStyle(fontSize: 20)),
        title: Text('Temperature'),
        subtitle: Text('${temperature.value} ${temperature.unit.symbol}'),
      );
    }

    if (widget.action.measurement.type == EnvironmentMeasurementType.humidity) {
      final humidity = widget.action.measurement.measurement['humidity'] as double;
      return ListTile(
        leading: Text(widget.action.measurement.type.icon, style: TextStyle(fontSize: 20)),
        title: Text('Humidity'),
        subtitle: Text('$humidity %'),
      );
    }

    if (widget.action.measurement.type == EnvironmentMeasurementType.co2) {
      final co2 = widget.action.measurement.measurement['co2'] as double;
      return ListTile(
        leading: Text(widget.action.measurement.type.icon, style: TextStyle(fontSize: 20)),
        title: Text('CO2'),
        subtitle: Text('$co2 ppm'),
      );
    }

    if (widget.action.measurement.type == EnvironmentMeasurementType.lightDistance) {
      final amount = MeasurementAmount.fromJson(widget.action.measurement.measurement);
      return ListTile(
        leading: Text(widget.action.measurement.type.icon, style: TextStyle(fontSize: 20)),
        title: Text('Light distance'),
        subtitle: Text('${amount.value}${amount.unit.symbol}'),
      );
    }

    return Container();
  }
}

class EnvironmentOtherActionSheetWidget extends StatefulWidget {
  final Environment environment;
  final EnvironmentOtherAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentOtherActionSheetWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  State<EnvironmentOtherActionSheetWidget> createState() =>
      _EnvironmentOtherActionSheetWidgetState();
}

class _EnvironmentOtherActionSheetWidgetState extends State<EnvironmentOtherActionSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      child: Container(),
      environment: widget.environment,
      action: widget.action,
      actionsProvider: widget.actionsProvider,
    );
  }
}

class EnvironmentPictureActionSheetWidget extends StatefulWidget {
  final Environment environment;
  final EnvironmentPictureAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentPictureActionSheetWidget(
      {super.key, required this.environment, required this.action, required this.actionsProvider});

  @override
  State<EnvironmentPictureActionSheetWidget> createState() =>
      _EnvironmentPictureActionSheetWidgetState();
}

class _EnvironmentPictureActionSheetWidgetState extends State<EnvironmentPictureActionSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return _BaseEnvironmentActionSheetWidget(
      environment: widget.environment,
      action: widget.action,
      actionsProvider: widget.actionsProvider,
      child: SizedBox(
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemCount: widget.action.images.length,
          itemBuilder: (context, index) {
            final picture = widget.action.images[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: InteractiveViewer(
                        panEnabled: false,
                        // Set it to false
                        boundaryMargin: EdgeInsets.all(100),
                        minScale: 1,
                        maxScale: 2,
                        child: Image.file(
                          alignment: Alignment.center,
                          File(picture),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Image.file(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                File(picture),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BaseEnvironmentActionSheetWidget extends StatefulWidget {
  final Environment environment;
  final EnvironmentAction action;
  final ActionsProvider actionsProvider;
  final Widget child;

  const _BaseEnvironmentActionSheetWidget({
    super.key,
    required this.child,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  State<_BaseEnvironmentActionSheetWidget> createState() =>
      _BaseEnvironmentActionSheetWidgetState();
}

class _BaseEnvironmentActionSheetWidgetState extends State<_BaseEnvironmentActionSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Text(widget.action.type.icon, style: TextStyle(fontSize: 18)),
          title: Text(widget.action.type.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.environment.name,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Text(widget.action.formattedDate),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final confirmed = await confirmDeletionOfEnvironmentActionDialog(
                      context, widget.action, widget.actionsProvider);
                  if (confirmed == true) {
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.action.type.name} has been deleted'),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
        Divider(),
        Text(widget.action.description == '' ? 'No description' : widget.action.description),
        Divider(),
        widget.child,
      ],
    );
  }
}
