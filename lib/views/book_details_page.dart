import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import indispensable
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:memo_livre/views/vocabulary_list_screen.dart';
import '../controllers/ChapterController.dart';
import '../controllers/ExcerptController.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/excerpt.dart';
import '../models/vocabulary.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    final chapterController = context.read<ChapterController>();
    final excerptController = context.read<ExcerptController>();
    final vocabController = context.read<VocabularyController>();

    // Fetch offline first
    await chapterController.fetchChapters(widget.book.id);
    await vocabController.fetchVocabulary(widget.book.id);

    // Sync local unsynced data
    await chapterController.syncLocalChapters();
    await excerptController.syncLocalExcerpts();
    await vocabController.syncVocabulary();

    // Refresh online
    await chapterController.fetchChapters(widget.book.id);
    await vocabController.fetchVocabulary(widget.book.id);
  }

  // ==================== DIALOGUES ====================

  void _addChapterDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un chapitre 📖"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Titre du chapitre"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final supabase = Supabase.instance.client;
              final userId = supabase.auth.currentUser?.id;

              final chapter = Chapter(
                id: uuid.v4(),
                bookId: widget.book.id,
                title: title,
                createdAt: DateTime.now(),
                isSynced: false,
                userId: userId ?? '',
              );

              await context.read<ChapterController>().addChapter(chapter);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _addExcerptDialog(String chapterId) {
    final contentController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un extrait ✍️"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: contentController,
                decoration:
                const InputDecoration(labelText: "Texte de l'extrait"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                    labelText: "Commentaire (optionnel)"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final content = contentController.text.trim();
              if (content.isEmpty) return;

              final excerpt = Excerpt(
                id: uuid.v4(),
                chapterId: chapterId,
                content: content,
                createdAt: DateTime.now(),
                comment: commentController.text.trim(),
              );

              await context.read<ExcerptController>().addExcerpt(excerpt);

              if (mounted) {
                await context.read<ExcerptController>().fetchExcerpts(chapterId);
                Navigator.pop(context);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _addVocabularyDialog() {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    final exampleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter un mot appris 🧠"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: "Mot"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: definitionController,
                decoration: const InputDecoration(labelText: "Définition"),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: exampleController,
                decoration:
                const InputDecoration(labelText: "Exemple (optionnel)"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final word = wordController.text.trim();
              final def = definitionController.text.trim();
              if (word.isEmpty || def.isEmpty) return;
              final supabase = Supabase.instance.client;
              final userId = supabase.auth.currentUser?.id;

              final vocab = Vocabulary(
                id: uuid.v4(),
                bookId: widget.book.id,
                word: word,
                definition: def,
                example: exampleController.text.trim(),
                createdAt: DateTime.now(),
                isSynced: false,
                userId: userId ?? ''
              );

              await context.read<VocabularyController>().addVocabulary(vocab);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  // ==================== AFFICHAGE ====================

  Widget _buildExcerpts(String chapterId) {
    final excerptController = context.watch<ExcerptController>();
    final excerpts = excerptController.getExcerptsByChapter(chapterId);

    if (excerptController.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (excerpts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Aucun extrait ajouté."),
      );
    }

    return Column(
      children: excerpts.map((ex) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          elevation: 2,
          child: ListTile(
            title: Text(ex.content),
            subtitle: (ex.comment?.isNotEmpty ?? false)
                ? Text("💬 ${ex.comment}")
                : null,
            trailing:
            ex.isSynced ? null : const Icon(Icons.cloud_off, color: Colors.red),
          ),
        );
      }).toList(),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final chapterController = context.watch<ChapterController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Colors.tealAccent[700],
        centerTitle: true,
      ),

      // ✅ Boutons flottants scrollables horizontalement
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'addChapter',
                backgroundColor: Colors.tealAccent,
                icon: const Icon(Icons.menu_book),
                label: const Text("Chapitre"),
                onPressed: _addChapterDialog,
              ),
              const SizedBox(width: 10),
              FloatingActionButton.extended(
                heroTag: 'addWord',
                backgroundColor: Colors.teal,
                icon: const Icon(Icons.lightbulb),
                label: const Text("Mot"),
                onPressed: _addVocabularyDialog,
              ),
              const SizedBox(width: 10),
              FloatingActionButton.extended(
                heroTag: 'listWords',
                backgroundColor: Colors.indigo,
                icon: const Icon(Icons.list),
                label: const Text("Mots appris"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VocabularyListScreen(bookId: widget.book.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: chapterController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Auteur : ${widget.book.author}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Chapitres 📚",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (chapterController.chapters.isEmpty)
              const Text("Aucun chapitre ajouté."),
            ...chapterController.chapters.map((chapter) {
              return ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(chapter.title,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    if (!chapter.isSynced)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.cloud_off, color: Colors.red),
                      )
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Colors.tealAccent),
                  onPressed: () => _addExcerptDialog(chapter.id),
                ),
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    context
                        .read<ExcerptController>()
                        .fetchExcerpts(chapter.id);
                  }
                },
                children: [_buildExcerpts(chapter.id)],
              );
            }),
          ],
        ),
      ),
    );
  }
}
