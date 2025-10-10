import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';

class ChapterController with ChangeNotifier {
  final ChapterService _chapterService = ChapterService();
  List<Chapter> _chapters = [];
  bool isLoading = false;

  List<Chapter> get chapters => _chapters;

  // Fonction sécurisée pour notifier seulement si le widget est monté
  void safeNotifyListeners() {
    if (kDebugMode) print("Notifying listeners...");
    try {
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Notification skipped: $e");
    }
  }

  Future<void> fetchChapters(String bookId) async {
    isLoading = true;
    safeNotifyListeners();

    try {
      _chapters = await _chapterService.getChaptersByBook(bookId);
    } catch (e) {
      print('Erreur : $e');
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> addChapter(Chapter chapter) async {
    try {
      await _chapterService.addChapter(chapter);
      _chapters.add(chapter);
      safeNotifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout du chapitre : $e');
    }
  }
}
