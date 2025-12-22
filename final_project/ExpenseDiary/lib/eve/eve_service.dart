import 'package:expense_tracker_app/eve/question_intent.dart';

import '../eve_memory/eve_context_store.dart';
import '../eve_memory/eve_context_mapper.dart';
import 'eve_context.dart';
import 'eve_prompt_builder.dart';
import 'llm_client.dart';
import 'question_intent_detector.dart';

class EveService {
  final bool useMock;
  final LLMClient? _client;

  EveService({
    this.useMock = false,
    LLMClient? client,
  }) : _client = client;

  Future<String> askEve({
    required String question,
  }) async {
    final state = await EveContextStore.instance.load();

    final intent = QuestionIntentDetector.detect(question);

    if (state == null || !state.hasAnythingToExplain) {
      // Intent-aware reassurance even when nothing is abnormal
      return _intentFallback(intent);
    }

    final EveContext context = toEveContext(state);

    final prompt = EvePromptBuilder.build(
      context,
      question,
      intent,
    );

    if (useMock || _client == null) {
      return _mockResponse(context, intent);
    }

    return await _client!.complete(
      systemPrompt: prompt,
      userPrompt: question,
    );
  }

  String _intentFallback(QuestionIntent intent) {
    switch (intent) {
      case QuestionIntent.clarity:
        return 'Nothing looks unusually high right now. Your spending is fairly balanced across categories.';

      case QuestionIntent.context:
        return 'This looks consistent with how you usually spend. There isn’t a clear sign of overspending.';

      case QuestionIntent.cause:
        return 'There hasn’t been a recent shift in your spending patterns. Things look stable.';

      case QuestionIntent.safety:
        return 'Based on your recent activity, things look steady right now.';

      case QuestionIntent.selfUnderstanding:
        return 'Spending patterns can fluctuate for many reasons. What you’re seeing doesn’t look concerning.';

      case QuestionIntent.unknown:
      default:
        return 'Nothing stands out right now.';
    }
  }

  String _mockResponse(EveContext context, QuestionIntent intent) {
    if (context.observations.isEmpty) {
      return _intentFallback(intent);
    }

    return '''
Here’s what I’m noticing:
${context.observations.first}

This is simply an observation, not something you need to act on.
''';
  }
}
