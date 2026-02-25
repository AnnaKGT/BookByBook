import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/cloud/cloud_book.dart';
import 'package:book_by_book/services/cloud/firebase_cloud_storage.dart';
import 'package:book_by_book/utilities/dialogs/cannot_share_empty_book_dialog.dart';
import 'package:book_by_book/utilities/dialogs/delete_dialog.dart';
import 'package:book_by_book/utilities/generics/get_argumants.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

typedef BookCallback = void Function(CloudBook book);

class CreateUpdateBookView extends StatefulWidget {
  const CreateUpdateBookView({super.key});

  @override
  State<CreateUpdateBookView> createState() => _CreateUpdateBookViewState();
}



class _CreateUpdateBookViewState extends State<CreateUpdateBookView> {

  CloudBook? _book;
  late final FirebaseCloudStorage _booksService;
  late final TextEditingController _textControllerAuthor;
  late final TextEditingController _textControllerTitle;
  late Future<CloudBook> _bookFuture;

  @override
  void initState() {
    _booksService = FirebaseCloudStorage();
    _textControllerAuthor = TextEditingController();
    _textControllerTitle = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();
  _bookFuture = createOrGetExistingBook(context); // cache it here
}

  void _textControllerListener() async {
    final book = _book;
    if (book == null) {
      return;
    }

    final textAuthor = _textControllerAuthor.text;
    final textTitle = _textControllerTitle.text;
    await _booksService.updateBook(
      documentId: book.documentId, 
      bookTitle: textTitle,
      bookAuthor: textAuthor,
      );
  }

  void _setupTextControllerListener() {
    _textControllerAuthor.removeListener(_textControllerListener);
    _textControllerAuthor.addListener(_textControllerListener);
    _textControllerTitle.removeListener(_textControllerListener);
    _textControllerTitle.addListener(_textControllerListener);
  }


  Future<CloudBook> createOrGetExistingBook(BuildContext context) async {

    final widgetBook = context.getArgument<CloudBook>();

    if (widgetBook != null) {
      _book = widgetBook;
      _textControllerTitle.text = widgetBook.bookTitle;
      _textControllerAuthor.text = widgetBook.bookAuthor;
      return widgetBook;
    }

    final existingBook = _book;
    if (existingBook != null) {
      return existingBook;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newBook = await _booksService.createNewBook(ownerUserId: userId);
    _book = newBook;
    return newBook;
  }

  void _deleteBookIfTitleIsEmpty() {
    final book = _book;
    if (_textControllerTitle.text.isEmpty && book != null) {
      _booksService.deleteBook(documentId: book.documentId);
    }
  }

  void _saveBookIfTitleIsNotEmpty() async {
    final book = _book;
    final textTitle = _textControllerTitle.text;
    final textAuthor = _textControllerAuthor.text;
    if (textTitle.isNotEmpty && book != null) {
      await _booksService.updateBook(
        documentId: book.documentId, 
        bookTitle: textTitle,
        bookAuthor: textAuthor,
        );
    }
  }

 
  @override
  void dispose() {
    _deleteBookIfTitleIsEmpty();
    _saveBookIfTitleIsNotEmpty();
    _textControllerAuthor.dispose();
    _textControllerTitle.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textControllerTitle.text;
              if (_book == null || text.isEmpty) {
                await showCannotShareEmptyBookDialog(context);
              } else {
               await SharePlus.instance.share(ShareParams(text: text));
              }
            },
            icon: const Icon(Icons.share),
            ),
          IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
               final book = _book;
               if (book != null) {
                await _booksService.deleteBook(documentId: book.documentId);
                if (context.mounted) Navigator.of(context).pop();
              }
            }
            }, 
            icon: const Icon(Icons.delete)),
        ],

      ),
      body: FutureBuilder(
        future: _bookFuture, 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                     controller: _textControllerAuthor,
                     decoration: const InputDecoration(
                       hintText: 'Book author'
                    ),
                      
                    ),
                    TextField(
                      controller: _textControllerTitle,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Book title'
                      )
                    ),
                  ],
                ),
              );
             
            default:
             return const CircularProgressIndicator();
          }
        },
        ),
    );
  }
}