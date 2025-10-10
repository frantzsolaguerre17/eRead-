import 'package:flutter/material.dart';
import '../models/book.dart';
import '../controllers/book_controller.dart';
import 'package:uuid/uuid.dart';

import 'book_details_page.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({Key? key}) : super(key: key);

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {

  final BookController _controller = BookController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadBooks();
  }


  Future<void> _loadBooks() async {
    await _controller.fetchBooks();
    setState(() {});
  }


  // 🔹 Méthode pour afficher le formulaire d’ajout
  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un livre'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Auteur'),
              ),
              TextField(
                controller: _pagesController,
                decoration: const InputDecoration(labelText: 'Nombre de pages'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _addBook();
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }



  // 🔹 Ajout d’un livre
  Future<void> _addBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) return;

    final newBook = Book(
      const Uuid().v4(),
      _titleController.text.trim(),
      _authorController.text.trim(),
      _pagesController.text.trim(),
      DateTime.now(),
    );

    await _controller.addBook(newBook);

    // Vider les champs
    _titleController.clear();
    _authorController.clear();
    _pagesController.clear();

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livre ajouté avec succès ✅')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final books = _controller.books;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Livres'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBookDialog,
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? const Center(
        child: Text(
          'Aucun livre trouvé 📖',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return InkWell(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context)=> BookDetailScreen(book: book),
                  )
              );
            },

          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.book_outlined, color: Colors.blueAccent, size: 32),
              title: Text(
                book.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                book.author,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              trailing: Text(
                '${book.numberOfPages ?? '-'} pages',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

}
