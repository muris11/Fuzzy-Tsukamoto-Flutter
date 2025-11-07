class Env {
  // Gunakan 10.0.2.2 untuk mengakses localhost host Windows dari Android emulator
  // Gunakan localhost untuk iOS simulator atau web
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fuzzy-tsukamoto-disease-prediction-git-main-getmuris-projects.vercel.app', // Backend API running on local network
  );
}

