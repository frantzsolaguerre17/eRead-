import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';
import 'locale_database_service.dart';

class VocabularyService {
  final SupabaseClient _client = Supabase.instance.client;
  final LocalDBService _localDB = LocalDBService();

  /// ➕ Ajouter un mot (offline-first)
  Future<void> addVocabulary(Vocabulary vocab) async {
    try {
      // 1️⃣ Sauvegarder localement
      await _localDB.insertVocabulary(vocab);

      // 2️⃣ Vérifier la connexion Internet
      final hasConnection = await _hasInternetConnection();
      if (hasConnection) {
        await _client.from('vocabulary').insert(vocab.toJson());
        await _localDB.updateVocabularySyncStatus(vocab.id, true);
        vocab.isSynced = true;
        print("✅ Mot synchronisé avec Supabase");
      } else {
        vocab.isSynced = false;
        print("📴 Hors ligne : Mot enregistré localement");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du mot : $e");
    }
  }

  /// 🔄 Récupérer tous les vocabulaires d’un livre
  Future<List<Vocabulary>> fetchVocabularyByBook(String bookId) async {
    try {
      final hasConnection = await _hasInternetConnection();
      if (hasConnection) {
        // 🌐 Charger depuis Supabase
        final response = await _client
            .from('vocabulary')
            .select()
            .eq('book_id', bookId)
            .order('created_at', ascending: false);

        // Supabase retourne une List<dynamic>
        final List<Vocabulary> vocabularies = (response as List)
            .map((e) => Vocabulary.fromJson(e as Map<String, dynamic>))
            .toList();

        // 💾 Mettre à jour la base locale
        for (var vocab in vocabularies) {
          await _localDB.insertOrUpdateVocabulary(vocab);
        }

        print("🌐 Vocabulaires chargés depuis Supabase");
        return vocabularies;
      } else {
        // 📴 Mode hors ligne
        print("📴 Mode hors ligne : chargement local");
        return await _localDB.getVocabularyByBook(bookId);
      }
    } catch (e) {
      throw Exception("Erreur lors du chargement des mots : $e");
    }
  }

  /// 🔁 Synchroniser les mots non envoyés vers Supabase
  Future<void> syncOfflineVocabulary() async {
    try {
      final unsynced = await _localDB.getUnsyncedVocabulary();
      if (unsynced.isEmpty) {
        print("✅ Aucun mot à synchroniser");
        return;
      }

      final hasConnection = await _hasInternetConnection();
      if (!hasConnection) {
        print("📴 Pas de connexion, synchronisation reportée");
        return;
      }

      for (var vocab in unsynced) {
        await _client.from('vocabulary').insert(vocab.toJson());
        await _localDB.updateVocabularySyncStatus(vocab.id, true);
        print("🔄 Mot synchronisé : ${vocab.word}");
      }

      print("🔄 Synchronisation terminée !");
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
