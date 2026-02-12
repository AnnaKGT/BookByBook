
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/firebase_options.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/views/login_view.dart';
import 'package:book_by_book/views/mainpage_view.dart';
import 'package:book_by_book/views/register_view.dart';
import 'package:book_by_book/views/verify_email.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(       
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        mainPageRoute: (context) => const MainPage(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const MainPage();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }

              
          default:
          return const CircularProgressIndicator();      
          }         
        },        
      );   
  }
}

