class Excerpt {
  // 🔒 Attributs privés
  String _id;
  String _chapterId;
  String _content;
  String? _comment;
  DateTime _createdAt;

  // 🔹 Constructeur avec paramètres nommés
  Excerpt({
    required String id,
    required String chapterId,
    required String content,
    String? comment,
    required DateTime createdAt,
  })  : _id = id,
        _chapterId = chapterId,
        _content = content,
        _comment = comment,
        _createdAt = createdAt;

  // 🔹 Getters
  String get id => _id;
  String get chapterId => _chapterId;
  String get content => _content;
  String? get comment => _comment;
  DateTime get createdAt => _createdAt;

  // 🔹 Factory constructor pour JSON
  factory Excerpt.fromJson(Map<String, dynamic> json) {
    return Excerpt(
      id: json['id'],
      chapterId: json['chapter_id'],
      content: json['content'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // 🔹 Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'chapter_id': _chapterId,
      'content': _content,
      'comment': _comment,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Excerpt(id: $_id, chapterId: $_chapterId, content: $_content, comment: $_comment)';
  }
}
