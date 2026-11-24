import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/ai_insight.dart';
import '../ai_analytics_controller.dart';
import '../services/ai_agentic_service.dart';
import 'dialogs/ai_endpoint_settings_dialog.dart';

/// Widget Panel Interaktif Asisten Konsultasi Bisnis AI (Carbon Design System)
class AiChatAdvisorWidget extends ConsumerStatefulWidget {
  const AiChatAdvisorWidget({super.key});

  @override
  ConsumerState<AiChatAdvisorWidget> createState() =>
      _AiChatAdvisorWidgetState();
}

class _AiChatAdvisorWidgetState extends ConsumerState<AiChatAdvisorWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(aiAnalyticsControllerProvider.notifier).sendMessage(text);
    if (presetText == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAnalyticsControllerProvider);
    final messages = state.chatMessages;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    ref.listen(aiAnalyticsControllerProvider, (previous, next) {
      if (previous?.chatMessages.length != next.chatMessages.length ||
          previous?.isGeneratingReply != next.isGeneratingReply) {
        _scrollToBottom();
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Chat Advisor (Hanya tampil di Desktop/Tablet, di mobile sudah diwakili bar ringkas atas)
          if (!isMobile) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: AppColors.surface1,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KONSULTASI ASISTEN AI BISNIS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Didukung 9router Local AI (Port 20128) • Claude & Gemini',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.inkMuted),
                    tooltip: 'Bersihkan Riwayat Percakapan',
                    onPressed: () {
                      ref.read(aiAnalyticsControllerProvider.notifier).clearChat();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 18, color: AppColors.inkMuted),
                    tooltip: 'Pengaturan Endpoint AI (Ollama/9router/OpenAI)',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AiEndpointSettingsDialog(),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2.0),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 6, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'AKTIF',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),
          ],

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length + (state.isGeneratingReply ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && state.isGeneratingReply) {
                  return _buildGeneratingBubble();
                }

                final msg = messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),

          // Suggestion Chips (Prompt Cepat)
          if (messages.isNotEmpty && messages.last.suggestions.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.surface1.withValues(alpha: 0.6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: messages.last.suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                        backgroundColor: AppColors.canvas,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                          side: const BorderSide(
                            color: AppColors.hairline,
                            width: 1.0,
                          ),
                        ),
                        onPressed: state.isGeneratingReply
                            ? null
                            : () => _handleSend(suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const Divider(color: AppColors.hairline, height: 1),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12.0),
            color: AppColors.canvas,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (val) => _handleSend(),
                    style: const TextStyle(fontSize: 13, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText:
                          'Tanyakan sesuatu tentang data transaksi, margin, atau pabrik...',
                      hintStyle: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.inkSubtle,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: state.isGeneratingReply ? null : () => _handleSend(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      elevation: 0,
                    ),
                    child: state.isGeneratingReply
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(AiChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isUser ? 'Anda' : 'Asisten AI',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.inkSubtle,
                ),
              ),
              if (!isUser) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: AiAgenticService.sanitizeAiText(msg.text)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teks jawaban AI disalin ke papan klip.'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(2),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.copy, size: 12, color: AppColors.inkSubtle),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: isUser ? AppColors.surface1 : AppColors.canvas,
              border: isUser
                  ? Border.all(color: AppColors.hairline)
                  : const Border(
                      left: BorderSide(color: AppColors.primary, width: 3.5),
                      top: BorderSide(color: AppColors.hairline),
                      right: BorderSide(color: AppColors.hairline),
                      bottom: BorderSide(color: AppColors.hairline),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _renderFormattedText(msg.text),
                if (msg.highlightMetrics != null &&
                    msg.highlightMetrics!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: msg.highlightMetrics!.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                                Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              border: Border.all(color: AppColors.hairline),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Asisten AI sedang menganalisis data transaksi...',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderFormattedText(String text) {
    final clean = AiAgenticService.sanitizeAiText(text);
    final lines = clean.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) {
          return const SizedBox(height: 6);
        }

        // Header level 3
        if (trimmed.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              trimmed.substring(4),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: 0.3,
              ),
            ),
          );
        }

        // Header level 2
        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
            child: Text(
              trimmed.substring(3),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          );
        }

        // Blockquote
        if (trimmed.startsWith('> ')) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 2.5),
              ),
            ),
            child: Text.rich(
              _buildInlineTextSpans(trimmed.substring(2)),
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.inkMuted,
                height: 1.35,
              ),
            ),
          );
        }

        // List item (bullet atau nomor)
        final isBullet = trimmed.startsWith('- ') || trimmed.startsWith('* ') || trimmed.startsWith('• ');
        final isNumber = RegExp(r'^\d+\.\s').hasMatch(trimmed);

        if (isBullet || isNumber) {
          final prefix = isBullet ? '• ' : trimmed.substring(0, trimmed.indexOf(' ') + 1);
          final content = trimmed.substring(prefix.length);

          return Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefix,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isNumber ? FontWeight.w600 : FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text.rich(
                    _buildInlineTextSpans(content),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Paragraf umum dengan inline styling
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text.rich(
            _buildInlineTextSpans(line),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              height: 1.35,
            ),
          ),
        );
      }).toList(),
    );
  }

  TextSpan _buildInlineTextSpans(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\*\*(.*?)\*\*|`([^`]+)`)');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final boldGroup = match.group(2);
      final codeGroup = match.group(3);

      if (boldGroup != null) {
        spans.add(TextSpan(
          text: boldGroup,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ));
      } else if (codeGroup != null) {
        spans.add(TextSpan(
          text: codeGroup,
          style: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: Color(0x1F808080),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
