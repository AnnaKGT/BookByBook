
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/services/auth/auth_exceptions.dart';
import 'package:book_by_book/services/auth/auth_service.dart';
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/auth/bloc/auth_state.dart';
import 'package:book_by_book/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
  if (state is AuthStateLoggedOut) {

      if (state.exception is UserNotFoundAuthException || state.exception is WrongPasswordAuthException) {
        await showErrorDialog(context, context.loc.login_error_cannot_find_user, );
      } else if (state.exception is InvalidCredentialsAuthException) {
        await showErrorDialog(context, context.loc.login_error_wrong_credentials,);
      } else if(state.exception is GenericAuthException){
        await showErrorDialog(context, context.loc.login_error_auth_error,);
      }
    }
  },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.login),),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(context.loc.login_view_prompt),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofocus: true,
                          decoration:  InputDecoration(
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
                        TextButton(
                          onPressed: () async {
                            final email = _email.text.trim();
                            final password = _password.text.trim();
                        
                            if (email.isEmpty || password.isEmpty) {
                              await showErrorDialog(
                                context,
                                context.loc.login_view_email_and_password_cannot_be_empty,
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                              AuthEventLogIn(email: email, password: password),
                            );
                          },
                          child: Text(context.loc.login),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const AuthEventForgotPassword());
                          },
                          child: Text(context.loc.login_view_forgot_password),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const AuthEventShouldRegister());
                          },
                          child: Text(context.loc.login_view_not_registered_yet,),
                        ),
                        
                      ],
                    ),
                  ),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
