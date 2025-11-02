import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/vocabulary.dart';
import '../models/excerpt.dart';

class LocalDBService {

  static Database? _database;

  /// 📦 Accès à la base de données locale
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memo_livre.db');
    return _database!;
  }


  /// 🏗️ Initialisation de la base
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }


  /// 🧱 Création des tables locales
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE book (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        number_of_pages TEXT,
        created_at TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE chapter (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        title TEXT NOT NULL,
        number_of_chapter,
        created_at TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE excerpt (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        content TEXT NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (chapter_id) REFERENCES chapter (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vocabulary (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        word TEXT NOT NULL,
        definition TEXT,
        example TEXT,
        created_at TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE CASCADE
      )
    ''');
  }


  // --------------------------------------------------------------------------
  // 📚 BOOKS
  // --------------------------------------------------------------------------

  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'book',
      book.toJson()
        ..['issynced'] = book.isSynced ? 1 : 0,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  /// 🔄 Insérer ou mettre à jour un livre
  Future<void> insertOrUpdateBook(Book book) async {
    final db = await database;
    await db.insert(
      'book',
      book.toJson()
        ..['is_synced'] = book.isSynced ? 1 : 0,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('book');
    return List.generate(maps.length, (i) => Book.fromJson(maps[i]));
  }


  Future<List<Book>> getUnsyncedBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('book', where: 'is_synced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Book.fromJson(maps[i]));
  }


  Future<void> updateBookSyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update(
      'book',
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /// 🧹 Supprimer tous les livres (utile pour reset)
  Future<void> clearBooks() async {
    final db = await database;
    await db.delete('book');
  }



  // --------------------------------------------------------------------------
  // 📖 CHAPTERS
  // --------------------------------------------------------------------------

  Future<void> insertChapter(Chapter chapter) async {
    final db = await database;
    await db.insert('chapter', chapter.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Chapter>> getChaptersByBook(String bookId) async {
    final db = await database;
    final maps = await db.query('chapter', where: 'book_id = ?', whereArgs: [bookId]);
    return maps.map((e) => Chapter.fromJson(e)).toList();
  }

  Future<List<Chapter>> getUnsyncedChapters() async {
    final db = await database;
    final maps = await db.query('chapter', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((e) => Chapter.fromJson(e)).toList();
  }

  Future<void> updateChapterSyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update('chapter', {'isSynced': isSynced ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }


  // --------------------------------------------------------------------------
  // 📝 EXCERPTS
  // --------------------------------------------------------------------------

  Future<void> insertExcerpt(Excerpt excerpt) async {
    final db = await database;
    await db.insert(
      'excerpts',
      excerpt.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertOrUpdateExcerpt(Excerpt excerpt) async {
    final db = await database;
    await db.insert(
      'excerpts',
      excerpt.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Excerpt>> getExcerptsByChapter(String chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'excerpts',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
      orderBy: 'created_at ASC',
    );
    return List.generate(
      maps.length,
          (i) => Excerpt.fromJson(maps[i]),
    );
  }

  Future<List<Excerpt>> getUnsyncedExcerpts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('excerpts', where: 'is_synced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Excerpt.fromJson(maps[i]));
  }

  Future<void> updateExcerptSyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update(
      'excerpts',
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // --------------------------------------------------------------------------
  // 🧠 VOCABULARY
  // --------------------------------------------------------------------------

  Future<void> insertVocabulary(Vocabulary vocab) async {
    final db = await database;
    await db.insert('vocabulary', vocab.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Vocabulary>> getVocabularyByBook(String bookId) async {
    final db = await database;
    final maps = await db.query('vocabulary', where: 'book_id = ?', whereArgs: [bookId]);
    return maps.map((e) => Vocabulary.fromJson(e)).toList();
  }

  Future<List<Vocabulary>> getUnsyncedVocabulary() async {
    final db = await database;
    final maps = await db.query('vocabulary', where: 'isSynced = ?', whereArgs: [0]);
    return maps.map((e) => Vocabulary.fromJson(e)).toList();
  }

  Future<void> updateVocabularySyncStatus(String id, bool isSynced) async {
    final db = await database;
    await db.update('vocabulary', {'isSynced': isSynced ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertOrUpdateVocabulary(Vocabulary vocab) async {
    final db = await database;
    await db.insert(
      'vocabulary',
      vocab.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace, // ✅ évite les doublons
    );
  }

  Future<List<Vocabulary>> getAllVocabulary() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vocabulary');

    return List.generate(maps.length, (i) {
      return Vocabulary.fromJson(maps[i]);
    });
  }



  // --------------------------------------------------------------------------
  // 🧹 Nettoyage
  // --------------------------------------------------------------------------

  /// Supprimer toutes les lignes d’une table spécifique
  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  /// Supprimer tous les chapitres d’un livre
  Future<void> clearChaptersByBook(String bookId) async {
    final db = await database;
    await db.delete('chapter', where: 'book_id = ?', whereArgs: [bookId]);
  }

  /// Supprimer tous les extraits d’un chapitre
  Future<void> clearExcerptsByChapter(String chapterId) async {
    final db = await database;
    await db.delete('excerpt', where: 'chapter_id = ?', whereArgs: [chapterId]);
  }

  /// Supprimer tous les mots d’un livre
  Future<void> clearVocabularyByBook(String bookId) async {
    final db = await database;
    await db.delete('vocabulary', where: 'book_id = ?', whereArgs: [bookId]);
  }

  /// Supprimer toutes les données
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('book');
    await db.delete('chapter');
    await db.delete('excerpt');
    await db.delete('vocabulary');
  }
}
