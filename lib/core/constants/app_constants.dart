class AppConstants {
  // API
  static const apiBaseUrl = 'http://10.0.2.2/Dammam_Projects/najma-api/api/v1/';
  // 10.0.2.2 = localhost from Android emulator
  // Change to actual server IP for device testing

  // Reverb WebSocket
  static const reverbHost = '10.0.2.2';
  static const reverbPort = 8080;
  static const reverbAppKey = 'najma_key';

  // App
  static const appName = 'نجم السهرة';
  static const appVersion = '1.0.0';
  static const commission = 0.35; // 35% platform fee

  // OTP
  static const otpLength = 6;
  static const otpExpiry = 600; // 10 minutes in seconds

  // Animation durations
  static const splashDuration = Duration(seconds: 3);
  static const pageDuration = Duration(milliseconds: 400);
  static const shimmerDuration = Duration(milliseconds: 1500);
}
