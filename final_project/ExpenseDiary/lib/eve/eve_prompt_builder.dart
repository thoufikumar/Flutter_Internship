import 'eve_context.dart';
import 'eve_persona.dart';
import 'question_intent.dart';

class EvePromptBuilder {
  static String build(
    EveContext context,
    String userQuestion,
    QuestionIntent intent,
  ) {
    final intentInstruction = _intentInstruction(intent, context);

    return '''
$eveSystemPrompt

Context:
Awareness level: ${context.level.name}
Category: ${context.category ?? 'None'}

Observations:
${context.observations.isEmpty ? '- No unusual patterns detected.' : context.observations.map((o) => '- $o').join('\n')}

User question:
"$userQuestion"

Instructions:
- Respond based on the user's intent
- Do not suggest actions
- Do not judge
- Use calm, reassuring language
$intentInstruction
''';
  }

  static String _intentInstruction(
    QuestionIntent intent,
    EveContext context,
  ) {
    switch (intent) {
      case QuestionIntent.clarity:
        return '''
Focus on helping the user understand *where* their money is going.
If nothing is unusual, reassure them that spending is spread normally.
''';

      case QuestionIntent.context:
        return '''
Compare current spending to the user's usual pattern.
If this looks normal, explicitly reassure them that they are not overspending.
''';

      case QuestionIntent.cause:
        return '''
Explain whether anything has changed recently.
If nothing changed, say so clearly to reduce anxiety.
''';

      case QuestionIntent.safety:
        return '''
Reassure the user about short-term financial safety.
Avoid predictions or advice. Speak in terms of stability only.
''';

      case QuestionIntent.selfUnderstanding:
        return '''
Acknowledge emotional or behavioral patterns gently.
Avoid blame. Normalize human spending behavior.
''';

      case QuestionIntent.unknown:
      default:
        return '''
Explain the observations in a neutral, general way.
Reassure calmly if nothing stands out.
''';
    }
  }
}
