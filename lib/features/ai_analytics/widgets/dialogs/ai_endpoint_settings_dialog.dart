import 'package:flutter/material.dart';
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
    if (name == '9router') {
      _urlController.text = 'http://localhost:20128/v1';
      _modelController.text = 'ag/gemini-3.8-flash-medium';
    } else if (name == 'ollama') {
      _urlController.text = 'http://localhost:11434/v1';
      _modelController.text = 'llama3.2';
    } else if (name == 'openai') {
      _urlController.text = 'https://api.openai.com/v1';
      _modelController.text = 'gpt-4o-mini';
    }
    setState(() {});
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
                        children: [
                          ActionChip(
                            label: const Text('9router (Port 20128)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('9router'),
                          ),
                          ActionChip(
                            label: const Text('Ollama (Port 11434)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('ollama'),
                          ),
                          ActionChip(
                            label: const Text('OpenAI API', style: TextStyle(fontSize: 11)),
                            onPressed: () => _applyPreset('openai'),
                          ),
                        ],
                      ),
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
                          labelText: 'API Key / Token (Opsional untuk Local)',
                          hintText: 'sk-... atau kosongkan jika tidak butuh',
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
                      const SizedBox(height: 20),

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
