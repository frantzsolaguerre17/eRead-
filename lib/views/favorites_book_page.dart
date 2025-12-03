import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'pdf_viewer_page.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key});

  @override
  State<FavoriteBooksPage> createState() => _FavoriteBooksPageState();
}

class _FavoriteBooksPageState extends State<FavoriteBooksPage> {
  List<Book> favoriteBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }


  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    // 1️⃣ Récupérer les IDs des livres favoris
    final favoriteIds = await BookService().getUserFavorites(); // List<String>

    // 2️⃣ Récupérer les livres complets correspondant à ces IDs
    favoriteBooks = await BookService().fetchFavoriteBooks();

    setState(() => isLoading = false);
  }

  Future<void> _removeFavorite(Book book) async {
    await BookService().removeFavorite(book.id);

    setState(() {
      favoriteBooks.removeWhere((b) => b.id == book.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const FavoriteShimmer()
          : favoriteBooks.isEmpty
          ? const Center(
        child: Text(
          "Aucun favori pour le moment.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favoriteBooks.length,
        itemBuilder: (context, index) {
          final book = favoriteBooks[index];
          return _FavoriteBookCard(
            book: book,
            onRemove: () => _removeFavorite(book),
          );
        },
      ),
    );
  }
}

// =================== Shimmer Loader ===================
class FavoriteShimmer extends StatelessWidget {
  const FavoriteShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.deepPurple.shade50,
            highlightColor: Colors.deepPurple.shade100,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================== Carte moderne pour chaque livre favori ===================
class _FavoriteBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onRemove;

  const _FavoriteBookCard({
    required this.book,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (book.pdf.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerPage(book: book)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF non disponible pour ce livre")),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        shadowColor: Colors.grey.shade300,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: book.cover.isNotEmpty
                    ? Image.network(
                  book.cover,
                  width: 120,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/default_image.png",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Container(
                  width: 120,
                  height: 140,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.book, size: 50),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Auteur : ${book.author}",
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 2),
                      Text("Pages : ${book.number_of_pages}",
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 2),
                      Text("Catégorie : ${book.category}",
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.favorite, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
