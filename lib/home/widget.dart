import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
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
  final FertilizerProvider fertilizerProvider;

  const PlantActionLogHomeWidget({
    super.key,
    required this.plant,
    required this.action,
    required this.actionsProvider,
    required this.fertilizerProvider,
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
          await showPlantActionDetailSheet(
              context, action, plant, actionsProvider, fertilizerProvider);
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

  bool _isToday(DateTime date) {
    return date.year == _now.year && date.month == _now.month && date.day == _now.day;
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
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return Center(child: Text(tr('actions.none')));
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
          },
        ),
      ],
    );
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

  Widget _buildWeekView(List<Widget> actionIndicators) {
    return Column(
      children: [
        _buildWeekdayHeader(),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _currentWeek.map((date) {
            return _buildDateCell(date, _isToday(date), actionIndicators);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthView(List<Widget> actionIndicators) {
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
                  _isToday(date),
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

  Widget _buildDateCell(DateTime date, bool isToday, List<Widget> actionIndicators,
      {bool isCurrentMonth = true}) {
    return isToday
        ? Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_formatDate(date)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: actionIndicators,
                  ),
                ],
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
