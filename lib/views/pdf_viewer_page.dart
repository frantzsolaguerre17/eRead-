import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import 'book_details_page.dart';

class PdfViewerPage extends StatefulWidget {
  final Book book;

  const PdfViewerPage({required this.book, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Télécharge le fichier PDF depuis le lien distant
      final response = await http.get(Uri.parse(widget.book.pdf));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.book.title}.pdf');
        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception("Erreur lors du chargement du PDF");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de charger le PDF : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath != null
          ? PDFView(filePath: localPath!)
          : const Center(child: Text("Erreur lors de l'ouverture du PDF")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal.shade700,
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
    );
  }
}
