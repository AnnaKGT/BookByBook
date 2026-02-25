
import 'package:book_by_book/services/auth/bloc/auth_bloc.dart';
import 'package:book_by_book/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              const Text("We've sent you an email verification. Please open it to verify your account. If you haven't received a verification emil yet, please click the button below"), 
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
                }, 
                child: const Text('Send email verification')),
              TextButton(
                onPressed: () async {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }, 
                child: const Text('Restart'))
            ],
          ),
      ),
    );
  }
}