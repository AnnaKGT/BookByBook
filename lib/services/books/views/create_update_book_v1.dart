// import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
// import 'package:book_by_book/services/auth/auth_service.dart';
// import 'package:book_by_book/services/books/cloud_book.dart';
// import 'package:book_by_book/services/books/firebase_cloud_storage.dart';
// import 'package:book_by_book/utilities/dialogs/cannot_share_empty_book_dialog.dart';
// import 'package:book_by_book/utilities/dialogs/delete_dialog.dart';
// import 'package:book_by_book/utilities/generics/get_argumants.dart';
// import 'package:book_by_book/utilities/open_link_in_new.dart';
// import 'package:book_by_book/utilities/rating_input_field.dart';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// typedef BookCallback = void Function(CloudBook book);

// class CreateUpdateBookView extends StatefulWidget {
//   const CreateUpdateBookView({super.key});

//   @override
//   State<CreateUpdateBookView> createState() => _CreateUpdateBookViewState();
// }



// class _CreateUpdateBookViewState extends State<CreateUpdateBookView> {

//   CloudBook? _book;
//   late final FirebaseCloudStorage _booksService;
//   late final TextEditingController _textControllerAuthor;
//   late final TextEditingController _textControllerTitle;
//   late final TextEditingController _textControllerNotes;
//   late final TextEditingController _textControllerLink;
//   DateTime? _selectedDate;
//   double _currentRating = 0.0;
//   bool _listenersAttached = false;

//   late Future<CloudBook> _bookFuture;

//   @override
//   void initState() {
//     // final date = DateTime.now();
//     _booksService = FirebaseCloudStorage();
//     _textControllerAuthor = TextEditingController();
//     _textControllerTitle = TextEditingController();
//     _textControllerNotes = TextEditingController();
//     _textControllerLink = TextEditingController();
//     // _selectedDate = DateTime(date.year, date.month, date.day);
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//   super.didChangeDependencies();
//   _bookFuture = createOrGetExistingBook(context); // cache it here
// }

//   void _textControllerListener() async {
//     final book = _book;
//     final date = _selectedDate;
//     if (book == null || date == null) {
//       return;
//     }

//     await _booksService.updateBook(
//       documentId: book.documentId, 
//       bookTitle: _textControllerTitle.text,
//       bookAuthor: _textControllerAuthor.text, 
//       bookNotes: _textControllerNotes.text,
//       bookLink: _textControllerLink.text, 
//       bookRating: _currentRating,
//       bookDate: date,
//       );
//   }

//   void _setupTextControllerListener() {
//     if (_listenersAttached) return;
//     _listenersAttached = true;

//     _textControllerAuthor.removeListener(_textControllerListener);
//     _textControllerAuthor.addListener(_textControllerListener);
//     _textControllerTitle.removeListener(_textControllerListener);
//     _textControllerTitle.addListener(_textControllerListener);
//     _textControllerNotes.removeListener(_textControllerListener);
//     _textControllerNotes.addListener(_textControllerListener);
//     _textControllerLink.removeListener(_textControllerListener);
//     _textControllerLink.addListener(_textControllerListener);
//   }


//   Future<CloudBook> createOrGetExistingBook(BuildContext context) async {

//     final widgetBook = context.getArgument<CloudBook>();

//     if (widgetBook != null) {
//       final d = widgetBook.bookDate;
//       _book = widgetBook;
//       _textControllerTitle.text = widgetBook.bookTitle;
//       _textControllerAuthor.text = widgetBook.bookAuthor;
//       _textControllerNotes.text = widgetBook.bookNotes;
//       _textControllerLink.text = widgetBook.bookLink;
//       _currentRating = widgetBook.bookRating;
//       _selectedDate = DateTime(d.year, d.month, d.day);
//       return widgetBook;
//     }

//     final existingBook = _book;
//     if (existingBook != null) {
//       return existingBook;
//     }

//     final now = DateTime.now();
//     _selectedDate = DateTime(now.year, now.month, now.day);

//     final currentUser = AuthService.firebase().currentUser!;
//     final userId = currentUser.id;
//     final newBook = await _booksService.createNewBook(ownerUserId: userId);
//     _book = newBook;
//     return newBook;
//   }

//   void _deleteBookIfTitleIsEmpty() {
//     final book = _book;
//     if (_textControllerTitle.text.isEmpty && book != null) {
//       _booksService.deleteBook(documentId: book.documentId);
//     }
//   }

//   void _saveBookIfTitleIsNotEmpty() async {
//     final book = _book;
//     final date = _selectedDate;
//     if (book == null || date == null) return;
//     if (_textControllerTitle.text.isEmpty) {
//       _booksService.deleteBook(documentId: book.documentId);
//     }

//     final textTitle = _textControllerTitle.text;
//     final textAuthor = _textControllerAuthor.text;
//     final textNotes = _textControllerNotes.text;
//     final textLink = _textControllerLink.text;
//     if (textTitle.isNotEmpty) {
//       await _booksService.updateBook(
//         documentId: book.documentId, 
//         bookTitle: textTitle,
//         bookAuthor: textAuthor, 
//         bookNotes: textNotes,
//         bookLink: textLink, 
//         bookRating: _currentRating,
//         bookDate: date,
//         );
//     }
//   }

//   // ── Date helpers ──────────────────────────────────────────────────────────
 
//   String _formatDate(DateTime? date) {
//     if (date == null) return '';
//     return '${date.day.toString().padLeft(2, '0')}.'
//         '${date.month.toString().padLeft(2, '0')}.'
//         '${date.year}';
//   }
 
//   Future<void> _pickDate() async {
//     // FIX: fall back to today only if _selectedDate is somehow still null
//     final current = _selectedDate ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: current,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = DateTime(picked.year, picked.month, picked.day);
//       });
//       // Immediately persist the updated date
//       _saveBookIfTitleIsNotEmpty();
//     }
//   }

// String _buildShareText() {
//   final title = _textControllerTitle.text;
//   final author = _textControllerAuthor.text;
//   final link = _textControllerLink.text;

//   final buffer = StringBuffer();
//   buffer.writeln('📖 $title');
//   if (author.isNotEmpty) buffer.writeln('✍️ $author');
//   if (link.isNotEmpty) buffer.writeln('🔗 $link');

//   return buffer.toString().trim();
// }


 
//   @override
//   void dispose() {
//     _deleteBookIfTitleIsEmpty();
//     _saveBookIfTitleIsNotEmpty();
//     _textControllerAuthor.dispose();
//     _textControllerTitle.dispose();
//     _textControllerNotes.dispose();
//     _textControllerLink.dispose();
//     super.dispose();
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: Text(context.loc.note),
//         actions: [
//           IconButton(
//             onPressed: () async {

//               final text = _textControllerTitle.text;

//               if (_book == null || text.isEmpty) {
//                 await showCannotShareEmptyBookDialog(context);
//               } else {
//                await SharePlus.instance.share(ShareParams(text: _buildShareText()));
//               }
//             },
//             icon: const Icon(Icons.share),
//             ),
//           IconButton(
//             onPressed: () async {
//               final shouldDelete = await showDeleteDialog(context);
//               if (shouldDelete) {
//                final book = _book;
//                if (book != null) {
//                 await _booksService.deleteBook(documentId: book.documentId);
//                 if (context.mounted) Navigator.of(context).pop();
//               }
//             }
//             }, 
//             icon: const Icon(Icons.delete)),
//         ],

//       ),
//       body: FutureBuilder(
//         future: _bookFuture, 
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
            
//             case ConnectionState.done:
//               _setupTextControllerListener();
//               return SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
                    
//                     Text(
//                       context.loc.author,
//                       style: TextStyle(fontSize: 14, color: Colors.grey)),
//                     TextField(
//                      controller: _textControllerAuthor,
//                      decoration: const InputDecoration(
//                        hintText: ' '
//                     ),
                      
//                     ),
//                     const SizedBox(height: 16,),
//                     Text(
//                       context.loc.title,
//                       style: TextStyle(fontSize: 14, color: Colors.grey)),
//                     TextField(
//                       controller: _textControllerTitle,
//                       keyboardType: TextInputType.multiline,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         hintText: ' '
//                       )
//                     ),
//                     const SizedBox(height: 16,),
//                     ListTile(
//                       // contentPadding: EdgeInsets.zero,
//                       leading: const Icon(Icons.calendar_today),
//                       title: Text(
//                         // 'Date added: ${_formatDate(_selectedDate)}',
//                         _formatDate(_selectedDate),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       // trailing: const Icon(Icons.edit, size: 18),
//                       onTap: _pickDate,
//                     ),
//                     const SizedBox(height: 16,),
//                     Text(
//                       context.loc.link,
//                       style: TextStyle(fontSize: 14, color: Colors.grey,)),
//                     ValueListenableBuilder(
//                       valueListenable: _textControllerLink, 
//                       builder: (context, value, _) {
//                         return TextField(
//                       controller: _textControllerLink,
//                       keyboardType: TextInputType.url,
//                       textAlignVertical: TextAlignVertical.center,
//                       decoration: InputDecoration(
//                         hintText: ' ',
//                         suffixIcon: value.text.isNotEmpty ? IconButton(
//                           onPressed: () => launchLink(_textControllerLink.text), 
//                           icon: const Icon(Icons.open_in_new, size: 16))
//                           : null,
//                         )
//                       );
//                       })
//                     ,
                   
//                     const SizedBox(height: 24,),
//                     Text(
//                       context.loc.how_do_you_like_the_book,
//                       style: TextStyle(fontSize: 14, color: Colors.grey)
//                     ),
//                     RatingField(
//                       initialRating: _currentRating == 0.0 ? 1.0 : _currentRating, 
//                       onRatingUpdate: (rating) async {
//                         setState(() => _currentRating = rating);
//                         final book = _book;
//                         final date = _selectedDate;
//                         if (book != null) {
//                           await _booksService.updateBook(
//                             documentId: book.documentId, 
//                             bookTitle: _textControllerTitle.text, 
//                             bookAuthor: _textControllerAuthor.text, 
//                             bookNotes: _textControllerNotes.text,
//                             bookLink: _textControllerLink.text, 
//                             bookRating: rating,
//                             bookDate: date,
//                             );
//                         }
//                       }),
//                     const SizedBox(height: 16,),
//                     Text(
//                       context.loc.notes,
//                       style: TextStyle(fontSize: 14, color: Colors.grey)),
//                     TextField(
//                       controller: _textControllerNotes,
//                       keyboardType: TextInputType.multiline,
//                       maxLines: null,
//                       decoration: const InputDecoration(
//                         hintText: ' ',
//                       )
//                     ),
//                   ],
//                 ),
//               );
             
//             default:
//              return Center(child: const CircularProgressIndicator());
//           }
//         },
//         ),
//     );
//   }
// }

