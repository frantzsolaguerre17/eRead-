import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'AddBook_page.dart';
import 'pdf_viewer_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Book> books = [];
  String displayName = 'Utilisateur';
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadBooks();
    _loadDisplayName();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    final data = await BookService().getBooks();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      books = data;
      isLoading = false;
    });
  }

  void _loadDisplayName() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        displayName = user.userMetadata?['full_name'] ?? 'Utilisateur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Mes Livres 📚"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: isLoading
          ? const BookListShimmer()
          : books.isEmpty
          ? const Center(
        child: Text(
          "Aucun livre ajouté pour le moment.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _ModernBookCard(book: book, displayName: displayName);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          );
          if (result == true) {
            _loadBooks();
          }
        },
      ),
    );
  }
}

// =================== Shimmer Loader (effet Facebook) ===================
class BookListShimmer extends StatelessWidget {
  const BookListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6, // nombre d’éléments simulés
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 16,
                              width: 150,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 180,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================== Carte moderne pour chaque livre ===================
class _ModernBookCard extends StatelessWidget {
  final Book book;
  final String displayName;

  const _ModernBookCard({required this.book, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (book.pdf.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(book: book),
            ),
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
              colors: [Colors.teal.shade50, Colors.teal.shade100],
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
                    return Container(
                      width: 120,
                      height: 140,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, size: 50),
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
                      const SizedBox(height: 4),
                      Text("Ajouté par : $displayName",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
