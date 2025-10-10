import 'package:flutter/foundation.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyController with ChangeNotifier {
  final VocabularyService _vocabularyService = VocabularyService();
  List<Vocabulary> _vocabularies = [];

  List<Vocabulary> get vocabularies => _vocabularies;
  bool isLoading = false;

  /// 🔹 Get vocabularies for a specific book
  Future<void> fetchVocabularies(String bookId) async {
    isLoading = true;
    notifyListeners();

    try {
      _vocabularies = await _vocabularyService.getVocabulariesByBook(bookId);
    } catch (e) {
      print('Erreur: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Add a new vocabulary
  Future<void> addVocabulary(Vocabulary vocabulary) async {
    try {
      await _vocabularyService.addVocabulary(vocabulary);
      _vocabularies.add(vocabulary);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout du mot: $e');
    }
  }
}
