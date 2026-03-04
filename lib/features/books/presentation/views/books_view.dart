import 'package:book_by_book/core/constants/routes.dart';
import 'package:book_by_book/core/enums/menu_action.dart';
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:book_by_book/features/auth/presentation/bloc/auth_event.dart';
import 'package:book_by_book/features/auth/presentation/bloc/auth_state.dart';
import 'package:book_by_book/features/books/domain/bloc/books_bloc.dart';
import 'package:book_by_book/features/books/domain/bloc/books_event.dart';
import 'package:book_by_book/features/books/domain/bloc/books_state.dart';
import 'package:book_by_book/utilities/dialogs/logout_dialog.dart';
import 'package:book_by_book/features/books/presentation/views/books_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Get userId from AuthBlock
    final authState = context.read<AuthBloc>().state as AuthStateLoggedIn;
    final userId = authState.user.id;

    // Trigger the book stream
    context.read<BooksBloc>().add(BooksEventLoadAll(ownerUserId: userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.books),
        actions: [
          IconButton(
            onPressed: () {
              // Create a new book via Bloc, then navigate on BooksStateCreated
              context.read<BooksBloc>().add(BooksEventCreate(ownerUserId: userId));
            }, 
            icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (!context.mounted) return;
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(context.loc.logout_button),)
              ],
              ),
        ],
        ),
        // Listen for BooksStateCreated to navigate to edit view
        body: BlocListener<BooksBloc, BooksState>(
          listener: (context, state) {
            if (state is BookStateCreated) {
              Navigator.of(context).pushNamed(
                createUpdateBookRoute,
                arguments: state.book,
              );
            }
          },
          child: BlocBuilder<BooksBloc, BooksState>(
            builder: (context, state) {
              if (state is BooksStateLoaded) {
                return BooksListView(
                  books: state.books, 
                  onDeleteBook: (book) {
                    context.read<BooksBloc>().add(
                      BooksEventDelete(documentId: book.documentId)
                    );
                  }, 
                  onTap: (book) {
                    Navigator.of(context).pushNamed(
                      createUpdateBookRoute,
                      arguments: book,
                      );
                  },
                  );
              }
              return const Center(child: CircularProgressIndicator(),);
            }
            ),
          ),
 
    );
  }
}
