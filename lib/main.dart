import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weedy/actions/fertilizer/provider.dart';
import 'package:weedy/actions/provider.dart';
import 'package:weedy/actions/view.dart';
import 'package:weedy/environments/provider.dart';
import 'package:weedy/environments/view.dart';
import 'package:weedy/home/view.dart';
import 'package:weedy/plants/provider.dart';
import 'package:weedy/plants/view.dart';
import 'package:weedy/settings/provider.dart';
import 'package:weedy/settings/view.dart';

import 'statistics/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Migrate settings
  // Example:
  // await migrateFileStore(
  //   name: 'settings.json',
  //   migration:
  //     (jsonContent) {
  //       migrateField<bool>(
  //         jsonContent: jsonContent,
  //         field: 'showAdvertisements',
  //         defaultValue: true,
  //       );
  //     },
  // );

  runApp(const WeedyApp());
}

class WeedyApp extends StatelessWidget {
  const WeedyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlantsProvider()),
        ChangeNotifierProvider(create: (_) => EnvironmentsProvider()),
        ChangeNotifierProvider(create: (_) => ActionsProvider()),
        ChangeNotifierProvider(create: (_) => FertilizerProvider()),
      ],
      child: Consumer5<SettingsProvider, PlantsProvider, EnvironmentsProvider,
          ActionsProvider, FertilizerProvider>(
        builder: (context, settingsProvider, plantsProvider,
            environmentsProvider, actionsProvider, fertilizerProvider, _) {
          return MaterialApp(
            title: 'Weedy',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: MainView(
              settingsProvider: settingsProvider,
              plantsProvider: plantsProvider,
              environmentsProvider: environmentsProvider,
              actionsProvider: actionsProvider,
              fertilizerProvider: fertilizerProvider,
            ),
          );
        },
      ),
    );
  }
}

class MainView extends StatefulWidget {
  final SettingsProvider settingsProvider;
  final PlantsProvider plantsProvider;
  final EnvironmentsProvider environmentsProvider;
  final ActionsProvider actionsProvider;
  final FertilizerProvider fertilizerProvider;

  const MainView({
    super.key,
    required this.settingsProvider,
    required this.plantsProvider,
    required this.environmentsProvider,
    required this.actionsProvider,
    required this.fertilizerProvider,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey<State<BottomNavigationBar>> _bottomNavigationKey =
      GlobalKey();
  int _selectedIndex = 0;
  late final List<Widget> _pages = [
    HomeView(
      actionsProvider: widget.actionsProvider,
      plantsProvider: widget.plantsProvider,
      environmentsProvider: widget.environmentsProvider,
      fertilizerProvider: widget.fertilizerProvider,
    ),
    PlantOverview(
      plantsProvider: widget.plantsProvider,
      environmentsProvider: widget.environmentsProvider,
      actionsProvider: widget.actionsProvider,
      bottomNavigationKey: _bottomNavigationKey,
    ),
    EnvironmentOverview(
      environmentsProvider: widget.environmentsProvider,
      plantsProvider: widget.plantsProvider,
      actionsProvider: widget.actionsProvider,
    ),
    const StatisticsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weedy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsView(
                        settingsProvider: widget.settingsProvider,
                      )));
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: _floatingActionButtonLocation(),
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavigationKey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            activeIcon: Icon(Icons.eco),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outlined),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Environments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Statistics',
          )
        ],
        elevation: 10.0,
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _floatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChooseActionView(
                    plantsProvider: widget.plantsProvider,
                    environmentsProvider: widget.environmentsProvider,
                    actionsProvider: widget.actionsProvider,
                    fertilizerProvider: widget.fertilizerProvider,
                  )));
        },
        tooltip: 'Aktion ausführen',
        child: const Stack(
          children: <Widget>[
            Icon(Icons.bolt, size: 36),
            Positioned(
              top: 22,
              left: 22,
              child: Icon(Icons.add, size: 18),
            ),
          ],
        ),
      );
    }

    if (_selectedIndex == 1) {
      return FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreatePlantView(
                    plantsProvider: widget.plantsProvider,
                    environmentsProvider: widget.environmentsProvider,
                  )));
        },
        tooltip: 'Pflanze hinzufügen',
        child: const Stack(
          children: <Widget>[
            Icon(Icons.eco, size: 36),
            Positioned(
              top: 22,
              left: 22,
              child: Icon(Icons.add, size: 18),
            ),
          ],
        ),
      );
    }

    if (_selectedIndex == 2) {
      return FloatingActionButton(
        backgroundColor: Colors.yellow[900],
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreateEnvironmentView(
                    environmentsProvider: widget.environmentsProvider,
                  )));
        },
        tooltip: 'Umgebung hinzufügen',
        child: const Stack(
          children: <Widget>[
            Icon(Icons.lightbulb, size: 36),
            Positioned(
              top: 22,
              left: 22,
              child: Icon(Icons.add, size: 18),
            ),
          ],
        ),
      );
    }
    return null;
  }

  FloatingActionButtonLocation _floatingActionButtonLocation() {
    if (_selectedIndex > 0) return FloatingActionButtonLocation.endFloat;
    return FloatingActionButtonLocation.centerFloat;
  }
}
