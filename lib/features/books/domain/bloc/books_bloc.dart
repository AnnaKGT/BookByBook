
import 'package:book_by_book/features/books/domain/bloc/book_repository.dart';
import 'package:book_by_book/features/books/domain/bloc/books_event.dart';
import 'package:book_by_book/features/books/domain/bloc/books_state.dart';
import 'package:book_by_book/features/books/domain/cloud/cloud_storage_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState>{
  final BookRepository _repository;

  BooksBloc(this._repository) : super(const BooksStatesLoading()) {

    on<BooksEventLoadAll>((event, emit) async {
      emit(const BooksStatesLoading());
      await emit.forEach(
        _repository.allBooks(ownerUserId: event.ownerUserId), 
        onData: (books) => BooksStateLoaded(books: books),
        onError: (_, _) => BooksStateError(
          exception: CouldNotGetAllBookException()
          ),
        );
    });

    on<BooksEventCreate>((event, emit) async {
      try {
        final book = await _repository.createNewBook(
          ownerUserId: event.ownerUserId,
          );
        emit(BookStateCreated(book: book));

      } on Exception catch (e) {
        emit(BooksStateError(exception: e));
      }
    });

    on<BooksEventUpdate>((event, emit) async {
      // Update is fire-and-forget from the view (debounced)
      // we don't change state. Stream will reflect the change automatically.
      try {
        await _repository.updateBook(
          documentId: event.documentId, 
          bookTitle: event.bookTitle, 
          bookAuthor: event.bookAuthor, 
          bookNotes: event.bookNotes, 
          bookLink: event.bookLink, 
          bookRating: event.bookRating,
          );
      } on Exception catch (e) {
        emit(BooksStateError(exception: e));
      }
    });

    on<BooksEventDelete>((event, emit) async {
      try {
        await _repository.deleteBook(documentId: event.documentId);
      } on Exception catch (e) {
        emit(BooksStateError(exception: e));
      }
    });

     on<BooksEventDeleteIfEmpty>((event, emit) async {
      if (event.currentTitle.trim().isEmpty) {
        try {
          await _repository.deleteBook(documentId: event.documentId);
          emit(const BooksStateDeleted());
        } on Exception catch (e) {
          emit(BooksStateError(exception: e));
        }
      }
    });


  }


}