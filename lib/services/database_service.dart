import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE users (
  id $idType,
  username $textType UNIQUE,
  password $textType
  )
''');

    await db.execute('''
CREATE TABLE decks (
  id $idType,
  userId $intType,
  title $textType,
  tags TEXT,
  colorCode $intType,
  FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
CREATE TABLE flashcards (
  id $idType,
  deckId $intType,
  question $textType,
  answer $textType,
  isMastered $boolType,
  FOREIGN KEY (deckId) REFERENCES decks (id) ON DELETE CASCADE
  )
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Recreate tables to add users
      await db.execute('DROP TABLE IF EXISTS flashcards');
      await db.execute('DROP TABLE IF EXISTS decks');
      await _createDB(db, newVersion);
    }
  }

  // Users CRUD
  Future<AppUser?> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      final id = await db.insert('users', {'username': username, 'password': password});
      return AppUser(id: id, username: username, password: password);
    } catch (e) {
      // e.g. UNIQUE constraint failed
      return null;
    }
  }

  Future<AppUser?> loginUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return AppUser.fromMap(result.first);
    }
    return null;
  }

  // Decks CRUD
  Future<Deck> createDeck(Deck deck, int userId) async {
    final db = await instance.database;
    final map = deck.toMap();
    map['userId'] = userId;
    final id = await db.insert('decks', map);
    return Deck(id: id, title: deck.title, tags: deck.tags, colorCode: deck.colorCode);
  }

  Future<List<Deck>> readAllDecks(int userId) async {
    final db = await instance.database;
    final result = await db.query('decks', where: 'userId = ?', whereArgs: [userId]);
    return result.map((json) => Deck.fromMap(json)).toList();
  }
  
  Future<int> deleteDeck(int id) async {
    final db = await instance.database;
    return await db.delete('decks', where: 'id = ?', whereArgs: [id]);
  }

  // Flashcards CRUD
  Future<Flashcard> createFlashcard(Flashcard flashcard) async {
    final db = await instance.database;
    final id = await db.insert('flashcards', flashcard.toMap());
    return Flashcard(
      id: id,
      deckId: flashcard.deckId,
      question: flashcard.question,
      answer: flashcard.answer,
      isMastered: flashcard.isMastered,
    );
  }

  Future<List<Flashcard>> readCardsForDeck(int deckId) async {
    final db = await instance.database;
    final result = await db.query(
      'flashcards',
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> updateFlashcard(Flashcard flashcard) async {
    final db = await instance.database;
    return db.update(
      'flashcards',
      flashcard.toMap(),
      where: 'id = ?',
      whereArgs: [flashcard.id],
    );
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
