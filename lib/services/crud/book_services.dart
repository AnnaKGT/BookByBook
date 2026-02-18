
import 'dart:async';

import 'package:book_by_book/extensions/list/filter.dart';
import 'package:book_by_book/services/crud/crud_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'show join;
import 'package:book_by_book/extensions/list/filter.dart';


class BooksService {
  Database? _db;
  List<DatabaseBook> _books = [];
  DatabaseUser? _user;

  static final BooksService _shared = BooksService._sharedInstance();
  BooksService._sharedInstance() {
    _booksStreamConroller = StreamController<List<DatabaseBook>>.broadcast(
      onListen: () {
        _booksStreamConroller.sink.add(_books);
      }
    );
  }
  factory BooksService() => _shared;

  late final StreamController<List<DatabaseBook>> _booksStreamConroller;

  Stream<List<DatabaseBook>> get allBooks => 
  _booksStreamConroller.stream.filter((book) {
    final currentUser = _user;
    if (currentUser != null) {
      return book.userId == currentUser.id;
    } else {
      throw UserShouldBeSetBeforeReadingBooks();
    }
  });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
    }) async {
   try {
    final user = await getUser(email: email);
    if (setAsCurrentUser) {
      _user = user;
    }
    return user;
   } on CouldNotFindUser {
    final createdUser = await createUser(email: email);
    if (setAsCurrentUser) {
      _user = createdUser;
    }
    return createdUser;
   } catch (e) {
    rethrow;
   }
  }

  Future<void> _cacheBooks() async {
    final allBooks = await getAllBooks();
    _books = allBooks.toList();
    _booksStreamConroller.add(_books);
  }

  Future<DatabaseBook> updateBook({
    
    required DatabaseBook book,
    //required String bookAuthor,
    required String bookTitle,
    }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getBook(id: book.id);

    // update DB
    final updatesCount = await db.update(bookTable, {
      //bookAuthor: bookAuthor,
      bookTitleColumn: bookTitle,
      isSyncedWithCloudColumn: 0,
    },
      where: 'id = ?',
      whereArgs: [book.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateBook();
    } else {
      final updatedBook = await getBook(id: book.id);
      _books.removeWhere((book) => book.id == updatedBook.id);
      _books.add(updatedBook);
      _booksStreamConroller.add(_books);
      return updatedBook;
    }
  }

  Future<Iterable<DatabaseBook>> getAllBooks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final books = await db.query(
      bookTable,
    );
    return books.map((bookRow) => DatabaseBook.fromRow(bookRow));
   }

  Future<DatabaseBook> getBook({required int id}) async {
    final db = _getDatabaseOrThrow();
    await _ensureDbIsOpen();
    final books = await db.query(
      bookTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (books.isEmpty) {
      throw CouldNotFindBook();
    } else {
      final book = DatabaseBook.fromRow(books.first);
      _books.removeWhere((book) => book.id == id);
      _books.add(book);
      _booksStreamConroller.add(_books);
      return book;
    }
  }

  Future<int> deleteAllBooks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(bookTable);
    _books = [];
    _booksStreamConroller.add(_books);
    return numberOfDeletions;
  }

  Future<void> deleteBook({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      bookTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteBook();
    } else {
      _books.removeWhere((book) => book.id == id);
      _booksStreamConroller.add(_books);

    }
  }

  Future<DatabaseBook> createBook({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const bookTitle = ' ';
    //const bookAuthor = ' ';

    // create the book
    final bookId = await db.insert(bookTable, {
      userIdColumn: owner.id,
      //bookAuthorColumn: bookAuthor,
      bookTitleColumn: bookTitle,
      isSyncedWithCloudColumn: 1,
    });

    final book = DatabaseBook(
      id: bookId, 
      userId: owner.id, 
      //bookAuthor: bookAuthor, 
      bookTitle: bookTitle, 
      isSyncedWithCloud: true);

    _books.add(book);
    _booksStreamConroller.add(_books);

    return book;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
        userTable, 
        limit: 1, 
        where: 'email = ?', 
        whereArgs: [email.toLowerCase()],
      );
    
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }


  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId, 
      email: email,
      );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final  deletedCount = await db.delete(
      userTable, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()],
      );
    
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();

    } on DatabaseAlreadyOpenExeception {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenExeception();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create the books table
      await db.execute(createBookTable);
      await _cacheBooks();

    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}


@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id, 
    required this.email
    });

  DatabaseUser.fromRow(Map<String, Object?> map) 
  : id = map[idColumn] as int, 
    email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

class DatabaseBook {
  final int id;
  final int userId;
  final String bookTitle;
  //final String bookAuthor;
  final bool isSyncedWithCloud;

  const DatabaseBook({
    required this.id,
    required this.userId,
    //required this.bookAuthor,
    required this.bookTitle,
    required this.isSyncedWithCloud,
  });


  DatabaseBook.fromRow(Map<String, Object?> map) 
  : id = map[idColumn] as int, 
    userId = map[userIdColumn] as int,
    //bookAuthor = map[bookAuthorColumn] as String,
    bookTitle = map[bookTitleColumn] as String,
    isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

 @override
  String toString() => 
    'Book, ID = $id, userId = $userId, bookTitle = $bookTitle, isSyncedWithCould = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseBook other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

const dbName = 'books.db';
const bookTable = 'book';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
//const bookAuthorColumn = 'book_author';
const bookTitleColumn = 'book_title';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL UNIQUE,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createBookTable = '''CREATE TABLE IF NOT EXISTS "book" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "book_title"	TEXT,
  "book_author"	TEXT ,
  "is_synced_with_cloud"	INTEGER DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';
