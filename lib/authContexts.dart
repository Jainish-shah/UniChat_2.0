import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class authContexts with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userImage;
  String? _studentId;
  String? _discordServerId;

  authContexts() {
    _loadDiscordServerId();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get userImage => _userImage;
  String? get studentId => _studentId;
  String? get discordServerId => _discordServerId;

  void login(String userImage, String studentId) {
    _isAuthenticated = true;
    _userImage = userImage;
    _studentId = studentId;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userImage = null;
    _studentId = null;
    _discordServerId = null;
    _saveDiscordServerId(null);
    notifyListeners();
  }

  void setDiscordServerId(String? discordServerId) {
    _discordServerId = discordServerId;
    _saveDiscordServerId(discordServerId);
    notifyListeners();
  }

  Future<void> _loadDiscordServerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _discordServerId = prefs.getString('discordServerId');
    notifyListeners();
  }

  Future<void> _saveDiscordServerId(String? discordServerId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (discordServerId == null) {
      await prefs.remove('discordServerId');
    } else {
      await prefs.setString('discordServerId', discordServerId);
    }
  }
}
