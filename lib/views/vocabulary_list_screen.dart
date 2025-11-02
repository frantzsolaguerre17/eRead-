import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';

class VocabularyListScreen extends StatefulWidget {
  final String bookId;

  const VocabularyListScreen({super.key, required this.bookId});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<VocabularyController>();

      // 1️⃣ Charger d'abord depuis la base locale
      await controller.fetchVocabulary(widget.bookId);

      // 2️⃣ Synchroniser les mots non synchronisés avec Supabase
      await controller.syncVocabulary();

      // 3️⃣ Recharger après synchronisation
      await controller.fetchVocabulary(widget.bookId);
    });
  }

  Future<void> _refreshVocabulary() async {
    final controller = context.read<VocabularyController>();
    await controller.fetchVocabulary(widget.bookId);
    await controller.syncVocabulary();
    await controller.fetchVocabulary(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    final vocabController = context.watch<VocabularyController>();
    final vocabList = vocabController.vocabularies;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mots appris 🧠"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshVocabulary,
            tooltip: 'Rafraîchir et synchroniser',
          ),
        ],
      ),
      body: vocabController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshVocabulary,
        child: vocabList.isEmpty
            ? const Center(
          child: Text(
            "Aucun mot appris pour ce livre.",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: vocabList.length,
          itemBuilder: (context, index) {
            final Vocabulary vocab = vocabList[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          vocab.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!vocab.isSynced)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.cloud_off,
                                color: Colors.red, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Définition : ${vocab.definition}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (vocab.example != null &&
                        vocab.example!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Exemple : ${vocab.example}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "📅 ${vocab.createdAt.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
