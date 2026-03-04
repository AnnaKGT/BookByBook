
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class BooksEvent {
  const BooksEvent();
}

//Load all books for the logged-in user
class BooksEventLoadAll extends BooksEvent {
  final String ownerUserId;
  const BooksEventLoadAll({required this.ownerUserId});
}

// Create a new empty book
class BooksEventCreate extends BooksEvent {
  final String ownerUserId;
  const BooksEventCreate ({required this.ownerUserId});
}

//Update an existing book
class BooksEventUpdate extends BooksEvent {
  final String documentId;
  final String bookTitle;
  final String bookAuthor;
  final String bookNotes;
  final String bookLink;
  final double bookRating;
  const BooksEventUpdate({
    required this.documentId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookNotes,
    required this.bookLink,
    required this.bookRating,
  });
}

// Delete a book
class BooksEventDelete extends BooksEvent {
  final String documentId;
  const BooksEventDelete({required this.documentId});
}

//auto-delete a book if the user left its title empty (replaces
// the old dispose-time _deleteBookIfTitleIsEmpty() that called
// FirebaseCloudStorage directly).
class BooksEventDeleteIfEmpty extends BooksEvent {
  final String documentId;
  final String currentTitle;
  const BooksEventDeleteIfEmpty({
    required this.documentId,
    required this.currentTitle,
  });
}