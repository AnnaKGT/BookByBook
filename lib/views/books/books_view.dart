import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/enums/menu_action.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/cloud/cloud_book.dart';
import 'package:book_by_book/services/cloud/firebase_cloud_storage.dart';
import 'package:book_by_book/utilities/dialogs/logout_dialog.dart';
import 'package:book_by_book/views/books/books_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final FirebaseCloudStorage _booksService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _booksService = FirebaseCloudStorage();
    //_booksService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Books'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateBookRoute);
            }, 
            icon: const Icon(Icons.add),
            ),
          PopupMenuButton<MenuAction> (
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {   
                    if (!context.mounted) return;                
                    context.read<AuthBloc>().add(const AuthEventLogOut(),);
                  }
                  break;
                
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log out')
                ),
              ];             
            }
            ),
        ],
      ),
      body: StreamBuilder(
        // stream: _booksService.allBooks(ownerUserId: userId),
        // builder: (context, snapshot) {
        //   if (snapshot.connectionState == ConnectionState.waiting) {
        //     return const Center(child: CircularProgressIndicator());
        //   }
        //   if (!snapshot.hasData || snapshot.data == null) {
        //     return const Center(child: CircularProgressIndicator());
        //   }
        //   final allBooks = snapshot.data as Iterable<CloudBook>;
        //   return BooksListView(
        //     books: allBooks,
        //     onDeleteBook: (book) async {
        //       await _booksService.deleteBook(documentId: book.documentId);
        //     },
        //     onTap: (book) {
        //       Navigator.of(context).pushNamed(
        //         createUpdateBookRoute,
        //         arguments: book,
        //       );
        //     },
        //   );
        // },


                stream: _booksService.allBooks(ownerUserId: userId), 
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                     if (snapshot.hasData) {
                      final allBooks = snapshot.data as Iterable<CloudBook>;
                      return BooksListView(
                        books: allBooks, 
                        onDeleteBook: (book) async {
                          await _booksService.deleteBook(documentId: book.documentId);
                        },
                        onTap: (book) {
                          Navigator.of(context).pushNamed(
                            createUpdateBookRoute,
                            arguments: book,
                            );
                        },
                        );
                     } else {
                      return const Text('active else');
                     }
                    
                    case ConnectionState.waiting:
                      return const Text('Waiting');

                    default:
                     return const CircularProgressIndicator();
                  }
                },
              )

    );
  }
}

