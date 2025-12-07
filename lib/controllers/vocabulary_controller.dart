import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyController extends ChangeNotifier {
  final VocabularyService service = VocabularyService();

  List<Vocabulary> _vocabularies = [];
  bool isLoading = false;

  List<Vocabulary> get vocabularies => _vocabularies;
  final SupabaseClient supabase = Supabase.instance.client;

  /// 🔄 Récupérer les vocabulaires pour un livre
  Future<void> fetchVocabulary(String bookId) async {
    try {
      isLoading = true;
      notifyListeners();

      _vocabularies = await service.fetchVocabulary(bookId);
    } catch (e) {
      debugPrint('Erreur fetchVocabulary : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Ajouter
  Future<void> addVocabulary(Vocabulary vocab) async {
    try {
      final inserted = await service.addVocabulary(vocab);
      _vocabularies.add(inserted);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur addVocabulary : $e');
      throw Exception('Erreur insertion vocabulary');
    }
  }

  /// ✏️ Modifier
  Future<void> updateVocabulary(Vocabulary vocab) async {
    try {
      await service.updateVocabulary(vocab);

      // Mise à jour locale
      final index = _vocabularies.indexWhere((v) => v.id == vocab.id);
      if (index != -1) {
        _vocabularies[index] = vocab;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur updateVocabulary : $e');
    }
  }

  /// 🗑️ Supprimer
  Future<void> deleteVocabulary(String vocabId) async {
    try {
      await service.deleteVocabulary(vocabId);
      _vocabularies.removeWhere((v) => v.id == vocabId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteVocabulary : $e');
    }
  }

  /// ⭐ Toggle Favoris
  Future<void> toggleFavorite(Vocabulary vocab) async {
    try {
      final newValue = !vocab.isFavorite;
      vocab.isFavorite = newValue;
      notifyListeners();

      await service.toggleFavorite(vocab.id, newValue);
    } catch (e) {
      debugPrint('Erreur toggleFavorite : $e');
    }
  }

  /// 🔢 Nombre de mots appris
  Future<int> getLearnedWordsCount() async {
    return await service.getLearnedWordsCount();
  }



  Future<void> fetchFavoriteVocabulary() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;
      if (user == null) {
        _vocabularies = [];
        return;
      }

      final response = await supabase
          .from('vocabulary')
          .select()
          .eq('user_id', user.id)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      _vocabularies = (response as List)
          .map((json) => Vocabulary.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur fetchFavoriteVocabulary: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}
