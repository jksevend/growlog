import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weedy/environments/view.dart';
import 'package:weedy/home/view.dart';
import 'package:weedy/plants/provider.dart';
import 'package:weedy/plants/view.dart';
import 'package:weedy/settings/provider.dart';
import 'package:weedy/settings/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const WeedyApp());
}

class WeedyApp extends StatelessWidget {
  const WeedyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
      ],
      child: Consumer2<SettingsProvider, PlantProvider>(
        builder: (context, settingsProvider, plantProvider, _) {
          return MaterialApp(
            title: 'Weedy',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: MainView(
              settingsProvider: settingsProvider,
              plantProvider: plantProvider,
            ),
          );
        },
      ),
    );
  }
}

class MainView extends StatefulWidget {
  final SettingsProvider settingsProvider;
  final PlantProvider plantProvider;

  const MainView({super.key, required this.settingsProvider, required this.plantProvider});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  late final List<Widget> _pages = [
    HomeView(),
    PlantOverview(plantProvider: widget.plantProvider),
    EnvironmentOverview(),
    SettingsView(provider: widget.settingsProvider),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: _floatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        elevation: 10.0,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _floatingActionButton() {
    if (_selectedIndex == 1) {
      return FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreatePlantView()));
        },
        tooltip: 'Pflanze hinzufügen',
        child: Stack(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Umgebung hinzufügen!')),
          );
        },
        tooltip: 'Umgebung hinzufügen',
        child: Stack(
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
}
