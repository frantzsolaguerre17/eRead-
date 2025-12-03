import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'book_details_page.dart';

class PdfViewerPage extends StatefulWidget {
  final Book book;

  const PdfViewerPage({required this.book, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late Future<File?> _pdfFuture;
  final PdfViewerController _pdfController = PdfViewerController();

  int _lastPage = 1;
  int? _markedPage;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
    _pdfFuture = _downloadAndCachePdf();
  }

  /// Charger la dernière page et la page marquée
  Future<void> _loadSavedPages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastPage = prefs.getInt('lastPage_${widget.book.id}') ?? 1;
      _markedPage = prefs.getInt('markedPage_${widget.book.id}');
    });
  }

  /// Sauvegarder la page actuelle
  Future<void> _saveLastPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage_${widget.book.id}', pageNumber);
  }

  /// Marquer une page
  Future<void> _saveMarkedPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('markedPage_${widget.book.id}', pageNumber);
    setState(() => _markedPage = pageNumber);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepPurple.shade600,
        content: Text('Page $pageNumber marquée ✅'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Supprimer la page marquée
  Future<void> _removeMarkedPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('markedPage_${widget.book.id}');
    setState(() => _markedPage = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent.shade400,
        content: const Text('Marque-page supprimé ❌'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Télécharger et mettre en cache le PDF
  Future<File?> _downloadAndCachePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/${widget.book.title.replaceAll(' ', '_')}.pdf';
      final file = File(filePath);

      if (file.existsSync()) return file;

      final response = await http.get(Uri.parse(widget.book.pdf));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw Exception('Erreur lors du téléchargement du PDF');
      }
    } catch (e) {
      debugPrint('Erreur PDF: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.bookmark, color: Colors.white),
              onSelected: (value) {
                if (value == 'mark' && _pdfController.pageNumber != null) {
                  _saveMarkedPage(_pdfController.pageNumber!);
                } else if (value == 'remove') {
                  _removeMarkedPage();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark',
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_add, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text("Marquer cette page"),
                    ],
                  ),
                ),
                if (_markedPage != null)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Supprimer le marque-page"),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Lecture du livre 📖",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                widget.book.title,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: FutureBuilder<File?>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            // ✅ Optimisation pour PDF volumineux
            return SfPdfViewer.file(
              snapshot.data!,
              controller: _pdfController,
              enableTextSelection: true,
              pageLayoutMode: PdfPageLayoutMode.single, // ← scroll fluide
              onDocumentLoaded: (details) {
                _pdfController.jumpToPage(_markedPage ?? _lastPage);
              },
              onPageChanged: (details) {
                _saveLastPage(details.newPageNumber);
              },
            );
          } else {
            return const Center(child: Text("Impossible de charger le PDF"));
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_markedPage != null)
            FloatingActionButton.extended(
              heroTag: 'gotoBookmark',
              backgroundColor: Colors.amber.shade700,
              icon: const Icon(Icons.bookmark_added),
              label: Text("Aller à la page $_markedPage"),
              onPressed: () {
                _pdfController.jumpToPage(_markedPage!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Aller à la page $_markedPage 📖'),
                    backgroundColor: Colors.amber.shade800,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'addNote',
            backgroundColor: Colors.deepPurple.shade700,
            icon: const Icon(Icons.note_add),
            label: const Text("Prendre des notes"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: widget.book),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
