import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';

class ChapterService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ajouter un chapitre
  Future<void> addChapter(Chapter chapter) async {
    try {
      await _supabase.from('chapter').insert(chapter.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du chapitre : $e');
    }
  }

  /// Récupérer les chapitres d’un livre
  Future<List<Chapter>> getChaptersByBook(String bookId) async {
    try {
      final response = await _supabase
          .from('chapter')
          .select('id, book_id, title, created_at')
          .eq('book_id', bookId)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Chapter.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des chapitres : $e');
    }
  }
}
