import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_by_book/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudBook {
  final String documentId;
  final String ownerUserId;
  final String bookTitle;
  final String bookAuthor;

  const CloudBook({
    required this.documentId,
    required this.ownerUserId,
    required this.bookTitle, 
    required this.bookAuthor,
    });

  CloudBook.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) : 
   documentId = snapshot.id,
   ownerUserId = snapshot.data()[ownerUserIdFieldName] as String,
   bookTitle = snapshot.data()[bookTitleFieldName] as String? ?? '',
   bookAuthor = snapshot.data()[bookAuthorFieldName] as String? ?? '';
}