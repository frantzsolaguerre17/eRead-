class Chapter {
  // 🔒 Attributs privés
  String _id;
  String _title;
  DateTime _createdAt;
  String _bookId;
  bool _isSynced;
  String _userId;

  // 🧱 Constructeur
  Chapter({
    required String id,
    required String title,
    required DateTime createdAt,
    required String bookId,
    required bool isSynced,
    required String userId,
  })  : _id = id,
        _title = title,
        _createdAt = createdAt,
        _bookId = bookId,
        _isSynced = isSynced,
        _userId = userId;

  // 🧩 Getters
  String get id => _id;
  String get title => _title;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;
  bool get isSynced => _isSynced;
  String get userId => _userId;

  // ✏️ Setters
  set title(String value) => _title = value;
  set bookId(String value) => _bookId = value;
  set isSynced(bool value) => _isSynced = value;
  set userId(String value) => _userId = value;

  // 🔁 Convertir depuis JSON (lecture depuis Supabase)
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: json['created_at'],
      bookId: json['book_id'] as String,
      isSynced: json['isSynced'] as bool,
      userId: json['user_id'] as String,
    );
  }

  // 🔁 Convertir vers JSON (insertion dans Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'created_at': _createdAt.toIso8601String(),
      'book_id': _bookId,
      'isSynced': _isSynced,
      'user_id': _userId,
    };
  }
}
