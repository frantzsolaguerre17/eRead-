import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/book.dart';
import '../services/book_service.dart';

class BookController extends ChangeNotifier {
  final BookService _service = BookService();

  List<Book> _books = [];
  bool isLoading = false;

  List<Book> get books => _books;

  // Liste des IDs des livres favoris
  List<String> favoriteBooks = [];

  /// 🔹 Charger tous les livres
  Future<void> fetchBooks() async {
    isLoading = true;
    notifyListeners();

    try {
      _books = await _service.fetchBooks();

      /// Charger les favoris depuis Supabase
      await loadFavorites();
    } catch (e) {
      debugPrint("Erreur fetchBooks: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Ajouter un nouveau livre
  Future<void> addBook(Book newBook, {
    required String title,
    required String author,
    String numberOfPages = '',
    String cover = '',
    String pdf = '',
    String category = 'Autre',
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final book = Book(
        id: const Uuid().v4(),
        title: title,
        author: author,
        number_of_pages: numberOfPages,
        createdAt: DateTime.now(),
        isSynced: true,
        cover: cover,
        pdf: pdf,
        userId: user.id,
        userName: user.userMetadata?['display_name'] ?? 'Inconnu',
        category: category,
      );

      await _service.addBook(book);
      _books.insert(0, book); // Ajouter en tête

    } catch (e) {
      debugPrint("Erreur addBook: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ============================================================
  //                     FAVORIS
  // ============================================================

  /// 🔹 Charger les favoris depuis Supabase
  Future<void> loadFavorites() async {
    try {
      favoriteBooks = await _service.getUserFavorites();
    } catch (e) {
      debugPrint("Erreur loadFavorites: $e");
    }
    notifyListeners();
  }

  /// 🔹 Ajouter / Retirer un favori
  Future<void> toggleFavorite(String bookId) async {
    try {
      final isFavorite = favoriteBooks.contains(bookId);

      if (isFavorite) {
        await _service.removeFavorite(bookId);
        favoriteBooks.remove(bookId);
      } else {
        await _service.addFavorite(bookId);
        favoriteBooks.add(bookId);
      }

    } catch (e) {
      debugPrint("Erreur toggleFavorite: $e");
    }

    notifyListeners();
  }

  /// 🔹 Vérifier si un livre est favori
  bool isFavorite(String bookId) {
    return favoriteBooks.contains(bookId);
  }
}
