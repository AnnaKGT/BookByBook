import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/enums/menu_action.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/crud/book_services.dart';
import 'package:book_by_book/utilities/dialogs/logout_dialog.dart';
import 'package:book_by_book/views/books/books_list_view.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final BooksService _booksService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _booksService = BooksService();
    //_booksService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Books'),
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
                    await AuthService.firebase().logOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute, 
                      (_) => false,
                      );
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
      body: FutureBuilder(
        future: _booksService.getOrCreateUser(email: userEmail), 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {

            case ConnectionState.done:
              return StreamBuilder(
                stream: _booksService.allBooks, 
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                     if (snapshot.hasData) {
                      final allBooks =snapshot.data as List<DatabaseBook>;
                      return BooksListView(
                        books: allBooks, 
                        onDeleteBook: (book) async {
                          await _booksService.deleteBook(id: book.id);
                        },
                        onTap: (book) {
                          Navigator.of(context).pushNamed(
                            createUpdateBookRoute,
                            arguments: book,
                            );
                        },
                        );
                     } else {
                      return const Text('Waiting for all books');
                     }
                    
                    case ConnectionState.waiting:
                      return const Text('Waiting for all books');
                    default:
                     return const CircularProgressIndicator();
                  }
                },
              );
              default:
               return const CircularProgressIndicator();
          }
        },
        ),

    );
  }
}

