import 'package:memo_livre/models/vocabulary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chapter.dart';

class Book {
  // 🔒 Attributs privés
  String _id;
  String _title;
  String _author;
  String? _numberOfPages;
  DateTime _createdAt;

  // 🔗 Relations
  List<Chapter>? chapters;
  List<Vocabulary>? vocabularies;

  // 🔹 Constructeur principal
  Book(
      this._id,
      this._title,
      this._author,
      this._numberOfPages,
      this._createdAt,
      {
        this.chapters,
        this.vocabularies,
      });

  // 🔹 Getters
  String get id => _id;
  String get title => _title;
  String get author => _author;
  String? get numberOfPages => _numberOfPages;
  DateTime get createdAt => _createdAt;

  // 🔹 Setters (si tu veux pouvoir modifier les champs)
  set title(String value) => _title = value;
  set author(String value) => _author = value;
  set numberOfPages(String? value) => _numberOfPages = value;

  // 🔹 Factory constructor pour créer un objet à partir du JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      json['id'],
      json['title'],
      json['author'],
      json['number_of_pages'],
      DateTime.parse(json['created_at']),
    );
  }

  // 🔹 Méthode pour convertir un objet en JSON (utile pour Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'author': _author,
      'number_of_pages': _numberOfPages,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  // 🔹 (Optionnel) Méthode pratique pour afficher les infos d’un livre
  @override
  String toString() {
    return 'Book(id: $_id, title: $_title, author: $_author, pages: $_numberOfPages, createdAt: $_createdAt)';
  }
}
