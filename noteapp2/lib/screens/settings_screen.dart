import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/language_selection_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(locale.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(locale.theme),
            subtitle: Text(themeProvider.themeMode == ThemeMode.dark
                ? locale.dark
                : locale.light),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              
            },
            activeColor: const Color.fromARGB(255, 0, 0, 0),
            activeTrackColor: Colors.green,
            inactiveTrackColor: const Color.fromARGB(255, 255, 255, 255),
            
            
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.dark_mode 
                  : Icons.light_mode,
                  color: themeProvider.themeMode == ThemeMode.dark ? Colors.blue : const Color.fromARGB(255, 221, 200, 4),
                  
            ),
          ),
          ListTile(
            title: Text(locale.language),
            subtitle: Text(_getLanguageName(
                localeProvider.locale.languageCode)),
            leading: Icon(Icons.language),
            iconColor: const Color.fromARGB(255, 4, 127, 221),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return LanguageSelectionDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'pl':
        return 'Polski';
      case 'ru':
        return 'Русский';
      // Weitere Sprachen hinzufügen
      default:
        return code;
    }
  }
}