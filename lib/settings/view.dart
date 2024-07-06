import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:weedy/settings/model.dart';
import 'package:weedy/settings/provider.dart';

/// A view that displays the application's settings.
class SettingsView extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const SettingsView({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.title')),
        centerTitle: true,
      ),
      body: StreamBuilder<Settings>(
          stream: settingsProvider.settings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(tr('settings.about.title')),
                      subtitle: Text(tr('settings.about.description')),
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
