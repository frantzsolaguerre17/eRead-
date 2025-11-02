class Expression {
  // 🔒 Attributs privés
  String _id;
  String _expressionText;
  String _definition;
  String _example;
  DateTime _createdAt;
  String _bookId;

  // 🧱 Constructeur
  Expression({
    required String id,
    required String expressionText,
    required String definition,
    required String example,
    required DateTime createdAt,
    required String bookId,
  })  : _id = id,
        _expressionText = expressionText,
        _definition = definition,
        _example = example,
        _createdAt = createdAt,
        _bookId = bookId;

  // 🧩 Getters
  String get id => _id;
  String get expressionText => _expressionText;
  String get definition => _definition;
  String get example => _example;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;

  // ✏️ Setters
  set expressionText(String value) => _expressionText = value;
  set definition(String value) => _definition = value;
  set example(String value) => _example = value;
  set bookId(String value) => _bookId = value;

  // 🔁 Convertir depuis JSON (lecture depuis Supabase)
  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'] as String,
      expressionText: json['expression_text'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      createdAt: json['created_at'],
      bookId: json['book_id'] as String,
    );
  }

  // 🔁 Convertir vers JSON (insertion dans Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'expression_text': _expressionText,
      'definition': _definition,
      'example': _example,
      'created_at': _createdAt?.toIso8601String(),
      'book_id': _bookId,
    };
  }
}
