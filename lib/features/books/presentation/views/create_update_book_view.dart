import 'dart:async';

import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/features/books/domain/bloc/books_bloc.dart';
import 'package:book_by_book/features/books/domain/bloc/books_event.dart';
import 'package:book_by_book/helpers/open_link_in_new.dart';
import 'package:book_by_book/helpers/rating_input_field.dart';
import 'package:book_by_book/features/books/domain/cloud/cloud_book.dart';
import 'package:book_by_book/utilities/dialogs/cannot_share_empty_book_dialog.dart';
import 'package:book_by_book/utilities/dialogs/delete_dialog.dart';
import 'package:book_by_book/utilities/generics/get_arguments_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateBookView extends StatefulWidget {
  const CreateUpdateBookView({super.key});

  @override
  State<CreateUpdateBookView> createState() => _CreateUpdateBookViewState();
}


class _CreateUpdateBookViewState extends State<CreateUpdateBookView> {

  CloudBook? _book;

  late final TextEditingController _textControllerAuthor;
  late final TextEditingController _textControllerTitle;
  late final TextEditingController _textControllerNotes;
  late final TextEditingController _textControllerLink;
  double _currentRating = 0.0;
  Timer? _debounce;
  bool _initialized = false;

  @override
  void initState() {

    _textControllerAuthor = TextEditingController();
    _textControllerTitle = TextEditingController();
    _textControllerNotes = TextEditingController();
    _textControllerLink = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_initialized) {
    _initialized = true;
    _initBook(); // cache it here
  }

}

  void _initBook() {
    final widgetBook = context.getArgument<CloudBook>();
    if (widgetBook != null) {
      _book = widgetBook;
      _textControllerTitle.text = widgetBook.bookTitle;
      _textControllerAuthor.text = widgetBook.bookAuthor;
      _textControllerNotes.text = widgetBook.bookNotes;
      _textControllerLink.text = widgetBook.bookLink;
      _currentRating = widgetBook.bookRating;
      _setupTextControllerListener();
    }
  }


  void _textControllerListener() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final book = _book;
      if (book == null) return;
      context.read<BooksBloc>().add(BooksEventUpdate(
        documentId: book.documentId, 
        bookTitle: _textControllerTitle.text,
        bookAuthor: _textControllerAuthor.text, 
        bookNotes: _textControllerNotes.text,
        bookLink: _textControllerLink.text, 
        bookRating: _currentRating,
        ));
    });
    
  }

  void _setupTextControllerListener() {
    for (final controller in [
      _textControllerAuthor,
      _textControllerTitle,
      _textControllerNotes,
      _textControllerLink,
    ]) {
      controller.removeListener(_textControllerListener);
      controller.addListener(_textControllerListener);
    }
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
  void dispose() {
    _debounce?.cancel();
    _textControllerAuthor.dispose();
    _textControllerTitle.dispose();
    _textControllerNotes.dispose();
    _textControllerLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(context.loc.note),
        actions: [
          IconButton(
            onPressed: () async {
              if (_book == null || _textControllerTitle.text.isEmpty) {
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
                if (!context.mounted) return;
                context.read<BooksBloc>().add(
                  BooksEventDelete(documentId: book.documentId)
                );
                if (context.mounted) Navigator.of(context).pop();
              }
            }
            }, 
            icon: const Icon(Icons.delete)),
        ],

      ),
      body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                      context.loc.author,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextField(
                     controller: _textControllerAuthor,
                     decoration: const InputDecoration(
                       hintText: ' '
                    ),
                      
                    ),
                    const SizedBox(height: 16,),
                    Text(
                      context.loc.title,
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
                    Text(
                      context.loc.link,
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
                    Text(
                      context.loc.how_do_you_like_the_book,
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                    RatingField(
                      initialRating: _currentRating == 0.0 ? 1.0 : _currentRating, 
                      onRatingUpdate: (rating) {
                        setState(() => _currentRating = rating);
                        _textControllerListener();
                      }),
                    const SizedBox(height: 16,),
                    Text(
                      context.loc.notes,
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
              )
           
    );
  }
}