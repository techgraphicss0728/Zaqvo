import 'package:shared_preferences/shared_preferences.dart';

/// Persists access/refresh tokens for the delivery partner.
class AuthSession {
  static const _kAccess = 'zaqvo_delivery_access_token';
  static const _kRefresh = 'zaqvo_delivery_refresh_token';

  /// Dev UI-only login (not sent to the API).
  static const kDummyAccessToken = '__DUMMY_DEV_ACCESS__';
  static const kDummyRefreshToken = '__DUMMY_DEV_REFRESH__';

  String? accessToken;
  String? refreshToken;

  bool get isLoggedIn => (accessToken?.isNotEmpty ?? false);

  bool get isDummySession => accessToken == kDummyAccessToken;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getString(_kAccess);
    final r = prefs.getString(_kRefresh);
    accessToken = a?.isNotEmpty == true ? a : null;
    refreshToken = r?.isNotEmpty == true ? r : null;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString(_kAccess, accessToken!);
    } else {
      await prefs.remove(_kAccess);
    }
    if (refreshToken != null) {
      await prefs.setString(_kRefresh, refreshToken!);
    } else {
      await prefs.remove(_kRefresh);
    }
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }

  Future<void> clearPersisted() async {
    clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }
}
