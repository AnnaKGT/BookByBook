
import 'package:book_by_book/constants/routes.dart';
import 'package:book_by_book/services/auth/auth_exceptions.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

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

                  final email = _email.text;
                  final password = _password.text;

                  if (email.isEmpty || password.isEmpty) {
                    await showErrorDialog(context, "Email and password cannot be empty");
                    return;
                  }

                  try {
                  await AuthService.firebase().createUser(
                    email: email, 
                    password: password,
                    );
                  
                  if (!context.mounted) return;
                  AuthService.firebase().sendEmailVerification();

                  Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(
                      context, 
                      'Weak password',
                      );
                  } on EmailInUseAuthException {
                    await showErrorDialog(
                      context, 
                      'Email is already in use',
                      );
                  } on InvalidEmaiAuthException {
                    await showErrorDialog(
                      context, 
                      'Invalid email',
                      );
                  } on GenericAuthException {
                    await showErrorDialog(
                      context, 
                      "Something went wrong. Try again.",
                      );
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


