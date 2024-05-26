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
                Text(
                  'Settings',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Divider(),

                /// Notifications
                SwitchListTile(
                  value: settings.notification.enabled,
                  onChanged: (value) async {
                    settings.notification.enabled = value;
                    await widget.provider.setSettings(settings);
                  },
                  title: const Text('Notifications'),
                  subtitle: const Text('Enable or disable notifications'),
                ),

                /// About the app
                ListTile(
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
        });
  }
}
