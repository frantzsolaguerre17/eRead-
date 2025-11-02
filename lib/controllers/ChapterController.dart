import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/locale_database_service.dart';

class ChapterController with ChangeNotifier {
  final ChapterService _chapterService = ChapterService();
  final LocalDBService _localDB = LocalDBService();

  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  bool isLoading = false;

  /// 🔹 Récupérer tous les chapitres d’un livre (local d’abord, puis Supabase)
  Future<void> fetchChapters(String bookId) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🔸 1. Charger depuis la base locale
      _chapters = await _localDB.getChaptersByBook(bookId);

      // 🔸 2. Tenter de récupérer les données en ligne
      final remoteChapters = await _chapterService.getChaptersByBook(bookId);

      if (remoteChapters.isNotEmpty) {
        _chapters = remoteChapters;
        // 🔁 Mettre à jour la base locale
        await _localDB.clearChaptersByBook(bookId);
        for (var c in remoteChapters) {
          await _localDB.insertChapter(c);
        }
      }
    } catch (e) {
      print('⚠️ Erreur lors du chargement des chapitres : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Ajouter un chapitre (offline-first)
  Future<void> addChapter(Chapter chapter) async {
    try {
      // 🔸 Enregistrer dans la base locale
      await _localDB.insertChapter(chapter);

      // 🔸 Essayer d’envoyer à Supabase (si connecté)
      try {
        await _chapterService.addChapter(chapter);
        chapter.isSynced = true;
        await _localDB.updateChapterSyncStatus(chapter.id, true);
      } catch (e) {
        chapter.isSynced = false;
        print('📴 Chapitre ajouté localement (offline mode)');
      }

      _chapters.add(chapter);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout du chapitre : $e');
    }
  }

  /// 🔄 Synchroniser les chapitres locaux non synchronisés avec Supabase
  Future<void> syncLocalChapters() async {
    try {
      final unsyncedChapters = await _localDB.getUnsyncedChapters();

      for (var chapter in unsyncedChapters) {
        try {
          await _chapterService.addChapter(chapter);
          await _localDB.updateChapterSyncStatus(chapter.id, true);
          print('✅ Chapitre synchronisé : ${chapter.title}');
        } catch (e) {
          print('⚠️ Échec de la synchronisation du chapitre ${chapter.title} : $e');
        }
      }
    } catch (e) {
      print('Erreur lors de la synchronisation des chapitres : $e');
    }
  }
}
