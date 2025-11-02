import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';
import 'locale_database_service.dart';

class ChapterService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalDBService _localDB = LocalDBService();

  /// 🔹 Ajouter un chapitre (hors ligne + en ligne)
  Future<void> addChapter(Chapter chapter) async {
    try {
      // 👉 Enregistrer d’abord en local (toujours)
      await _localDB.insertChapter(chapter);

      // 👉 Si la connexion Internet est disponible, on tente de synchroniser
      final hasConnection = await _hasInternetConnection();
      if (hasConnection) {
        await _supabase.from('chapter').insert(chapter.toJson());
        print("✅ Chapitre synchronisé avec Supabase");
      } else {
        print("📴 Hors ligne : Chapitre enregistré localement");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du chapitre : $e");
    }
  }

  /// 🔹 Récupérer les chapitres d’un livre
  Future<List<Chapter>> getChaptersByBook(String bookId) async {
    try {
      // 1️⃣ Vérifie si Internet est disponible
      final hasConnection = await _hasInternetConnection();

      if (hasConnection) {
        // 2️⃣ Charger depuis Supabase
        final response = await _supabase
            .from('chapter')
            .select('id, book_id, title, created_at')
            .eq('book_id', bookId)
            .order('created_at', ascending: true);

        final chapters =
        (response as List).map((json) => Chapter.fromJson(json)).toList();

        // 3️⃣ Sauvegarde localement pour accès hors ligne
        for (var chapter in chapters) {
          await _localDB.insertChapter(chapter);
        }

        print("🌐 Chapitres chargés depuis Supabase");
        return chapters;
      } else {
        // 4️⃣ Si hors ligne, on récupère les chapitres depuis SQLite
        print("📴 Mode hors ligne : chargement des chapitres locaux");
        return await _localDB.getChaptersByBook(bookId);
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération des chapitres : $e");
    }
  }

  /// 🔹 Synchronisation automatique (hors ligne → Supabase)
  Future<void> syncOfflineChapters() async {
    try {
      final unsynced = await _localDB.getUnsyncedChapters();

      if (unsynced.isEmpty) {
        print("✅ Aucun chapitre à synchroniser");
        return;
      }

      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        print("📴 Pas de connexion, synchronisation reportée");
        return;
      }

      for (var chapter in unsynced) {
        await _supabase.from('chapter').insert(chapter.toJson());
        await _localDB.updateChapterSyncStatus(chapter.id, true);
      }

      print("🔄 Synchronisation des chapitres terminée !");
    } catch (e) {
      throw Exception("Erreur lors de la synchronisation : $e");
    }
  }

  /// 🔹 Vérifie la connexion Internet
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
