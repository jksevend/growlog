import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
}

class WeedyApp extends StatelessWidget {
  const WeedyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Weedy',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Weedy'),
          ),
          body: Center(
            child: Text('Hello World'),
          ),
        )
      );
  }
}
