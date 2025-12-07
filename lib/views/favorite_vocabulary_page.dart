import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';

class FavoriteVocabularyScreen extends StatefulWidget {
  const FavoriteVocabularyScreen({super.key});

  @override
  State<FavoriteVocabularyScreen> createState() =>
      _FavoriteVocabularyScreenState();
}

class _FavoriteVocabularyScreenState extends State<FavoriteVocabularyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<VocabularyController>().fetchFavoriteVocabulary();
    });
  }

  Future<void> _refreshFavorites() async {
    await context.read<VocabularyController>().fetchFavoriteVocabulary();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VocabularyController>();
    final favoriteList = controller.vocabularies
        .where((vocab) => vocab.isFavorite)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Mots favoris"),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: favoriteList.isEmpty
            ? const Center(
          child: Text("Aucun mot favori pour le moment.",
              style: TextStyle(fontSize: 16)),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            final vocab = favoriteList[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vocab.word,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            vocab.isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () async {
                            final updated = Vocabulary(
                              id: vocab.id,
                              word: vocab.word,
                              definition: vocab.definition,
                              example: vocab.example ?? '',
                              createdAt: vocab.createdAt,
                              bookId: vocab.bookId,
                              userId: vocab.userId,
                              isSynced: true,
                              isFavorite: !vocab.isFavorite,
                            );

                            await context
                                .read<VocabularyController>()
                                .updateVocabulary(updated);

                            await context
                                .read<VocabularyController>()
                                .fetchFavoriteVocabulary();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Définition : ${vocab.definition}",
                        style: const TextStyle(fontSize: 16)),
                    if (vocab.example != null &&
                        vocab.example!.trim().isNotEmpty)
                      ...[
                        const SizedBox(height: 6),
                        Text(
                          "Exemple : ${vocab.example}",
                          style: const TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                        ),
                      ],
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
