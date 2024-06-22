import 'package:easy_localization/easy_localization.dart';
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
import 'package:weedy/statistics/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Migrate settings after initial release
  // Example:
  // await migrateFileStore(
  //   name: 'settings.json',
  //   migration:
  //     (jsonContent) {
  //       addField<bool>(
  //         jsonContent: jsonContent,
  //         field: 'showAdvertisements',
  //         defaultValue: true,
  //       );
  //       deleteField(
  //         jsonContent: jsonContent,
  //         field: 'showAds',
  //       );
  //     },
  // );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const WeedyApp(),
    ),
  );
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
      child: Consumer5<SettingsProvider, PlantsProvider, EnvironmentsProvider, ActionsProvider,
          FertilizerProvider>(
        builder: (context, settingsProvider, plantsProvider, environmentsProvider, actionsProvider,
            fertilizerProvider, _) {
          return MaterialApp(
            title: 'Weedy',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
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

/// The main view of the app that holds the bottom navigation bar.
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
  final GlobalKey<State<BottomNavigationBar>> _bottomNavigationKey = GlobalKey();
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
      fertilizerProvider: widget.fertilizerProvider,
      bottomNavigationKey: _bottomNavigationKey,
    ),
    EnvironmentOverview(
      environmentsProvider: widget.environmentsProvider,
      plantsProvider: widget.plantsProvider,
      actionsProvider: widget.actionsProvider,
    ),
    const StatisticsView(),
  ];

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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr('main.home_label'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.eco_outlined),
            activeIcon: const Icon(Icons.eco),
            label: tr('main.plants_label'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb_outlined),
            activeIcon: const Icon(Icons.lightbulb),
            label: tr('main.environments_label'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            label: tr('main.statistics_label'),
          )
        ],
        elevation: 10.0,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  /// Handles the tap on the bottom navigation bar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Returns the floating action button based on the selected index.
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
        tooltip: tr('main.add_action'),
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
        tooltip: tr('main.add_plant'),
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
        tooltip: tr('main.add_environment'),
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

  /// Returns the floating action button location based on the selected index.
  FloatingActionButtonLocation _floatingActionButtonLocation() {
    if (_selectedIndex > 0) return FloatingActionButtonLocation.endFloat;
    return FloatingActionButtonLocation.centerFloat;
  }
}
