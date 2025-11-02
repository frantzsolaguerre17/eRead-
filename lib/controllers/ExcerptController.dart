import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/excerpt.dart';
import '../services/excerpt_service.dart';
import '../services/locale_database_service.dart';

class ExcerptController with ChangeNotifier {
  final ExcerptService _excerptService = ExcerptService();
  final LocalDBService _localDB = LocalDBService();
  final Uuid uuid = const Uuid();

  List<Excerpt> _excerpts = [];
  List<Excerpt> get excerpts => _excerpts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 🔹 Récupérer les extraits d’un chapitre (offline-first)
  Future<void> fetchExcerpts(String chapterId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1️⃣ Charger depuis la base locale (SQLite)
      _excerpts = await _localDB.getExcerptsByChapter(chapterId);

      // 2️⃣ Charger depuis Supabase
      final remoteExcerpts =
      await _excerptService.getExcerptsByChapter(chapterId);

      if (remoteExcerpts.isNotEmpty) {
        _excerpts = remoteExcerpts;

        // 🧹 Supprimer les anciens extraits locaux
        await _localDB.clearExcerptsByChapter(chapterId);

        // 💾 Réinsérer les nouveaux extraits
        for (var e in remoteExcerpts) {
          await _localDB.insertExcerpt(e);
        }

        debugPrint("✅ Extraits mis à jour depuis Supabase");
      } else {
        debugPrint("📴 Aucun extrait trouvé sur Supabase");
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors du chargement des extraits : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Ajouter un extrait (Offline-First)
  Future<void> addExcerpt(Excerpt excerpt) async {
    try {
      _excerpts.add(excerpt);
      notifyListeners();

      // Optionnel : envoi vers Supabase
      // await Supabase.instance.client.from('excerpt').insert(excerpt.toJson());
    } catch (e) {
      debugPrint('⚠️ Erreur lors de l’ajout d’un extrait : $e');
    }
  }


  /// 🔄 Synchroniser les extraits hors ligne vers Supabase
  Future<void> syncLocalExcerpts() async {
    try {
      final unsyncedExcerpts = await _localDB.getUnsyncedExcerpts();

      if (unsyncedExcerpts.isEmpty) {
        debugPrint("✅ Aucun extrait à synchroniser");
        return;
      }

      for (var ex in unsyncedExcerpts) {
        try {
          await _excerptService.addExcerpt(ex);
          await _localDB.updateExcerptSyncStatus(ex.id, true);
          debugPrint("🔄 Extrait synchronisé : ${ex.content}");
        } catch (e) {
          debugPrint("⚠️ Échec de synchronisation pour ${ex.content} : $e");
        }
      }

      debugPrint("✅ Synchronisation complète des extraits hors ligne !");
    } catch (e) {
      debugPrint("⚠️ Erreur lors de la synchronisation locale : $e");
    }
  }

  /// 🔍 Filtrer les extraits par chapitre
  List<Excerpt> getExcerptsByChapter(String chapterId) {
    return _excerpts.where((ex) => ex.chapterId == chapterId).toList();
  }
}
