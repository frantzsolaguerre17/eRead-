import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/excerpt.dart';
import 'locale_database_service.dart';

class ExcerptService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final LocalDBService _localDB = LocalDBService();

  /// ➕ Ajouter un extrait (offline-first)
  Future<void> addExcerpt(Excerpt excerpt) async {
    try {
      // 💾 Enregistrer localement d'abord
      await _localDB.insertExcerpt(excerpt);

      // 🌐 Vérifie la connexion Internet
      final hasConnection = await _hasInternetConnection();

      if (hasConnection) {
        await _supabase.from('excerpt').insert(excerpt.toJson());
        await _localDB.updateExcerptSyncStatus(excerpt.id, true);
        print("✅ Extrait synchronisé avec Supabase");
      } else {
        print("📴 Hors ligne : extrait enregistré localement");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'ajout de l'extrait : $e");
    }
  }

  /// 🔄 Récupérer les extraits d’un chapitre
  Future<List<Excerpt>> getExcerptsByChapter(String chapterId) async {
    try {
      final hasConnection = await _hasInternetConnection();

      if (hasConnection) {
        // 🌐 Charger depuis Supabase
        final data = await _supabase
            .from('excerpt')
            .select('id, chapter_id, content, comment, created_at')
            .eq('chapter_id', chapterId)
            .order('created_at', ascending: true);

        if (data == null || (data as List).isEmpty) {
          print("⚠️ Aucun extrait trouvé pour ce chapitre");
          return [];
        }

        // 🔁 Convertir en liste d'objets Excerpt
        final excerpts = (data as List)
            .map((e) => Excerpt.fromJson(e as Map<String, dynamic>))
            .toList();

        // 💾 Met à jour la base locale
        for (var ex in excerpts) {
          await _localDB.insertOrUpdateExcerpt(ex);
        }

        print("🌐 Extraits chargés depuis Supabase");
        return excerpts;
      } else {
        // 📴 Mode hors ligne
        print("📴 Mode hors ligne : chargement local des extraits");
        return await _localDB.getExcerptsByChapter(chapterId);
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération des extraits : $e");
    }
  }

  /// 🔁 Synchroniser les extraits non envoyés vers Supabase
  Future<void> syncOfflineExcerpts() async {
    try {
      final unsynced = await _localDB.getUnsyncedExcerpts();

      if (unsynced.isEmpty) {
        print("✅ Aucun extrait à synchroniser");
        return;
      }

      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        print("📴 Pas de connexion, synchronisation reportée");
        return;
      }

      for (var ex in unsynced) {
        await _supabase.from('excerpt').insert(ex.toJson());
        await _localDB.updateExcerptSyncStatus(ex.id, true);
        print("🔄 Extrait synchronisé : ${ex.content}");
      }

      print("✅ Synchronisation des extraits terminée !");
    } catch (e) {
      throw Exception("Erreur lors de la synchronisation : $e");
    }
  }

  /// 🌐 Vérifie la connexion Internet
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
