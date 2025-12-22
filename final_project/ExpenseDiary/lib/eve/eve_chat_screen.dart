// import 'package:expense_tracker_app/eve/llm_client.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'eve_observation_mapper.dart';
// import '../state/awareness_provider.dart';
// import 'eve_service.dart';

// class EveChatScreen extends StatefulWidget {
//   const EveChatScreen({super.key});

//   @override
//   State<EveChatScreen> createState() => _EveChatScreenState();
// }

// class _EveChatScreenState extends State<EveChatScreen> {
// final EveService _eveService = EveService(
//   client: LLMClient(
//     const String.fromEnvironment('OPENAI_API_KEY'),
//   ),
// );
//   bool _loading = true;
//   String? _response;
//   bool _loadedOnce = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Prevent multiple calls
//     if (_loadedOnce) return;
//     _loadedOnce = true;

//     _loadExplanation();
//   }

//   Future<void> _loadExplanation() async {
//     final awarenessProvider =
//         context.read<AwarenessProvider>();
// final signals = awarenessProvider.signals;
//     final awareness = awarenessProvider.currentAwareness;

//     // 🧘 No awareness → silence respected
//     if (awareness == null) {
//       setState(() {
//         _response = 'There’s nothing to explain right now.';
//         _loading = false;
//       });
//       return;
//     }

// final eveContext = EveObservationMapper.map(
//   level: awareness.level,
//   reason: awareness.reason,
//   category: awareness.category,
//   velocity: signals?.velocity,
//   frequency: signals?.frequency,
//   rhythm: signals?.rhythm,
// );

//     try {
//       final reply = await _eveService.askEve(
//         context: eveContext,
//         question: 'Why am I seeing this?',
//       );

//       if (!mounted) return;

//       setState(() {
//         _response = reply;
//         _loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _response =
//             'I couldn’t load an explanation right now.';
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('EVE'),
//         backgroundColor: const Color(0xFF4F9792),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       backgroundColor: const Color(0xFFEFF9F7),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: _loading
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : _EveMessageBubble(
//                 message: _response ?? '',
//               ),
//       ),
//     );
//   }
// }

// /// Simple calm message bubble
// class _EveMessageBubble extends StatelessWidget {
//   final String message;

//   const _EveMessageBubble({
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Text(
//           message,
//           style: const TextStyle(
//             fontSize: 15,
//             height: 1.4,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }
