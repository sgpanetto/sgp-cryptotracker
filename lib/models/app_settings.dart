enum FiatCurrency { eur, usd }
enum AppTheme { light, dark, auto }

class AppSettings {
  final FiatCurrency fiatCurrency;
  final AppTheme theme;
  final bool biometricEnabled;
  final DateTime lastDataRefresh;

  AppSettings({
    required this.fiatCurrency,
    required this.theme,
    required this.biometricEnabled,
    required this.lastDataRefresh,
  });

  Map<String, dynamic> toMap() {
    return {
      'fiatCurrency': fiatCurrency.index,
      'theme': theme.index,
      'biometricEnabled': biometricEnabled ? 1 : 0,
      'lastDataRefresh': lastDataRefresh.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      fiatCurrency: FiatCurrency.values[map['fiatCurrency'] ?? 0],
      theme: AppTheme.values[map['theme'] ?? 2],
      biometricEnabled: map['biometricEnabled'] == 1,
      lastDataRefresh: DateTime.fromMillisecondsSinceEpoch(
        map['lastDataRefresh'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  AppSettings copyWith({
    FiatCurrency? fiatCurrency,
    AppTheme? theme,
    bool? biometricEnabled,
    DateTime? lastDataRefresh,
  }) {
    return AppSettings(
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      theme: theme ?? this.theme,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lastDataRefresh: lastDataRefresh ?? this.lastDataRefresh,
    );
  }

  static AppSettings get defaultSettings => AppSettings(
    fiatCurrency: FiatCurrency.eur,
    theme: AppTheme.auto,
    biometricEnabled: false,
    lastDataRefresh: DateTime.now(),
  );
} 