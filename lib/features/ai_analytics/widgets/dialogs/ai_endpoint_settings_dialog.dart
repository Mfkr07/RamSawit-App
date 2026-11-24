import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/ai_endpoint_config_service.dart';

/// Dialog untuk mengatur Endpoint AI kustom (9router / Ollama / OpenAI-compatible / Local LLM)
class AiEndpointSettingsDialog extends StatefulWidget {
  const AiEndpointSettingsDialog({super.key});

  @override
  State<AiEndpointSettingsDialog> createState() =>
      _AiEndpointSettingsDialogState();
}

class _AiEndpointSettingsDialogState extends State<AiEndpointSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _keyController;
  late TextEditingController _modelController;
  bool _isEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _testResultText;
  bool? _testResultSuccess;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _keyController = TextEditingController();
    _modelController = TextEditingController();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    final cfg = await AiEndpointConfigService.loadConfig();
    if (!mounted) return;
    setState(() {
      _urlController.text = cfg.baseUrl;
      _keyController.text = cfg.apiKey;
      _modelController.text = cfg.modelName;
      _isEnabled = cfg.isEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final newConfig = AiEndpointConfig(
      baseUrl: _urlController.text.trim(),
      apiKey: _keyController.text.trim(),
      modelName: _modelController.text.trim(),
      isEnabled: _isEnabled,
    );

    await AiEndpointConfigService.saveConfig(newConfig);

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigurasi Endpoint AI berhasil disimpan.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyPreset(String name) {
    if (name == 'gemini') {
      _urlController.text = 'https://generativelanguage.googleapis.com/v1beta/openai';
      _modelController.text = 'gemini-1.5-flash';
      if (_keyController.text == AiEndpointConfig.default9RouterKey) {
        _keyController.text = '';
      }
    } else if (name == 'groq') {
      _urlController.text = 'https://api.groq.com/openai/v1';
      _modelController.text = 'llama-3.3-70b-versatile';
      if (_keyController.text == AiEndpointConfig.default9RouterKey) {
        _keyController.text = '';
      }
    } else if (name == 'openrouter') {
      _urlController.text = 'https://openrouter.ai/api/v1';
      _modelController.text = 'google/gemini-2.0-flash-exp:free';
      if (_keyController.text == AiEndpointConfig.default9RouterKey) {
        _keyController.text = '';
      }
    } else if (name == '9router-lan') {
      _urlController.text = 'http://10.9.124.164:20128/v1';
      _modelController.text = 'ag/gemini-3.8-flash-medium';
      _keyController.text = AiEndpointConfig.default9RouterKey;
    } else if (name == 'tunnel') {
      _urlController.text = 'https://nama-tunnel.trycloudflare.com/v1';
      _modelController.text = 'ag/gemini-3.8-flash-medium';
      _keyController.text = AiEndpointConfig.default9RouterKey;
    } else if (name == 'ollama') {
      _urlController.text = 'http://localhost:11434/v1';
      _modelController.text = 'llama3.2';
    } else if (name == 'openai') {
      _urlController.text = 'https://api.openai.com/v1';
      _modelController.text = 'gpt-4o-mini';
    } else if (name == '9router') {
      _urlController.text = 'http://localhost:20128/v1';
      _modelController.text = 'ag/gemini-3.8-flash-medium';
      _keyController.text = AiEndpointConfig.default9RouterKey;
    }
    _testResultText = null;
    _testResultSuccess = null;
    setState(() {});
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();
    final model = _modelController.text.trim();

    if (url.isEmpty || model.isEmpty) {
      setState(() {
        _testResultSuccess = false;
        _testResultText = 'URL dan Nama Model tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResultText = null;
      _testResultSuccess = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final cleanBaseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final endpoint = Uri.parse('$cleanBaseUrl/chat/completions');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'close',
        if (key.isNotEmpty) 'Authorization': 'Bearer $key',
      };

      final body = jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'Ping test. Balas singkat satu kata: OK'}
        ],
        'max_tokens': 15,
        'stream': false,
      });

      final response = await http
          .post(endpoint, headers: headers, body: body)
          .timeout(const Duration(seconds: 12));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        final answer = choices != null && choices.isNotEmpty
            ? (choices[0]['message']?['content'] as String? ?? 'OK').trim()
            : 'OK';

        setState(() {
          _testResultSuccess = true;
          _testResultText = 'Terhubung! (${stopwatch.elapsedMilliseconds} ms)\nRespons Model: "$answer"';
        });
      } else {
        setState(() {
          _testResultSuccess = false;
          final preview = response.body.length > 120 ? response.body.substring(0, 120) : response.body;
          _testResultText = 'Gagal (${response.statusCode}): $preview';
        });
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _testResultSuccess = false;
        _testResultText = 'Koneksi gagal: $e';
      });
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(
                heightFactor: 3,
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(Icons.settings_suggest,
                              color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'PENGATURAN ENDPOINT AGENTIC AI',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hubungkan asisten AI ke model LLM pilihan Anda (9router, Ollama, OpenAI) untuk kapabilitas analisis bisnis mendalam.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Aktifkan
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Gunakan Model LLM Eksternal',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _isEnabled
                              ? 'Aktif (Koneksi ke Endpoint LLM)'
                              : 'Nonaktif (Menggunakan Analisis Deterministik Lokal)',
                          style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                        ),
                        value: _isEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isEnabled = val),
                      ),
                      const Divider(height: 20),

                      // Preset Cepat
                      const Text(
                        'PILIHAN PRESET CEPAT:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.computer, size: 14, color: AppColors.primary),
                            label: const Text('9router (PC)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('9router'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.wifi, size: 14, color: Color(0xFF0F62FE)),
                            label: const Text('9router (Wi-Fi HP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () => _applyPreset('9router-lan'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.cloud_sync, size: 14, color: Color(0xFF10B981)),
                            label: const Text('9router (Tunnel HP)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('tunnel'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                            label: const Text('Google Gemini (Cloud)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('gemini'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.flash_on, size: 14, color: Color(0xFFF59E0B)),
                            label: const Text('Groq Cloud', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('groq'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.alt_route, size: 14),
                            label: const Text('OpenRouter', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('openrouter'),
                          ),
                        ],
                      ),
                      if (_urlController.text.contains(':20128') && !_urlController.text.contains('localhost')) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F62FE).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF0F62FE).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.wifi, size: 16, color: Color(0xFF0F62FE)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Akses 9router dari HP Android: Pastikan HP dan Laptop terhubung ke satu Wi-Fi yang sama. Ganti IP (misal 10.9.124.164) dengan IP Wi-Fi laptop Anda.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF0F62FE), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_urlController.text.contains('trycloudflare') || _urlController.text.contains('loca.lt')) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.vpn_lock, size: 16, color: Color(0xFF10B981)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Akses 9router via Tunnel: Jalankan Cloudflare Tunnel atau npx localtunnel di laptop, lalu tempel URL HTTPS tunnel tersebut ke sini.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_urlController.text.contains('googleapis.com')) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dapatkan API Key Gemini gratis via Google AI Studio: aistudio.google.com/app/apikey (login dengan akun Google Anda).',
                                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_urlController.text.contains('groq.com')) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dapatkan API Key Groq gratis via: console.groq.com/keys (kecepatan respon sangat tinggi).',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // URL Base
                      TextFormField(
                        controller: _urlController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          labelText: 'Base URL (OpenAI-compatible)',
                          hintText: 'http://localhost:20128/v1',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.link, size: 18),
                        ),
                        validator: (v) {
                          if (_isEnabled && (v == null || v.trim().isEmpty)) {
                            return 'Base URL tidak boleh kosong saat aktif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Model Name
                      TextFormField(
                        controller: _modelController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          labelText: 'Nama Model LLM',
                          hintText: 'ag/gemini-3.8-flash-medium / llama3.2',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.memory, size: 18),
                        ),
                        validator: (v) {
                          if (_isEnabled && (v == null || v.trim().isEmpty)) {
                            return 'Nama model wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // API Key
                      TextFormField(
                        controller: _keyController,
                        obscureText: _obscureKey,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'API Key / Token (9router / Provider)',
                          hintText: 'sk-... atau token autentikasi',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: const Icon(Icons.key, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureKey ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureKey = !_obscureKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Uji Koneksi
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.hairline),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        onPressed: _isTesting ? null : _testConnection,
                        icon: _isTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.network_check, size: 16),
                        label: Text(_isTesting ? 'Menguji Koneksi...' : 'Uji Koneksi Endpoint'),
                      ),

                      if (_testResultText != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _testResultSuccess == true
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: _testResultSuccess == true
                                  ? AppColors.success.withValues(alpha: 0.4)
                                  : AppColors.error.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _testResultSuccess == true ? Icons.check_circle : Icons.error_outline,
                                size: 16,
                                color: _testResultSuccess == true ? AppColors.success : AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _testResultText!,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _testResultSuccess == true ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Tombol Aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, size: 16),
                            label: const Text('Simpan Konfigurasi'),
                            onPressed: _isSaving ? null : _saveConfig,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
