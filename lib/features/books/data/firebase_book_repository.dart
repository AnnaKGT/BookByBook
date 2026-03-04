import 'package:book_by_book/features/books/domain/cloud/cloud_book.dart';
import 'package:book_by_book/features/books/domain/cloud/cloud_storage_constants.dart';
import 'package:book_by_book/features/books/domain/cloud/cloud_storage_exceptions.dart';
import 'package:book_by_book/features/books/domain/bloc/book_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBookRepository implements BookRepository{
  final _books = FirebaseFirestore.instance.collection('books');

  //Singleton
  static final FirebaseBookRepository _shared = FirebaseBookRepository._sharedInstance();
  FirebaseBookRepository._sharedInstance();
  factory FirebaseBookRepository() => _shared;

  @override
  Stream<Iterable<CloudBook>> allBooks({required String ownerUserId}) {
    return _books
    .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
    .snapshots()
    .map((event) => event.docs.map((doc) => CloudBook.fromSnapshot(doc)));
  }

  @override
  Future<CloudBook> createNewBook({required String ownerUserId}) async {
    try {
      final ref = await _books.add({
        ownerUserIdFieldName: ownerUserId,
        bookAuthorFieldName: "",
        bookTitleFieldName: "",
        bookNotesFieldName: '',
        bookLinkFieldName: '',
        bookRatingFieldName: 0.0,
      });
      return CloudBook(
        documentId: ref.id, 
        ownerUserId: ownerUserId, 
        bookTitle: '', 
        bookAuthor: '',
        bookRating: 0.0,
        bookNotes: '',
        bookLink: '',
        );

    } catch (e) {
      throw CouldNotCreateBookException();
    }
  }

  @override
  Future<void> deleteBook({required String documentId}) async {
    try {
      await _books.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteBookException();
    }
  }

  @override
  Future<void> updateBook({
    required String documentId, 
    required String bookTitle, 
    required String bookAuthor, 
    required String bookNotes, 
    required String bookLink, 
    required double bookRating}) async {
    try {
      await _books.doc(documentId).update({
        bookAuthorFieldName: bookAuthor,
        bookTitleFieldName: bookTitle,
        bookNotesFieldName: bookNotes,
        bookLinkFieldName: bookLink,
        bookRatingFieldName: bookRating,
      });
    } catch (e) {
      throw CouldNotUpdateBookException();
    }
    
  }

  
}