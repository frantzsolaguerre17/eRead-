import 'excerpt.dart';

class Chapter {
  // 🔒 Attributs privés
  String _id;
  String _bookId;
  String _title;
  DateTime _createdAt;

  // 🔗 Relation : un chapitre contient plusieurs extraits
  List<Excerpt>? _excerpts;

  // 🔹 Constructeur avec paramètres nommés
  Chapter({
    required String id,
    required String bookId,
    required String title,
    required DateTime createdAt,
    List<Excerpt>? excerpts,
  })  : _id = id,
        _bookId = bookId,
        _title = title,
        _createdAt = createdAt,
        _excerpts = excerpts;

  // 🔹 Getters
  String get id => _id;
  String get bookId => _bookId;
  String get title => _title;
  DateTime get createdAt => _createdAt;
  List<Excerpt>? get excerpts => _excerpts;

  // 🔹 Setter pour ajouter des extraits
  set excerpts(List<Excerpt>? value) => _excerpts = value;

  void addExcerpt(Excerpt excerpt) {
    _excerpts ??= [];
    _excerpts!.add(excerpt);
  }

  // 🔹 Factory constructor pour JSON
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      bookId: json['book_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      excerpts: json['excerpts'] != null
          ? List<Excerpt>.from(
          json['excerpts'].map((e) => Excerpt.fromJson(e)))
          : null,
    );
  }

  // 🔹 Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'book_id': _bookId,
      'title': _title,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Chapter(id: $_id, title: $_title, bookId: $_bookId)';
  }
}
