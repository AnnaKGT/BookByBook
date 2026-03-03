
import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog<void>(
    context: context, 
    title: context.loc.generic_error_prompt, 
    content: text, 
    optionsBuilder: () => {
      context.loc.ok: null,
    },
    );
}