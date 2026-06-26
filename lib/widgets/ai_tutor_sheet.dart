import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';

class AiTutorSheet extends StatefulWidget {
  final String systemContext;
  final String initialPrompt;

  const AiTutorSheet({
    super.key,
    required this.systemContext,
    required this.initialPrompt,
  });

  static Future<void> show(
    BuildContext context, {
    required String systemContext,
    required String initialPrompt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AiTutorSheet(
          systemContext: systemContext,
          initialPrompt: initialPrompt,
        ),
      ),
    );
  }

  @override
  State<AiTutorSheet> createState() => _AiTutorSheetState();
}

class _AiTutorSheetState extends State<AiTutorSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<AiMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendMessage(widget.initialPrompt, isInitial: true);
  }

  Future<void> _sendMessage(String text, {bool isInitial = false}) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _messages.add(AiMessage(role: 'user', content: msg));
      if (!isInitial) _controller.clear();
      _isLoading = true;
    });

    final aiResponse = await AiService.instance.generateText(
      messages: _messages,
      systemContext: widget.systemContext,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (aiResponse != null) {
          _messages.add(AiMessage(role: 'assistant', content: aiResponse));
        } else {
          _messages.add(
            AiMessage(
              role: 'assistant',
              content: 'Sorry, I am having trouble connecting right now.',
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: FluentianColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Tutor',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? FluentianColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : null,
                        bottomLeft: !isUser ? const Radius.circular(0) : null,
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg.content,
                      style: GoogleFonts.inter(
                        color: isUser ? Colors.white : FluentianColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: FluentianColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
