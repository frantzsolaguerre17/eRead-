import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/excerpt.dart';

class ExcerptService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ajouter un extrait
  Future<void> addExcerpt(Excerpt excerpt) async {
    try {
      await _supabase.from('excerpt').insert(excerpt.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'extrait : $e');
    }
  }

  /// Récupérer les extraits d’un chapitre
  Future<List<Excerpt>> getExcerptsByChapter(String chapterId) async {
    try {
      final response = await _supabase
          .from('excerpt')
          .select('id, chapter_id, content, comment, created_at')
          .eq('chapter_id', chapterId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Excerpt.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des extraits : $e');
    }
  }
}
