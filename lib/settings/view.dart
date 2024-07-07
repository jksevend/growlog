import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:growlog/settings/model.dart';
import 'package:growlog/settings/provider.dart';
import 'package:in_app_update/in_app_update.dart';

/// Helper for all supported locales in this game
enum AppLocale { german, english, spanish }

extension AppLocaleExtension on AppLocale {
  String get localeFlag => _localeFlag(this);

  String get translationKey => _translationKey(this);

  /// Returns the path to a flag image of a given [appLocale]
  String _localeFlag(final AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.german:
        return 'assets/img/german.png';
      case AppLocale.english:
        return 'assets/img/us.png';
      case AppLocale.spanish:
        return 'assets/img/espanol.png';
    }
  }

  /// Translation key for a [appLocale] located in assets/lang/
  String _translationKey(final AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.german:
        return 'common.german';
      case AppLocale.english:
        return 'common.english';
      case AppLocale.spanish:
        return 'common.spanish';
    }
  }
}

/// A view that displays the application's settings.
class SettingsView extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const SettingsView({super.key, required this.settingsProvider});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(tr('settings.title')),
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

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    subtitle: Text(tr('common.change_language')),
                    title: DropdownButton<AppLocale>(
                      onChanged: (value) {
                        if (value == AppLocale.german) {
                          context.setLocale(const Locale('de', 'DE'));
                        } else if (value == AppLocale.english) {
                          context.setLocale(const Locale('en', 'US'));
                        } else if (value == AppLocale.spanish) {
                          context.setLocale(const Locale('es', 'ES'));
                        }
                      },
                      value: _determineAppLocale(context),
                      items: AppLocale.values
                          .map(
                            (locale) => DropdownMenuItem(
                              value: locale,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage(locale.localeFlag),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(tr(locale.translationKey)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.update),
                    title: Text(tr('settings.update.title')),
                    subtitle: Text(tr('settings.update.description')),
                    onTap: () async {
                      final updateInfo = await _checkForUpdate();
                      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
                        await InAppUpdate.performImmediateUpdate().catchError((error) {
                          _showUpdateResultSnack(tr('settings.update.error'));
                          return AppUpdateResult.inAppUpdateFailed;
                        });
                      } else {
                        _showUpdateResultSnack(tr('settings.update.no_update'));
                      }
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(tr('settings.about.title')),
                      subtitle: Text(tr('settings.about.description')),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationIcon:
                              Image.asset('assets/img/app_icon.png', width: 50, height: 50),
                          applicationName: 'GrowLog - Cannabis diary',
                          applicationVersion: '1.2.0',
                          applicationLegalese:
                              'MIT LICENSE 2024 GrowLog\ngithub.com/jksevend/growlog',
                        );
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Check for an update and return the [AppUpdateInfo]
  Future<AppUpdateInfo> _checkForUpdate() async {
    return InAppUpdate.checkForUpdate();
  }

  /// Show a snack bar with the result of an update
  void _showUpdateResultSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  /// Determine the current app locale
  AppLocale _determineAppLocale(BuildContext context) {
    if (context.locale == const Locale('de', 'DE')) {
      return AppLocale.german;
    } else if (context.locale == const Locale('en', 'US')) {
      return AppLocale.english;
    } else if (context.locale == const Locale('es', 'ES')) {
      return AppLocale.spanish;
    }

    return AppLocale.english;
  }
}
