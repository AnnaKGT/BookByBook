import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/enums/menu_action.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/crud/book_services.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final BooksService _booksService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _booksService = BooksService();
    _booksService.open();
    super.initState();
  }

  @override
  void dispose() {
    _booksService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
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


Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Log out"),
          )
        ]

      );
    }
    ).then((value) => value ?? false);
}
