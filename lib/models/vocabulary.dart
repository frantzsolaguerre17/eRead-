import 'package:supabase_flutter/supabase_flutter.dart';

class Vocabulary {
  // 🔒 Attributs privés
  String _id;
  String _word;
  String _definition;
  String? _example;
  DateTime _createdAt;
  String _bookId; // lien avec le livre

  // 🔹 Constructeur principal
  Vocabulary(
      this._id,
      this._word,
      this._definition,
      this._example,
      this._createdAt,
      this._bookId,
      );

  // 🔹 Getters
  String get id => _id;
  String get word => _word;
  String get definition => _definition;
  String? get example => _example;
  DateTime get createdAt => _createdAt;
  String get bookId => _bookId;

  // 🔹 Setters (optionnels si tu veux modifier des champs après création)
  set word(String value) => _word = value;
  set definition(String value) => _definition = value;
  set example(String? value) => _example = value;

  // 🔹 Factory constructor : créer un objet Vocabulary à partir d’un JSON
  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      json['id'],
      json['word'],
      json['definition'],
      json['example'],
      DateTime.parse(json['created_at']),
      json['book_id'],
    );
  }

  // 🔹 Méthode pour convertir un objet Vocabulary en JSON (utile pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'word': _word,
      'definition': _definition,
      'example': _example,
      'created_at': _createdAt.toIso8601String(),
      'book_id': _bookId,
    };
  }

  // 🔹 (Optionnel) Pour faciliter le débogage
  @override
  String toString() {
    return 'Vocabulary(id: $_id, word: $_word, definition: $_definition, example: $_example, book_id: $_bookId, createdAt: $_createdAt)';
  }
}
