import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final String mistralApiKey;

  const UserSettings({this.mistralApiKey = ''});

  bool get hasMistralKey =>
      mistralApiKey.isNotEmpty &&
      mistralApiKey != 'REMPLACE_PAR_TA_CLE_MISTRAL';
}

class UserSettingsRepository {
  static const _mistralKeyPrefix = 'mistral_api_key_';

  Future<UserSettings> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      mistralApiKey: prefs.getString('$_mistralKeyPrefix$userId') ?? '',
    );
  }

  Future<void> saveMistralApiKey(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_mistralKeyPrefix$userId', key.trim());
  }
}
