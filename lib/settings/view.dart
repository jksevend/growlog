import 'package:flutter/material.dart';
import 'package:weedy/settings/model.dart';
import 'package:weedy/settings/provider.dart';

class SettingsView extends StatefulWidget {
  final SettingsProvider provider;

  const SettingsView({super.key, required this.provider});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Settings>(
        stream: widget.provider.settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Divider(),
                SwitchListTile(
                  value: settings.notification.enabled,
                  onChanged: (value) async {
                    settings.notification.enabled = value;
                    await widget.provider.setSettings(settings);
                  },
                  title: const Text('Notifications'),
                  subtitle: const Text('Enable or disable notifications'),
                ),
              ],
            ),
          );
        });
  }
}
