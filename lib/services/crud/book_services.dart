
import 'package:book_by_book/services/crud/crud_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'show join;


class BooksService {
  Database? _db;

  Future<DatabaseBook> updateBook({
    required DatabaseBook book,
    required String bookAuthor,
    required String bookTitle,
    }) async {
    final db = _getDatabaseOrThrow();

    await getBook(id: book.id);

    final updatesCount = await db.update(bookTable, {
      bookAuthor: bookAuthor,
      bookTitle: bookTitle,
      isSyncedWithCloudColumn: 0,
    }
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateBook();
    } else {
      return await getBook(id: book.id);
    }
  }

  Future<Iterable<DatabaseBook>> getAllBooks() async {
    final db = _getDatabaseOrThrow();
    final books = await db.query(
      bookTable,
    );
    return books.map((bookRow) => DatabaseBook.fromRow(bookRow));
   }

  Future<DatabaseBook> getBook({required int id}) async {
    final db = _getDatabaseOrThrow();
    final books = await db.query(
      bookTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (books.isEmpty) {
      throw CouldNotFindBook();
    } else {
      return DatabaseBook.fromRow(books.first);
    }
  }

  Future<int> deleteAllBooks() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(bookTable);
  }

  Future<void> deleteBook({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      bookTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteBook();
    }
  }

  Future<DatabaseBook> createBook({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const bookTitle = ' ';
    const bookAuthor = ' ';

    // create the book
    final bookId = await db.insert(bookTable, {
      userIdColumn: owner.id,
      bookAuthorColumn: bookAuthor,
      bookTitleColumn: bookTitle,
      isSyncedWithCloudColumn: 1,
    });

    final book = DatabaseBook(
      id: bookId, 
      userId: owner.id, 
      bookAuthor: bookAuthor, 
      bookTitle: bookTitle, 
      isSyncedWithCloud: true);

    return book;
  }

  Future<DatabaseUser> getUser({required String email}) async {
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
  final String bookAuthor;
  final bool isSyncedWithCloud;

  const DatabaseBook({
    required this.id,
    required this.userId,
    required this.bookAuthor,
    required this.bookTitle,
    required this.isSyncedWithCloud,
  });


  DatabaseBook.fromRow(Map<String, Object?> map) 
  : id = map[idColumn] as int, 
    userId = map[userIdColumn] as int,
    bookAuthor = map[bookAuthorColumn] as String,
    bookTitle = map[bookTitleColumn] as String,
    isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

 @override
  String toString() => 
    'Book, ID = $id, userId = $userId, bookTitle = $bookTitle, bookAuthor = $bookAuthor, isSyncedWithCould = $isSyncedWithCloud';

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
const bookAuthorColumn = 'book_author';
const bookTitleColumn = 'book_title';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL UNIQUE,
  "email"	TEXT NOT NULL UNIQUE,
  PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createBookTable = '''CREATE TABLE IF NOT EXISTS "books" (
  "id"	INTEGER NOT NULL,
  "user_id"	INTEGER NOT NULL,
  "book_title"	TEXT,
  "book_author"	TEXT,
  "is_synced_with cloud"	INTEGER DEFAULT 0,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';
