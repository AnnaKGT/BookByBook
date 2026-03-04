import 'package:book_by_book/features/books/domain/cloud/cloud_book.dart';

abstract class BookRepository {
  Stream<Iterable<CloudBook>> allBooks({required String ownerUserId});

  Future<CloudBook> createNewBook({
    required String ownerUserId, 
    
    });

  Future<void> updateBook({
    required String documentId,
    required String bookTitle,
    required String bookAuthor,
    required String bookNotes,
    required String bookLink,
    required double bookRating,
    });

  Future<void> deleteBook({
    required String documentId,
    });
}