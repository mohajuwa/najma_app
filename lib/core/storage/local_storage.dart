import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async => _prefs?.setString('token', token);
  static String? getToken() => _prefs?.getString('token');
  static Future<void> clearToken() async => _prefs?.remove('token');

  // Role
  static Future<void> saveRole(String role) async => _prefs?.setString('role', role);
  static String? getRole() => _prefs?.getString('role');

  // Language
  static Future<void> saveLang(String lang) async => _prefs?.setString('lang', lang);
  static String? getLang() => _prefs?.getString('lang') ?? 'ar';

  // First launch
  static bool isFirstLaunch() => _prefs?.getBool('first_launch') ?? true;
  static Future<void> setLaunched() async => _prefs?.setBool('first_launch', false);

  // Clear all
  static Future<void> clearAll() async => _prefs?.clear();
}
