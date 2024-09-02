import 'dart:async';
import 'dart:io' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_backend.dart';

class TokenManager {
  final authBackend = AuthBackend();

  Timer? timer;

  Future<void> init() async {
    // Start the periodic token refresh
    startRefreshTimer();
  }

  void startRefreshTimer() {
    // Every 9 minutes, refresh the token
    timer = Timer.periodic(const Duration(minutes: 9), (timer) async {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');

      final result = await authBackend.refreshAccessToken(accessToken!, refreshToken!);

      if (!result['success']) {
        // If token refresh fails, exit the app
        exitApp();
      }
    });
  }

  // Exit the app if token refresh fails
  void exitApp() {
    if (io.Platform.isAndroid) {
      io.exit(0);
    }
  }

  // Dispose the timer when the app is closed
  void dispose() {
    timer?.cancel();
  }
}