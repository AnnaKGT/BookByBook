
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
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
            await showErrorDialog(context, context.loc.register_error_weak_password,);
          } else if (state.exception is EmailInUseAuthException) {
            await showErrorDialog(context, context.loc.register_error_email_already_in_use,);
          } else if (state.exception is InvalidEmaiAuthException) {
            await showErrorDialog(context, context.loc.register_error_invalid_email,);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, context.loc.register_error_generic,);
          } else {
            await showErrorDialog(context, context.loc.register_error_generic,);
          }}},
      child: Scaffold(
        appBar: AppBar(title: Text(context.loc.register,)),
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
                      Text(context.loc.register_view_prompt),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: false,
                        autocorrect: false,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: context.loc.email_text_field_placeholder,
                        ),
                      ),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: context.loc.password_text_field_placeholder,
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
                                    context.loc.login_view_email_and_password_cannot_be_empty,
                                  );
                                  return;
                                }
                                              
                                context.read<AuthBloc>().add(AuthEventRegister(
                                  email,
                                  password,
                                  ));
                              },
                              child: Text(context.loc.register),
                            ),
                            TextButton(
                          onPressed: () {
                           context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                           );
                          },
                          child: Text(context.loc.register_view_already_registered),
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
