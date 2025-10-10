import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;


  /// 🔹 Add Book
  Future<void> addBook(Book book) async {
    try {
      await _supabase.from('book').insert({
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'number_of_pages': book.numberOfPages,
        'created_at': book.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du livre : $e');
    }
  }


  /// 🔹 Get Books
  Future<List<Book>> getAllBooks() async {
    try {
      final response = await _supabase.from('book').select('id, title, author, number_of_pages, created_at');

      final List<Book> books = (response as List).map((json) => Book.fromJson(json)).toList();

      return books;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des livres : $e');
    }
  }
}
