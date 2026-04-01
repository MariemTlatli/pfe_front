import 'package:flutter/material.dart';
import '../../config/localization/localization_service.dart';
import '../../config/localization/localization_en.dart';
import '../../config/localization/localization_fr.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  AppLocalizations _appLocalizations = AppLocalizationsEn();

  Locale get currentLocale => _currentLocale;
  AppLocalizations get locale => _appLocalizations;
  List<String> get supportedLanguages => ['en', 'fr'];

  void changeLanguage(String languageCode) {
    if (languageCode == 'en') {
      _currentLocale = const Locale('en');
      _appLocalizations = AppLocalizationsEn();
    } else if (languageCode == 'fr') {
      _currentLocale = const Locale('fr');
      _appLocalizations = AppLocalizationsFr();
    }
    notifyListeners();
  }
}
