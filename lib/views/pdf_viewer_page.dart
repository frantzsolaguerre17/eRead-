import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;

  int _lastPage = 1;
  int? _markedPage;
  int _totalPages = 1;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
    _pdfFuture = _downloadAndCachePdf();
  }

  Future<void> _loadSavedPages() async {
    final prefs = await SharedPreferences.getInstance();
    _lastPage = prefs.getInt('lastPage_${widget.book.id}') ?? 1;
    _markedPage = prefs.getInt('markedPage_${widget.book.id}');
  }

  Future<void> _saveLastPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage_${widget.book.id}', pageNumber);
  }

  Future<void> _saveMarkedPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('markedPage_${widget.book.id}', pageNumber);
    setState(() => _markedPage = pageNumber);
  }

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
      }
    } catch (_) {}
    return null;
  }

  // ✅ Calcul de progression
  Future<void> _updateProgress(int currentPage) async {
    if (_totalPages == 0) return;

    final percent = ((currentPage / _totalPages) * 100).round();
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _progress = currentPage / _totalPages;
    });

    final payload = {
      'user_id': user.id,
      'book_id': widget.book.id,
      'reading_progress': percent,
      'is_read': percent >= 80,
    };

    try {
      await supabase
          .from('user_book_progress')
          .upsert(payload, onConflict: 'user_id,book_id');
    } catch (_) {}
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ APPBAR AVEC BARRE DE PROGRESSION
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        automaticallyImplyLeading: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Lecture du livre 📖",
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.book.title,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // ✅ Barre de progression DANS l’AppBar
            /*ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 4,
                backgroundColor: Colors.white30,
                color: _progress >= 0.8 ? Colors.green : Colors.white,
              ),
            ),*/
            //const SizedBox(height: 2),
            /*Align(
              alignment: Alignment.centerRight,
              child: Text(
                _progress >= 0.8
                    ? "Lu ✅"
                    : "${(_progress * 100).round()} %",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),*/
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onSelected: (value) {
              if (value == 'mark') {
                _saveMarkedPage(_pdfController.pageNumber);
              } else if (value == 'remove') {
                _removeMarkedPage();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'mark', child: Text('Marquer la page')),
              if (_markedPage != null)
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Supprimer le marque-page'),
                ),
            ],
          )
        ],
      ),

      // ✅ PDF
      body: SafeArea(
        child: FutureBuilder<File?>(
          future: _pdfFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return SfPdfViewer.file(
                snapshot.data!,
                controller: _pdfController,
                scrollDirection: PdfScrollDirection.vertical,
                onDocumentLoaded: (details) {
                  _totalPages = details.document.pages.count;
                  _pdfController.jumpToPage(_markedPage ?? _lastPage);
                  _updateProgress(_lastPage);
                },
                onPageChanged: (details) {
                  _saveLastPage(details.newPageNumber);
                  _updateProgress(details.newPageNumber);
                },
              );
            }
            return const Center(child: Text("Impossible de charger le PDF"));
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.note_add),
        label: const Text("Notes"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(book: widget.book),
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeMarkedPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('markedPage_${widget.book.id}');
    setState(() => _markedPage = null);
  }
}
