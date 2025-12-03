import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyController extends ChangeNotifier {
  final VocabularyService service = VocabularyService();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Vocabulary> _vocabularies = [];
  bool isLoading = false;

  List<Vocabulary> get vocabularies => _vocabularies;

  /// Récupérer les vocabulaires depuis Supabase
  Future<void> fetchVocabulary(String bookId) async {
    try {
      isLoading = true;
      notifyListeners();

      final fetched = await service.fetchVocabulary(bookId);
      _vocabularies = fetched;
    } catch (e) {
      debugPrint('Erreur fetchVocabulary : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /// Ajouter un vocabulaire dans Supabase et mettre à jour la liste locale
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


  Future<Vocabulary> updateVocabulary(Vocabulary vocab) async {
    final data = await supabase
        .from('vocabulary')
        .update({
      'word': vocab.word,
      'definition': vocab.definition,
      'example': vocab.example,
    })
        .eq('id', vocab.id)
        .select()
        .single();

    return Vocabulary.fromJson(data);
  }


  Future<void> deleteVocabulary(String vocabId) async {
    await supabase
        .from('vocabulary')
        .delete()
        .eq('id', vocabId);
  }



  Future<int> getLearnedWordsCount() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final res = await supabase
        .from('vocabulary')
        .select('*')
        .eq('user_id', userId)
        .count();               // <-- utiliser .count() ici

    return res.count ?? 0;
  }


}
