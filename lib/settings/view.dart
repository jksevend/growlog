import 'package:flutter/material.dart';
import 'package:weedy/settings/model.dart';
import 'package:weedy/settings/provider.dart';

class SettingsView extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const SettingsView({super.key, required this.settingsProvider});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: StreamBuilder<Settings>(
          stream: widget.settingsProvider.settings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final settings = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      subtitle: const Text('Information about the app'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Weedy',
                          applicationVersion: '1.0.0',
                          applicationLegalese: 'MIT LICENSE 2024 Weedy\ngithub.com/jksevend/weedy',
                        );
                      }),
                ],
              ),
            );
          }),
    );
  }
}
