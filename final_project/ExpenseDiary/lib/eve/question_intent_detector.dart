import 'question_intent.dart';

class QuestionIntentDetector {
  static QuestionIntent detect(String question) {
    final q = question.toLowerCase();

    if (q.contains('where') || q.contains('money go') || q.contains('spent')) {
      return QuestionIntent.clarity;
    }

    if (q.contains('overspend') || q.contains('normal')) {
      return QuestionIntent.context;
    }

    if (q.contains('changed') || q.contains('recent')) {
      return QuestionIntent.cause;
    }

    if (q.contains('afford') || q.contains('safe')) {
      return QuestionIntent.safety;
    }

    if (q.contains('why do i') || q.contains('keep')) {
      return QuestionIntent.selfUnderstanding;
    }

    return QuestionIntent.unknown;
  }
}
