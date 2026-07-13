import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier{
  String language = 'Русский';
  String theme = 'light';
  String defaultMap = 'OpenStreetMap';
  String? exportPath;

  set setLanguage(String value){
    language = value;
    notifyListeners();
  }

  set setDefaultMap(String value){
    defaultMap = value;
    notifyListeners();
  }

  set setTheme(String value){
    theme = value;
    notifyListeners();
  }
}