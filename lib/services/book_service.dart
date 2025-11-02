import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';

class BookService {
  final supabase = Supabase.instance.client;

  /// 🔹 Ajouter un livre
  Future<void> addBook(Book book) async {
    await supabase.from('book').insert(book.toJson());
  }

  /// 🔹 Récupérer tous les livres
  Future<List<Book>> getBooks() async {
    final response = await supabase.from('book').select('*').order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((data) => Book.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// 🔹 Récupérer les livres d’un utilisateur spécifique
  Future<List<Book>> getBooksByUser(String userId) async {
    final response = await supabase.from('book').select('*').eq('user_id', userId);
    return (response as List<dynamic>)
        .map((data) => Book.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}
