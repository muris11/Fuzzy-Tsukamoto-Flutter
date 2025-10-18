class Env {
  // Gunakan 10.0.2.2 untuk mengakses localhost host Windows dari Android emulator
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://rifqy11.pythonanywhere.com',
  );
}
