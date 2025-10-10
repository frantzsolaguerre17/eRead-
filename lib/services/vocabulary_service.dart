import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔹 Add Vocabulary
  Future<void> addVocabulary(Vocabulary vocabulary) async {
    try {
      await _supabase.from('vocabulary').insert({
        'id': vocabulary.id,
        'word': vocabulary.word,
        'definition': vocabulary.definition,
        'example': vocabulary.example,
        'book_id': vocabulary.bookId,
        'created_at': vocabulary.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du mot : $e');
    }
  }

  /// 🔹 Get Vocabularies by Book ID
  Future<List<Vocabulary>> getVocabulariesByBook(String bookId) async {
    try {
      final response = await _supabase
          .from('vocabulary')
          .select('id, word, definition, example, created_at, book_id')
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      final List<Vocabulary> vocabularies =
      (response as List).map((json) => Vocabulary.fromJson(json)).toList();

      return vocabularies;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des mots : $e');
    }
  }
}
