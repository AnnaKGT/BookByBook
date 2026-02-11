
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/firebase_options.dart';
import 'package:book_by_book/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
        ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {

            case ConnectionState.done:
              return Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here'
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password'
                ),
              ),
              TextButton(
                onPressed: () async {

                  final email = _email.text;
                  final password = _password.text;
                  
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, 
                      password: password,
                      );
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      mainPageRoute, 
                      (route) => false);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      await showErrorDialog(context, "User not found");
                      
                    } else if (e.code == 'wrong-password') {
                      await showErrorDialog(context, "Wrong password");
                      
                    }
                      else if (e.code == 'invalid-credential') {
                      await showErrorDialog(context, "Invalid credential");
                       
                    } else {
                      await showErrorDialog(context, "Error:  ${e.code}");
                    }
                   
                  } catch (e) {
                    await showErrorDialog(context, "Error:  ${e.toString()}");
                  }
                  
          
                }, 
                child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false);
                  }, 
                  child: const Text("Not registered yet? Sign up here!"))
            ],
          );
          default:
          return const Text('Loading ...');      
          }
          
        },
        
      ),
    );
  }
  
}

