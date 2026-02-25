import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:book_by_book/services/auth/bloc/auth_state.dart';
import 'package:book_by_book/utilities/dialogs/error_dialog.dart';
import 'package:book_by_book/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSendEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context, 
              'We could not process your request. Please make sure you’re registered. If you’re not, go back one step and create an account.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgot password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('If you forgot your password, simply enter your email and we will send you a password reset link.'),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Your email address...'
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                }, 
                child: const Text('Send me password reset link'),
                ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    const AuthEventLogOut()
                  );
                }, 
                child: const Text('Back to login page'),
                ),
              

            ]
          ),
          )
      ),
      );
  }
}