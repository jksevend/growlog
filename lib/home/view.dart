import 'package:flutter/material.dart';
import 'package:weedy/actions/model.dart';
import 'package:weedy/actions/provider.dart';

class HomeView extends StatefulWidget {
  final ActionsProvider actionsProvider;

  const HomeView({super.key, required this.actionsProvider});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Divider(),
            Text('Plant Actions'),
            StreamBuilder(
              stream: widget.actionsProvider.plantActions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final plantActions = snapshot.data!;
                if (plantActions.isEmpty) {
                  return Center(
                    child: Text('No plant actions performed today.'),
                  );
                }
                return Column(
                  children: plantActions
                      .map((action) => ListTile(
                            leading: action.type.icon,
                            title: Text(action.description),
                            subtitle: Text(action.createdAt.toIso8601String()),
                          ))
                      .toList(),
                );
              },
            ),
            Divider(),
            Text('Environment Actions'),
            StreamBuilder(
                stream: widget.actionsProvider.environmentActions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final environmentActions = snapshot.data!;
                  if (environmentActions.isEmpty) {
                    return Center(
                      child: Text('No environment actions performed today.'),
                    );
                  }
                  return Column(
                    children: environmentActions
                        .map((action) => ListTile(
                              title: Text(action.description),
                              subtitle: Text(action.createdAt.toIso8601String()),
                            ))
                        .toList(),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
