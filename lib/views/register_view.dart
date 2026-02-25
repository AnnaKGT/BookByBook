
import 'package:book_by_book/services/auth/auth_exceptions.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/auth/bloc/auth_state.dart';
import 'package:book_by_book/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, "Weak password");
          } else if (state.exception is EmailInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use',);
          } else if (state.exception is InvalidEmaiAuthException) {
            await showErrorDialog(context, "Invalid email",);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Something went wrong. Try again.",);
          } else {
            await showErrorDialog(context, "Something went wrong. Try again.",);
          }}},
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enter your email and password to see your books!'),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email here',
                        ),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'Enter your password',
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () async {
                                final email = _email.text;
                                final password = _password.text;
                                if (email.isEmpty || password.isEmpty) {
                                  await showErrorDialog(
                                    context,
                                    "Email and password cannot be empty",
                                  );
                                  return;
                                }
                                              
                                context.read<AuthBloc>().add(AuthEventRegister(
                                  email,
                                  password,
                                  ));
                              },
                              child: const Text('Register'),
                            ),
                            TextButton(
                          onPressed: () {
                           context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                           );
                          },
                          child: const Text("Already registred? Login here!"),
                        ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                );
              default:
                return const Text('Loading ...');
            }
          },
        ),
      ),
    );
  }
}
