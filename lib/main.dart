
import 'package:book_by_book/firebase_options.dart';
import 'package:book_by_book/views/login_view.dart';
import 'package:book_by_book/views/register_view.dart';
import 'package:book_by_book/views/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        
        ),

      body: FutureBuilder(
        future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = (FirebaseAuth.instance.currentUser);
              if (user != null) {
                if (user.emailVerified) {
                  return const Text('Done');
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
              // if (user?.emailVerified ?? false) {
              //   return Text('Done');
              // } else {
              //  return const VerifyEmailView();

              //}
              
          default:
          return const CircularProgressIndicator();      
          }
          
        },
        
      ),
    );
  }
}


