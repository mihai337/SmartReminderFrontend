abstract class AppEnv {
  String get apiBaseUrl;
}

class DevEnv implements AppEnv {
  @override
  String get apiBaseUrl => 'http://192.168.1.104:8080';
}

class ProdEnv implements AppEnv {
  @override
  String get apiBaseUrl => 'https://smartreminderbackend.onrender.com';
}

class Config {
  static final AppEnv env = _getEnv();

  static AppEnv _getEnv() {
    const env = String.fromEnvironment('ENV', defaultValue: 'DEV');

    switch (env) {
      case 'PROD':
        return ProdEnv();
      case 'DEV':
      default:
        return DevEnv();
    }
  }
}