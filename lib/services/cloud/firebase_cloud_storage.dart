import 'package:book_by_book/services/cloud/cloud_storage_constants.dart';
import 'package:book_by_book/services/cloud/cloud_book.dart';
import 'package:book_by_book/services/cloud/cloud_storage_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {

  final books = FirebaseFirestore.instance.collection('books');

  Future<void> deleteBook({
    required String documentId
  }) async {
    try {
      await books.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteBookException();
    }
  }

  Future<void> updateBook({
    required String documentId,
    required String bookTitle,
  }) async {
    try {
      await books.doc(documentId).update({
        bookTitleFieldName: bookTitle,
      });
    } catch (e) {
      throw CouldNotUpdateBookException();
    }
  }

  Stream<Iterable<CloudBook>> allBooks({required String ownerUserId}) =>
    books.snapshots().map((event) => event.docs
      .map((doc) => CloudBook.fromSnapshot(doc))
      .where((book) => book.ownerUserId == ownerUserId
      ));

  Future<Iterable<CloudBook>> getBooks({required String ownerUserId}) async {
    try {
      return await books.where(
        ownerUserIdFieldName,
        isEqualTo: ownerUserId,
      )
      .get()
      .then((value) => value.docs.map((doc) {
        return CloudBook(
          documentId: doc.id, 
          ownerUserId: doc.data()[ownerUserIdFieldName] as String, 
          bookTitle: doc.data()[bookTitleFieldName] as String,
          );
      }));
    } catch (e) {
      throw CouldNotGetAllBookException();
    }
  }

  void createNewBook({required String ownerUserId}) async {
    await books.add({
      ownerUserIdFieldName: ownerUserId,
      bookTitleFieldName: '',
    });
  }

  // creating singleton
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;


}