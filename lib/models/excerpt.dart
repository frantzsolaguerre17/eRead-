class Excerpt {
  // 🔒 Attributs privés
  String _id;
  String _chapter_id;
  String _content;
  String? _example;
  String? _comment;
  DateTime _created_at;
  bool _isSynced;

  // 🔹 Constructeur avec paramètres nommés
  Excerpt({
    required String id,
    required String chapterId,
    required String content,
    required DateTime createdAt,
    String? example,
    String? comment,
    bool isSynced = false,
  })  : _id = id,
        _chapter_id = chapterId,
        _content = content,
        _created_at = createdAt,
        _example = example,
        _comment = comment,
        _isSynced = isSynced;

  // 🔹 Getters
  String get id => _id;
  String get chapterId => _chapter_id;
  String get content => _content;
  String? get example => _example;
  String? get comment => _comment;
  DateTime get createdAt => _created_at;
  bool get isSynced => _isSynced;

  // 🔹 Setters
  set content(String value) => _content = value;
  set example(String? value) => _example = value;
  set comment(String? value) => _comment = value;
  set isSynced(bool value) => _isSynced = value;

  // 🔹 Depuis JSON (Supabase)
  factory Excerpt.fromJson(Map<String, dynamic> json) {
    return Excerpt(
      id: json['id'],
      chapterId: json['chapter_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      example: json['example'],
      comment: json['comment'],
      isSynced: true,
    );
  }

  // 🔹 Vers JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'chapter_id': _chapter_id,
      'content': _content,
      'example': _example,
      'comment': _comment,
      'created_at': _created_at.toIso8601String(),
    };
  }

  // 🔹 Vers Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'chapter_id': _chapter_id,
      'content': _content,
      'example': _example,
      'comment': _comment,
      'created_at': _created_at.toIso8601String(),
      'isSynced': _isSynced ? 1 : 0,
    };
  }

  // 🔹 Depuis Map (SQLite)
  factory Excerpt.fromMap(Map<String, dynamic> map) {
    return Excerpt(
      id: map['id'],
      chapterId: map['chapter_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      example: map['example'],
      comment: map['comment'],
      isSynced: map['isSynced'] == 1,
    );
  }

  @override
  String toString() {
    return 'Excerpt(id: $_id, chapterId: $_chapter_id, content: $_content, example: $_example, comment: $_comment, isSynced: $_isSynced)';
  }
}
