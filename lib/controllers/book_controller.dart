import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookController with ChangeNotifier {

  final BookService _bookService = BookService();
  List<Book> _books = [];

  List<Book> get books => _books;
  bool isLoading = false;


  /// 🔹 Get books
  Future<void> fetchBooks() async {
    isLoading = true;
    notifyListeners();

    try {
      _books = await _bookService.getAllBooks();
    } catch (e) {
      print('Erreur: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /// 🔹 Add book
  Future<void> addBook(Book book) async {
    try {
      await _bookService.addBook(book);
      _books.add(book);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout du livre: $e');
    }
  }
}
