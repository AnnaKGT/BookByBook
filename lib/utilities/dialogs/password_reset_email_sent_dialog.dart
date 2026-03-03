import 'package:book_by_book/extensions/list/buildcontext/loc.dart';
import 'package:book_by_book/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context, 
    title: context.loc.password_reset, 
    content: context.loc.password_reset_dialog_prompt, 
    optionsBuilder: () => {
      context.loc.ok : null,
    },
    );
}