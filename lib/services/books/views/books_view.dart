import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/enums/menu_action.dart';
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/auth/bloc/auth_state.dart';
import 'package:book_by_book/services/books/cloud_book.dart';
import 'package:book_by_book/services/books/firebase_cloud_storage.dart';
import 'package:book_by_book/utilities/dialogs/logout_dialog.dart';
import 'package:book_by_book/services/books/views/books_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);

}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final FirebaseCloudStorage _booksService;

  String? get userId {
  final state = context.read<AuthBloc>().state;
  return state is AuthStateLoggedIn ? state.user.id : null;
  }

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
        
        title: StreamBuilder(
          stream: _booksService.allBooks(ownerUserId: userId!).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final bookCount = snapshot.data ?? 0;
              if (bookCount == 0) {}
              return Text(context.loc.books);
            } else {
              return Text(context.loc.books);
            }
            
          }
        ),
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
              return [
                PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text(context.loc.logout_button)
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


                stream: _booksService.allBooks(ownerUserId: userId!), 
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                     if (snapshot.hasData) {
                      final allBooks = snapshot.data as Iterable<CloudBook>;
                      // final allBooks = snapshot.data!.toList()
                      //     ..sort((a, b) => b.bookDate.compareTo(a.bookDate));

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
                      final size = MediaQuery.of(context).size;
                      // final renderBox = context.findRenderObject() as RenderBox;
                      // final size = renderBox.size;
                      return Container(
                        constraints: BoxConstraints(
                        maxWidth: size.width * 0.8,
                        maxHeight: size.height * 0.8,
                        minWidth: size.width * 0.5,
                      ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const CircularProgressIndicator(),
                        ));

                    default:
                     return const CircularProgressIndicator();
                  }
                },
              )

    );
  }
}

