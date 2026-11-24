import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Konfigurasi endpoint AI (OpenAI API-compatible / Ollama / 9router / Local LLM)
class AiEndpointConfig {
  final String baseUrl;
  final String apiKey;
  final String modelName;
  final bool isEnabled;

  const AiEndpointConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.modelName,
    this.isEnabled = true,
  });

  /// Default API Key bawaan untuk 9router lokal
  static const default9RouterKey = 'sk-66e08effc02f9916-2mrqwi-c58ba80f';

  /// Default bawaan: 9router Local proxy port 20128
  factory AiEndpointConfig.defaultConfig() {
    return const AiEndpointConfig(
      baseUrl: 'http://localhost:20128/v1',
      apiKey: default9RouterKey,
      modelName: 'ag/gemini-3.8-flash-medium',
      isEnabled: true,
    );
  }

  bool get hasValidUrl => baseUrl.trim().isNotEmpty && baseUrl.startsWith('http');

  AiEndpointConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? modelName,
    bool? isEnabled,
  }) {
    return AiEndpointConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'modelName': modelName,
        'isEnabled': isEnabled,
      };

  factory AiEndpointConfig.fromJson(Map<String, dynamic> json) {
    return AiEndpointConfig(
      baseUrl: json['baseUrl'] as String? ?? 'http://localhost:20128/v1',
      apiKey: json['apiKey'] as String? ?? '',
      modelName: json['modelName'] as String? ?? 'ag/gemini-3.8-flash-medium',
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

/// Service untuk menyimpan & memuat konfigurasi endpoint AI kustom pengguna
class AiEndpointConfigService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  static const _keyBaseUrl = 'ai_endpoint_base_url';
  static const _keyApiKey = 'ai_endpoint_api_key';
  static const _keyModelName = 'ai_endpoint_model_name';
  static const _keyIsEnabled = 'ai_endpoint_is_enabled';

  /// Membaca konfigurasi AI
  static Future<AiEndpointConfig> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString(_keyBaseUrl) ?? 'http://localhost:20128/v1';
      final modelName = prefs.getString(_keyModelName) ?? 'ag/gemini-3.8-flash-medium';
      final isEnabled = prefs.getBool(_keyIsEnabled) ?? true;

      // Ambil API key dari secure storage
      String apiKey = '';
      try {
        apiKey = await _storage.read(key: _keyApiKey) ?? '';
      } catch (_) {
        apiKey = prefs.getString(_keyApiKey) ?? '';
      }

      // Jika menggunakan 9router lokal dan belum ada API key, gunakan default key
      if (apiKey.trim().isEmpty && baseUrl.contains('20128')) {
        apiKey = AiEndpointConfig.default9RouterKey;
      }

      return AiEndpointConfig(
        baseUrl: baseUrl,
        apiKey: apiKey,
        modelName: modelName,
        isEnabled: isEnabled,
      );
    } catch (_) {
      return AiEndpointConfig.defaultConfig();
    }
  }

  /// Menyimpan konfigurasi AI
  static Future<void> saveConfig(AiEndpointConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, config.baseUrl.trim());
    await prefs.setString(_keyModelName, config.modelName.trim());
    await prefs.setBool(_keyIsEnabled, config.isEnabled);

    try {
      await _storage.write(key: _keyApiKey, value: config.apiKey.trim());
    } catch (_) {
      await prefs.setString(_keyApiKey, config.apiKey.trim());
    }
  }
}
