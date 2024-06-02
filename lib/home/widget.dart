import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        leading: action.type.icon,
        title: Text(environment.name),
        subtitle: Text(action.formattedDate),
      ),
    );
  }
}

class WeekAndMonthView extends StatefulWidget {
  const WeekAndMonthView({super.key});

  @override
  State<WeekAndMonthView> createState() => _WeekAndMonthViewState();
}

class _WeekAndMonthViewState extends State<WeekAndMonthView> {
  bool _isExpanded = false;

  DateTime get _startOfWeek {
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    return now.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> get _currentWeek {
    DateTime startOfWeek = _startOfWeek;
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<DateTime> get _currentMonth {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int startWeekday = startOfMonth.weekday;

    // Calculate the first day to display (including the previous month's days)
    DateTime firstDayToDisplay = startOfMonth.subtract(Duration(days: startWeekday));

    // Calculate the total number of days to display (including next month's days)
    int totalDays = daysInMonth + startWeekday;
    int rows = (totalDays / 7).ceil();
    int daysToDisplay = rows * 7;

    List<DateTime> monthDays =
    List.generate(daysToDisplay, (index) => firstDayToDisplay.add(Duration(days: index)));

    return monthDays;
  }

  String _formatDate(DateTime date) {
    return DateFormat('d').format(date);
  }

  String _currentMonthName() {
    return DateFormat('MMMM').format(DateTime.now());
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
              Spacer(),
              Text(_currentMonthName()),
              _buildHeader(),
            ],
          ),
        ),
        Divider(),
        AnimatedCrossFade(
          firstChild: _buildWeekView(),
          secondChild: _buildMonthView(),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 350),
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

  Widget _buildWeekView() {
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: _currentWeek.map((date) {
        bool isToday = date.day == DateTime
            .now()
            .day && date.month == DateTime
            .now()
            .month;
        return _buildDateCell(date, isToday);
      }).toList(),
    );
  }

  Widget _buildMonthView() {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxWidth / 7 * 6,
        child: GridView.count(
          crossAxisCount: 7,
          children: _currentMonth.map((date) {
            bool isCurrentMonth = date.month == DateTime
                .now()
                .month;
            bool isToday = date.day == DateTime
                .now()
                .day && date.month == DateTime
                .now()
                .month;
            return _buildDateCell(date, isToday, isCurrentMonth);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildDateCell(DateTime date, bool isToday, [bool isCurrentMonth = true]) {
    return isToday
        ? Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            _formatDate(date),
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
