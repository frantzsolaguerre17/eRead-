import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/ChapterController.dart';
import '../controllers/ExcerptController.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/excerpt.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChapterController>().fetchChapters(widget.book.id);
    });
  }

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
            onPressed: () {
              Navigator.pop(context); // Fermeture sans dispose
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final chapter = Chapter(
                id: uuid.v4(),
                bookId: widget.book.id,
                title: title,
                createdAt: DateTime.now(),
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
                decoration: const InputDecoration(labelText: "Texte de l'extrait"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: "Commentaire (optionnel)"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermeture sans dispose
            },
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = contentController.text.trim();
              if (content.isEmpty) return;

              final excerpt = Excerpt(
                id: uuid.v4(),
                chapterId: chapterId,
                content: content,
                comment: commentController.text.trim(),
                createdAt: DateTime.now(),
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
            subtitle: (ex.comment?.isNotEmpty ?? false) ? Text("💬 ${ex.comment}") : null,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterController = context.watch<ChapterController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Colors.blueGrey[700],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChapterDialog,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
      body: chapterController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => chapterController.fetchChapters(widget.book.id),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Auteur : ${widget.book.author}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Chapitres 📚", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (chapterController.chapters.isEmpty)
              const Text("Aucun chapitre ajouté."),
            ...chapterController.chapters.map((chapter) {
              return ExpansionTile(
                title: Text(chapter.title, style: const TextStyle(fontSize: 18)),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueGrey),
                  onPressed: () => _addExcerptDialog(chapter.id),
                ),
                children: [_buildExcerpts(chapter.id)],
              );
            }),
          ],
        ),
      ),
    );
  }
}
