

import 'package:book_by_book/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      body: Column(
          children: [
            const Text("We've sent you an email verification. Please open it to verify your account. If you haven't received a verification emil yet, please the button below"), 
            TextButton(
              onPressed: () async {
                final user = (FirebaseAuth.instance.currentUser);
                await user?.sendEmailVerification();
      
              }, 
              child: const Text('Send email verification')),
            TextButton(
              onPressed: () async {
                
               await FirebaseAuth.instance.signOut();

               if (!context.mounted) return;
               
               Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute, 
                (route) => false);
              }, 
              child: const Text('Restart'))
          ],
        ),
    );
  }
}