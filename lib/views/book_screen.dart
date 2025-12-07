import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../models/userBookProgress.dart';
import '../services/book_service.dart';
import 'AddBook_page.dart';
import 'pdf_viewer_page.dart';
import 'favorites_book_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  List<String> categories = ['Toutes'];
  String selectedCategory = 'Toutes';
  String displayName = 'Utilisateur';
  bool isLoading = true;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final supabase = Supabase.instance.client;

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
    final data = await BookService().fetchBooks();
    await Future.delayed(const Duration(milliseconds: 500));
    final allCategories = data.map((b) => b.category).where((c) => c.isNotEmpty).toSet().toList();

    setState(() {
      books = data;
      filteredBooks = books;
      categories = ['Toutes', ...allCategories];
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

  void _filterBooks(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void _filterByCategory(String category) {
    selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Book> results = books;

    if (selectedCategory != 'Toutes') {
      results = results.where((b) => b.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      results = results
          .where((b) => b.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    setState(() => filteredBooks = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: _filterBooks,
                decoration: InputDecoration(
                  hintText: "Rechercher un livre...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        _searchController.clear();
                      });
                      _filterBooks('');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.deepPurple.shade600,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoriteBooksPage()),
                );
              },
            )
          ],
        ),
      ),
      body: isLoading
          ? const BookListShimmer()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                dropdownColor: Colors.deepPurple.shade50,
                items: categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _filterByCategory(value);
                },
              ),
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? const Center(
              child: Text("Aucun livre trouvé.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return ModernBookCard(book: book);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
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

// =================== Shimmer Loader ===================
class BookListShimmer extends StatelessWidget {
  const BookListShimmer({super.key});
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: 160,
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

// ================= ModernBookCard avec badge sous le bouton favoris =================
class ModernBookCard extends StatefulWidget {
  final Book book;
  const ModernBookCard({required this.book, super.key});

  @override
  State<ModernBookCard> createState() => _ModernBookCardState();
}

class _ModernBookCardState extends State<ModernBookCard> {
  bool isFavorite = false;
  double progress = 0;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadProgress();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorites = await BookService().getUserFavorites();
    setState(() {
      isFavorite = favorites.contains(widget.book.id);
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await BookService().removeFavorite(widget.book.id);
    } else {
      await BookService().addFavorite(widget.book.id);
    }
    setState(() => isFavorite = !isFavorite);
  }

  Future<void> _loadProgress() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('user_book_progress')
        .select()
        .eq('user_id', user.id)
        .eq('book_id', widget.book.id)
        .maybeSingle();

    if (response != null) {
      final progressData = UserBookProgress.fromMap(response);
      setState(() {
        progress = (progressData.readingProgress / 100).clamp(0.0, 1.0);
      });
    }
  }

  Color _getBadgeColor() {
    if (progress >= 0.8) return Colors.green;
    if (progress > 0) return Colors.blue;
    return Colors.grey.shade400;
  }

  String _getBadgeText() {
    return progress >= 0.8 ? "LU" : "${(progress * 100).round()}%";
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 160;
    return GestureDetector(
      onTap: () {
        if (widget.book.pdf.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PdfViewerPage(book: widget.book)),
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
        child: SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                child: widget.book.cover.isNotEmpty
                    ? Image.network(
                  widget.book.cover,
                  width: 120,
                  height: cardHeight,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 120,
                  height: cardHeight,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.book, size: 50),
                ),
              ),
              // Texte + badges + favoris
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text("Auteur : ${widget.book.author}",
                                style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 2),
                            Text("Pages : ${widget.book.number_of_pages}",
                                style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 2),
                            Text("Catégorie : ${widget.book.category}",
                                style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text("Ajouté par : ${widget.book.userName}",
                                style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12)),
                          /*  const SizedBox(height: 32), // espace pour badge
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              color: progress >= 0.8
                                  ? Colors.green
                                  : Colors.deepPurple,
                            ),*/
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 37,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red),
                              onPressed: _toggleFavorite,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getBadgeText(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
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
