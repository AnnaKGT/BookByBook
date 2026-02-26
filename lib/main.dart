
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/auth/bloc/auth_state.dart';
import 'package:book_by_book/services/auth/firebase_auth_provider.dart';
import 'package:book_by_book/views/books/create_update_book_view.dart';
import 'package:book_by_book/views/forgot_password_view.dart';
import 'package:book_by_book/views/login_view.dart';
import 'package:book_by_book/views/books/books_view.dart';
import 'package:book_by_book/views/register_view.dart';
import 'package:book_by_book/views/verify_email.dart';
import 'package:book_by_book/helpers/loading/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'BookByBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createUpdateBookRoute: (context) => const CreateUpdateBookView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context, 
            text: state.loadingText ?? 'Please wait a momemt',
            );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const MainPage();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator()
        );
      }
    },
    );
  }
}
