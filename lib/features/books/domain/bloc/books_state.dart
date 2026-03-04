

import 'package:book_by_book/features/books/domain/cloud/cloud_book.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class BooksState {
  const BooksState();
}

// Initial / loading
class BooksStatesLoading extends BooksState {
  const BooksStatesLoading();
}

// Stream of books is active
class BooksStateLoaded extends BooksState {
  final Iterable<CloudBook> books;
  const BooksStateLoaded({required this.books});
}

// A new book was just created — carry it to the edit view
class BookStateCreated extends BooksState {
  final CloudBook book;
  const BookStateCreated({required this.book});
}

//Something went wrong
class BooksStateError extends BooksState {
  final Exception exception;
  const BooksStateError({required this.exception});
}

class BooksStateDeleted extends BooksState {
  const BooksStateDeleted();
}