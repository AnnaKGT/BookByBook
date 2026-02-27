import 'package:book_by_book/helpers/open_link_in_new.dart';
import 'package:book_by_book/helpers/rating_input_field.dart';
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
  late final TextEditingController _textControllerNotes;
  late final TextEditingController _textControllerLink;
  double _currentRating = 0.0;

  late Future<CloudBook> _bookFuture;

  @override
  void initState() {
    _booksService = FirebaseCloudStorage();
    _textControllerAuthor = TextEditingController();
    _textControllerTitle = TextEditingController();
    _textControllerNotes = TextEditingController();
    _textControllerLink = TextEditingController();
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

    await _booksService.updateBook(
      documentId: book.documentId, 
      bookTitle: _textControllerTitle.text,
      bookAuthor: _textControllerAuthor.text, 
      bookNotes: _textControllerNotes.text,
      bookLink: _textControllerLink.text, 
      bookRating: _currentRating,
      );
  }

  void _setupTextControllerListener() {
    _textControllerAuthor.removeListener(_textControllerListener);
    _textControllerAuthor.addListener(_textControllerListener);
    _textControllerTitle.removeListener(_textControllerListener);
    _textControllerTitle.addListener(_textControllerListener);
    _textControllerNotes.removeListener(_textControllerListener);
    _textControllerNotes.addListener(_textControllerListener);
    _textControllerLink.removeListener(_textControllerListener);
    _textControllerLink.addListener(_textControllerListener);
  }


  Future<CloudBook> createOrGetExistingBook(BuildContext context) async {

    final widgetBook = context.getArgument<CloudBook>();

    if (widgetBook != null) {
      _book = widgetBook;
      _textControllerTitle.text = widgetBook.bookTitle;
      _textControllerAuthor.text = widgetBook.bookAuthor;
      _textControllerNotes.text = widgetBook.bookNotes;
      _textControllerLink.text = widgetBook.bookLink;
      _currentRating = widgetBook.bookRating;
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
    final textNotes = _textControllerNotes.text;
    final textLink = _textControllerLink.text;
    if (textTitle.isNotEmpty && book != null) {
      await _booksService.updateBook(
        documentId: book.documentId, 
        bookTitle: textTitle,
        bookAuthor: textAuthor, 
        bookNotes: textNotes,
        bookLink: textLink, 
        bookRating: _currentRating,
        );
    }
  }

 
  @override
  void dispose() {
    _deleteBookIfTitleIsEmpty();
    _saveBookIfTitleIsNotEmpty();
    _textControllerAuthor.dispose();
    _textControllerTitle.dispose();
    _textControllerNotes.dispose();
    _textControllerLink.dispose();
    super.dispose();
  }

  String _buildShareText() {
    final title = _textControllerTitle.text;
    final author = _textControllerAuthor.text;
    final link = _textControllerLink.text;

    final buffer = StringBuffer();
    buffer.writeln('📖 $title');
    if (author.isNotEmpty) buffer.writeln('✍️ $author');
    if (link.isNotEmpty) buffer.writeln('🔗 $link');

    return buffer.toString().trim();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            onPressed: () async {

              final text = _textControllerTitle.text;

              if (_book == null || text.isEmpty) {
                await showCannotShareEmptyBookDialog(context);
              } else {
               await SharePlus.instance.share(ShareParams(text: _buildShareText()));
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const Text(
                      'Author:',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextField(
                     controller: _textControllerAuthor,
                     decoration: const InputDecoration(
                       hintText: ' '
                    ),
                      
                    ),
                    const SizedBox(height: 16,),
                    const Text(
                      'Title:',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextField(
                      controller: _textControllerTitle,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: ' '
                      )
                    ),
                    const SizedBox(height: 16,),
                    const Text(
                      'Link:',
                      style: TextStyle(fontSize: 14, color: Colors.grey,)),
                    ValueListenableBuilder(
                      valueListenable: _textControllerLink, 
                      builder: (context, value, _) {
                        return TextField(
                      controller: _textControllerLink,
                      keyboardType: TextInputType.url,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: ' ',
                        suffixIcon: value.text.isNotEmpty ? IconButton(
                          onPressed: () => launchLink(_textControllerLink.text), 
                          icon: const Icon(Icons.open_in_new, size: 16))
                          : null,
                        )
                      );
                      })
                    ,

                    const SizedBox(height: 24,),
                    const Text(
                      'How do you like the book?',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                    RatingField(
                      initialRating: _currentRating == 0.0 ? 1.0 : _currentRating, 
                      onRatingUpdate: (rating) async {
                        setState(() => _currentRating = rating);
                        final book = _book;
                        if (book != null) {
                          await _booksService.updateBook(
                            documentId: book.documentId, 
                            bookTitle: _textControllerTitle.text, 
                            bookAuthor: _textControllerAuthor.text, 
                            bookNotes: _textControllerNotes.text,
                            bookLink: _textControllerLink.text, 
                            bookRating: rating,
                            );
                        }
                      }),
                    const SizedBox(height: 16,),
                    const Text(
                      'Notes:',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextField(
                      controller: _textControllerNotes,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: ' ',
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