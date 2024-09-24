import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.language),
      content: SingleChildScrollView(
        child: Column(
          children: LocaleProvider.supportedLocales.map((locale) {
            return RadioListTile<Locale>(
              title: Text(_getLanguageName(locale.languageCode)),
              value: locale,
              groupValue: localeProvider.locale,
              onChanged: (Locale? value) {
                if (value != null) {
                  localeProvider.setLocale(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
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