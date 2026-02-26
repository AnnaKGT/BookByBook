
import 'package:flutter/material.dart';
import 'package:book_by_book/services/cloud/cloud_book.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.bookAuthor,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
            
                Text(
                  book.bookTitle,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            RatingBarIndicator(
              rating: book.bookRating,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20,
              direction: Axis.horizontal,
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