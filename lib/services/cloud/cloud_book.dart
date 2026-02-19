
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_by_book/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudBook {
  final String documentId;
  final String ownerUserId;
  final String bookTitle;

  const CloudBook({
    required this.documentId,
    required this.ownerUserId,
    required this.bookTitle
    });

  CloudBook.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) : 
   documentId = snapshot.id,
   ownerUserId = snapshot.data()[ownerUserIdFieldName],
   bookTitle = snapshot.data()[bookTitleFieldName] as String;
}