import 'package:flutter/material.dart';

class EnvironmentOverview extends StatefulWidget {
  const EnvironmentOverview({super.key});

  @override
  State<EnvironmentOverview> createState() => _EnvironmentOverviewState();
}

class _EnvironmentOverviewState extends State<EnvironmentOverview> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Environments Page'),
    );
  }
}
