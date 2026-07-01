class Deck {
  final int? id;
  final String title;
  final String tags;
  final int colorCode;

  Deck({
    this.id,
    required this.title,
    this.tags = '',
    this.colorCode = 0xFF3B82F6,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'colorCode': colorCode,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      title: map['title'],
      tags: map['tags'],
      colorCode: map['colorCode'],
    );
  }
}
