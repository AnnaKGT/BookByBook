import 'package:book_by_book/services/crud/book_services.dart';
import 'package:book_by_book/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef BookCallback = void Function(DatabaseBook book);

class BooksListView extends StatelessWidget {
  final List<DatabaseBook> books;
  final BookCallback onDeleteBook;
  final BookCallback onTap;

  const BooksListView({
    super.key, 
    required this.books, 
    required this.onDeleteBook, 
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
      final book = books[index];
      return ListTile(
        onTap: () {
          onTap(book);
        },
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