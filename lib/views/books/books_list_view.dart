
import 'package:flutter/material.dart';
import 'package:book_by_book/services/cloud/cloud_book.dart';

typedef BookCallback = void Function(CloudBook book);

class BooksListView extends StatelessWidget {
  final Iterable<CloudBook> books;
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
      final book = books.elementAt(index);
      return ListTile(
        onTap: () {
          onTap(book);
        },
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.bookAuthor,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              ),
            const Text(' — '),
            Text(
              book.bookTitle,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        // trailing: IconButton(
        //   onPressed: () async {
        //     final shouldDelete = await showDeleteDialog(context);
        //     if (shouldDelete) {
        //       onDeleteBook(book);
        //     }
        //   },
        //   icon: const Icon(Icons.delete),
        // ),
        );
      },
   );
  }
}