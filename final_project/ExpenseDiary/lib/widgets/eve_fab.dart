import 'package:expense_tracker_app/screens/eve_chat_screen.dart';
import 'package:flutter/material.dart';

class EveFab extends StatelessWidget {
  const EveFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EveChatScreen(),
          ),
        );
      },
      child: const Icon(Icons.chat_bubble_outline),
    );
  }
}
