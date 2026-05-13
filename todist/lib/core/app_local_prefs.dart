import 'package:hive_flutter/hive_flutter.dart';

class AppLocalPrefs {
  static Box<dynamic> box() {
    return Hive.box('app_hive');
  }

  static String? get latSyncAt =>
      box().get('lastSyncAt', defaultValue: null).toString();
  static set latSyncAt(String? value) => box().put('lastSyncAt', value);

  static void clearAll() {
    box().clear();
  }
}
