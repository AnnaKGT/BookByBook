import 'package:book_by_book/constants/routes.dart';
import 'package:flutter/material.dart';

class EmptyBooksView extends StatelessWidget {
  const EmptyBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: Colors.deepPurple.shade200,
          ),
          const SizedBox(height: 20),
          const Text(
            'No books yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateBookRoute);
            }, 
            child: const Text(
              "Add your first book",
              style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            )),
          ),
        ],
      ),
    );
  }
}