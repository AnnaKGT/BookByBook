import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/crud/book_services.dart';
import 'package:book_by_book/utilities/generics/get_argumants.dart';
import 'package:flutter/material.dart';

class CreateUpdateBookView extends StatefulWidget {
  const CreateUpdateBookView({super.key});

  @override
  State<CreateUpdateBookView> createState() => _CreateUpdateBookViewState();
}



class _CreateUpdateBookViewState extends State<CreateUpdateBookView> {

  DatabaseBook? _book;
  late final BooksService _booksService;
  //late final TextEditingController _textControllerAuthor;
  late final TextEditingController _textControllerTitle;

  @override
  void initState() {
    _booksService = BooksService();
    //_textControllerAuthor = TextEditingController();
    _textControllerTitle = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final book = _book;
    if (book == null) {
      return;
    }

    //final textAuthor = _textControllerAuthor.text;
    final textTitle = _textControllerTitle.text;
    await _booksService.updateBook(
      book: book, 
      //bookAuthor: textAuthor, 
      bookTitle: textTitle,
      );
  }

  void _setupTextControllerListener() {
    //_textControllerAuthor.removeListener(_textControllerListener);
    //_textControllerAuthor.addListener(_textControllerListener);
    _textControllerTitle.removeListener(_textControllerListener);
    _textControllerTitle.addListener(_textControllerListener);
  }


  Future<DatabaseBook> createOrGetExistingBook(BuildContext context) async {

    final widgetBook = context.getArgument<DatabaseBook>();

    if (widgetBook != null) {
      _book = widgetBook;
      _textControllerTitle.text = widgetBook.bookTitle;
      return widgetBook;
    }

    final existingBook = _book;
    if (existingBook != null) {
      return existingBook;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _booksService.getUser(email: email);
    final newBook = await _booksService.createBook(owner: owner);
    _book = newBook;
    return newBook;
  }

  void _deleteBookIfTitleIsEmpty() {
    final book = _book;
    if (_textControllerTitle.text.isEmpty && book != null) {
      _booksService.deleteBook(id: book.id);
    }
  }

  void _saveBookIfTitleIsNotEmpty() async {
    final book = _book;
    final textTitle = _textControllerTitle.text;
    //final textAuthor = _textControllerAuthor.text;
    if (textTitle.isNotEmpty && book != null) {
      await _booksService.updateBook(book: book, bookTitle: textTitle);
    }
  }

 
  @override
  void dispose() async {
    _deleteBookIfTitleIsEmpty();
    _saveBookIfTitleIsNotEmpty();
    //_textControllerAuthor.dispose();
    _textControllerTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Book'),

      ),
      body: FutureBuilder(
        future: createOrGetExistingBook(context), 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  const Text('Add a book'),
                  //TextField(
                  //  controller: _textControllerAuthor,
                  //  decoration: const InputDecoration(
                  //    hintText: 'Book author'
                  // ),
                    
                  //),
                  TextField(
                    controller: _textControllerTitle,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Book title'
                    )
                  ),
                ],
              );
             
            default:
             return const CircularProgressIndicator();
          }
        },
        ),
    );
  }
}