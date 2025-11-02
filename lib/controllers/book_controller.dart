import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookController extends ChangeNotifier {
  final BookService _service = BookService();

  List<Book> _books = [];
  bool isLoading = false; // ✅ ajoute ce booléen

  List<Book> get books => _books;

  /// 🔹 Charger tous les livres
  Future<void> fetchBooks() async {
    isLoading = true;
    notifyListeners();

    try {
      _books = await _service.getBooks();
    } catch (e) {
      debugPrint("Erreur fetchBooks: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Ajouter un nouveau livre
  Future<void> addBook(Book newBook) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.addBook(newBook);
      _books.add(newBook);
    } catch (e) {
      debugPrint("Erreur addBook: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
