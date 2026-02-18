import 'package:book_by_book/services/crud/book_services.dart';
import 'package:book_by_book/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef DeleteBookCallback = void Function(DatabaseBook book);

class BooksListView extends StatelessWidget {
  final List<DatabaseBook> books;
  final DeleteBookCallback onDeleteBook;

  const BooksListView({
    super.key, 
    required this.books, 
    required this.onDeleteBook,
    });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
      final book = books[index];
      return ListTile(
        title: Text(
          book.bookTitle,
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          ),
        trailing: IconButton(
          onPressed: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              onDeleteBook(book);
            }
          },
          icon: const Icon(Icons.delete),
        ),
        );
      },
   );
  }
}