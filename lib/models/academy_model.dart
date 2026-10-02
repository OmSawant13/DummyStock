class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class AcademyLesson {
  final String id;
  final String title;
  final String category; // "Stock Basics", "Technical Analysis", "Risk & Money Management", "Market Psychology"
  final String summary;
  final String readTime;
  final String content;
  final List<QuizQuestion> quiz;
  bool isCompleted;

  AcademyLesson({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.readTime,
    required this.content,
    required this.quiz,
    this.isCompleted = false,
  });
}

class GlossaryTerm {
  final String term;
  final String category;
  final String definition;
  final String example;

  GlossaryTerm({
    required this.term,
    required this.category,
    required this.definition,
    required this.example,
  });
}
