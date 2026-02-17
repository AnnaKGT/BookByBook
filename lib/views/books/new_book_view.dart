import 'package:flutter/material.dart';

class NewBookView extends StatefulWidget {
  const NewBookView({super.key});

  @override
  State<NewBookView> createState() => _NewBookViewState();
}



class _NewBookViewState extends State<NewBookView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Book'),

      ),
      body: const Text('Add a new book here')
    );
  }
}