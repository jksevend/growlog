import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Weedy',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: MainView(settingsProvider: settingsProvider),
          );
        },
      ),
    );
  }
}

class MainView extends StatefulWidget {
  final SettingsProvider settingsProvider;
  const MainView({super.key, required this.settingsProvider});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  late final List<Widget> _pages = [
    Center(child: Text('Home Page')),
    Center(child: Text('Plants Page')),
    Center(child: Text('Environments Page')),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pflanze hinzufügen!')),
          );
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

