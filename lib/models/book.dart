class Book {
  // 🔒 Attributs privés
  String _id;
  String _title;
  String _author;
  String _number_of_pages;
  DateTime _createdAt;
  bool _isSynced;
  String _cover;
  String _pdf;
  String _userId;
  String _category; // 🆕 Nouvelle variable

  // 🧱 Constructeur
  Book({
    required String id,
    required String title,
    required String author,
    required String number_of_pages,
    required DateTime createdAt,
    required bool isSynced,
    required String cover,
    required String pdf,
    required String userId,
    required String category, // 🆕 Ajout dans le constructeur
  })  : _id = id,
        _title = title,
        _author = author,
        _number_of_pages = number_of_pages,
        _createdAt = createdAt,
        _isSynced = isSynced,
        _cover = cover,
        _pdf = pdf,
        _userId = userId,
        _category = category; // 🆕

  // 🧩 Getters
  String get id => _id;
  String get title => _title;
  String get author => _author;
  String get number_of_pages => _number_of_pages;
  DateTime get createdAt => _createdAt;
  bool get isSynced => _isSynced;
  String get cover => _cover;
  String get pdf => _pdf;
  String get userId => _userId;
  String get category => _category; // 🆕

  // ✏️ Setters
  set title(String value) => _title = value;
  set author(String value) => _author = value;
  set number_of_pages(String value) => _number_of_pages = value;
  set isSynced(bool value) => _isSynced = value;
  set cover(String value) => _cover = value;
  set pdf(String value) => _pdf = value;
  set userId(String value) => _userId = value;
  set category(String value) => _category = value; // 🆕

  // 🔁 Convertir depuis JSON (pour lecture depuis Supabase)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      number_of_pages: json['number_of_pages'].toString(),
      createdAt: DateTime.parse(json['created_at']), // ✅ conversion correcte
      isSynced: json['isSynced'] as bool,
      cover: json['cover'] as String,
      pdf: json['pdf'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String? ?? 'Autre', // 🆕 valeur par défaut
    );
  }

  // 🔁 Convertir vers JSON (pour insertion dans Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'author': _author,
      'number_of_pages': _number_of_pages,
      'created_at': _createdAt.toIso8601String(),
      'isSynced': _isSynced,
      'cover': _cover,
      'pdf': _pdf,
      'user_id': _userId,
      'category': _category, // 🆕
    };
  }
}
