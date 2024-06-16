import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/model.dart' as weedy;
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/sheet.dart';
import 'package:weedy/environments/model.dart';
import 'package:weedy/plants/model.dart';

/// An item of a list of plant actions
class PlantActionLogHomeWidget extends StatelessWidget {
  final Plant plant;
  final weedy.PlantAction action;
  final ActionsProvider actionsProvider;

  const PlantActionLogHomeWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: Text(action.type.icon, style: const TextStyle(fontSize: 14)),
        title: Text(plant.name),
        subtitle: Text(action.formattedDate),
        onTap: () async {
          await showPlantActionDetailSheet(context, action, plant, actionsProvider);
        },
      ),
    );
  }
}

/// An item of a list of environment actions
class EnvironmentActionLogHomeWidget extends StatelessWidget {
  final Environment environment;
  final weedy.EnvironmentAction action;
  final ActionsProvider actionsProvider;

  const EnvironmentActionLogHomeWidget({
    super.key,
    required this.environment,
    required this.action,
    required this.actionsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: Text(action.type.icon, style: const TextStyle(fontSize: 14)),
        title: Text(environment.name),
        subtitle: Text(action.formattedDate),
        onTap: () async {
          await showEnvironmentActionDetailSheet(context, action, environment, actionsProvider);
        },
      ),
    );
  }
}

/// A view that displays the current weeks and the weeks of the current month.
///
/// In this view actions done today are highlighted.
class WeekAndMonthView extends StatefulWidget {
  final ActionsProvider actionsProvider;

  const WeekAndMonthView({super.key, required this.actionsProvider});

  @override
  State<WeekAndMonthView> createState() => _WeekAndMonthViewState();
}

class _WeekAndMonthViewState extends State<WeekAndMonthView> {
  bool _isExpanded = false;

  /// Returns the start of the current week.
  DateTime get _startOfWeek {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1));
  }

  /// Returns a list of days of the current week.
  List<DateTime> get _currentWeek {
    DateTime startOfWeek = _startOfWeek;
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  /// Returns a list of days of the current month.
  ///
  /// The list includes the days of the previous month and the next month to fill the grid.
  List<DateTime> get _currentMonth {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int startWeekday = startOfMonth.weekday;

    // Adjust startWeekday to make Monday as the start of the week
    int adjustedStartWeekday = (startWeekday + 6) % 7;

    // Calculate the first day to display (including the previous month's days)
    DateTime firstDayToDisplay = startOfMonth.subtract(Duration(days: adjustedStartWeekday));

    // Calculate the total number of days to display (including next month's days)
    int totalDays = daysInMonth + adjustedStartWeekday;
    int rows = (totalDays / 7).ceil();
    int daysToDisplay = rows * 7;

    List<DateTime> monthDays =
        List.generate(daysToDisplay, (index) => firstDayToDisplay.add(Duration(days: index)));

    return monthDays;
  }

  /// Formats a date to a string.
  String _formatDate(DateTime date) {
    return DateFormat('d').format(date);
  }

  /// Returns the name of the current month.
  String _currentMonthName() {
    return DateFormat('MMMM').format(DateTime.now());
  }

  /// A list of weekday headers.
  /// TODO: Localize this
  List<String> get _weekdayHeaders {
    return ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  }

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
        StreamBuilder(
            stream: CombineLatestStream.list([
              widget.actionsProvider.plantActions,
              widget.actionsProvider.environmentActions,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error ${snapshot.error}'),
                );
              }

              final plantActions = snapshot.data![0] as List<weedy.PlantAction>;
              final environmentActions = snapshot.data![1] as List<weedy.EnvironmentAction>;

              List<weedy.Action> allActions = [...plantActions, ...environmentActions];
              allActions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final List<weedy.Action> fourLatestActions =
                  allActions.where((action) => action.isToday()).take(4).toList();

              final List<Widget> actionIndicators = fourLatestActions.map((action) {
                if (action is weedy.PlantAction) {
                  return Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  );
                } else if (action is weedy.EnvironmentAction) {
                  return Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.yellow[900],
                      shape: BoxShape.circle,
                    ),
                  );
                }
                throw Exception('Unknown action type');
              }).toList();

              return AnimatedCrossFade(
                firstChild: _buildWeekView(actionIndicators),
                secondChild: _buildMonthView(actionIndicators),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 500),
              );
            }),
      ],
    );
  }

  /// A header that toggles between the week and month view.
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

  /// A view that displays the current week.
  Widget _buildWeekView(final List<Widget> actionIndicators) {
    return Column(
      children: [
        _buildWeekdayHeader(),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _currentWeek.map((date) {
            bool isToday = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            return _buildDateCell(date, isToday, actionIndicators);
          }).toList(),
        ),
      ],
    );
  }

  /// A view that displays the current month.
  Widget _buildMonthView(final List<Widget> actionIndicators) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          _buildWeekdayHeader(),
          SizedBox(
            height: constraints.maxWidth / 7 * 6,
            child: GridView.count(
              crossAxisCount: 7,
              children: _currentMonth.map((date) {
                bool isCurrentMonth = date.month == DateTime.now().month;
                bool isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;
                return _buildDateCell(
                  date,
                  isToday,
                  actionIndicators,
                  isCurrentMonth: isCurrentMonth,
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  /// A header that displays the weekdays.
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

  /// A cell that displays a date.
  Widget _buildDateCell(DateTime date, bool isToday, final List<Widget> actionIndicators,
      {bool isCurrentMonth = true}) {
    return isToday
        ? Center(
            child: Container(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDate(date),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actionIndicators,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  color: isCurrentMonth ? Colors.grey : Colors.grey[700],
                  fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
  }
}
