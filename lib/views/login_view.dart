
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/services/auth/auth_exceptions.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
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
        future: AuthService.firebase().initialize(),
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

                  final email = _email.text.trim();
                  final password = _password.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    await showErrorDialog(context, "Email and password cannot be empty");
                    return;
                  }
                                
                  try {
                    await AuthService.firebase().logIn(
                      email: email, 
                      password: password,
                      );
                    
                    if (!context.mounted) return;

                    final user = AuthService.firebase().currentUser;

                    if (user?.isEmailVerified ?? false) {
                      // user's email is verified
                      Navigator.of(context).pushNamedAndRemoveUntil(
                      mainPageRoute, 
                      (route) => false);

                    } else {
                      // user's email isn't verified
                      Navigator.of(context).pushNamed(
                      verifyEmailRoute);
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, "User not found");
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, "Wrong password");
                  } on InvalidCredentialsAuthException {
                    await showErrorDialog(context, "Invalid credentials");
                  } on GenericAuthException {
                     await showErrorDialog(context, "Something went wrong. Try again.");
                  }
                          
                  }, child: const Text('Log in'),
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


Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showDialog(
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text('An error occurred'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            }, 
            child: const Text('OK')
            )
        ],
      );

    });
}

