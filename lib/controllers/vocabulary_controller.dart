import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyController extends ChangeNotifier {
  final VocabularyService _service = VocabularyService();

  List<Vocabulary> _vocabularies = [];
  List<Vocabulary> get vocabularies => _vocabularies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 🔹 Charger tous les vocabulaires d’un livre
  Future<void> fetchVocabulary(String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1️⃣ Charger depuis Supabase (ou local)
      _vocabularies = await _service.fetchVocabularyByBook(bookId);

      // 2️⃣ Synchroniser les mots hors ligne vers Supabase
      await _service.syncOfflineVocabulary();

      // 3️⃣ Recharger après synchro
      _vocabularies = await _service.fetchVocabularyByBook(bookId);
    } catch (e) {
      debugPrint("⚠️ Erreur fetchVocabulary : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVocabulary(Vocabulary vocab) async {
    try {
      await _service.addVocabulary(vocab);
      await _service.syncOfflineVocabulary();
      _vocabularies = await _service.fetchVocabularyByBook(vocab.bookId);
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Erreur addVocabulary : $e");
    }
  }

  /// 🔄 Synchroniser manuellement les mots hors ligne
  Future<void> syncVocabulary() async {
    try {
      await _service.syncOfflineVocabulary();

      // 🔁 Recharger après synchronisation
      if (_vocabularies.isNotEmpty) {
        final bookId = _vocabularies.first.bookId;
        _vocabularies = await _service.fetchVocabularyByBook(bookId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ Erreur syncVocabulary : $e");
    }
  }
}
