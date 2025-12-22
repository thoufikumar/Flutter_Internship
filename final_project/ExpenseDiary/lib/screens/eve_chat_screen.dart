import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../eve/eve_observation_mapper.dart';
import '../eve/eve_service.dart';
import '../state/awareness_provider.dart';
import '../rules_engine/models.dart';

class EveChatScreen extends StatefulWidget {
  const EveChatScreen({super.key});

  @override
  State<EveChatScreen> createState() => _EveChatScreenState();
}

class _EveChatScreenState extends State<EveChatScreen> {
  final EveService _eveService = EveService();
  final List<_EveMessage> _messages = [];
  bool _loading = false;

  final Color _primary = const Color(0xFF4F9792);
  final Color _background = const Color(0xFFEFF9F7);

final List<String> _suggestedQuestions = const [
  'Where did my money go?',
  'Did I overspend or is this normal?',
  'What changed recently?',
  'Can I afford this right now?',
  'Why do I keep breaking my plan?',
];

  @override
  void initState() {
    super.initState();

    _messages.add(
      _EveMessage(
        text:
            'Hi, I’m Eve.\nI’m here if you want to understand what you’re seeing.',
        isUser: false,
      ),
    );
  }

  Future<void> _askEve(String question) async {
  setState(() {
    _messages.add(_EveMessage(text: question, isUser: true));
    _loading = true;
  });

  try {
    final reply = await _eveService.askEve(
      question: question,
    );

    if (!mounted) return;

    setState(() {
      _messages.add(
        _EveMessage(text: reply, isUser: false),
      );
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _messages.add(
        _EveMessage(
          text: 'I had trouble responding just now.\nLet’s try again later.',
          isUser: false,
        ),
      );
    });
  } finally {
    if (!mounted) return;
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        title: const Text('Eve'),
      ),
      body: Column(
        children: [
          // 🤖 EVE AVATAR
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.auto_awesome,
                color: _primary,
                size: 28,
              ),
            ),
          ),

          // 💬 CHAT
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(
                  message: _messages[index],
                  primary: _primary,
                );
              },
            ),
          ),

          // 🧠 SUGGESTED QUESTIONS
          if (!_loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedQuestions.map((q) {
                  return ActionChip(
                    label: Text(q),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _askEve(q),
                  );
                }).toList(),
              ),
            ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _EveMessage {
  final String text;
  final bool isUser;

  _EveMessage({
    required this.text,
    required this.isUser,
  });
}

class _ChatBubble extends StatelessWidget {
  final _EveMessage message;
  final Color primary;

  const _ChatBubble({
    required this.message,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser
              ? primary.withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
