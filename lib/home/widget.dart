import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
import 'package:weedy/actions/model.dart' as weedy;
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/sheet.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

/// An item of a list of plant actions
class PlantActionLogHomeWidget extends StatelessWidget {
  final Plant plant;
  final weedy.PlantAction action;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;
  final PlantsProvider plantsProvider;

  const PlantActionLogHomeWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.fertilizerProvider,
    required this.plantsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: Text(_determineIcon(), style: const TextStyle(fontSize: 14)),
        title: Text(plant.name),
        subtitle: Text(action.formattedDate),
        onTap: () async {
          await showPlantActionDetailSheet(
              context, action, plant, actionsProvider, fertilizerProvider, plantsProvider);
        },
      ),
    );
  }

  /// The icon of the displayed action
  String _determineIcon() {
    if (action.type != weedy.PlantActionType.measurement) {
      return action.type.icon;
    }
    final fertilizerAction = action as weedy.PlantMeasurementAction;
    return fertilizerAction.measurement.type.icon;
  }
}

/// An item of a list of environment actions
class EnvironmentActionLogHomeWidget extends StatelessWidget {
  final Environment environment;
  final weedy.EnvironmentAction action;
  final ActionsProvider actionsProvider;
  final EnvironmentsProvider environmentsProvider;

  const EnvironmentActionLogHomeWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
    required this.environmentsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: Text(_determineIcon(), style: const TextStyle(fontSize: 14)),
        title: Text(environment.name),
        subtitle: Text(action.formattedDate),
        onTap: () async {
          await showEnvironmentActionDetailSheet(
            context,
            action,
            environment,
            actionsProvider,
            environmentsProvider,
          );
        },
      ),
    );
  }

  /// The icon of the displayed action
  String _determineIcon() {
    if (action.type != weedy.EnvironmentActionType.measurement) {
      return action.type.icon;
    }
    final measurementAction = action as weedy.EnvironmentMeasurementAction;
    return measurementAction.measurement.type.icon;
  }
}

/// A view that displays the current weeks and the weeks of the current month.
///
/// In this view actions done today are highlighted.
class WeekAndMonthView extends StatefulWidget {
  final Map<DateTime, List<Widget>> actionIndicators;

  const WeekAndMonthView({super.key, required this.actionIndicators});

  @override
  State<WeekAndMonthView> createState() => _WeekAndMonthViewState();
}

class _WeekAndMonthViewState extends State<WeekAndMonthView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              const Spacer(),
              Text(_currentMonthName()),
              _buildHeader(),
            ],
          ),
        ),
        const Divider(),
        AnimatedCrossFade(
          firstChild: _buildWeekView(widget.actionIndicators),
          secondChild: _buildMonthView(widget.actionIndicators),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }

  DateTime get _now => DateTime.now();

  DateTime get _startOfWeek {
    int weekday = _now.weekday;
    return _now.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> get _currentWeek {
    DateTime startOfWeek = _startOfWeek;
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<DateTime> get _currentMonth {
    DateTime startOfMonth = DateTime(_now.year, _now.month, 1);
    int daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    int startWeekday = startOfMonth.weekday;
    int adjustedStartWeekday = (startWeekday + 6) % 7;
    DateTime firstDayToDisplay = startOfMonth.subtract(Duration(days: adjustedStartWeekday));
    int totalDays = daysInMonth + adjustedStartWeekday;
    int rows = (totalDays / 7).ceil();
    int daysToDisplay = rows * 7;

    return List.generate(daysToDisplay, (index) => firstDayToDisplay.add(Duration(days: index)));
  }

  String _formatDate(DateTime date) => DateFormat('d').format(date);

  String _currentMonthName() => DateFormat('MMMM').format(_now);

  List<String> get _weekdayHeaders {
    return List.generate(7, (index) {
      return DateFormat('E', Localizations.localeOf(context).toString())
          .dateSymbols
          .SHORTWEEKDAYS[(index + 1) % 7];
    });
  }

  Widget _buildHeader() {
    return IconButton(
      icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
    );
  }

  Widget _buildWeekView(Map<DateTime, List<Widget>> actionIndicators) {
    return Column(
      children: [
        _buildWeekdayHeader(),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _currentWeek.map((date) {
            return _buildDateCell(
                date, actionIndicators[DateTime(date.year, date.month, date.day)]);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthView(Map<DateTime, List<Widget>> actionIndicators) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          _buildWeekdayHeader(),
          SizedBox(
            height: constraints.maxWidth / 7 * 6,
            child: GridView.count(
              crossAxisCount: 7,
              children: _currentMonth.map((date) {
                bool isCurrentMonth = date.month == _now.month;
                return _buildDateCell(
                  date,
                  actionIndicators[DateTime(date.year, date.month, date.day)],
                  isCurrentMonth: isCurrentMonth,
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdayHeaders.map((day) {
        return Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(day),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateCell(DateTime date, List<Widget>? actionIndicators,
      {bool isCurrentMonth = true}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDate(date),
              style: TextStyle(
                color: isCurrentMonth ? Colors.grey : Colors.grey[700],
                fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: actionIndicators ??
                  [
                    Container(),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
