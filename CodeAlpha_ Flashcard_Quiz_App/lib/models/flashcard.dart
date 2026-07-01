class Flashcard {
  final int? id;
  final int deckId;
  final String question;
  final String answer;
  final bool isMastered;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.isMastered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'question': question,
      'answer': answer,
      'isMastered': isMastered ? 1 : 0,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deckId'],
      question: map['question'],
      answer: map['answer'],
      isMastered: map['isMastered'] == 1,
    );
  }
}
