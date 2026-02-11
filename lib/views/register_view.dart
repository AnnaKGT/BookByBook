
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/firebase_options.dart';
import 'package:book_by_book/show_error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
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

                  if (email.isEmpty || password.isEmpty) {
                    await showErrorDialog(context, "Email and password cannot be empty");
                    return;
                  }

                  try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email, 
                    password: password,
                    );
                  
                  if (!context.mounted) return;
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();

                  Navigator.of(context).pushNamed(verifyEmailRoute);

                  } on FirebaseAuthException catch (e) {
                    if (!context.mounted) return;

                    if (e.code == 'weak-password') {
                      await showErrorDialog(context, 'Weak password');
                    } else if (e.code == 'email-already-in-use') {
                      await showErrorDialog(context, 'Email is already in use');
                    } else if (e.code == 'invalid-email') {
                      await showErrorDialog(context, 'Invalid email');
                    } else {
                      devtools.log('Error: ${e.code} - ${e.message}');
                    }               
                  } catch (e, stack) {
                      devtools.log('Unexpected error', error: e, stackTrace: stack);
                      if (!context.mounted) return;
                      await showErrorDialog(context, "Something went wrong. Try again.");
                    }          
                }, 
                child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false);
                  }, 
                  child: const Text("Already registred? Login here!"))
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


