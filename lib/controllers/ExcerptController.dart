import 'package:flutter/foundation.dart';
import '../models/excerpt.dart';
import '../services/excerpt_service.dart';

class ExcerptController with ChangeNotifier {
  final ExcerptService _excerptService = ExcerptService();
  List<Excerpt> _excerpts = [];
  bool isLoading = false;

  List<Excerpt> get excerpts => _excerpts;

  Future<void> fetchExcerpts(String chapterId) async {
    isLoading = true;
    notifyListeners();

    try {
      _excerpts = await _excerptService.getExcerptsByChapter(chapterId);
    } catch (e) {
      print('Erreur : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExcerpt(Excerpt excerpt) async {
    try {
      await _excerptService.addExcerpt(excerpt);
      _excerpts.add(excerpt);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'extrait : $e');
    }
  }

  List<Excerpt> getExcerptsByChapter(String chapterId) {
    return excerpts.where((ex) => ex.chapterId == chapterId).toList();
  }
}
