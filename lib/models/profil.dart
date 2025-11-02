class Profil {
  // 🔒 Attributs privés
  String _id;
  DateTime _createdAt;
  String _username;
  String _email;
  String _userId;

  // 🧱 Constructeur
  Profil({
    required String id,
    required DateTime createdAt,
    required String username,
    required String email,
    required String userId,
  })  : _id = id,
        _createdAt = createdAt,
        _username = username,
        _email = email,
        _userId = userId;

  // 🧩 Getters
  String get id => _id;
  DateTime get createdAt => _createdAt;
  String get username => _username;
  String get email => _email;
  String get userId => _userId;

  // ✏️ Setters
  set username(String value) => _username = value;
  set email(String value) => _email = value;
  set userId(String value) => _userId = value;

  // 🔁 Convertir depuis JSON (lecture depuis Supabase)
  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: json['id'] as String,
      createdAt: json['created_at'],
      username: json['username'] as String,
      email: json['email'] as String,
      userId: json['user_id'] as String,
    );
  }

  // 🔁 Convertir vers JSON (insertion / mise à jour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'created_at': _createdAt.toIso8601String(),
      'username': _username,
      'email': _email,
      'user_id': _userId,
    };
  }
}
