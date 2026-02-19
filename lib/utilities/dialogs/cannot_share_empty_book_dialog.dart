import 'package:book_by_book/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyBookDialog(BuildContext context) {
  return showGenericDialog<void> (
    context: context, 
    title: 'Sharing', 
    content: 'You cannot share an empty book!', 
    optionsBuilder: () => {
      'OK': null,
    },
    );
  
}